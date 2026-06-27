//---------- parameters ----------

//
// GENERAL
//
@description('The name of the resource. This parameter is overridden in the pipeline YAML.')
param name string

@description('The geo-location where the resource lives.')
param location string

import { lockType } from 'br/public:avm/utl/types/avm-common-types:0.5.1'
@description('Specify the type of resource lock.')
param resourceLock lockType?

@description('Resource tags to apply to the resource.')
@metadata({
  doc: 'https://docs.microsoft.com/en-us/azure/azure-resource-manager/management/tag-resources?tabs=bicep#arm-templates'
  example: {
    tagKey: 'string'
  }
})
param tags object = {}

@description('Environment being deployed to.')
param environment string

import { roleAssignmentType } from 'br/public:avm/utl/types/avm-common-types:0.5.1'
@description('Role assignments to apply to the resource. The roleDefinitionIdOrName can be a built-in role name or a custom role definition ID.')
param roleAssignments roleAssignmentType[] = []

//
// RESOURCE-SPECIFIC
//

@allowed([
  'Basic'
  'BasicV2'
  'Consumption'
  'Developer'
  'Premium'
  'Standard'
  'StandardV2'
  // 'PremiumV2' TODO: Doesn't look like AVM supports PremiumV2 yet
])
@description('The pricing tier of this API Management service.')
param skuName string

@description('The capacity of the API Management service. This is required for the Standard, Premium, and Consumption tiers. For the Consumption tier, this value must be 0. For the Basic and Developer tiers, this value must be 1.')
param skuCapacity int

@description('The name of the public IP resource. This parameter is overridden in the pipeline YAML.')
param publicIpName string

@description('The central key vault to be used by API Management.')
param keyVaultName string

@description('Optional. Enable Custom Domain for API Management Gateway.')
param enableGatewayCustomDomain bool = false

@description('Optional. Enable Custom Domain for Developer Portal.')
param enablePortalCustomDomain bool = false

@description('Optional. Enable Custom Domain for Management Endpoint. Required when using custom domains for Developer Portal.')
param enableManagementCustomDomain bool = false

@description('Optional. The name of the secret which contains the API Gateway Proxy custom domain certificate.')
param apiGatewayProxyCertificateSecretName string = 'api-${environment}-proxy-certificate'

@description('Optional. The name of the secret which contains the API Gateway Management endpoint custom domain certificate.')
param apiGatewayManagementCertificateSecretName string = 'api-${environment}-mgmt-certificate'

@description('Optional. The name of the secret which contains the API Gateway Portal custom domain certificate.')
param apiGatewayPortalCertificateSecretName string = 'api-${environment}-portal-certificate'

@description('Optional. The domain which API Gateway Custom Domains will be configured against.')
param apiGatewayHostDomain string = 'domain.com.au'

@description('The email address of the owner of the API Management Service')
param publisherEmailAddress string

@description('The name of the owner of the API Management Service')
param publisherName string

@description('Optional. Auto scale alert emails.')
param autoScaleAlertEmailAddresses array = []

@description('Optional. Auto scale profiles.')
param autoScaleProfiles array = []

@description('Required if using an App Configuration Store. The name of the App Configuration Store to be used by API Management.')
param appConfigurationStoreName string = ''

//
// DIAGNOSTICS
//
import { diagnosticSettingFullType } from 'br/public:avm/utl/types/avm-common-types:0.5.1'
@description('Optional. The diagnostic settings of the service.')
param diagnosticSettings diagnosticSettingFullType[]?

//
// NETWORKING
//
@description('The type of virtual network in which API Management service needs to be configured in. None (Default Value) means the API Management service is not part of any Virtual Network, External means the API Management deployment is set up inside a Virtual Network having an internet-facing endpoint, and Internal means that API Management deployment is setup inside a Virtual Network having an intranet-facing endpoint only.')
@allowed([
  'None'
  'External'
  'Internal'
])
param virtualNetworkType string

@description('Optional. The Virtual Network Subnet resource ID to link with API Management. Required when virtualNetworkType is either External or Internal.')
param virtualNetworkSubnetResourceId string = ''

import { privateEndpointMultiServiceType } from 'br/public:avm/utl/types/avm-common-types:0.5.1'
@description('Optional. Configuration details for private endpoints. For security reasons, it is recommended to use private endpoints whenever possible.')
param privateEndpoints privateEndpointMultiServiceType[]?

