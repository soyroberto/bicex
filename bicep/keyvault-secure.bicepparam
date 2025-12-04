using './keyvault-secure.bicep'

// ============================================================================
// Azure Key Vault Parameters - TEMPLATE
// Author: Roberto
// Description: Parameter file for Key Vault creation
// 
// SECURITY WARNING: This is a TEMPLATE file. Do NOT commit actual values to Git.
// Copy this file to keyvault.bicepparam and fill in your actual values locally.
// Add keyvault.bicepparam to .gitignore to prevent accidental commits.
// ============================================================================

// Key Vault Configuration - Update with your values
param keyVaultName = '<YOUR_KEYVAULT_NAME>'  // Example: kvaueansdeploy
param location = '<YOUR_LOCATION>'  // Example: australiaeast

// Principal ID - Get with: az ad signed-in-user show --query id -o tsv
// DO NOT share this value in public repositories
param principalId = '<YOUR_PRINCIPAL_ID>'

// Admin Credentials - CRITICAL: Never hardcode passwords
// Use secure methods to pass this value:
// 1. Via Azure CLI: --parameters adminPassword=$(read -s; echo $REPLY)
// 2. Via environment variable: --parameters adminPassword=$ADMIN_PASSWORD
// 3. Via Azure DevOps secret variable: --parameters adminPassword=$(AdminPassword)
param adminUsername = '<YOUR_ADMIN_USERNAME>'  // Example: roberto
param adminPassword = '<SECURE_PASSWORD_PLACEHOLDER>'

// Security Settings
param enableSoftDelete = true
param enablePurgeProtection = true

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
// 1. Copy this file: cp keyvault-secure.bicepparam keyvault.bicepparam
// 
// 2. Add to .gitignore to prevent accidental commits:
//    echo "keyvault.bicepparam" >> .gitignore
// 
// 3. Fill in actual values in keyvault.bicepparam (NOT in this file)
// 
// 4. For Local Deployment:
//    
//    # Get your principal ID
//    PRINCIPAL_ID=$(az ad signed-in-user show --query id -o tsv)
//    
//    # Deploy with secure password input
//    read -s -p "Enter admin password: " ADMIN_PASSWORD
//    
//    az deployment group create \
//      --resource-group RGAUANSDeploy \
//      --template-file keyvault-secure.bicep \
//      --parameters keyvault.bicepparam \
//      --parameters principalId=$PRINCIPAL_ID \
//      --parameters adminPassword=$ADMIN_PASSWORD
// 
// 5. For Azure DevOps Pipeline:
//    - Create a pipeline secret variable for the password
//    - Use variable groups for sensitive values
//    - Reference in YAML: $(AdminPassword)
// 
// 6. To find your principal ID:
//    az ad signed-in-user show --query id -o tsv
// 
// 7. NEVER:
//    - Commit actual passwords to Git
//    - Hardcode secrets in parameter files
//    - Share principal IDs or resource IDs publicly
//    - Use the same password for multiple resources
// 
// ============================================================================
