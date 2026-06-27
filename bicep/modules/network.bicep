targetScope = 'resourceGroup'

// ============================================================================
// Parameters
// ============================================================================

@description('Azure region for all resources.')
param location string

@description('Address prefix for the Virtual Network (must be /24).')
param vnetAddressPrefix string = '20.0.0.0/24'

@description('Address prefix for private endpoints subnet (must be /26).')
param peSubnetPrefix string = '20.0.0.0/26'

@description('Address prefix for API Management subnet delegation (must be /26).')
param apimSubnetPrefix string = '20.0.0.64/26'

@description('Address prefix for Function App subnet delegation (must be /26).')
param funcSubnetPrefix string = '20.0.0.128/26'

@description('Address prefix for Logic App subnet delegation (must be /26).')
param lappSubnetPrefix string = '20.0.0.192/26'

@description('Resource tags to apply to the resource.')
@metadata({
  doc: 'https://docs.microsoft.com/en-us/azure/azure-resource-manager/management/tag-resources?tabs=bicep#arm-templates'
  example: {
    tagKey: 'string'
  }
})
param tags object = {}

// ============================================================================
// Variables
// ============================================================================

@description('Object containing generated resource names based on the baseName and environment parameters.')
param names object

var vnetName = names.vnet.name
var subnet1Name = '${vnetName}-snet-pe'
var subnet2Name = '${vnetName}-snet-apim'
var subnet3Name = '${vnetName}-snet-func'
var subnet4Name = '${vnetName}-snet-lapp'
var nsg1Name = '${vnetName}-nsg-pe'
var nsg2Name = '${vnetName}-nsg-apim'
var nsg3Name = '${vnetName}-nsg-func'
var nsg4Name = '${vnetName}-nsg-lapp'

// ============================================================================
// NSG for Subnet 1 (Private Endpoints)
// ============================================================================

module nsg1 'br/public:avm/res/network/network-security-group:0.5.0' = {
  name: 'deploy-${nsg1Name}'
  params: {
    name: nsg1Name
    location: location
    tags: tags
    securityRules: [
      {
        name: 'AllowHttpsInbound'
        properties: {
          priority: 100
          direction: 'Inbound'
          access: 'Allow'
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRange: '443'
          sourceAddressPrefix: 'VirtualNetwork'
          destinationAddressPrefix: '*'
        }
      }
      {
        name: 'DenyAllInbound'
        properties: {
          priority: 4096
          direction: 'Inbound'
          access: 'Deny'
          protocol: '*'
          sourcePortRange: '*'
          destinationPortRange: '*'
          sourceAddressPrefix: '*'
          destinationAddressPrefix: '*'
        }
      }
    ]
  }
}

// ============================================================================
// NSG for Subnet 2 (API Management Delegation)
// ============================================================================

module nsg2 'br/public:avm/res/network/network-security-group:0.5.0' = {
  name: 'deploy-${nsg2Name}'
  params: {
    name: nsg2Name
    location: location
    tags: tags
    securityRules: [
      {
        name: 'AllowInternetInbound'
        properties: {
          priority: 100
          direction: 'Inbound'
          access: 'Allow'
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRange: '443'
          sourceAddressPrefix: 'Internet'
          destinationAddressPrefix: 'VirtualNetwork'
        }
      }
      {
        name: 'AllowAPIManagementInbound'
        properties: {
          priority: 110
          direction: 'Inbound'
          access: 'Allow'
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRange: '443'
          sourceAddressPrefix: 'ApiManagement'
          destinationAddressPrefix: 'VirtualNetwork'
        }
      }
      {
        name: 'AllowAzureLoadBalancerInbound'
        properties: {
          priority: 120
          direction: 'Inbound'
          access: 'Allow'
          protocol: '*'
          sourcePortRange: '*'
          destinationPortRange: '6390'
          sourceAddressPrefix: 'AzureLoadBalancer'
          destinationAddressPrefix: 'VirtualNetwork'
        }
      }
      {
        name: 'AllowLogicAppStorageOutbound'
        properties: {
          priority: 100
          direction: 'Outbound'
          access: 'Allow'
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRange: '443'
          sourceAddressPrefix: 'VirtualNetwork'
          destinationAddressPrefix: 'Storage'
        }
      }
      {
        name: 'AllowSQLOutbound'
        properties: {
          priority: 110
          direction: 'Outbound'
          access: 'Allow'
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRange: '1433'
          sourceAddressPrefix: 'VirtualNetwork'
          destinationAddressPrefix: 'SQL'
        }
      }
      {
        name: 'AllowKeyVaultOutbound'
        properties: {
          priority: 120
          direction: 'Outbound'
          access: 'Allow'
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRange: '443'
          sourceAddressPrefix: 'VirtualNetwork'
          destinationAddressPrefix: 'AzureKeyVault'
        }
      }
    ]
  }
}

