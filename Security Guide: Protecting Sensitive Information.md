# Security Guide: Protecting Sensitive Information

**Author**: Roberto  
**Version**: 1.0.0  
**Last Updated**: December 2024

---

## Overview

This guide explains how to safely manage sensitive information when deploying infrastructure with Bicep and Azure DevOps. **Never commit secrets to Git repositories.**

---

## Critical Security Principles

### 🔴 NEVER DO THIS

```bash
# ❌ DO NOT hardcode subscription IDs in code
param subscriptionId = 'f87077b9-ed2e-497d-876f-02c0a33e3774'

# ❌ DO NOT hardcode resource group names
param resourceGroup = 'RGAUANSDeploy'

# ❌ DO NOT hardcode passwords
param adminPassword = 'MyPassword123!'

# ❌ DO NOT commit parameter files with actual values
git add main.bicepparam  # WRONG!

# ❌ DO NOT include secrets in pipeline YAML
variables:
  ADMIN_PASSWORD: 'MyPassword123!'  # WRONG!
```

### ✅ DO THIS INSTEAD

```bash
# ✅ Use parameter placeholders
param subscriptionId string  # Provided at deployment time

# ✅ Use environment variables
export SUBSCRIPTION_ID='f87077b9-ed2e-497d-876f-02c0a33e3774'
az deployment group create --parameters subscriptionId=$SUBSCRIPTION_ID

# ✅ Use Azure DevOps secret variables
# Define in Pipeline > Library > Variable groups

# ✅ Add parameter files to .gitignore
echo "*.bicepparam" >> .gitignore

# ✅ Use secure input for passwords
read -s -p "Enter password: " ADMIN_PASSWORD
```

---

## Sensitive Information Categories

### Subscription-Level Secrets

| Item | Example | Risk Level | Storage |
|------|---------|-----------|---------|
| Subscription ID | f87077b9-ed2e-497d-876f-02c0a33e3774 | 🔴 HIGH | Azure DevOps Secret Variable |
| Tenant ID | 72f988bf-86f1-41af-91ab-2d7cd011db47 | 🔴 HIGH | Azure DevOps Secret Variable |
| Principal ID | a1b2c3d4-e5f6-7890-abcd-ef1234567890 | 🟡 MEDIUM | Azure DevOps Variable |

### Resource-Level Secrets

| Item | Example | Risk Level | Storage |
|------|---------|-----------|---------|
| Resource Group Name | RGAUANSDeploy | 🟡 MEDIUM | Azure DevOps Variable |
| Key Vault Name | kvaueansdeploy | 🟡 MEDIUM | Azure DevOps Variable |
| VM Admin Password | P@ssw0rd123!XyZ | 🔴 HIGH | Azure Key Vault |
| Resource IDs | /subscriptions/.../resourceGroups/... | 🟡 MEDIUM | Azure DevOps Variable |

### Network-Level Secrets

| Item | Example | Risk Level | Storage |
|------|---------|-----------|---------|
| Virtual Network ID | /subscriptions/.../virtualNetworks/vnet | 🟡 MEDIUM | Azure DevOps Variable |
| NSG ID | /subscriptions/.../networkSecurityGroups/nsg | 🟡 MEDIUM | Azure DevOps Variable |
| Public IP Address | 203.0.113.42 | 🟡 MEDIUM | Deployment Output Only |

---

## File Organization

### Safe to Commit ✅

```
repository/
├── bicep/
│   ├── main-secure.bicep           ✅ Safe (no secrets)
│   ├── main-secure.bicepparam      ✅ Safe (template with placeholders)
│   ├── keyvault-secure.bicep       ✅ Safe (no secrets)
│   └── keyvault-secure.bicepparam  ✅ Safe (template with placeholders)
├── azure-pipelines-secure.yml      ✅ Safe (uses variables)
├── README.md                       ✅ Safe (documentation)
├── SECURITY_GUIDE.md               ✅ Safe (documentation)
└── .gitignore                      ✅ Safe (configuration)
```

### NOT Safe to Commit ❌

```
repository/
├── main.bicepparam                 ❌ NEVER commit (has actual values)
├── keyvault.bicepparam             ❌ NEVER commit (has actual values)
├── .env                            ❌ NEVER commit (environment variables)
├── credentials.json                ❌ NEVER commit (credentials)
└── secrets.txt                     ❌ NEVER commit (secrets)
```

---

## Setup Instructions

### Step 1: Create .gitignore

```bash
# Copy the template
cp .gitignore-template .gitignore

# Add to your repository
git add .gitignore
git commit -m "Add .gitignore to prevent secret leaks"
```