@description('The availability zones to be used for the public IP address. Required when virtualNetworkType is External and the region supports availability zones.')
param availabilityZones array

@description('The instrumentation key for Application Insights.')
param applicationInsightsInstrumentionKey string

//---------- variables ----------

var deploymentSuffix = uniqueString(deployment().name, location)

var environmentHostingDomain = '${environment}.${apiGatewayHostDomain}'
var apiHostname = 'api-${environmentHostingDomain}'
var portalHostname = 'portal-api-${environmentHostingDomain}'
var managementHostname = 'mgmt-api-${environmentHostingDomain}'

var hostnameProxyConfigurations = (enableGatewayCustomDomain)
  ? [
      {
        type: 'Proxy'
        hostName: apiHostname
        keyVaultId: apiGatewayProxyCertificateSecret!.properties.secretUri
        negotiateClientCertificate: false
      }
    ]
  : []

var hostNamePortalConfigurations = (enablePortalCustomDomain)
  ? [
      {
        type: 'DeveloperPortal'
        hostName: portalHostname
        keyVaultId: portalCertificateSecret!.properties.secretUri
        negotiateClientCertificate: false
      }
    ]
  : []

var hostNameMgmtConfigurations = (enableManagementCustomDomain)
  ? [
      {
        type: 'Management'
        hostName: managementHostname
        keyVaultId: managementCertificateSecret!.properties.secretUri
        negotiateClientCertificate: false
      }
    ]
  : []

var builtInRoleNames = {
  'API Management Developer Portal Content Editor': subscriptionResourceId(
    'Microsoft.Authorization/roleDefinitions',
    'c031e6a8-4391-4de0-8d69-4706a7ed3729'
  )
  'API Management Service Contributor': subscriptionResourceId(
    'Microsoft.Authorization/roleDefinitions',
    '312a565d-c81f-4fd8-895a-4e21e48d571c'
  )
  'API Management Service Operator Role': subscriptionResourceId(
    'Microsoft.Authorization/roleDefinitions',
    'e022efe7-f5ba-4159-bbe4-b44f577e9b61'
  )
  'API Management Service Reader Role': subscriptionResourceId(
    'Microsoft.Authorization/roleDefinitions',
    '71522526-b88f-4d52-b57f-d31fc3546d0d'
  )
}

var formattedRoleAssignments = [
  for (roleAssignment, index) in (roleAssignments ?? []): union(roleAssignment, {
    roleDefinitionId: builtInRoleNames[?roleAssignment.roleDefinitionIdOrName] ?? (contains(
        roleAssignment.roleDefinitionIdOrName,
        '/providers/Microsoft.Authorization/roleDefinitions/'
      )
      ? roleAssignment.roleDefinitionIdOrName
      : subscriptionResourceId('Microsoft.Authorization/roleDefinitions', roleAssignment.roleDefinitionIdOrName))
  })
]

var hostnameConfigurations = union(
  hostnameProxyConfigurations,
  hostNamePortalConfigurations,
  hostNameMgmtConfigurations
)

//---------- resource lookups ----------

resource keyVault 'Microsoft.KeyVault/vaults@2021-10-01' existing = {
  name: keyVaultName
}

// Certificates for API Management custom domains

resource apiGatewayProxyCertificateSecret 'Microsoft.KeyVault/vaults/secrets@2023-02-01' existing = if (enableGatewayCustomDomain) {
  parent: keyVault
  name: apiGatewayProxyCertificateSecretName
}

resource managementCertificateSecret 'Microsoft.KeyVault/vaults/secrets@2023-02-01' existing = if (enableManagementCustomDomain) {
  parent: keyVault
  name: apiGatewayManagementCertificateSecretName
}

resource portalCertificateSecret 'Microsoft.KeyVault/vaults/secrets@2023-02-01' existing = if (enablePortalCustomDomain) {
  parent: keyVault
  name: apiGatewayPortalCertificateSecretName
}

resource appConfiguration 'Microsoft.AppConfiguration/configurationStores@2024-05-01' existing = if (appConfigurationStoreName != '') {
  name: appConfigurationStoreName
  scope: resourceGroup()
}

//---------- deployments ----------

