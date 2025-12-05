// Key Vault for storing VM secrets
param keyVaultName string
param location string
param adminUsername string
param principalId string  // Will get this from pipeline

resource keyVault 'Microsoft.KeyVault/vaults@2023-07-01' = {
  name: keyVaultName
  location: location
  properties: {
    tenantId: subscription().tenantId
    sku: {
      family: 'A'
      name: 'standard'
    }
    accessPolicies: [
      {
        tenantId: subscription().tenantId
        objectId: principalId
        permissions: {
          secrets: [
            'get'
            'list'
            'set'
            'delete'
            'recover'
            'backup'
            'restore'
          ]
        }
      }
    ]
    enableSoftDelete: true
    enablePurgeProtection: true
    enabledForDeployment: true
    enabledForTemplateDeployment: true
  }
}

// Create VM password secret
resource vmPassword 'Microsoft.KeyVault/vaults/secrets@2023-07-01' = {
  name: 'vmAdminPassword'
  parent: keyVault
  properties: {
    value: take(uniqueString(resourceGroup().id, keyVaultName, 'password'), 16)
    contentType: 'VM Administrator Password'
    attributes: {
      enabled: true
    }
  }
}

output vaultUri string = keyVault.properties.vaultUri
output secretId string = vmPassword.id
