// ============================================================================
// Azure VM Deployment with SQL Server 2019 and JIT Access
// Author: Roberto
// Description: Bicep template to deploy Windows Server 2022 with SQL Server 2019
// ============================================================================

metadata description = 'Deploy a Windows Server 2022 VM with SQL Server 2019 using Bicep'
metadata author = 'Roberto'
metadata version = '1.0.0'

// ============================================================================
// PARAMETERS
// ============================================================================

@description('The name of the virtual machine')
@minLength(1)
@maxLength(15)
param vmName string = 'vmauansvm01'

@description('The username for the VM administrator account')
@minLength(1)
@maxLength(20)
param adminUsername string = 'roberto'

@description('The size of the virtual machine')
@description('Standard_B2s_v2 is recommended for SQL Server 2019')
param vmSize string = 'Standard_B2s_v2'

@description('The location for all resources')
param location string = resourceGroup().location

@description('The resource ID of the existing virtual network')
param vnetResourceId string = '/subscriptions/f87077b9-ed2e-497d-876f-02c0a33e3774/resourceGroups/RGAUSNetCh/providers/Microsoft.Network/virtualNetworks/vnetausclient'

@description('The name of the subnet within the vnet')
param subnetName string = 'misc'

@description('The resource ID of the existing NSG for JIT access')
param nsgResourceId string = '/subscriptions/f87077b9-ed2e-497d-876f-02c0a33e3774/resourceGroups/RGAUSNetCh/providers/Microsoft.Network/networkSecurityGroups/nsgauejit'

@description('The name of the Key Vault containing the admin password')
param keyVaultName string = 'kvaueansdeploy'

@description('The name of the secret in Key Vault containing the admin password')
param keyVaultSecretName string = 'vmAdminPassword'

@description('Tags to apply to all resources')
param tags object = {
  environment: 'production'
  project: 'AnsibleDeploy'
  managedBy: 'Bicep'
  createdDate: utcNow('u')
}

// ============================================================================
// VARIABLES
// ============================================================================

var nicName = '${vmName}-nic'
var osDiskName = '${vmName}-osdisk'
var imagePublisher = 'MicrosoftSQLServer'
var imageOffer = 'sql2019-ws2022'
var imageSku = 'web'
var imageVersion = 'latest'

// Reference to existing resources
var vnetId = vnetResourceId
var subnetId = '${vnetId}/subnets/${subnetName}'

// ============================================================================
// RESOURCES
// ============================================================================

// Network Interface Card for the VM
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

// Public IP Address for RDP access
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

// Reference to existing Key Vault for retrieving admin password
resource keyVault 'Microsoft.KeyVault/vaults@2023-07-01' existing = {
  name: keyVaultName
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
      adminPassword: keyVault.getSecret(keyVaultSecretName)
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

// ============================================================================
// OUTPUTS
// ============================================================================

@description('The resource ID of the virtual machine')
output vmId string = vm.id

@description('The name of the virtual machine')
output vmName string = vm.name

@description('The private IP address of the VM')
output privateIpAddress string = nic.properties.ipConfigurations[0].properties.privateIPAddress

@description('The public IP address of the VM')
output publicIpAddress string = publicIP.properties.ipAddress

@description('The fully qualified domain name of the VM')
output fqdn string = publicIP.properties.dnsSettings.fqdn

@description('The admin username for the VM')
output adminUsername string = adminUsername

@description('Instructions for connecting to the VM')
output connectionInstructions string = 'Use RDP to connect to ${publicIP.properties.ipAddress} with username: ${adminUsername}'
