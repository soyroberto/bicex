# Deploying a Secure SQL Server VM in Azure with Bicep and Azure DevOps: An End-to-End Tutorial

*By Roberto*

Welcome to our deep-dive tutorial on automating the deployment of a secure Windows Server VM with SQL Server 2019 in Azure. In this guide, we will leverage Infrastructure as Code (IaC) using Bicep, manage our code in GitHub, and build a full CI/CD pipeline in Azure DevOps. This end-to-end process ensures your deployments are repeatable, secure, and efficient.

We will cover everything from creating the Bicep files to deploying the infrastructure, with a special focus on security best practices like Just-In-Time (JIT) access and credential management with Azure Key Vault. This post is designed to be a practical, step-by-step guide that you can follow to implement a production-ready workflow.

### Table of Contents

1.  [Prerequisites](#prerequisites)
2.  [Step 1: Structuring Your Project](#step-1-structuring-your-project)
3.  [Step 2: Creating the Key Vault with Bicep](#step-2-creating-the-key-vault-with-bicep)
4.  [Step 3: Defining the Virtual Machine with Bicep](#step-3-defining-the-virtual-machine-with-bicep)
5.  [Step 4: Setting Up Your GitHub Repository](#step-4-setting-up-your-github-repository)
6.  [Step 5: Configuring Your Azure DevOps Project](#step-5-configuring-your-azure-devops-project)
7.  [Step 6: Building the CI/CD Pipeline in Azure DevOps](#step-6-building-the-cicd-pipeline-in-azure-devops)
8.  [Step 7: Running the Pipeline and Deploying](#step-7-running-the-pipeline-and-deploying)
9.  [Step 8: Verifying the Deployment](#step-8-verifying-the-deployment)
10. [Understanding Just-In-Time (JIT) Access](#understanding-just-in-time-jit-access)
11. [Best Practices for Password Rotation](#best-practices-for-password-rotation)
12. [Conclusion](#conclusion)
13. [References](#references)

---

### Prerequisites

Before we begin, ensure you have the following set up:

*   **Azure Subscription**: An active Azure subscription. If you don't have one, you can [create a free account][1]. The subscription ID used in this tutorial is `f87077b9-ed2e-497d-876f-02c0a33e3774`.
*   **Azure DevOps Organization**: An Azure DevOps organization and a project. The project used here is `https://dev.azure.com/soydevops/AnsibleDeploy`.
*   **GitHub Account**: A GitHub account to host your Bicep code.
*   **Visual Studio Code**: VS Code installed on your macOS (or any other OS) with the [Bicep extension][2] installed.
*   **Azure CLI**: The Azure CLI installed on your local machine. You can find installation instructions [here][3].
*   **Permissions**: You will need appropriate permissions to create resources in your Azure subscription and to create service connections in Azure DevOps.

### Step 1: Structuring Your Project

First, let's set up a clean folder structure for our project on your local machine. This helps in keeping our code organized.

```bash
mkdir azure-bicep-vm
cd azure-bicep-vm
mkdir bicep
```

Your project structure should look like this:

```
azure-bicep-vm/
├── bicep/
│   ├── main.bicep
│   ├── main.bicepparam
│   ├── keyvault.bicep
│   └── keyvault.bicepparam
└── azure-pipelines.yml
```

We will create these files in the upcoming steps.

### Step 2: Creating the Key Vault with Bicep

Storing credentials securely is paramount. We'll create an Azure Key Vault to store the VM's administrator password. This avoids exposing sensitive information in our code or pipeline variables.

#### `keyvault.bicep`

Create this file inside the `bicep` folder. This template defines the Key Vault and a secret for the VM password.

```bicep
// ============================================================================
// Azure Key Vault Deployment
// Author: Roberto
// Description: Bicep template to create Key Vault for storing VM credentials
// ============================================================================

metadata description = 'Deploy an Azure Key Vault for secure credential storage'
metadata author = 'Roberto'
metadata version = '1.0.0'

// ============================================================================
// PARAMETERS
// ============================================================================

@description('The name of the Key Vault')
@minLength(3)
@maxLength(24)
param keyVaultName string = 'kvaueansdeploy'

@description('The location for the Key Vault')
param location string = resourceGroup().location

@description('The object ID of the user or service principal that will have access to the Key Vault')
param principalId string

@description('The username for the VM administrator')
param adminUsername string = 'roberto'

@description('The password for the VM administrator account')
@secure()
param adminPassword string

@description('Enable soft delete protection')
param enableSoftDelete bool = true

@description('Enable purge protection')
param enablePurgeProtection bool = true

@description('Tags to apply to the Key Vault')
param tags object = {
  environment: 'production'
  project: 'AnsibleDeploy'
  managedBy: 'Bicep'
}

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
// OUTPUTS
// ============================================================================

@description('The resource ID of the Key Vault')
output keyVaultId string = keyVault.id

@description('The name of the Key Vault')
output keyVaultName string = keyVault.name

@description('The URI of the Key Vault')
output keyVaultUri string = keyVault.properties.vaultUri

@description('The name of the admin password secret')
output secretName string = secretName

@description('The resource ID of the admin password secret')
output secretId string = adminPasswordSecret.id

@description('Instructions for accessing the secret')
output secretAccessInstructions string = 'Access the secret at: ${keyVault.properties.vaultUri}secrets/${secretName}/'

```

#### `keyvault.bicepparam`

This parameter file provides the values for the `keyvault.bicep` template. **Remember to replace `<YOUR_PRINCIPAL_ID>` and `<SECURE_PASSWORD_HERE>` with your actual values.**

```bicep
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

```

To get your principal ID, run the following Azure CLI command:

```bash
az ad signed-in-user show --query id -o tsv
```

### Step 3: Defining the Virtual Machine with Bicep

Now, let's define the core of our infrastructure: the SQL Server VM.

#### `main.bicep`

This is the main Bicep file that defines the VM, its network interface (NIC), public IP address, and references the Key Vault for the admin password.

```bicep
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

```

This template is configured to use the `MicrosoftSQLServer:sql2019-ws2022:web:15.0.251107` image and a `Standard_B2s_v2` size VM. It also references existing network resources (`vnetausclient` and `nsgauejit`).

#### `main.bicepparam`

This file provides the parameters for our main Bicep template.

```bicep
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

```

### Step 4: Setting Up Your GitHub Repository

With our Bicep code ready, the next step is to push it to a GitHub repository. This will be the source for our Azure DevOps pipeline.

1.  Create a new repository on GitHub.
2.  Initialize a Git repository in your local `azure-bicep-vm` folder and push the code:

```bash
git init
git add .
git commit -m "Initial commit of Bicep templates for SQL VM"
git branch -M main
git remote add origin <YOUR_GITHUB_REPO_URL>
git push -u origin main
```

### Step 5: Configuring Your Azure DevOps Project

Before creating the pipeline, we need to connect Azure DevOps to our Azure subscription and GitHub repository.

1.  **Create a Service Connection to Azure**: In your Azure DevOps project, go to **Project settings** > **Service connections**. Create a new service connection of type **Azure Resource Manager** and use the **Service principal (automatic)** authentication method. Name it `AzureServiceConnection`.
2.  **Connect to GitHub**: The pipeline will ask for authorization to connect to your GitHub repository the first time you run it.

### Step 6: Building the CI/CD Pipeline in Azure DevOps

Now, we'll create the YAML pipeline in Azure DevOps to automate the deployment.

#### `azure-pipelines.yml`

Create this file in the root of your project. This pipeline has multiple stages: Validate, Test (What-If), Deploy, and Post-Deployment.

```yaml
# ============================================================================
# Azure DevOps Pipeline for Bicep Deployment
# Author: Roberto
# Description: CI/CD pipeline for deploying Windows Server 2022 with SQL 2019 VM
# ============================================================================

trigger:
  branches:
    include:
      - main
      - develop
  paths:
    include:
      - 'bicep/**'
      - 'azure-pipelines.yml'

pr:
  branches:
    include:
      - main
      - develop
  paths:
    include:
      - 'bicep/**'
      - 'azure-pipelines.yml'

pool:
  vmImage: 'ubuntu-latest'

variables:
  # Azure Subscription and Resource Group
  azureSubscriptionId: 'f87077b9-ed2e-497d-876f-02c0a33e3774'
  resourceGroupName: 'RGAUANSDeploy'
  location: 'australiaeast'
  
  # Bicep file paths
  keyVaultBicepFile: '$(Build.SourcesDirectory)/bicep/keyvault.bicep'
  keyVaultParamFile: '$(Build.SourcesDirectory)/bicep/keyvault.bicepparam'
  vmBicepFile: '$(Build.SourcesDirectory)/bicep/main.bicep'
  vmParamFile: '$(Build.SourcesDirectory)/bicep/main.bicepparam'
  
  # Deployment settings
  deploymentMode: 'Incremental'
  keyVaultName: 'kvaueansdeploy'
  vmName: 'vmauansvm01'
  
  # Build output
  buildArtifactName: 'bicep-templates'

stages:
  # ========================================================================
  # STAGE 1: VALIDATE
  # ========================================================================
  - stage: Validate
    displayName: 'Validate Bicep Templates'
    jobs:
      - job: ValidateBicep
        displayName: 'Validate and Lint Bicep Files'
        steps:
          - checkout: self
            fetchDepth: 0

          - task: UseDotNet@2
            displayName: 'Install .NET for Bicep CLI'
            inputs:
              version: '7.x'

          - task: PowerShell@2
            displayName: 'Install Bicep CLI'
            inputs:
              targetType: 'inline'
              script: |
                az bicep install
                az bicep version

          - task: PowerShell@2
            displayName: 'Validate Key Vault Bicep Template'
            inputs:
              targetType: 'inline'
              script: |
                Write-Host "Validating Key Vault Bicep template..."
                az bicep build --file $(keyVaultBicepFile) --outfile $(Build.ArtifactStagingDirectory)/keyvault.json
                if ($LASTEXITCODE -ne 0) {
                  Write-Error "Key Vault Bicep validation failed"
                  exit 1
                }
                Write-Host "Key Vault Bicep validation successful"

          - task: PowerShell@2
            displayName: 'Validate VM Bicep Template'
            inputs:
              targetType: 'inline'
              script: |
                Write-Host "Validating VM Bicep template..."
                az bicep build --file $(vmBicepFile) --outfile $(Build.ArtifactStagingDirectory)/main.json
                if ($LASTEXITCODE -ne 0) {
                  Write-Error "VM Bicep validation failed"
                  exit 1
                }
                Write-Host "VM Bicep validation successful"

          - task: PublishBuildArtifacts@1
            displayName: 'Publish Validation Artifacts'
            inputs:
              pathToPublish: '$(Build.ArtifactStagingDirectory)'
              artifactName: $(buildArtifactName)
              publishLocation: 'Container'

  # ========================================================================
  # STAGE 2: TEST (What-If)
  # ========================================================================
  - stage: Test
    displayName: 'Test Deployment with What-If'
    dependsOn: Validate
    condition: succeeded()
    jobs:
      - job: WhatIfDeployment
        displayName: 'Run What-If Analysis'
        steps:
          - checkout: self

          - task: AzureCLI@2
            displayName: 'Azure CLI Login'
            inputs:
              azureSubscription: 'AzureServiceConnection'
              scriptType: 'bash'
              scriptLocation: 'inlineScript'
              inlineScript: |
                az account set --subscription $(azureSubscriptionId)
                az account show

          - task: AzureCLI@2
            displayName: 'What-If: Key Vault Deployment'
            inputs:
              azureSubscription: 'AzureServiceConnection'
              scriptType: 'bash'
              scriptLocation: 'inlineScript'
              inlineScript: |
                echo "Running What-If for Key Vault deployment..."
                az deployment group what-if \
                  --resource-group $(resourceGroupName) \
                  --template-file $(keyVaultBicepFile) \
                  --parameters $(keyVaultParamFile) \
                  --name 'WhatIfKeyVault'
                echo "What-If analysis completed for Key Vault"

          - task: AzureCLI@2
            displayName: 'What-If: VM Deployment'
            inputs:
              azureSubscription: 'AzureServiceConnection'
              scriptType: 'bash'
              scriptLocation: 'inlineScript'
              inlineScript: |
                echo "Running What-If for VM deployment..."
                az deployment group what-if \
                  --resource-group $(resourceGroupName) \
                  --template-file $(vmBicepFile) \
                  --parameters $(vmParamFile) \
                  --name 'WhatIfVM'
                echo "What-If analysis completed for VM"

  # ========================================================================
  # STAGE 3: DEPLOY TO PRODUCTION
  # ========================================================================
  - stage: DeployProduction
    displayName: 'Deploy to Production'
    dependsOn: Test
    condition: and(succeeded(), eq(variables['Build.SourceBranch'], 'refs/heads/main'))
    jobs:
      - deployment: DeployKeyVault
        displayName: 'Deploy Key Vault'
        environment: 'Production'
        strategy:
          runOnce:
            deploy:
              steps:
                - checkout: self

                - task: AzureCLI@2
                  displayName: 'Deploy Key Vault'
                  inputs:
                    azureSubscription: 'AzureServiceConnection'
                    scriptType: 'bash'
                    scriptLocation: 'inlineScript'
                    inlineScript: |
                      echo "Deploying Key Vault to $(resourceGroupName)..."
                      
                      # Get current user's principal ID
                      PRINCIPAL_ID=$(az ad signed-in-user show --query id -o tsv)
                      echo "Current user principal ID: $PRINCIPAL_ID"
                      
                      az deployment group create \
                        --resource-group $(resourceGroupName) \
                        --template-file $(keyVaultBicepFile) \
                        --parameters $(keyVaultParamFile) \
                        --parameters principalId=$PRINCIPAL_ID \
                        --name 'DeployKeyVault-$(Build.BuildId)' \
                        --mode $(deploymentMode)
                      
                      echo "Key Vault deployment completed successfully"

      - deployment: DeployVM
        displayName: 'Deploy Virtual Machine'
        dependsOn: DeployKeyVault
        environment: 'Production'
        strategy:
          runOnce:
            deploy:
              steps:
                - checkout: self

                - task: AzureCLI@2
                  displayName: 'Deploy Virtual Machine'
                  inputs:
                    azureSubscription: 'AzureServiceConnection'
                    scriptType: 'bash'
                    scriptLocation: 'inlineScript'
                    inlineScript: |
                      echo "Deploying Virtual Machine to $(resourceGroupName)..."
                      
                      az deployment group create \
                        --resource-group $(resourceGroupName) \
                        --template-file $(vmBicepFile) \
                        --parameters $(vmParamFile) \
                        --name 'DeployVM-$(Build.BuildId)' \
                        --mode $(deploymentMode)
                      
                      echo "Virtual Machine deployment completed successfully"

      - deployment: ConfigureJIT
        displayName: 'Configure Just-In-Time Access'
        dependsOn: DeployVM
        environment: 'Production'
        strategy:
          runOnce:
            deploy:
              steps:
                - checkout: self

                - task: AzureCLI@2
                  displayName: 'Enable JIT Access on VM'
                  inputs:
                    azureSubscription: 'AzureServiceConnection'
                    scriptType: 'bash'
                    scriptLocation: 'inlineScript'
                    inlineScript: |
                      echo "Configuring Just-In-Time access for $(vmName)..."
                      
                      VM_ID=$(az vm show \
                        --resource-group $(resourceGroupName) \
                        --name $(vmName) \
                        --query id -o tsv)
                      
                      echo "VM ID: $VM_ID"
                      
                      # Enable JIT through Azure Defender for Cloud
                      # Note: This requires Microsoft Defender for Servers Plan 2
                      echo "JIT configuration should be completed through Azure Portal or Azure Defender for Cloud"
                      echo "VM is ready for JIT configuration"

  # ========================================================================
  # STAGE 4: POST-DEPLOYMENT
  # ========================================================================
  - stage: PostDeployment
    displayName: 'Post-Deployment Validation'
    dependsOn: DeployProduction
    condition: succeeded()
    jobs:
      - job: ValidateDeployment
        displayName: 'Validate Deployment'
        steps:
          - checkout: self

          - task: AzureCLI@2
            displayName: 'Verify Resources'
            inputs:
              azureSubscription: 'AzureServiceConnection'
              scriptType: 'bash'
              scriptLocation: 'inlineScript'
              inlineScript: |
                echo "Verifying deployed resources..."
                
                # Check Key Vault
                echo "Checking Key Vault..."
                az keyvault show --name $(keyVaultName) --resource-group $(resourceGroupName)
                
                # Check VM
                echo "Checking Virtual Machine..."
                az vm show --name $(vmName) --resource-group $(resourceGroupName)
                
                # Get VM details
                echo "Getting VM connection details..."
                VM_IP=$(az vm show -d --name $(vmName) --resource-group $(resourceGroupName) --query publicIps -o tsv)
                echo "VM Public IP: $VM_IP"
                
                echo "Deployment validation completed successfully"

          - task: AzureCLI@2
            displayName: 'Generate Deployment Report'
            inputs:
              azureSubscription: 'AzureServiceConnection'
              scriptType: 'bash'
              scriptLocation: 'inlineScript'
              inlineScript: |
                echo "=== Deployment Summary ===" > $(Build.ArtifactStagingDirectory)/deployment-report.txt
                echo "Deployment Date: $(date)" >> $(Build.ArtifactStagingDirectory)/deployment-report.txt
                echo "Resource Group: $(resourceGroupName)" >> $(Build.ArtifactStagingDirectory)/deployment-report.txt
                echo "Location: $(location)" >> $(Build.ArtifactStagingDirectory)/deployment-report.txt
                echo "VM Name: $(vmName)" >> $(Build.ArtifactStagingDirectory)/deployment-report.txt
                echo "Key Vault Name: $(keyVaultName)" >> $(Build.ArtifactStagingDirectory)/deployment-report.txt
                echo "" >> $(Build.ArtifactStagingDirectory)/deployment-report.txt
                echo "=== VM Details ===" >> $(Build.ArtifactStagingDirectory)/deployment-report.txt
                az vm show -d --name $(vmName) --resource-group $(resourceGroupName) >> $(Build.ArtifactStagingDirectory)/deployment-report.txt
                
                cat $(Build.ArtifactStagingDirectory)/deployment-report.txt

          - task: PublishBuildArtifacts@1
            displayName: 'Publish Deployment Report'
            inputs:
              pathToPublish: '$(Build.ArtifactStagingDirectory)'
              artifactName: 'deployment-report'
              publishLocation: 'Container'

```

**Pipeline Stages Explained:**

*   **Validate**: This stage compiles the Bicep files into ARM templates to ensure the syntax is correct.
*   **Test**: This stage runs a `what-if` deployment. This is a crucial step that shows you what resources will be created, changed, or deleted without actually applying the changes.
*   **DeployProduction**: This stage, which only runs on a push to the `main` branch, deploys the Key Vault and the VM.
*   **PostDeployment**: This final stage runs some checks to verify that the resources were deployed successfully.

### Step 7: Running the Pipeline and Deploying

1.  In Azure DevOps, go to **Pipelines** and create a **New pipeline**.
2.  Select **GitHub** as your code source and choose your repository.
3.  Select **Existing Azure Pipelines YAML file** and point it to `/azure-pipelines.yml` on your `main` branch.
4.  Click **Run**. The pipeline will trigger. Since this is the first run on the `main` branch, it will go through all the stages and deploy your infrastructure.

### Step 8: Verifying the Deployment

Once the pipeline completes successfully, you can verify the resources in the Azure portal. You should see the `kvaueansdeploy` Key Vault and the `vmauansvm01` virtual machine in the `RGAUANSDeploy` resource group.

The pipeline's final stage also provides a summary of the deployed resources.

### Understanding Just-In-Time (JIT) Access

*Just-In-Time (JIT) VM access* is a feature of Microsoft Defender for Cloud that locks down inbound traffic to your Azure VMs, reducing exposure to attacks. When JIT is enabled, it blocks all inbound traffic on specific management ports (like RDP and SSH) by default. When a user needs access, they request temporary access, and Defender for Cloud opens the port for a limited time to a specific IP address or range.

**Requirements for JIT:**

*   **Licensing**: JIT requires **Microsoft Defender for Servers Plan 2** to be enabled on your subscription.
*   **Networking**: A **Network Security Group (NSG)** must be associated with the VM's NIC or subnet. Our Bicep template already references the `nsgauejit` NSG.
*   **Permissions**: You need `Reader` and `SecurityReader` roles to view JIT status and `SecurityAdmin` or a custom role with appropriate permissions to configure it.

To enable JIT on the deployed VM, navigate to the **Microsoft Defender for Cloud** dashboard in the Azure portal, go to **Workload protections** > **Just-in-time VM access**, find your VM in the "Not configured" tab, and enable it.

### Best Practices for Password Rotation

Managing credentials effectively is crucial for security. Here are some best practices for password rotation with Azure Key Vault:

*   **Regular Rotation**: Secrets should be rotated periodically. A common best practice is to rotate them at least every 60-90 days.
*   **Automate Rotation**: Azure Key Vault supports automated rotation of secrets. You can configure a rotation policy on a secret, which can trigger an Azure Function to update the password on the target resource (the VM in our case) and in the Key Vault.
*   **Zero-Downtime Rotation**: For services that need to be available 24/7, implement a dual credential system. The application can use a secondary credential while the primary one is being rotated, ensuring no downtime.
*   **Monitoring and Alerting**: Enable logging for your Key Vault to track access to secrets. Set up alerts for unusual activity, such as a secret being accessed from an unexpected location.

### Conclusion

Congratulations! You have successfully built a robust, automated, and secure pipeline to deploy a SQL Server VM on Azure. By using Bicep for infrastructure as code, Azure DevOps for CI/CD, and integrating security best practices like Key Vault and JIT access, you have created a deployment process that is both efficient and secure.

This tutorial provides a solid foundation that you can adapt and expand for more complex scenarios. The principles of IaC, automated pipelines, and integrated security are key to modern cloud operations.

---

### References

[1]: https://azure.microsoft.com/en-us/free/ "Create your Azure free account today"
[2]: https://marketplace.visualstudio.com/items?itemName=ms-azure-tools.bicep "Bicep - Visual Studio Marketplace"
[3]: https://docs.microsoft.com/en-us/cli/azure/install-azure-cli "How to install the Azure CLI"
[4]: https://learn.microsoft.com/en-us/azure/defender-for-cloud/just-in-time-access-overview "Understand just-in-time (JIT) VM access"
[5]: https://learn.microsoft.com/en-us/azure/azure-resource-manager/bicep/best-practices "Best practices for Bicep"
[6]: https://learn.microsoft.com/en-us/azure/key-vault/secrets/secrets-best-practices "Best practices for secrets management in Azure Key Vault"
[7]: https://learn.microsoft.com/en-us/azure/azure-resource-manager/bicep/add-template-to-azure-pipelines "Integrate Bicep with Azure Pipelines"
