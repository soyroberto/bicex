using './main.bicep'

// ============================================================================
// Azure VM Deployment Parameters
// Author: Roberto
// Description: Parameter file for Windows Server 2022 with SQL Server 2019 VM
// ============================================================================

param vmName = 'vmauansvm01'
param adminUsername = 'roberto'
param vmSize = 'Standard_B2s_v2'
param location = 'australiaeast'

// Existing resource references
param vnetResourceId = '/subscriptions/f87077b9-ed2e-497d-876f-02c0a33e3774/resourceGroups/RGAUSNetCh/providers/Microsoft.Network/virtualNetworks/vnetausclient'
param subnetName = 'misc'
param nsgResourceId = '/subscriptions/f87077b9-ed2e-497d-876f-02c0a33e3774/resourceGroups/RGAUSNetCh/providers/Microsoft.Network/networkSecurityGroups/nsgauejit'

// Key Vault references
param keyVaultName = 'kvaueansdeploy'
param keyVaultSecretName = 'vmAdminPassword'

// Tags for resource management
param tags = {
  environment: 'production'
  project: 'AnsibleDeploy'
  managedBy: 'Bicep'
  costCenter: 'IT-Infrastructure'
  owner: 'Roberto'
}
