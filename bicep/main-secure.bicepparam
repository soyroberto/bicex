using './main-secure.bicep'

// ============================================================================
// Azure VM Deployment Parameters - TEMPLATE
// Author: Roberto
// Description: Parameter file for Windows Server 2022 with SQL Server 2019 VM
// 
// SECURITY WARNING: This is a TEMPLATE file. Do NOT commit actual values to Git.
// Copy this file to main.bicepparam and fill in your actual values locally.
// Add main.bicepparam to .gitignore to prevent accidental commits.
// ============================================================================

// VM Configuration - Update with your values
param vmName = '<YOUR_VM_NAME>'  // Example: vmauansvm01
param adminUsername = '<YOUR_ADMIN_USERNAME>'  // Example: roberto
param vmSize = 'Standard_B2s_v2'

// Location - Update with your Azure region
param location = '<YOUR_LOCATION>'  // Example: australiaeast

// Existing Resource References - CRITICAL: Update with your actual resource IDs
// DO NOT share these values in public repositories
param vnetResourceId = '<YOUR_VNET_RESOURCE_ID>'
// Example format: /subscriptions/<SUBSCRIPTION_ID>/resourceGroups/<RG_NAME>/providers/Microsoft.Network/virtualNetworks/<VNET_NAME>

param subnetName = '<YOUR_SUBNET_NAME>'  // Example: misc

param nsgResourceId = '<YOUR_NSG_RESOURCE_ID>'
// Example format: /subscriptions/<SUBSCRIPTION_ID>/resourceGroups/<RG_NAME>/providers/Microsoft.Network/networkSecurityGroups/<NSG_NAME>

// Key Vault References - CRITICAL: Update with your actual Key Vault details
param keyVaultName = '<YOUR_KEYVAULT_NAME>'  // Example: kvaueansdeploy

param keyVaultResourceId = '<YOUR_KEYVAULT_RESOURCE_ID>'
// Example format: /subscriptions/<SUBSCRIPTION_ID>/resourceGroups/<RG_NAME>/providers/Microsoft.KeyVault/vaults/<KEYVAULT_NAME>

param keyVaultSecretName = 'vmAdminPassword'

// Tags for resource management
param tags = {
  environment: 'production'
  project: 'AnsibleDeploy'
  managedBy: 'Bicep'
  costCenter: 'IT-Infrastructure'
  owner: 'Roberto'
}

// ============================================================================
// INSTRUCTIONS FOR SAFE PARAMETER MANAGEMENT
// ============================================================================
// 
// 1. Copy this file: cp main-secure.bicepparam main.bicepparam
// 
// 2. Add to .gitignore to prevent accidental commits:
//    echo "main.bicepparam" >> .gitignore
//    echo "keyvault-secure.bicepparam" >> .gitignore
// 
// 3. Fill in actual values in main.bicepparam (NOT in this file)
// 
// 4. For Azure DevOps Pipeline:
//    - Create pipeline variables for sensitive values
//    - Use variable groups for secret management
//    - Never hardcode secrets in YAML files
// 
// 5. For local testing:
//    - Use environment variables: export VNET_RESOURCE_ID="..."
//    - Pass via command line: --parameters vnetResourceId=$VNET_RESOURCE_ID
// 
// 6. To find your resource IDs, use Azure CLI:
//    az resource show --resource-group <RG_NAME> --name <RESOURCE_NAME> --resource-type <TYPE> --query id
// 
// ============================================================================