module publicIpAddress 'br/public:avm/res/network/public-ip-address:0.12.0' = if (virtualNetworkType != 'None') {
  name: 'public-ip-${deploymentSuffix}'
  params: {
    name: publicIpName
    location: location
    publicIPAddressVersion: 'IPv4'
    publicIPAllocationMethod: 'Static'
    skuName: 'Standard' // Can't use StandardV2 in australiaeast?
    skuTier: 'Regional'
    availabilityZones: availabilityZones
    dnsSettings: {
      domainNameLabel: publicIpName
      domainNameLabelScope: 'TenantReuse'
    }
    diagnosticSettings: diagnosticSettings
    lock: resourceLock
    tags: tags
  }
}

module apiManagementService 'br/public:avm/res/api-management/service:0.14.1' = {
  name: 'apim-service-${deploymentSuffix}'
  params: {
    name: name
    location: location
    publisherEmail: publisherEmailAddress
    publisherName: publisherName
    availabilityZones: availabilityZones
    sku: skuName
    skuCapacity: skuCapacity
    minApiVersion: '2019-12-01'
    virtualNetworkType: virtualNetworkType
    subnetResourceId: virtualNetworkSubnetResourceId
    publicIpAddressResourceId: virtualNetworkType == 'None' ? null : publicIpAddress.outputs.resourceId
    managedIdentities: {
      systemAssigned: true
    }
    hostnameConfigurations: hostnameConfigurations
    loggers: [
      {
        type: 'applicationInsights'
        name: 'app-insights-logger'
        credentials: {
          instrumentationKey: applicationInsightsInstrumentionKey
        }
        isBuffered: true
      }
    ]
    apis: [] // Configure separately if needed — logger sampling/correlation was per-API in AVM
    // OWASP disable insecure ciphers
    customProperties: {
      'Microsoft.WindowsAzure.ApiManagement.Gateway.Security.Ciphers.TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA': 'false'
      'Microsoft.WindowsAzure.ApiManagement.Gateway.Security.Ciphers.TLS_ECDHE_RSA_WITH_AES_128_CBC_SHA': 'false'
      'Microsoft.WindowsAzure.ApiManagement.Gateway.Security.Ciphers.TLS_RSA_WITH_AES_128_GCM_SHA256': 'false'
      'Microsoft.WindowsAzure.ApiManagement.Gateway.Security.Ciphers.TLS_RSA_WITH_AES_256_CBC_SHA256': 'false'
      'Microsoft.WindowsAzure.ApiManagement.Gateway.Security.Ciphers.TLS_RSA_WITH_AES_128_CBC_SHA256': 'false'
      'Microsoft.WindowsAzure.ApiManagement.Gateway.Security.Ciphers.TLS_RSA_WITH_AES_256_CBC_SHA': 'false'
      'Microsoft.WindowsAzure.ApiManagement.Gateway.Security.Ciphers.TLS_RSA_WITH_AES_128_CBC_SHA': 'false'
      'Microsoft.WindowsAzure.ApiManagement.Gateway.Security.Ciphers.TripleDes168': 'false'
      'Microsoft.WindowsAzure.ApiManagement.Gateway.Security.Protocols.Tls10': 'false'
      'Microsoft.WindowsAzure.ApiManagement.Gateway.Security.Protocols.Tls11': 'false'
      'Microsoft.WindowsAzure.ApiManagement.Gateway.Security.Protocols.Ssl30': 'false'
      'Microsoft.WindowsAzure.ApiManagement.Gateway.Security.Backend.Protocols.Tls10': 'false'
      'Microsoft.WindowsAzure.ApiManagement.Gateway.Security.Backend.Protocols.Tls11': 'false'
      'Microsoft.WindowsAzure.ApiManagement.Gateway.Security.Backend.Protocols.Ssl30': 'false'
      'Microsoft.WindowsAzure.ApiManagement.Gateway.Protocols.Server.Http2': 'false'
    }
    diagnosticSettings: diagnosticSettings
    lock: resourceLock
    tags: tags
  }
}

// AVM Autoscale Settings module is still only in the proposal stage
module autoScaleSettings 'br/ArincoModules:insights/autoscale:1.0.1' = if (skuName == 'Standard' || skuName == 'Premium') {
  name: 'auto-scale-settings-${deploymentSuffix}'
  params: {
    location: location
    targetResourceId: apiManagementService.outputs.resourceId
    customEmails: autoScaleAlertEmailAddresses
    profiles: autoScaleProfiles
  }
}

//---------- role assignments ----------

