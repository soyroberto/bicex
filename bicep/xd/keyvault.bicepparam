using './keyvault.bicep'

// ============================================================================
// Azure Key Vault Parameters
// Author: Roberto
// Description: Parameter file for Key Vault creation
// ============================================================================

param keyVaultName = 'kvaueansdeploy'
param location = 'australiaeast'

// NOTE: Replace with your actual principal ID (user or service principal)
// To find your principal ID, run: az ad signed-in-user show --query id -o tsv
param principalId = '<YOUR_PRINCIPAL_ID>'

param adminUsername = 'roberto'

// NOTE: This should be a strong password
// Best practice: Use Azure CLI to generate and pass this securely
// Example: az keyvault secret set --vault-name kvaueansdeploy --name vmAdminPassword --value <password>
param adminPassword = '<SECURE_PASSWORD_HERE>'

param enableSoftDelete = true
param enablePurgeProtection = true

param tags = {
  environment: 'production'
  project: 'AnsibleDeploy'
  managedBy: 'Bicep'
  costCenter: 'IT-Infrastructure'
  owner: 'Roberto'
}
