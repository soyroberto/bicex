# Azure DevOps Pipeline Setup Guide

**Author**: Roberto  
**Version**: 1.0.0  
**Date**: December 2024

---

## Overview

This guide explains how to set up and configure the Azure DevOps pipeline for deploying your Bicep infrastructure. The pipeline is fully automated with 4 stages:

1. **Validate** - Validates Bicep syntax
2. **Test** - Runs What-If analysis
3. **Deploy** - Deploys to production
4. **Post-Deployment** - Verifies and reports

---

## Prerequisites

Before starting, ensure you have:

- ✅ Azure DevOps organization and project created
- ✅ GitHub repository with Bicep files
- ✅ Azure subscription with appropriate permissions
- ✅ Resource group `RGAUANSDeploy` created
- ✅ Virtual network `vnetausclient` in `RGAUSNetCh`
- ✅ NSG `nsgauejit` in `RGAUSNetCh`

---

## Step 1: Create Service Connection

### 1.1 Navigate to Service Connections

1. Go to your Azure DevOps project: https://dev.azure.com/soydevops/AnsibleDeploy
2. Click **Project Settings** (bottom left)
3. Select **Service connections** under Pipelines

### 1.2 Create New Service Connection

1. Click **Create service connection** (top right)
2. Select **Azure Resource Manager**
3. Click **Next**

### 1.3 Configure Service Connection

1. **Authentication method**: Select "Service principal (automatic)"
2. **Scope level**: Select "Subscription"
3. **Subscription**: Select your subscription
4. **Resource group**: Select `RGAUANSDeploy`
5. **Service connection name**: Enter `AzureServiceConnection`
6. Click **Save**

### 1.4 Verify Service Connection

```bash
# In Azure DevOps, test the connection
# The system will verify it can authenticate to Azure
```

---

## Step 2: Create Variable Group

### 2.1 Navigate to Variable Groups

1. Go to **Pipelines** > **Library** > **Variable groups**
2. Click **+ Variable group**

### 2.2 Create Group

1. **Name**: `bicep-deployment-secrets`
2. **Description**: "Secrets and variables for Bicep deployment"
3. Leave "Link secrets from an Azure key vault" unchecked for now
4. Click **Save**

### 2.3 Add Variables

Click **+ Add** and add these variables:

#### Non-Sensitive Variables (Uncheck "Secret")

| Variable Name | Value | Example |
|---------------|-------|---------|
| RESOURCE_GROUP_NAME | Your resource group | RGAUANSDeploy |
| LOCATION | Azure region | australiaeast |
| VM_NAME | VM name | vmauansvm01 |
| ADMIN_USERNAME | Admin username | roberto |
| KEY_VAULT_NAME | Key Vault name | kvaueansdeploy |
| SUBNET_NAME | Subnet name | misc |
| SERVICE_CONNECTION_NAME | Service connection name | AzureServiceConnection |

#### Sensitive Variables (Check "Secret" ✅)

| Variable Name | Value | Example |
|---------------|-------|---------|
| AZURE_SUBSCRIPTION_ID | Your subscription ID | f87077b9-ed2e-497d-876f-02c0a33e3774 |
| AZURE_TENANT_ID | Your tenant ID | 72f988bf-86f1-41af-91ab-2d7cd011db47 |
| PRINCIPAL_ID | Your principal ID | a1b2c3d4-e5f6-7890-abcd-ef1234567890 |
| KEY_VAULT_RESOURCE_ID | Full Key Vault resource ID | /subscriptions/.../vaults/kvaueansdeploy |
| VNET_RESOURCE_ID | Full vnet resource ID | /subscriptions/.../virtualNetworks/vnetausclient |
| NSG_RESOURCE_ID | Full NSG resource ID | /subscriptions/.../networkSecurityGroups/nsgauejit |
| ADMIN_PASSWORD | Strong password | P@ssw0rd123!XyZ |

### 2.4 Get Resource IDs

Use Azure CLI to get resource IDs:

```bash
# Get subscription ID
az account show --query id -o tsv

# Get tenant ID
az account show --query tenantId -o tsv

# Get principal ID
az ad signed-in-user show --query id -o tsv

# Get Key Vault resource ID
az resource show \
  --resource-group RGAUANSDeploy \
  --name kvaueansdeploy \
  --resource-type Microsoft.KeyVault/vaults \
  --query id -o tsv

# Get vnet resource ID
az resource show \
  --resource-group RGAUSNetCh \
  --name vnetausclient \
  --resource-type Microsoft.Network/virtualNetworks \
  --query id -o tsv

# Get NSG resource ID
az resource show \
  --resource-group RGAUSNetCh \
  --name nsgauejit \
  --resource-type Microsoft.Network/networkSecurityGroups \
  --query id -o tsv
```

