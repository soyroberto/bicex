using './main.bicep'

param vmName = 'vmausbixvm01'  //changed, Roberto
param adminUsername = 'roberto'
param vmSize = 'Standard_B2s_v2'
param location = 'australiasoutheast'
param subnetName = 'misc'
param keyVaultSecretName = 'vmAdminPassword'
