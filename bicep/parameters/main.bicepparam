// Bring in all parameters from the main Bicep file
using '../main.bicep'

param environment = 'demo'
param location = 'australiaeast'
param companyPrefix = 'ar'
param functionalUnit = 'int'
param tags = {
  Environment: environment
  Project: 'demo'
  Owner: 'Arinco'
  CostCenter: 'demo'
  Purpose: 'This is a ${environment} resource group for the integration platform accelerator'
  DeleteAfter: '31-12-2029'
}

param resourceLock = { kind: 'None' }
param enableDiagnostics = true

// DiagnosticsParams
param diagnosticParams = {
  diagnosticLogCategoryGroupsToEnable: [
    {
      categoryGroup: 'AllLogs'
    }
  ]
  diagnosticMetricsToEnable: [
    {
      category: 'AllMetrics'
    }
  ]
}

/*======================================================================
APIM PARAMETERS
======================================================================*/
// ApimServiceParams
param apimServiceParams = {
  skuName: 'BasicV2'
  publisherEmailAddress: 'joe.bloggs@arinco.com.au'
  publisherName: 'Joe Bloggs'
  virtualNetworkType: 'None'
  virtualNetworkSubnet: deployDefaultVirtualNetwork
  appConfigurationStoreName: ''
  roleAssignments: [
    {
      principalId: integrationTeamGroupPrincipalId
      principalType: 'Group'
      roleDefinitionIdOrName: 'API Management Service Contributor'
    }
  ]
  privateEndpoints: []
  privateEndpointSubnetResourceId: ''
}