### 2.5 Save Variable Group

Click **Save** to save the variable group.

---

## Step 3: Prepare Repository

### 3.1 Repository Structure

Ensure your repository has this structure:

```
azure-bicep-vm/
├── azure-pipelines.yml          ← Pipeline file (ROOT)
├── .gitignore
├── README.md
├── SECURITY_GUIDE.md
├── bicep/
│   ├── main-secure.bicep
│   ├── main-secure.bicepparam
│   ├── keyvault-secure.bicep
│   └── keyvault-secure.bicepparam
```

### 3.2 Copy Pipeline File

Copy the `azure-pipelines-final.yml` to your repository root as `azure-pipelines.yml`:

```bash
cp azure-pipelines-final.yml azure-pipelines.yml
```

### 3.3 Commit and Push

```bash
git add azure-pipelines.yml
git commit -m "Add Azure DevOps pipeline for Bicep deployment"
git push origin main
```

---

## Step 4: Create Pipeline in Azure DevOps

### 4.1 Navigate to Pipelines

1. Go to your Azure DevOps project
2. Click **Pipelines** (left sidebar)
3. Click **Create Pipeline** (or **New pipeline**)

### 4.2 Select Repository Source

1. Select **GitHub** as the repository source
2. Click **Authorize** if needed
3. Select your GitHub account
4. Select your repository: `YOUR_USERNAME/azure-bicep-vm`

### 4.3 Configure Pipeline

1. When asked "Configure your pipeline", select:
   - **Existing Azure Pipelines YAML file**

2. In the path selector:
   - **Branch**: `main`
   - **Path**: `/azure-pipelines.yml`

3. Click **Continue**

### 4.4 Review and Save

1. Review the pipeline YAML
2. Click **Save and run**
3. Select **Create a new branch for this commit** (optional)
4. Click **Save and run**

---

## Step 5: Link Variable Group to Pipeline

### 5.1 Edit Pipeline

1. Go to **Pipelines** > **Your Pipeline**
2. Click **Edit** (top right)

### 5.2 Link Variable Group

1. Click **Variables** (top right)
2. Click **Variable groups**
3. Click **Link variable group**
4. Select `bicep-deployment-secrets`
5. Click **Link**

### 5.3 Save Pipeline

1. Click **Save** (top right)
2. Select **Save** in the dialog

---

## Step 6: First Pipeline Run

### 6.1 Queue Pipeline

1. Go to **Pipelines** > **Your Pipeline**
2. Click **Run pipeline** (top right)
3. Select branch: `main`
4. Click **Run**

### 6.2 Monitor Execution

The pipeline will execute 4 stages:

1. **Validate** (5-10 minutes)
   - Installs .NET and Bicep CLI
   - Validates Bicep templates
   - Lints for best practices

2. **Test** (5-10 minutes)
   - Runs What-If analysis
   - Shows what resources will be created

3. **Deploy** (10-20 minutes)
   - Deploys Key Vault
   - Deploys Virtual Machine
   - Configures JIT access

4. **Post-Deployment** (5 minutes)
   - Verifies resources
   - Generates deployment report

### 6.3 View Logs

1. Click on each job to view detailed logs
2. Look for ✅ (success) or ❌ (failure) indicators
3. Check for error messages if deployment fails

---

## Step 7: Verify Deployment

### 7.1 Check Azure Portal

1. Go to Azure Portal
2. Navigate to resource group `RGAUANSDeploy`
3. Verify these resources exist:
   - Key Vault: `kvaueansdeploy`
   - Virtual Machine: `vmauansvm01`
   - Network Interface: `vmauansvm01-nic`
   - Public IP: `vmauansvm01-pip`

### 7.2 Get VM Details

```bash
# Get VM public IP
az vm show -d \
  --resource-group RGAUANSDeploy \
  --name vmauansvm01 \
  --query publicIps -o tsv

# Get VM private IP
az vm show -d \
  --resource-group RGAUANSDeploy \
  --name vmauansvm01 \
  --query privateIps -o tsv
```

### 7.3 Retrieve Admin Password

```bash
# Get password from Key Vault
az keyvault secret show \
  --vault-name kvaueansdeploy \
  --name vmAdminPassword \
  --query value -o tsv
```

### 7.4 Connect to VM

1. Get the public IP from step 7.2
2. Open Remote Desktop Connection (RDP)
3. Enter: `<PUBLIC_IP>`
4. Username: `roberto`
5. Password: (from step 7.3)

