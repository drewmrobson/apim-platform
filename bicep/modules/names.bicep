metadata name = 'Naming Conventions Module'
metadata description = 'This module is used to create a naming convention for resources in Azure.'
metadata owner = 'DrewRobsonConsulting'

targetScope = 'subscription'

@description('Prefixes to set (in order) for the resource name.')
param prefixes array

@description('Suffixes to set (in order) for the resource name.')
param suffixes array

@description('Optional. Separator to use for the resource name, e.g. \'-\' or \'_\'.')
param separator string = '-'

@description('Deployment location.')
param location string

@description('Optional. Geo-location codes for resources.')
param geoLocationCodes object = {
  australiacentral: 'acl'
  australiacentral2: 'acl2'
  australiaeast: 'ae'
  australiasoutheast: 'ase'
  brazilsouth: 'brs'
  centraluseuap: 'ccy'
  canadacentral: 'cnc'
  canadaeast: 'cne'
  centralus: 'cus'
  eastasia: 'ea'
  eastus2euap: 'ecy'
  eastus: 'eus'
  eastus2: 'eus2'
  francecentral: 'frc'
  francesouth: 'frs'
  germanynorth: 'gn'
  germanywestcentral: 'gwc'
  centralindia: 'inc'
  southindia: 'ins'
  westindia: 'inw'
  japaneast: 'jpe'
  japanwest: 'jpw'
  koreacentral: 'krc'
  koreasouth: 'krs'
  newzealandnorth: 'nzn'
  northcentralus: 'ncus'
  northeurope: 'ne'
  norwayeast: 'nwe'
  norwaywest: 'nww'
  southafricanorth: 'san'
  southafricawest: 'saw'
  southcentralus: 'scus'
  swedencentral: 'sdc'
  swedensouth: 'sds'
  southeastasia: 'sea'
  switzerlandnorth: 'szn'
  switzerlandwest: 'szw'
  uaecentral: 'uac'
  uaenorth: 'uan'
  uksouth: 'uks'
  ukwest: 'ukw'
  westcentralus: 'wcus'
  westeurope: 'we'
  westus: 'wus'
  westus2: 'wus2'
  usdodcentral: 'udc'
  usdodeast: 'ude'
  usgovarizona: 'uga'
  usgoviowa: 'ugi'
  usgovtexas: 'ugt'
  usgovvirginia: 'ugv'
  chinanorth: 'bjb'
  chinanorth2: 'bjb2'
  chinaeast: 'sha'
  chinaeast2: 'sha2'
  germanycentral: 'gec'
  germanynortheast: 'gne'
}

@export()
type nameType = {
  name: string
  slug: string
}

@description('Optional. The geo-location identifier used for all resources.')
@minLength(2)
@maxLength(4)
param locationIdentifier string = contains(geoLocationCodes, location)
  ? '${geoLocationCodes[toLower(location)]}'
  : location

var prefix = join(prefixes, separator)
var suffix = join(suffixes, separator)
var baseName = toLower(replace(
  '${prefix}${!empty(suffix) ? separator : ''}${suffix}',
  '**location**',
  locationIdentifier
))

