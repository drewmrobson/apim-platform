targetScope = 'subscription'

@description('The name of the resource group to deploy.')
param resourceGroupName string

@description('The geo-location where the resource group lives.')
param location string

@description('Resource tags to apply to the resource.')
@metadata({
  doc: 'https://docs.microsoft.com/en-us/azure/azure-resource-manager/management/tag-resources?tabs=bicep#arm-templates'
  example: {
    tagKey: 'string'
  }
})
param tags object = {}

resource resourceGroup 'Microsoft.Resources/resourceGroups@2025-04-01' = {
  name: resourceGroupName
  location: location
  tags: tags
}

@description('The resource ID of the resource group.')
output resourceGroupId string = resourceGroup.id
