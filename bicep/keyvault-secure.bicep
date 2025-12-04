// ============================================================================
// Azure Key Vault Deployment
// Author: Roberto
// Description: Bicep template to create Key Vault for storing VM credentials
// SECURITY NOTE: All sensitive values are parameterized. Do NOT hardcode secrets.
// ============================================================================

metadata description = 'Deploy an Azure Key Vault for secure credential storage'
metadata author = 'Roberto'
metadata version = '1.0.0'

// ============================================================================
// PARAMETERS - All sensitive values must be provided at deployment time
// ============================================================================

@description('The name of the Key Vault')
@minLength(3)
@maxLength(24)
param keyVaultName string

@description('The location for the Key Vault')
param location string = resourceGroup().location

@description('The object ID of the user or service principal that will have access to the Key Vault')
param principalId string

@description('The username for the VM administrator')
param adminUsername string

@description('The password for the VM administrator account')
@secure()
param adminPassword string

@description('Enable soft delete protection')
param enableSoftDelete bool = true

@description('Enable purge protection')
param enablePurgeProtection bool = true

@description('Tags to apply to the Key Vault')
param tags object = {}

// ============================================================================
// VARIABLES
// ============================================================================

var secretName = 'vmAdminPassword'
var tenantId = subscription().tenantId

// ============================================================================
// RESOURCES
// ============================================================================

// Azure Key Vault
resource keyVault 'Microsoft.KeyVault/vaults@2023-07-01' = {
  name: keyVaultName
  location: location
  tags: tags
  properties: {
    tenantId: tenantId
    sku: {
      family: 'A'
      name: 'standard'
    }
    accessPolicies: [
      {
        tenantId: tenantId
        objectId: principalId
        permissions: {
          keys: [
            'get'
            'list'
            'create'
            'update'
            'delete'
            'recover'
            'backup'
            'restore'
          ]
          secrets: [
            'get'
            'list'
            'set'
            'delete'
            'recover'
            'backup'
            'restore'
          ]
          certificates: [
            'get'
            'list'
            'create'
            'update'
            'delete'
            'recover'
            'backup'
            'restore'
          ]
        }
      }
    ]
    enabledForDeployment: true
    enabledForTemplateDeployment: true
    enabledForDiskEncryption: false
    enableSoftDelete: enableSoftDelete
    softDeleteRetentionInDays: 90
    enablePurgeProtection: enablePurgeProtection
    publicNetworkAccess: 'Enabled'
  }
}

// Secret for VM Admin Password
resource adminPasswordSecret 'Microsoft.KeyVault/vaults/secrets@2023-07-01' = {
  parent: keyVault
  name: secretName
  properties: {
    value: adminPassword
    contentType: 'text/plain'
    attributes: {
      enabled: true
      expires: dateTimeAdd(utcNow('u'), 'P365D') // Expires in 365 days
    }
  }
}

// ============================================================================
// OUTPUTS - Mark sensitive outputs with @secure()
// ============================================================================

@description('The resource ID of the Key Vault')
output keyVaultId string = keyVault.id

@description('The name of the Key Vault')
output keyVaultName string = keyVault.name

@description('The URI of the Key Vault')
output keyVaultUri string = keyVault.properties.vaultUri

@description('The name of the admin password secret')
output secretName string = secretName

@description('The resource ID of the admin password secret - DO NOT SHARE PUBLICLY')
@secure()
output secretId string = adminPasswordSecret.id

@description('Instructions for accessing the secret - DO NOT SHARE PUBLICLY')
@secure()
output secretAccessInstructions string = 'Access the secret at: ${keyVault.properties.vaultUri}secrets/${secretName}/'
