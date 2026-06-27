@description('The name of the Application Insights instance.')
param name string

@description('The location where the resources are deployed.')
param location string

@description('Diagnostic settings to apply to the Application Insights resource.')
param logAnalyticsWorkspaceResourceId string

@description('The number of days to retain data in Application Insights. Default is 90 days.')
param appInsightsRetentionInDays int

import { diagnosticSettingFullType } from 'br/public:avm/utl/types/avm-common-types:0.5.1'
@description('Optional. The diagnostic settings of the service.')
param diagnosticSettings diagnosticSettingFullType[]?

import { lockType } from 'br/public:avm/utl/types/avm-common-types:0.5.1'
@description('Specify the type of resource lock to apply to all resources.')
param resourceLock lockType?

@description('Resource tags to apply to the resource.')
@metadata({
  doc: 'https://docs.microsoft.com/en-us/azure/azure-resource-manager/management/tag-resources?tabs=bicep#arm-templates'
  example: {
    tagKey: 'string'
  }
})
param tags object = {}

// Application Insights
module appInsights 'br/public:avm/res/insights/component:0.7.1' = {
  name: '${uniqueString(deployment().name, location)}-appInsights'
  params: {
    name: name
    tags: tags
    location: location
    workspaceResourceId: logAnalyticsWorkspaceResourceId
    kind: 'web'
    applicationType: 'web'
    diagnosticSettings: diagnosticSettings
    lock: resourceLock
    retentionInDays: appInsightsRetentionInDays
    disableLocalAuth: true
  }
}

resource dataCollectionEndpoint 'Microsoft.Insights/dataCollectionEndpoints@2023-03-11' = {
  name: '${name}-dce'
  location: location
  tags: tags
  properties: {
    networkAcls: {
      publicNetworkAccess: 'SecuredByPerimeter'
    }
  }
}

@description('The instrumentation key of the Application Insights instance.')
output instrumentationKey string = appInsights.outputs.instrumentationKey

@description('The connection string of the Application Insights instance.')
output connectionString string = appInsights.outputs.connectionString

@description('The resource ID of the data collection endpoint.')
output dataCollectionEndpointResourceId string = dataCollectionEndpoint.id