@export()
type namingOutput = {
  @description('Azure container registry (ACR) name.')
  acr: nameType
  @description('Azure Container Instance (ACI) name.')
  aci: nameType
  @description('Alert name.')
  alert: nameType
  @description('API Center name.')
  apiCenter: nameType
  @description('Azure API Management name.')
  apim: nameType
  @description('Action group name.')
  actionGroup: nameType
  @description('App Configuration name.')
  appConfig: nameType
  @description('Application Gateway name.')
  appGateway: nameType
  @description('Application Gateway WAF policy name.')
  appGatewayPolicy: nameType
  @description('Application Insights name.')
  appInsights: nameType
  @description('App Service plan name.')
  appServicePlan: nameType
  @description('Azure Kubernetes Service (AKS) name.')
  aks: nameType
  @description('Automation account name.')
  automationAccount: nameType
  @description('Availability set name.')
  availabilitySet: nameType
  @description('Azure Communication Service name.')
  azureCommunicationService: nameType
  @description('Azure Bastion name.')
  bastion: nameType
  @description('Budget name.')
  budget: nameType
  @description('Azure Cosmos DB name.')
  cosmosDb: nameType
  @description('DDoS protection plan name.')
  ddosProtectionPlan: nameType
  @description('DNS resolver name.')
  dnsResolver: nameType
  @description('Email Service name.')
  emailService: nameType
  @description('Event Grid Namespace name.')
  eventGridNamespace: nameType
  @description('Event Grid Topic name.')
  eventGridTopic: nameType
  @description('Event Hub Namespace name.')
  eventHubNamespace: nameType
  @description('Event Hub Namespace Event Hub name.')
  eventHubNamespaceEventHub: nameType
  @description('ExpressRoute circuit name.')
  expressRouteCircuit: nameType
  @description('External load balancer name.')
  externalLoadBalancer: nameType
  @description('Firewall name.')
  firewall: nameType
  @description('Firewall policy name.')
  firewallPolicy: nameType
  @description('Azure Front Door name.')
  frontDoor: nameType
  @description('Internal load balancer name.')
  internalLoadBalancer: nameType
  @description('Key Vault name.')
  keyVault: nameType
  @description('Local network gateway name.')
  localNetworkGateway: nameType
  @description('Dev centre name.')
  devCentre: nameType
  @description('Dev centre project name.')
  devCentreProject: nameType
  @description('Managed devops pool name.')
  managedDevOpsPool: nameType
  @description('Log Analytics name.')
  logAnalytics: nameType
  @description('Logic App name.')
  logicApp: nameType
  @description('Machine Learning workspace name.')
  mlWorkspace: nameType
  @description('Managed identity name.')
  managedIdentity: nameType
  @description('Network interface name.')
  networkInterface: nameType
  @description('Network security group name.')
  nsg: nameType
  @description('Network security group flow log name.')
  nsgFlowLog: nameType
  @description('Network watcher name.')
  networkWatcher: nameType
  @description('Public IP address name.')
  publicIp: nameType
  @description('Recovery Services vault name.')
  recoveryServicesVault: nameType
  @description('Resource group name.')
  resourceGroup: nameType
  @description('Route table name.')
  routeTable: nameType
  @description('Private end point name.')
  privateEndpoint: nameType
  @description('Private link name.')
  privateLink: nameType
  @description('SQL database name.')
  sqlDb: nameType
  @description('SQL server name.')
  sqlServer: nameType
  @description('Data bricks workspace name.')
  dataBricks: nameType
  @description('Data lake store name.')
  dataLakeStore: nameType
  @description('Service Bus Namespace name.')
  serviceBusNamespace: nameType
  @description('Service Bus Queue name.')
  serviceBusQueue: nameType
  @description('Static Web App name.')
  staticWebApp: nameType
  @description('Storage account name.')
  storageAccount: nameType
  @description('Traffic Manager name.')
  trafficManager: nameType
  @description('Virtual machine name.')
  virtualMachine: nameType
  @description('Virtual machine scale set name.')
  virtualMachineScaleSet: nameType
  @description('Virtual network name.')
  vnet: nameType
  @description('Virtual network gateway name.')
  vnetGateway: nameType
  @description('Virtual WAN name.')
  vwan: nameType
  @description('Virtual WAN hub name.')
  vwanHub: nameType
  @description('Web App name.')
  webApp: nameType
}

