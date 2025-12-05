// ============================================================================
// Azure VM Deployment with SQL Server 2019
// Updated for secure pipeline deployment
// ============================================================================

metadata description = 'Deploy a Windows Server 2022 VM with SQL Server 2019 using Bicep'
metadata author = 'Roberto'
metadata version = '1.0.0'

param vmName string = 'vmausbixvm01'
param adminUsername string = 'roberto'
param vmSize string = 'Standard_B2s_v2'
param location string = resourceGroup().location

// References to existing infrastructure
param vnetResourceId string
param subnetName string = 'misc'
param nsgResourceId string
param keyVaultName string
param keyVaultSecretName string = 'vmAdminPassword'

param tags object = {
  environment: 'production'
  project: 'AnsibleDeploy'
  managedBy: 'Bicep'
}

// Variables
var nicName = '${vmName}-nic'
var osDiskName = '${vmName}-osdisk'
var imagePublisher = 'MicrosoftSQLServer'
var imageOffer = 'sql2019-ws2022'
var imageSku = 'web'
var imageVersion = 'latest'
var subnetId = '${vnetResourceId}/subnets/${subnetName}'

// Resources
resource nic 'Microsoft.Network/networkInterfaces@2023-11-01' = {
  name: nicName
  location: location
  tags: tags
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          subnet: {
            id: subnetId
          }
          privateIPAllocationMethod: 'Dynamic'
          publicIPAddress: {
            id: publicIP.id
          }
        }
      }
    ]
    networkSecurityGroup: {
      id: nsgResourceId
    }
  }
}

resource publicIP 'Microsoft.Network/publicIPAddresses@2023-11-01' = {
  name: '${vmName}-pip'
  location: location
  tags: tags
  properties: {
    publicIPAllocationMethod: 'Static'
    publicIPAddressVersion: 'IPv4'
    idleTimeoutInMinutes: 4
  }
  sku: {
    name: 'Standard'
    tier: 'Regional'
  }
}

// Reference existing Key Vault
resource keyVault 'Microsoft.KeyVault/vaults@2023-07-01' existing = {
  name: keyVaultName
}

// Get the secret reference properly
resource vmPassword 'Microsoft.KeyVault/vaults/secrets@2023-07-01' existing = {
  name: keyVaultSecretName
  parent: keyVault
}

// Virtual Machine with SQL Server 2019
resource vm 'Microsoft.Compute/virtualMachines@2023-09-01' = {
  name: vmName
  location: location
  tags: tags
  properties: {
    hardwareProfile: {
      vmSize: vmSize
    }
    osProfile: {
      computerName: vmName
      adminUsername: adminUsername
      // CORRECT: Use the secretUri for password reference
      adminPassword: vmPassword.properties.secretUri
      windowsConfiguration: {
        enableAutomaticUpdates: true
        provisionVMAgent: true
        patchSettings: {
          patchMode: 'AutomaticByPlatform'
          assessmentMode: 'ImageDefault'
        }
      }
    }
    storageProfile: {
      imageReference: {
        publisher: imagePublisher
        offer: imageOffer
        sku: imageSku
        version: imageVersion
      }
      osDisk: {
        name: osDiskName
        caching: 'ReadWrite'
        createOption: 'FromImage'
        managedDisk: {
          storageAccountType: 'Premium_LRS'
        }
      }
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: nic.id
          properties: {
            primary: true
          }
        }
      ]
    }
  }
}

// Outputs
output vmId string = vm.id
output vmName string = vm.name
output privateIpAddress string = nic.properties.ipConfigurations[0].properties.privateIPAddress
output publicIpAddress string = publicIP.properties.ipAddress
output adminUsername string = adminUsername
output keyVaultName string = keyVaultName
output connectionInstructions string = 'Use RDP to connect to ${publicIP.properties.ipAddress} with username: ${adminUsername}'
