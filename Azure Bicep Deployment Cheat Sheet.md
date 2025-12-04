# Azure Bicep Deployment Cheat Sheet

Quick reference for common commands and tasks.

## Azure CLI Essentials

### Authentication

```bash
# Login to Azure
az login

# Login with specific tenant
az login --tenant <TENANT_ID>

# Logout
az logout

# Show current account
az account show

# List all subscriptions
az account list --output table

# Set default subscription
az account set --subscription <SUBSCRIPTION_ID>
```

### Resource Groups

```bash
# List resource groups
az group list --output table

# Create resource group
az group create --name MyRG --location australiaeast

# Delete resource group
az group delete --name MyRG --yes

# Get resource group details
az group show --name RGAUANSDeploy
```

## Bicep Commands

### Validation and Building

```bash
# Build Bicep to ARM template
az bicep build --file main.bicep --outfile main.json

# Lint Bicep file (check best practices)
az bicep lint --file main.bicep

# Decompile ARM template to Bicep
az bicep decompile --file template.json

# Install/update Bicep CLI
az bicep install

# Check Bicep version
az bicep version
```

## Deployment Commands

### What-If (Preview Changes)

```bash
# What-If for resource group deployment
az deployment group what-if \
  --resource-group RGAUANSDeploy \
  --template-file main.bicep \
  --parameters main.bicepparam

# What-If with inline parameters
az deployment group what-if \
  --resource-group RGAUANSDeploy \
  --template-file main.bicep \
  --parameters keyVaultName=mykeyvault
```

### Deploy Resources

```bash
# Deploy with Bicep file
az deployment group create \
  --resource-group RGAUANSDeploy \
  --template-file main.bicep \
  --parameters main.bicepparam \
  --name MyDeployment

# Deploy with inline parameters
az deployment group create \
  --resource-group RGAUANSDeploy \
  --template-file main.bicep \
  --parameters keyVaultName=mykeyvault location=australiaeast

# Deploy in validation mode (no changes applied)
az deployment group validate \
  --resource-group RGAUANSDeploy \
  --template-file main.bicep \
  --parameters main.bicepparam
```

### Deployment Status

```bash
# List deployments
az deployment group list --resource-group RGAUANSDeploy --output table

# Get deployment details
az deployment group show \
  --resource-group RGAUANSDeploy \
  --name MyDeployment

# Get deployment outputs
az deployment group show \
  --resource-group RGAUANSDeploy \
  --name MyDeployment \
  --query properties.outputs
```

## Virtual Machine Management

### VM Operations

```bash
# List VMs
az vm list --resource-group RGAUANSDeploy --output table

# Get VM details
az vm show \
  --resource-group RGAUANSDeploy \
  --name vmauansvm01

# Get VM with network details
az vm show -d \
  --resource-group RGAUANSDeploy \
  --name vmauansvm01

# Get public IP
az vm show -d \
  --resource-group RGAUANSDeploy \
  --name vmauansvm01 \
  --query publicIps -o tsv

# Get private IP
az vm show -d \
  --resource-group RGAUANSDeploy \
  --name vmauansvm01 \
  --query privateIps -o tsv

# Start VM
az vm start \
  --resource-group RGAUANSDeploy \
  --name vmauansvm01

# Stop VM
az vm stop \
  --resource-group RGAUANSDeploy \
  --name vmauansvm01

# Deallocate VM (stop and release compute resources)
az vm deallocate \
  --resource-group RGAUANSDeploy \
  --name vmauansvm01

# Delete VM
az vm delete \
  --resource-group RGAUANSDeploy \
  --name vmauansvm01 \
  --yes

# Reboot VM
az vm restart \
  --resource-group RGAUANSDeploy \
  --name vmauansvm01
```

### VM Password Management

```bash
# Reset password for VM user
az vm user update \
  --resource-group RGAUANSDeploy \
  --name vmauansvm01 \
  --username roberto \
  --password NewPassword123!

# Run command on VM
az vm run-command invoke \
  --resource-group RGAUANSDeploy \
  --name vmauansvm01 \
  --command-id RunPowerShellScript \
  --scripts "Get-ComputerInfo"
```

## Key Vault Management

### Key Vault Operations

```bash
# List key vaults
az keyvault list --output table

# Get key vault details
az keyvault show \
  --name kvaueansdeploy \
  --resource-group RGAUANSDeploy

# Create key vault
az keyvault create \
  --name kvaueansdeploy \
  --resource-group RGAUANSDeploy \
  --location australiaeast

# Delete key vault
az keyvault delete \
  --name kvaueansdeploy \
  --resource-group RGAUANSDeploy
```

### Secret Management