// ============================================================================
// NSG for Subnet 3 (Function Delegation)
// ============================================================================

module nsg3 'br/public:avm/res/network/network-security-group:0.5.0' = {
  name: 'deploy-${nsg3Name}'
  params: {
    name: nsg3Name
    location: location
    tags: tags
    securityRules: [
      {
        name: 'AllowInternetInbound'
        properties: {
          priority: 100
          direction: 'Inbound'
          access: 'Allow'
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRange: '443'
          sourceAddressPrefix: 'Internet'
          destinationAddressPrefix: 'VirtualNetwork'
        }
      }
      {
        name: 'AllowFunctionAppInbound'
        properties: {
          priority: 110
          direction: 'Inbound'
          access: 'Allow'
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRange: '443'
          sourceAddressPrefix: 'AppService'
          destinationAddressPrefix: 'VirtualNetwork'
        }
      }
      {
        name: 'AllowAzureLoadBalancerInbound'
        properties: {
          priority: 120
          direction: 'Inbound'
          access: 'Allow'
          protocol: '*'
          sourcePortRange: '*'
          destinationPortRange: '6390'
          sourceAddressPrefix: 'AzureLoadBalancer'
          destinationAddressPrefix: 'VirtualNetwork'
        }
      }
      {
        name: 'AllowLogicAppStorageOutbound'
        properties: {
          priority: 100
          direction: 'Outbound'
          access: 'Allow'
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRange: '443'
          sourceAddressPrefix: 'VirtualNetwork'
          destinationAddressPrefix: 'Storage'
        }
      }
      {
        name: 'AllowSQLOutbound'
        properties: {
          priority: 110
          direction: 'Outbound'
          access: 'Allow'
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRange: '1433'
          sourceAddressPrefix: 'VirtualNetwork'
          destinationAddressPrefix: 'SQL'
        }
      }
      {
        name: 'AllowKeyVaultOutbound'
        properties: {
          priority: 120
          direction: 'Outbound'
          access: 'Allow'
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRange: '443'
          sourceAddressPrefix: 'VirtualNetwork'
          destinationAddressPrefix: 'AzureKeyVault'
        }
      }
    ]
  }
}

// ============================================================================
// NSG for Subnet 4 (Logic App Delegation)
// ============================================================================