resource createdResource 'Microsoft.ApiManagement/service@2024-06-01-preview' existing = {
  name: name
  dependsOn: [
    apiManagementService
  ]
}

resource apimToKvRoleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(createdResource.id, name, '4633458b-17de-408a-b874-0445c86b69e6')
  scope: keyVault
  properties: {
    principalId: apiManagementService.outputs.?systemAssignedMIPrincipalId!
    principalType: 'ServicePrincipal'
    roleDefinitionId: subscriptionResourceId(
      'Microsoft.Authorization/roleDefinitions',
      '4633458b-17de-408a-b874-0445c86b69e6'
    )
  }
}

resource apimToAppConfigurationRoleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = if (appConfigurationStoreName != '') {
  name: guid(createdResource.id, name, '516239f1-63e1-4d78-a4de-a74fb236a071')
  scope: appConfiguration
  properties: {
    principalId: apiManagementService.outputs.?systemAssignedMIPrincipalId!
    principalType: 'ServicePrincipal'
    roleDefinitionId: subscriptionResourceId(
      'Microsoft.Authorization/roleDefinitions',
      '516239f1-63e1-4d78-a4de-a74fb236a071'
    )
  }
}

resource apiManagement_roleAssignments 'Microsoft.Authorization/roleAssignments@2022-04-01' = [
  for (roleAssignment, index) in (formattedRoleAssignments ?? []): {
    name: guid(createdResource.id, roleAssignment.principalId, roleAssignment.roleDefinitionId)
    scope: createdResource
    properties: {
      principalId: roleAssignment.principalId
      principalType: roleAssignment.principalType
      roleDefinitionId: roleAssignment.roleDefinitionId
    }
  }
]

module apiManagement_privateEndpoints 'br/public:avm/res/network/private-endpoint:0.12.0' = [
  for (privateEndpoint, index) in (privateEndpoints ?? []): {
    name: '${uniqueString(deployment().name, location)}-sa-PrivateEndpoint-${index}'
    scope: resourceGroup(
      split(privateEndpoint.?resourceGroupResourceId ?? resourceGroup().id, '/')[2],
      split(privateEndpoint.?resourceGroupResourceId ?? resourceGroup().id, '/')[4]
    )
    params: {
      name: privateEndpoint.?name ?? 'pep-${last(split(createdResource.id, '/'))}-${privateEndpoint.service}-${index}'
      privateLinkServiceConnections: privateEndpoint.?isManualConnection != true
        ? [
            {
              name: privateEndpoint.?privateLinkServiceConnectionName ?? '${last(split(createdResource.id, '/'))}-${privateEndpoint.service}-${index}'
              properties: {
                privateLinkServiceId: createdResource.id
                groupIds: [
                  privateEndpoint.service
                ]
              }
            }
          ]
        : null
      manualPrivateLinkServiceConnections: privateEndpoint.?isManualConnection == true
        ? [
            {
              name: privateEndpoint.?privateLinkServiceConnectionName ?? '${last(split(createdResource.id, '/'))}-${privateEndpoint.service}-${index}'
              properties: {
                privateLinkServiceId: createdResource.id
                groupIds: [
                  privateEndpoint.service
                ]
                requestMessage: privateEndpoint.?manualConnectionRequestMessage ?? 'Manual approval required.'
              }
            }
          ]
        : null
      subnetResourceId: privateEndpoint.subnetResourceId
      location: privateEndpoint.?location ?? reference(
        split(privateEndpoint.subnetResourceId, '/subnets/')[0],
        '2020-06-01',
        'Full'
      ).location
      privateDnsZoneGroup: privateEndpoint.?privateDnsZoneGroup
      roleAssignments: privateEndpoint.?roleAssignments
      tags: privateEndpoint.?tags ?? tags
      customDnsConfigs: privateEndpoint.?customDnsConfigs
      ipConfigurations: privateEndpoint.?ipConfigurations
      applicationSecurityGroupResourceIds: privateEndpoint.?applicationSecurityGroupResourceIds
      customNetworkInterfaceName: privateEndpoint.?customNetworkInterfaceName
    }
  }
]

@description('The resource ID of the API Management service.')
output resourceId string = apiManagementService.outputs.resourceId

@description('The principal ID of the system assigned identity.')
output systemAssignedMIPrincipalId string? = apiManagementService.outputs.?systemAssignedMIPrincipalId
