targetScope = 'subscription'

import * as Types from './types.bicep'

@description('The environment in which the resources are deployed.')
param environment string

@description('The location where the resources are deployed.')
param location string

@description('The company prefix for naming conventions.')
param companyPrefix string

@description('The functional unit for naming conventions.')
param functionalUnit string

@description('Resource tags to apply to the resource.')
@metadata({
  doc: 'https://docs.microsoft.com/en-us/azure/azure-resource-manager/management/tag-resources?tabs=bicep#arm-templates'
  example: {
    tagKey: 'string'
  }
})
param tags object = {}

import { lockType } from 'br/public:avm/utl/types/avm-common-types:0.5.1'
@description('Specify the type of resource lock to apply to all resources.')
param resourceLock lockType?

@description('Whether to enable diagnostics on the resources. If true, diagnostic settings will be applied to all resources that support it, using the provided diagnostic parameters.')
param enableDiagnostics bool = true

@description('Parameters for configuring diagnostics on the resources.')
param diagnosticParams Types.DiagnosticsParams?

@description('Parameters for configuring the API Management service.')
param apimServiceParams Types.ApimServiceParams

// Resolve names
module names 'modules/names.bicep' = {
  scope: subscription()
  name: 'names-${uniqueString(deployment().name, environment, location)}'
  params: {
    location: location
    prefixes: [
      companyPrefix
      '**location**'
      environment
    ]
    suffixes: [
      functionalUnit
    ]
  }
}

// Create resource group if it doesn't exist
module resourceGroup 'modules/rg.bicep' = {
  name: 'resourceGroup-${deployment().name}'
  params: {
    resourceGroupName: names.outputs.names.resourceGroup.name
    location: location
    tags: tags
  }
}



var diagnosticSettings = enableDiagnostics
  ? [
      {
        metricCategories: diagnosticParams.?diagnosticMetricsToEnable
        logCategoriesAndGroups: diagnosticParams.?diagnosticLogCategoryGroupsToEnable
        storageAccountResourceId: !empty(diagnosticParams.?diagnosticStorageAccount)
          ? resourceId(
              diagnosticParams.?diagnosticStorageAccount.?subscriptionId ?? az.subscription().subscriptionId,
              diagnosticParams.?diagnosticStorageAccount.resourceGroupName!,
              'Microsoft.Storage/storageAccounts',
              diagnosticParams.?diagnosticStorageAccount.name!
            )
          : null

        eventHubName: !empty(diagnosticParams.?diagnosticEventHub)
          ? diagnosticParams.?diagnosticEventHub.eventHubName
          : null

        eventHubAuthorizationRuleResourceId: !empty(diagnosticParams.?diagnosticEventHub)
          ? resourceId(
              diagnosticParams.?diagnosticEventHub.eventHubNamespace.?subscriptionId ?? az.subscription().subscriptionId,
              diagnosticParams.?diagnosticEventHub.eventHubNamespace.resourceGroupName!,
              'Microsoft.EventHub/namespaces/authorizationRules',
              diagnosticParams.?diagnosticEventHub.eventHubNamespace.name!,
              diagnosticParams.?diagnosticEventHub.authorizationRuleName!
            )
          : null

        workspaceResourceId: resourceId(
          diagnosticParams.?diagnosticLogAnalyticsWorkspace.?subscriptionId ?? az.subscription().subscriptionId,
          diagnosticParams.?diagnosticLogAnalyticsWorkspace.?resourceGroupName ?? names.outputs.names.resourceGroup.name,
          'Microsoft.OperationalInsights/workspaces',
          diagnosticParams.?diagnosticLogAnalyticsWorkspace.?name ?? names.outputs.names.logAnalytics.name
        )
      }
    ]
  : []


// Resolve VNET delegation for API Management service if virtual network parameters are provided
#disable-next-line no-unused-vars
var apimVirtualNetworkSubnetResourceId = !empty(apimServiceParams.?virtualNetworkSubnet.subnetName!)
      ? resourceId(
          az.subscription().subscriptionId,
          apimServiceParams.?virtualNetworkSubnet.resourceGroupName!,
          'Microsoft.Network/virtualNetworks/subnets',
          apimServiceParams.?virtualNetworkSubnet.virtualNetworkName!,
          apimServiceParams.?virtualNetworkSubnet.subnetName!
        )
      : ''

// PE
module workload 'modules/workload.bicep' = {
  name: 'workload-${deployment().name}'
  params: {
    location: location
    resourceGroupName: names.outputs.names.resourceGroup.name
    privateEndpointName: names.outputs.names.privateEndpoint.name
    privateLinkServiceId: apimService.outputs.resourceId
    subnetResourceId: apimServiceParams.privateEndpointSubnetResourceId
    tags: tags
  }
}
