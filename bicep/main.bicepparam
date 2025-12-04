using './main.bicep'

// Non-sensitive values only
param vmName = 'vmauansvm01'
param adminUsername = 'roberto'
param vmSize = 'Standard_B2s_v2'
param location = 'australiaeast'   
param subnetName = 'misc'
param keyVaultSecretName = 'vmAdminPassword'

// These will be provided by pipeline
// param vnetResourceId
// param nsgResourceId  
// param keyVaultName
