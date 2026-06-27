import { roleAssignmentType } from 'br/public:avm/utl/types/avm-common-types:0.5.1'

@export()
type ApimServiceParams = {
  @description('The SKU name for the API Management service.')
  skuName: 'Basic' | 'BasicV2' | 'Consumption' | 'Developer' | 'Premium' | 'Standard' | 'StandardV2' | 'PremiumV2'

  @description('The email address of the owner of the API Management Service')
  publisherEmailAddress: string

  @description('The name of the owner of the API Management Service')
  publisherName: string

  @description('The type of virtual network in which API Management service needs to be configured in. None (Default Value) means the API Management service is not part of any Virtual Network, External means the API Management deployment is set up inside a Virtual Network having an internet-facing endpoint, and Internal means that API Management deployment is setup inside a Virtual Network having an intranet-facing endpoint only.')
  virtualNetworkType: 'None' | 'External' | 'Internal'

  @description('Optional. The Virtual Network Subnet resource ID to link with API Management. Required when virtualNetworkType is either External or Internal.')
  virtualNetworkSubnet: virtualNetworkSubnet?

  @description('Optional. Array of role assignments to create.')
  roleAssignments: roleAssignmentType[]

  @description('Optional. Array of private endpoints to create.')
  privateEndpoints: privateEndpointType[]

  @description('The availability zones to be used for the public IP address. Required when virtualNetworkType is External and the region supports availability zones.')
  availabilityZones: [1] | [1, 2] | [1, 2, 3]
}

type virtualNetworkSubnet = {
  @description('Optional. The virtual network subscription identifier')
  subscriptionId: string?

  @description('Optional. The Virtual network resource group.')
  resourceGroupName: string

  @description('The Virtual network name.')
  virtualNetworkName: string

  @description('The Virtual Network Subnet name.')
  subnetName: string
}

type resourceIdentifier = {
  @description('The resource subscription identifier')
  subscriptionId: string?

  @description('The resource group.')
  resourceGroupName: string

  @description('The name.')
  name: string
}

// @export()
// type ServiceBusNamespaceParams = {
//   @description('The SKU name for the Service Bus namespace.')
//   skuName: 'Basic' | 'Standard' | 'Premium'

//   @description('The capacity of the Service Bus namespace. Only applicable for Premium SKU.')
//   capacity: int?

//   @description('This determines if traffic is allowed over public network.')
//   publicNetworkAccess: 'Enabled' | 'Disabled'

//   @description('Optional. Array of role assignments to create.')
//   roleAssignments: roleAssignmentType[]

//   @description('Optional. Array of private endpoints to create.')
//   privateEndpoints: privateEndpointType[]
// }

// @export()
// type StorageAccountParams = {
//   @description('The SKU for the Storage Account.')
//   skuName:
//     | 'Standard_LRS' // 3 copies in a single datacenter
//     | 'Standard_GRS' // 3 copies across availability zones in one region
//     | 'Standard_RAGRS' // LRS locally + async replication to a secondary region (LRS there)
//     | 'Standard_ZRS' // ZRS locally + async replication to a secondary region (LRS there)
//     | 'Standard_GZRS' // Same as GRS but the secondary is readable
//     | 'Standard_RAGZRS' // Same as RAGRS but the secondary is readable
//     | 'Premium_LRS' // Premium LRS
//     | 'Premium_ZRS' // Premium ZRS

//   @description('This determines if traffic is allowed over public network.')
//   publicNetworkAccess: 'Enabled' | 'Disabled' | 'SecuredByPerimeter'

//   @description('Optional. Whether to allow shared key access. Default is false.')
//   allowSharedKeyAccess: bool?

//   @description('Optional. Array of role assignments to create.')
//   roleAssignments: roleAssignmentType[]

//   @description('Optional. Array of private endpoints to create.')
//   privateEndpoints: privateEndpointType[]
// }

// @export()
// type LogAnalyticsWorkspaceParams = {
//   @description('The SKU for the Log Analytics Workspace.')
//   skuName: 'PerGB2018' | 'PerNode' | 'Free'?

//   @description('Optional. Array of role assignments to create.')
//   roleAssignments: roleAssignmentType[]

//   @description('Optional. Array of private endpoints to create.')
//   privateEndpoints: privateEndpointType[]

//   @description('This determines if traffic is allowed over public network for ingestion.')
//   publicNetworkAccessForIngestion: 'Enabled' | 'Disabled' | 'SecuredByPerimeter'

//   @description('This determines if traffic is allowed over public network for query.')
//   publicNetworkAccessForQuery: 'Enabled' | 'Disabled' | 'SecuredByPerimeter'
// }