```bash
# List secrets
az keyvault secret list \
  --vault-name kvaueansdeploy \
  --output table

# Get secret value
az keyvault secret show \
  --vault-name kvaueansdeploy \
  --name vmAdminPassword \
  --query value -o tsv

# Set/update secret
az keyvault secret set \
  --vault-name kvaueansdeploy \
  --name vmAdminPassword \
  --value "NewPassword123!"

# Delete secret
az keyvault secret delete \
  --vault-name kvaueansdeploy \
  --name vmAdminPassword

# Get secret metadata (without value)
az keyvault secret show \
  --vault-name kvaueansdeploy \
  --name vmAdminPassword
```

## Network Management

### Public IP

```bash
# List public IPs
az network public-ip list \
  --resource-group RGAUANSDeploy \
  --output table

# Get public IP details
az network public-ip show \
  --resource-group RGAUANSDeploy \
  --name vmauansvm01-pip

# Get public IP address
az network public-ip show \
  --resource-group RGAUANSDeploy \
  --name vmauansvm01-pip \
  --query ipAddress -o tsv
```

### Network Security Group (NSG)

```bash
# List NSGs
az network nsg list --output table

# Get NSG rules
az network nsg rule list \
  --resource-group RGAUSNetCh \
  --nsg-name nsgauejit \
  --output table

# Add NSG rule
az network nsg rule create \
  --resource-group RGAUSNetCh \
  --nsg-name nsgauejit \
  --name AllowRDP \
  --priority 100 \
  --source-address-prefixes '*' \
  --destination-port-ranges 3389 \
  --access Allow \
  --protocol Tcp

# Delete NSG rule
az network nsg rule delete \
  --resource-group RGAUSNetCh \
  --nsg-name nsgauejit \
  --name AllowRDP
```

## Git Commands

### Basic Git Operations

```bash
# Clone repository
git clone <REPO_URL>

# Check status
git status

# View changes
git diff

# Stage changes
git add .

# Commit changes
git commit -m "Your commit message"

# Push changes
git push origin main

# Pull latest changes
git pull origin main
```

### Branching

```bash
# Create new branch
git checkout -b feature/new-feature

# Switch branch
git checkout main

# List branches
git branch -a

# Delete branch
git branch -d feature/new-feature

# Rename branch
git branch -m old-name new-name
```

### History and Logs

```bash
# View commit history
git log --oneline -10

# View changes in specific file
git log -p -- filename

# View who changed each line
git blame filename

# View commits by author
git log --author="Roberto"
```

## Azure DevOps CLI

### Pipeline Management

```bash
# Configure defaults
az devops configure --defaults \
  organization=https://dev.azure.com/soydevops \
  project=AnsibleDeploy

# List pipelines
az pipelines build list --top 10

# Get pipeline details
az pipelines build show --id <BUILD_ID>

# Queue new build
az pipelines build queue --definition-id <DEFINITION_ID>

# View build logs
az pipelines build log list --id <BUILD_ID>
```

## Useful One-Liners

```bash
# Get VM public IP and open RDP
VM_IP=$(az vm show -d --resource-group RGAUANSDeploy --name vmauansvm01 --query publicIps -o tsv)
echo "Connect to: $VM_IP"

# Get all resource IDs in a resource group
az resource list --resource-group RGAUANSDeploy --query "[].id" -o tsv

# Count resources in a resource group
az resource list --resource-group RGAUANSDeploy --query "length([*])"

# Export resource group as template
az group export --name RGAUANSDeploy > template.json

# Get principal ID for current user
az ad signed-in-user show --query id -o tsv

# List all resources with specific tag
az resource list --query "[?tags.environment=='production']" --output table
```

## Common Errors and Solutions

### Error: "The template is invalid"

**Solution**: Validate Bicep file
```bash
az bicep build --file main.bicep
```

### Error: "Resource group not found"

**Solution**: Create resource group first
```bash
az group create --name RGAUANSDeploy --location australiaeast
```

### Error: "Insufficient permissions"

**Solution**: Check role assignment
```bash
az role assignment list --resource-group RGAUANSDeploy --output table
```

### Error: "The resource already exists"

**Solution**: Use what-if to preview changes
```bash
az deployment group what-if \
  --resource-group RGAUANSDeploy \
  --template-file main.bicep \
  --parameters main.bicepparam
```

## Quick Deployment Checklist

- [ ] Validate Bicep files: `az bicep build --file main.bicep`
- [ ] Run what-if: `az deployment group what-if ...`
- [ ] Check Key Vault secret exists
- [ ] Verify NSG rules are correct
- [ ] Confirm resource group exists
- [ ] Review parameter values
- [ ] Deploy: `az deployment group create ...`
- [ ] Verify deployment: `az deployment group show ...`
- [ ] Check resources in portal
- [ ] Test VM connectivity

## Useful Links

- [Azure CLI Documentation](https://learn.microsoft.com/en-us/cli/azure/)
- [Bicep Documentation](https://learn.microsoft.com/en-us/azure/azure-resource-manager/bicep/)
- [Azure DevOps CLI](https://learn.microsoft.com/en-us/azure/devops/cli/)
- [Azure Pricing Calculator](https://azure.microsoft.com/en-us/pricing/calculator/)