---

## Troubleshooting

### Issue: Pipeline Not Found

**Error**: "The path 'azure-pipelines.yml' does not exist in the repository"

**Solution**:
1. Verify file is in repository root: `ls -la azure-pipelines.yml`
2. Verify file is committed: `git ls-files | grep azure-pipelines.yml`
3. Push latest changes: `git push origin main`
4. Try creating pipeline again

### Issue: Variable Group Not Linked

**Error**: "Variable group not found" during pipeline execution

**Solution**:
1. Go to **Pipelines** > **Your Pipeline** > **Edit**
2. Click **Variables** > **Variable groups**
3. Click **Link variable group**
4. Select `bicep-deployment-secrets`
5. Click **Link**
6. Click **Save**

### Issue: Service Connection Failed

**Error**: "Failed to authenticate with Azure"

**Solution**:
1. Go to **Project Settings** > **Service connections**
2. Click on `AzureServiceConnection`
3. Click **Edit**
4. Click **Verify connection**
5. If it fails, delete and recreate the connection

### Issue: Validation Stage Fails

**Error**: "Bicep validation failed"

**Solution**:
1. Check Bicep files for syntax errors
2. Run locally: `az bicep build --file bicep/main-secure.bicep`
3. Fix any errors in the Bicep files
4. Commit and push changes
5. Re-run pipeline

### Issue: What-If Stage Fails

**Error**: "What-If analysis failed"

**Solution**:
1. Check variable values are correct
2. Verify resource IDs are valid
3. Ensure resource group exists
4. Check service connection has permissions

### Issue: Deployment Stage Fails

**Error**: "Deployment failed"

**Solution**:
1. Check Key Vault can be created (name must be unique)
2. Verify resource group exists
3. Check admin password meets complexity requirements
4. Review detailed error message in logs

---

## Pipeline Customization

### Change Trigger Branch

Edit `azure-pipelines.yml`:

```yaml
trigger:
  branches:
    include:
      - main          # Change this
      - develop       # Or add more branches
```

### Change Deployment Mode

Edit the `deploymentMode` variable:

```yaml
variables:
  deploymentMode: 'Incremental'  # or 'Complete'
```

- **Incremental**: Only creates/updates specified resources
- **Complete**: Deletes resources not in template (use with caution!)

### Add Approval Gate

Add approval before production deployment:

1. Go to **Pipelines** > **Your Pipeline** > **Edit**
2. Click **Environments** (in the pipeline)
3. Click **Production**
4. Click **Approvals and checks**
5. Click **+ Approvals**
6. Add approvers
7. Click **Create**

---

## Best Practices

### 1. Use Variable Groups for Secrets
✅ Store all secrets in Variable Groups  
❌ Never hardcode secrets in YAML

### 2. Mark Sensitive Variables as Secret
✅ Check "Secret" for passwords and IDs  
❌ Don't leave sensitive values as plain text

### 3. Use What-If Before Deploy
✅ Always review What-If analysis  
❌ Don't skip the Test stage

### 4. Monitor Pipeline Execution
✅ Check logs for warnings and errors  
❌ Don't ignore failed stages

### 5. Document Changes
✅ Write meaningful commit messages  
❌ Don't commit without description

### 6. Test Locally First
✅ Validate Bicep locally before pushing  
❌ Don't rely only on pipeline validation

### 7. Regular Password Rotation
✅ Rotate admin password every 60-90 days  
❌ Don't use the same password forever

---

## Maintenance

### Weekly
- Monitor pipeline execution logs
- Check for any warnings
- Verify VM is running

### Monthly
- Review Key Vault access logs
- Check for unauthorized access attempts
- Update documentation if needed

### Quarterly
- Rotate admin password
- Review and update Bicep templates
- Test disaster recovery procedures

### Annually
- Review security settings
- Update to latest Bicep syntax
- Plan infrastructure upgrades

---

## Support

For issues or questions:

1. Check **SECURITY_GUIDE.md** for security questions
2. Check **README.md** for general information
3. Check **SETUP_GUIDE.md** for development setup
4. Review pipeline logs for specific errors
5. Consult Azure DevOps documentation

---

## Next Steps

1. ✅ Create service connection
2. ✅ Create variable group
3. ✅ Prepare repository
4. ✅ Create pipeline
5. ✅ Link variable group
6. ✅ Run first pipeline
7. ✅ Verify deployment
8. ✅ Connect to VM
9. ✅ Configure JIT access
10. ✅ Set up monitoring

You're now ready to deploy infrastructure with Bicep and Azure DevOps! 🚀
