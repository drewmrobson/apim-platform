// Construct subnet resource

targetScope = 'subscription'
param location string
param resourceGroupName string
param privateEndpointName string
param privateLinkServiceId string
param subnetResourceId string

param applicationInsightsName string

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

// Existing Application Insights
resource appInsights 'Microsoft.Insights/components@2020-02-02' existing = {
  scope: resourceGroup(resourceGroupName)
  name: applicationInsightsName
}

param appConfigurationStoreName string

// Existing App Configuration store
resource appConfig 'Microsoft.AppConfiguration/configurationStores@2024-05-01' existing = {
  scope: resourceGroup(resourceGroupName)
  name: appConfigurationStoreName
}

// API Management
module apimService 'modules/apim.bicep' = {
  scope: existingResourceGroup
  name: 'apimService-${deployment().name}'
  params: {
    name: names.outputs.names.apim.name
    location: location
    applicationInsightsInstrumentionKey: appInsights.outputs.instrumentationKey
    availabilityZones: apimServiceParams.availabilityZones
    roleAssignments: apimServiceParams.?roleAssignments ?? []
    skuName: apimServiceParams.?skuName ?? 'Developer'
    skuCapacity: apimServiceParams.?skuCapacity ?? 1
    environment: environment
    keyVaultName: names.outputs.names.keyVault.name
    publicIpName: names.outputs.names.publicIp.name
    publisherEmailAddress: apimServiceParams.?publisherEmailAddress ?? 'publisher@arinco.com.au'
    publisherName: apimServiceParams.?publisherName ?? 'Default Publisher'
    virtualNetworkType: apimServiceParams.?virtualNetworkType ?? 'None'
    virtualNetworkSubnetResourceId: apimServiceParams.virtualNetworkSubnet
    appConfigurationStoreName: apimServiceParams.appConfigurationStoreName
    privateEndpoints: [
      for (pe, index) in (apimServiceParams.?privateEndpoints ?? []): {
        name: '${names.outputs.names.apim.name}-${toLower(pe.?service ?? 'gateway')}-pep${index+1}'
        service: pe.?service ?? 'Gateway'
        subnetResourceId: resourceId(
          az.subscription().subscriptionId,
          pe.virtualNetworkResourceGroupName,
          'Microsoft.Network/virtualNetworks/subnets',
          pe.virtualNetworkName,
          pe.?virtualNetworkSubnetName ?? 'PrivateEndpoints'
        )
        privateDnsZoneGroup: {
          privateDnsZoneGroupConfigs: [
            {
              privateDnsZoneResourceId: resourceId(
                pe.privateDNSZoneSubscriptionId,
                pe.privateDNSZoneResourceGroupName,
                'Microsoft.Network/privateDnsZones',
                'privatelink.azure-api.net'
              )
            }
          ]
        }
      }
    ]
    diagnosticSettings: diagnosticSettings
    resourceLock: resourceLock
    tags: tags
  }
}

// Private endpoint for inbound requests to API Management
module apimPrivateEndpoint 'br/public:avm/res/network/private-endpoint:0.9.0' = {
  scope: az.resourceGroup(resourceGroupName)
  name: '${uniqueString(deployment().name, location)}-apimPrivateEndpoint'
  params: {
    name: '${privateEndpointName}-apim'
    location: location
    tags: tags
    subnetResourceId: subnetResourceId
    privateLinkServiceConnections: [
      {
        name: '${privateEndpointName}-connection'
        properties: {
          privateLinkServiceId: privateLinkServiceId
          groupIds: ['Gateway']
        }
      }
    ]
  }
}