### Step 2: Create Parameter Files from Templates

```bash
# Copy secure templates to working files
cp bicep/main-secure.bicepparam bicep/main.bicepparam
cp bicep/keyvault-secure.bicepparam bicep/keyvault.bicepparam

# Fill in actual values in the copied files
# These files are ignored by Git
```

### Step 3: Set Up Azure DevOps Secret Variables

#### Create Variable Group

1. Go to **Pipelines** > **Library** > **Variable groups**
2. Click **+ Variable group**
3. Name it: `bicep-deployment-secrets`
4. Add the following variables:

| Variable Name | Value | Secret? |
|---------------|-------|---------|
| AZURE_SUBSCRIPTION_ID | Your subscription ID | ✅ Yes |
| RESOURCE_GROUP_NAME | RGAUANSDeploy | ❌ No |
| LOCATION | australiaeast | ❌ No |
| VM_NAME | vmauansvm01 | ❌ No |
| KEY_VAULT_NAME | kvaueansdeploy | ❌ No |
| PRINCIPAL_ID | Your principal ID | ✅ Yes |
| ADMIN_PASSWORD | Strong password | ✅ Yes |
| VNET_RESOURCE_ID | Full resource ID | ✅ Yes |
| NSG_RESOURCE_ID | Full resource ID | ✅ Yes |

5. Click **Save**

#### Link Variable Group to Pipeline

1. Go to **Pipelines** > **Your Pipeline** > **Edit**
2. Click **Variables** > **Variable groups** > **Link variable group**
3. Select `bicep-deployment-secrets`
4. Click **Link**

### Step 4: Update Pipeline YAML

Use the `azure-pipelines-secure.yml` file which references variables:

```yaml
variables:
  - group: 'bicep-deployment-secrets'
```

### Step 5: Local Development Setup

Create a local environment file (NOT committed to Git):

```bash
# Create local environment file
cat > .env.local << 'EOF'
export AZURE_SUBSCRIPTION_ID="f87077b9-ed2e-497d-876f-02c0a33e3774"
export RESOURCE_GROUP_NAME="RGAUANSDeploy"
export LOCATION="australiaeast"
export VM_NAME="vmauansvm01"
export KEY_VAULT_NAME="kvaueansdeploy"
export PRINCIPAL_ID="your-principal-id"
EOF

# Add to .gitignore
echo ".env.local" >> .gitignore

# Source before deployment
source .env.local
```

---

## Deployment Methods

### Method 1: Azure DevOps Pipeline (Recommended for Production)

**Advantages:**
- Secrets stored securely in Azure DevOps
- Audit trail of deployments
- No local secrets
- Automated deployments

**Process:**
1. Push code to main branch
2. Pipeline triggers automatically
3. Variables injected from secret group
4. Deployment runs with secrets

### Method 2: Local Deployment (Development Only)

**Advantages:**
- Fast iteration
- Easy testing
- Full control

**Process:**

```bash
# 1. Get your principal ID
PRINCIPAL_ID=$(az ad signed-in-user show --query id -o tsv)

# 2. Get resource IDs
VNET_ID=$(az resource show --resource-group RGAUSNetCh --name vnetausclient \
  --resource-type Microsoft.Network/virtualNetworks --query id -o tsv)

NSG_ID=$(az resource show --resource-group RGAUSNetCh --name nsgauejit \
  --resource-type Microsoft.Network/networkSecurityGroups --query id -o tsv)

# 3. Deploy Key Vault (password input is hidden)
read -s -p "Enter admin password: " ADMIN_PASSWORD
echo

az deployment group create \
  --resource-group RGAUANSDeploy \
  --template-file bicep/keyvault-secure.bicep \
  --parameters bicep/keyvault.bicepparam \
  --parameters principalId=$PRINCIPAL_ID \
  --parameters adminPassword=$ADMIN_PASSWORD \
  --name 'DeployKeyVault'

# 4. Deploy VM
az deployment group create \
  --resource-group RGAUANSDeploy \
  --template-file bicep/main-secure.bicep \
  --parameters bicep/main.bicepparam \
  --parameters vnetResourceId=$VNET_ID \
  --parameters nsgResourceId=$NSG_ID \
  --name 'DeployVM'
```

### Method 3: Azure CLI with Secure Input

```bash
# Secure password input (not visible in terminal)
read -s -p "Enter admin password: " ADMIN_PASSWORD

# Deploy with secure password
az deployment group create \
  --resource-group RGAUANSDeploy \
  --template-file bicep/keyvault-secure.bicep \
  --parameters bicep/keyvault.bicepparam \
  --parameters adminPassword=$ADMIN_PASSWORD
```