module nsg4 'br/public:avm/res/network/network-security-group:0.5.0' = {
  name: 'deploy-${nsg4Name}'
  params: {
    name: nsg4Name
    location: location
    tags: tags
    securityRules: [
      {
        name: 'AllowInternetInbound'
        properties: {
          priority: 100
          direction: 'Inbound'
          access: 'Allow'
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRange: '443'
          sourceAddressPrefix: 'Internet'
          destinationAddressPrefix: 'VirtualNetwork'
        }
      }
      {
        name: 'AllowLogicAppInbound'
        properties: {
          priority: 110
          direction: 'Inbound'
          access: 'Allow'
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRange: '443'
          sourceAddressPrefix: 'LogicApps'
          destinationAddressPrefix: 'VirtualNetwork'
        }
      }
      {
        name: 'AllowAzureLoadBalancerInbound'
        properties: {
          priority: 120
          direction: 'Inbound'
          access: 'Allow'
          protocol: '*'
          sourcePortRange: '*'
          destinationPortRange: '6390'
          sourceAddressPrefix: 'AzureLoadBalancer'
          destinationAddressPrefix: 'VirtualNetwork'
        }
      }
      {
        name: 'AllowLogicAppStorageOutbound'
        properties: {
          priority: 100
          direction: 'Outbound'
          access: 'Allow'
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRange: '443'
          sourceAddressPrefix: 'VirtualNetwork'
          destinationAddressPrefix: 'Storage'
        }
      }
      {
        name: 'AllowSQLOutbound'
        properties: {
          priority: 110
          direction: 'Outbound'
          access: 'Allow'
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRange: '1433'
          sourceAddressPrefix: 'VirtualNetwork'
          destinationAddressPrefix: 'SQL'
        }
      }
      {
        name: 'AllowKeyVaultOutbound'
        properties: {
          priority: 120
          direction: 'Outbound'
          access: 'Allow'
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRange: '443'
          sourceAddressPrefix: 'VirtualNetwork'
          destinationAddressPrefix: 'AzureKeyVault'
        }
      }
    ]
  }
}

// ============================================================================
// Virtual Network with Subnets
// ============================================================================

module virtualNetwork 'br/public:avm/res/network/virtual-network:0.5.2' = {
  name: 'deploy-${vnetName}'
  params: {
    name: vnetName
    location: location
    tags: tags
    addressPrefixes: [
      vnetAddressPrefix
    ]
    subnets: [
      {
        name: subnet1Name
        addressPrefix: peSubnetPrefix
        networkSecurityGroupResourceId: nsg1.outputs.resourceId
        privateEndpointNetworkPolicies: 'Disabled'
      }
      {
        name: subnet2Name
        addressPrefix: apimSubnetPrefix
        networkSecurityGroupResourceId: nsg2.outputs.resourceId
        delegation: 'Microsoft.Web/serverFarms'
      }
      {
        name: subnet3Name
        addressPrefix: funcSubnetPrefix
        networkSecurityGroupResourceId: nsg3.outputs.resourceId
        // Flex Consumption plan — delegate to Microsoft.App/environments
        // Other plans (Elastic Premium, Dedicated) — delegate to Microsoft.Web/serverFarms
        delegation: 'Microsoft.App/environments'
      }
      {
        name: subnet4Name
        addressPrefix: lappSubnetPrefix
        networkSecurityGroupResourceId: nsg4.outputs.resourceId
        delegation: 'Microsoft.Web/serverFarms'
      }
    ]
  }
}

// ============================================================================
// Outputs – Resource IDs
// ============================================================================

@description('Resource ID of the Virtual Network.')
output vnetResourceId string = virtualNetwork.outputs.resourceId

@description('Resource ID of the Private Endpoints subnet.')
output peSubnetResourceId string = virtualNetwork.outputs.subnetResourceIds[0]

@description('Resource ID of the API Management subnet.')
output apimSubnetResourceId string = virtualNetwork.outputs.subnetResourceIds[1]

@description('Resource ID of the Function App subnet.')
output funcSubnetResourceId string = virtualNetwork.outputs.subnetResourceIds[2]

@description('Resource ID of the Logic App subnet.')
output lappSubnetResourceId string = virtualNetwork.outputs.subnetResourceIds[3]

@description('Resource ID of the Private Endpoints NSG.')
output peNsgResourceId string = nsg1.outputs.resourceId

@description('Resource ID of the API Management NSG.')
output apimNsgResourceId string = nsg2.outputs.resourceId

@description('Resource ID of the Function App NSG.')
output funcNsgResourceId string = nsg3.outputs.resourceId

@description('Resource ID of the Logic App NSG.')
output lappNsgResourceId string = nsg4.outputs.resourceId