// @export()
// type KeyVaultParams = {
//   @description('The SKU for the Key Vault.')
//   skuName: 'standard' | 'premium'

//   @description('Optional. Enable purge protection. Default is true.')
//   enablePurgeProtection: bool?

//   @description('Optional. Enable soft delete. Default is true.')
//   enableSoftDelete: bool?

//   @description('This determines if traffic is allowed over public network.')
//   publicNetworkAccess: 'Enabled' | 'Disabled' // | 'SecuredByPerimeter' AVM doesn't support Network Security Perimeter yet

//   @description('Optional. Array of role assignments to create.')
//   roleAssignments: roleAssignmentType[]

//   @description('Optional. Array of private endpoints to create.')
//   privateEndpoints: privateEndpointType[]
// }

// @export()
// type AppConfigurationStoreParams = {
//   @description('The SKU for the app configuration store.')
//   skuName: 'Free' | 'Standard' | 'Developer' | 'Premium'

//   @description('Enable purge protection.')
//   enablePurgeProtection: bool

//   @description('The public network access for the app configuration store')
//   publicNetworkAccess: 'Enabled' | 'Disabled'

//   @description('Optional. Array of role assignments to create.')
//   roleAssignments: roleAssignmentType[]

//   @description('Optional. Array of private endpoints to create.')
//   privateEndpoints: privateEndpointType[]

//   @description('Optional. The number of days that deleted configurations are retained. Default is 7 days. Minimum is 1 day, maximum is 7 days.')
//   @minValue(1)
//   @maxValue(7)
//   softDeleteRetentionInDays: int?
// }

// @export()
// type ApiCenterParams = {
//   @description('The SKU for the API Center.')
//   skuName: 'Free' | 'Standard'

//   @description('The public network access for the API Center')
//   publicNetworkAccess: 'Enabled' | 'Disabled'

//   @description('Optional. Array of role assignments to create.')
//   roleAssignments: roleAssignmentType[]
// }

// @export()
// type EventHubParams = {
//   @description('The SKU for the Event Hub namespace.')
//   skuName: 'Basic' | 'Standard' | 'Premium'

//   @description('The capacity of the Event Hub namespace. Only applicable for Premium SKU.')
//   capacity: int?

//   @description('This determines if traffic is allowed over public network.')
//   publicNetworkAccess: 'Enabled' | 'Disabled'

//   @description('Optional. Array of role assignments to create.')
//   roleAssignments: roleAssignmentType[]

//   @description('Optional. Array of private endpoints to create.')
//   privateEndpoints: privateEndpointType[]
// }

// @export()
// type AppConfigurationReplicaProperties = {
//   @description('The name of the replica.')
//   name: string

//   @description('The location of the replica.')
//   location: string
// }

@export()
type privateEndpointType = {
  @description('The name of the virtual network where private endpoints will be created.')
  virtualNetworkName: string

  @description('The resource group name containing the virtual network.')
  virtualNetworkResourceGroupName: string

  @description('The name of the subnet where private endpoints will be deployed.')
  virtualNetworkSubnetName: string?

  @description('The subscription ID containing the shared DNS zones.')
  privateDNSZoneSubscriptionId: string

  @description('The resource group name containing the shared DNS zones.')
  privateDNSZoneResourceGroupName: string

  @description('Resource type ID for the private endpoint connection')
  service: string?
}

@export()
type DiagnosticsParams = {
  @description('Optional. The name of log category groups that will be streamed.')
  diagnosticLogCategoryGroupsToEnable: object[]?

  @description('Optional. The name of metrics that will be streamed.')
  diagnosticMetricsToEnable: object[]?

  @description('Optional. Storage account resource id.')
  diagnosticStorageAccount: resourceIdentifier?

  @description('Optional. Log analytics workspace resource id.')
  diagnosticLogAnalyticsWorkspace: object?

  @description('Optional. Event Hub namespace and authorization rule resource id. ')
  diagnosticEventHub: diagnosticEventHubIdentifier?
}

type diagnosticEventHubIdentifier = {
  @description('The name of the authorization rule.')
  authorizationRuleName: string
  @description('The Event Hub name.')
  eventHubName: string?
  @description('The resource ID of the Event Hub namespace.')
  eventHubNamespace: resourceIdentifier
}

// @export()
// type NetworkAcls = {
//   @description('Optional. The IP address ranges in CIDR notation that are allowed to access the resource.')
//   ipRules: IpRule[]

//   @description('Optional. The virtual network rules that are allowed to access the resource.')
//   virtualNetworkRules: VirtualNetworkRule[]

//   @description('Optional. The resource access rules that are allowed to access the resource.')
//   resourceAccessRules: ResourceAccessRule[]