var typeMap = {
  acr: {
    slug: 'cr'
    allowSeparator: false
    maxLength: 24
  }
  aci: {
    slug: 'ci'
    allowSeparator: true
  }
  alert: {
    slug: 'alert'
    allowSeparator: true
  }
  apim: {
    slug: 'apim'
    allowSeparator: true
  }
  apiCenter: {
    slug: 'apic'
    allowSeparator: true
  }
  appConfig: {
    slug: 'appcs'
    allowSeparator: true
  }
  actionGroup: {
    slug: 'ag'
    allowSeparator: true
  }
  appGateway: {
    slug: 'agw'
    allowSeparator: true
  }
  appGatewayPolicy: {
    slug: 'waf'
    allowSeparator: true
  }
  appInsights: {
    slug: 'appi'
    allowSeparator: true
  }
  appServicePlan: {
    slug: 'asp'
    allowSeparator: true
  }
  aks: {
    slug: 'aks'
    allowSeparator: true
  }
  automationAccount: {
    slug: 'aa'
    allowSeparator: true
  }
  availabilitySet: {
    slug: 'avail'
    allowSeparator: true
  }
  azureCommunicationService: {
    slug: 'acs'
    allowSeparator: true
  }
  bastion: {
    slug: 'bas'
    allowSeparator: true
  }
  budget: {
    slug: 'bgt'
    allowSeparator: true
  }
  cosmosDb: {
    slug: 'cosmos'
    allowSeparator: true
  }
  ddosProtectionPlan: {
    slug: 'ddos'
    allowSeparator: true
  }
  dnsResolver: {
    slug: 'dnspr'
    allowSeparator: true
  }
  emailService: {
    slug: 'es'
    allowSeparator: true
  }
  eventHubNamespace: {
    slug: 'evhns'
    allowSeparator: true
  }
  eventGridNamespace: {
    slug: 'egns'
    allowSeparator: true
  }
  eventGridTopic: {
    slug: 'egt'
    allowSeparator: true
  }
  eventHubNamespaceEventHub: {
    slug: 'evh'
    allowSeparator: true
  }
  expressRouteCircuit: {
    slug: 'erc'
    allowSeparator: true
  }
  externalLoadBalancer: {
    slug: 'lbe'
    allowSeparator: true
  }
  firewall: {
    slug: 'afw'
    allowSeparator: true
  }
  firewallPolicy: {
    slug: 'afwp'
    allowSeparator: true
  }
  frontDoor: {
    slug: 'afd'
    allowSeparator: true
  }
  internalLoadBalancer: {
    slug: 'lbi'
    allowSeparator: true
  }
  keyVault: {
    slug: 'kv'
    allowSeparator: true
  }
  localNetworkGateway: {
    slug: 'lgw'
    allowSeparator: true
  }
  dataBricks: {
    slug: 'dbw'
    allowSeparator: true
  }
  dataLakeStore: {
    slug: 'dls'
    allowSeparator: false
    maxLength: 24
  }
  devCentre: {
    slug: 'dc'
    allowSeparator: true
  }
  devCentreProject: {
    slug: 'dcp'
    allowSeparator: true
  }
  managedDevOpsPool: {
    slug: 'mdp'
    allowSeparator: true
  }
  logAnalytics: {
    slug: 'log'
    allowSeparator: true
  }
  logicApp: {
    slug: 'logic'
    allowSeparator: true
  }
  mlWorkspace: {
    slug: 'mlw'
    allowSeparator: true
  }
  managedIdentity: {
    slug: 'id'
    allowSeparator: true
  }
  networkInterface: {
    slug: 'nic'
    allowSeparator: true
  }
  nsg: {
    slug: 'nsg'
    allowSeparator: true
  }
  nsgFlowLog: {
    slug: 'flow'
    allowSeparator: true
  }
  networkWatcher: {
    slug: 'nw'
    allowSeparator: true
  }
  publicIp: {
    slug: 'pip'
    allowSeparator: true
  }
  recoveryServicesVault: {
    slug: 'rsv'
    allowSeparator: true
  }
  resourceGroup: {
    slug: 'rg'
    allowSeparator: true
  }
  routeTable: {
    slug: 'rt'
    allowSeparator: true
  }
  privateEndpoint: {
    slug: 'pep'
    allowSeparator: true
  }
  privateLink: {
    slug: 'pl'
    allowSeparator: true
  }
  serviceBusNamespace: {
    slug: 'sbns'
    allowSeparator: true
  }
  serviceBusQueue: {
    slug: 'sbq'
    allowSeparator: true
  }
  sqlDb: {
    slug: 'sqldb'
    allowSeparator: true
  }
  sqlServer: {
    slug: 'sql'
    allowSeparator: true
  }
  staticWebApp: {
    slug: 'stapp'
    allowSeparator: true
  }
  storageAccount: {
    slug: 'st'
    allowSeparator: false
    maxLength: 24
  }
  trafficManager: {
    slug: 'traf'
    allowSeparator: true
  }
  virtualMachine: {
    slug: 'vm'
    allowSeparator: false
  }
  virtualMachineScaleSet: {
    slug: 'vmss'
    allowSeparator: true
  }
  vnet: {
    slug: 'vnet'
    allowSeparator: true
  }
  vnetGateway: {
    slug: 'vgw'
    allowSeparator: true
  }
  vwan: {
    slug: 'vwan'
    allowSeparator: true
  }
  vwanHub: {
    slug: 'vhub'
    allowSeparator: true
  }
  webApp: {
    slug: 'app'
    allowSeparator: true
  }
}

@description('Resource names.')
var namesOutput = reduce(
  map(items(typeMap), type => {
    '${type.key}': type.value.allowSeparator
      ? {
          name: '${type.value.slug}${separator}${baseName}'
          slug: type.value.slug
        }
      : {
          name: replace('${type.value.slug}${baseName}', separator, '')
          slug: type.value.slug
        }
  }),
  {},
  (cur, next) => union(cur, next)
)

@description('Resource names.')
output names namingOutput = namesOutput