---

## Checking for Secrets in Git

### Before Committing

```bash
# Check for common secret patterns
git diff --cached | grep -i "password\|secret\|key\|token"

# Check for subscription IDs
git diff --cached | grep -E "[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}"
```

### If You Accidentally Committed Secrets

```bash
# 1. Immediately rotate the exposed secret
az keyvault secret set --vault-name kvaueansdeploy --name vmAdminPassword --value <NEW_PASSWORD>

# 2. Remove from Git history (use BFG Repo-Cleaner)
# https://rtyley.github.io/bfg-repo-cleaner/

# 3. Force push (DANGEROUS - only if you own the repo)
git push --force-with-lease

# 4. Notify your team
# 5. Audit access logs
```

---

## Monitoring and Auditing

### Enable Key Vault Logging

```bash
# Enable diagnostic logging
az monitor diagnostic-settings create \
  --name KeyVaultDiagnostics \
  --resource /subscriptions/<SUBSCRIPTION_ID>/resourceGroups/RGAUANSDeploy/providers/Microsoft.KeyVault/vaults/kvaueansdeploy \
  --logs '[{"category":"AuditEvent","enabled":true}]' \
  --workspace /subscriptions/<SUBSCRIPTION_ID>/resourceGroups/RGAUANSDeploy/providers/Microsoft.OperationalInsights/workspaces/myworkspace
```

### Review Access Logs

```bash
# View Key Vault access logs
az monitor log-analytics query \
  --workspace <WORKSPACE_ID> \
  --analytics-query "AzureDiagnostics | where ResourceType == 'VAULTS' | project TimeGenerated, OperationName, CallerIPAddress"
```

### Set Up Alerts

```bash
# Alert on suspicious Key Vault access
az monitor metrics alert create \
  --name KeyVaultAccessAlert \
  --resource-group RGAUANSDeploy \
  --scopes /subscriptions/<SUBSCRIPTION_ID>/resourceGroups/RGAUANSDeploy/providers/Microsoft.KeyVault/vaults/kvaueansdeploy \
  --condition "total KeyVaultAccessCount > 100 in 5m"
```

---

## Incident Response

### If Secrets Are Exposed

**Immediate Actions:**
1. ⏱️ **Within 5 minutes**: Rotate the exposed secret
2. 📋 **Within 15 minutes**: Notify security team
3. 🔍 **Within 1 hour**: Audit access logs
4. 🔐 **Within 1 hour**: Review who had access
5. 📝 **Within 24 hours**: Document incident

### Rotation Process

```bash
# 1. Generate new password
NEW_PASSWORD=$(openssl rand -base64 32)

# 2. Update in Key Vault
az keyvault secret set \
  --vault-name kvaueansdeploy \
  --name vmAdminPassword \
  --value "$NEW_PASSWORD"

# 3. Update VM password
az vm user update \
  --resource-group RGAUANSDeploy \
  --name vmauansvm01 \
  --username roberto \
  --password "$NEW_PASSWORD"

# 4. Verify new password works
# Test RDP connection with new credentials

# 5. Document in incident log
echo "Password rotated at $(date)" >> incident_log.txt
```

---

## Best Practices Summary

| Practice | Why | How |
|----------|-----|-----|
| Use Variable Groups | Centralized secret management | Azure DevOps Library |
| Mark as Secret | Prevents logging | Check "Secret" checkbox |
| Use .gitignore | Prevents accidental commits | Copy .gitignore-template |
| Rotate Regularly | Reduces exposure | Every 60-90 days |
| Audit Access | Detect unauthorized access | Enable Key Vault logging |
| Use Secure Input | Passwords not visible | `read -s` command |
| Document Procedures | Team alignment | This guide |
| Test Locally First | Catch errors early | Use what-if analysis |

---

## References

- [Azure Key Vault Security Best Practices](https://learn.microsoft.com/en-us/azure/key-vault/general/security-features)
- [Azure DevOps Secret Variables](https://learn.microsoft.com/en-us/azure/devops/pipelines/process/variables?view=azure-devops&tabs=yaml%2Cbatch#secret-variables)
- [Git Security - Removing Sensitive Data](https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/removing-sensitive-data-from-a-repository)
- [OWASP: Secrets Management](https://cheatsheetseries.owasp.org/cheatsheets/Secrets_Management_Cheat_Sheet.html)

---

## Questions?

Refer to the main `blog-post.md` or `README.md` for additional guidance.

**Remember: Security is everyone's responsibility. When in doubt, ask before committing.**