//   @description('Optional. The name of the subnet where private endpoints will be deployed.')
//   defaultAction: 'Allow' | 'Deny'?

//   @description('Optional. Specifies whether traffic is bypassed for Logging,Metrics or Azure services. Possible values are any combination of Logging, Metrics, AzureServices.')
//   bypass: string?
// }

// @export()
// type IpRule = {
//   @description('The action to take on the IP address range.')
//   action: 'Allow' | 'Deny'
//   @description('The IP address range in CIDR notation that is allowed to access the resource.')
//   value: string
// }

// @export()
// type VirtualNetworkRule = {
//   @description('The action to take on the virtual network.')
//   action: 'Allow' | 'Deny'
//   @description('Full resource ID of the virtual network subnet.')
//   id: string
// }

// @export()
// type ResourceAccessRule = {
//   @description('The full resource ID of the resource access rule.')
//   resourceId: string
//   @description('The tenant ID of the resource access rule.')
//   tenantId: string
// }

// @export()
// type ElasticScale = {
//   @description('Indicates whether elastic scale is enabled.')
//   elasticScaleEnabled: bool

//   @description('The target number of workers for the App Service plan when elastic scale is enabled. This property is required when elasticScaleEnabled is true. The value must be between 1 and maximumElasticWorkerCount. If elasticScaleEnabled is false, this property is ignored.')
//   targetWorkerCount: int

//   @description('The maximum number of workers that can be added to the App Service plan when elastic scale is enabled. This property is required when elasticScaleEnabled is true. The value must be between 1 and 20. If elasticScaleEnabled is false, this property is ignored.')
//   @minValue(1)
//   @maxValue(20)
//   maximumElasticWorkerCount: int
// }

// import { profileType } from 'br/public:avm/res/network/network-security-perimeter:0.1.3'

// @export()
// type NetworkSecurityPerimeterParams = {
//   @description('Optional. Array of profiles to create.')
//   profiles: profileType[]

//   @description('Optional. Array of resource associations to create.')
//   resourceAssociations: networkSecurityPerimeterResourceAssociation[]?

//   @description('Resource tags to apply to the resource.')
//   tags: object
// }

// type networkSecurityPerimeterAccessRule = {
//   @description('The name of the access rule.')
//   name: string

//   @description('The direction of the access rule.')
//   direction: 'Inbound' | 'Outbound'

//   @description('Optional. The address prefixes allowed by the access rule.')
//   addressPrefixes: string[]?

//   @description('Optional. The fully qualified domain names allowed by the access rule.')
//   fullyQualifiedDomainNames: string[]?

//   @description('Optional. The subscriptions allowed by the access rule.')
//   subscriptions: string[]?

//   @description('Optional. The email addresses allowed by the access rule.')
//   emailAddresses: string[]?

//   @description('Optional. The phone numbers allowed by the access rule.')
//   phoneNumbers: string[]?
// }

// type networkSecurityPerimeterResourceAssociation = {
//   @description('The access mode for the resource association.')
//   accessMode: 'Enforced' | 'Learning' | 'Audit'

//   @description('The resource ID of the private link resource.')
//   privateLinkResource: string

//   @description('The profile name to associate with.')
//   profile: string
// }

// @export()
// type ActionGroupEmailReceivers = {
//   @description('The name of the email receiver.')
//   name: string

//   @description('The email address of the receiver.')
//   emailAddress: string

//   @description('Indicates whether to use common alert schema.')
//   useCommonAlertSchema: bool

//   @description('Resource tags to apply to the resource.')
//   tags: object
// }

// @export()
// type SftpParams = {
//   containerName: string
//   user: string
//   sshAuthorizedKeysName: string
// }

// @export()
// type NetworkDelegationAppParams = {
//   @description('Optional. Indicates whether to use the default virtual network subnet. If false, virtualNetworkSubnet must be provided.')
//   useDefaultVirtualNetworkSubnet: bool

//   @description('Optional. The Virtual Network Subnet resource ID to link with Logic App Standard. Required when useDefaultVirtualNetworkSubnet is false.')
//   virtualNetworkSubnet: virtualNetworkSubnet?
// }

// @export()
// type ContainerRegistryParams = {
//   @description('The SKU for the Container Registry.')
//   skuName: 'Basic' | 'Standard' | 'Premium'

//   @description('This determines if traffic is allowed over public network.')
//   publicNetworkAccess: 'Enabled' | 'Disabled'

//   @description('Optional. Array of role assignments to create.')
//   roleAssignments: roleAssignmentType[]

//   @description('Optional. Array of private endpoints to create.')
//   privateEndpoints: privateEndpointType[]
// }
