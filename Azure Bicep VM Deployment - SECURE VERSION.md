# Azure Bicep VM Deployment - SECURE VERSION

**⚠️ CRITICAL SECURITY UPDATE**: This version removes all hardcoded sensitive information.

## What Changed

### Old (Insecure) Files ❌
- `main.bicep` - Had hardcoded subscription IDs and resource IDs
- `main.bicepparam` - Had actual values
- `keyvault.bicep` - Had hardcoded values
- `keyvault.bicepparam` - Had actual values
- `azure-pipelines.yml` - Had hardcoded variables

### New (Secure) Files ✅
- `main-secure.bicep` - All values parameterized
- `main-secure.bicepparam` - Template with placeholders only
- `keyvault-secure.bicep` - All values parameterized
- `keyvault-secure.bicepparam` - Template with placeholders only
- `azure-pipelines-secure.yml` - Uses Azure DevOps secret variables
- `SECURITY_GUIDE.md` - Complete security documentation
- `.gitignore-template` - Prevents accidental secret commits

---

## Key Security Features

### 1. No Hardcoded Secrets
✅ Subscription IDs are parameterized  
✅ Resource IDs are parameterized  
✅ Passwords are never in code  
✅ Principal IDs are parameterized  

### 2. Environment Variables
✅ All sensitive values passed at deployment time  
✅ Secrets stored in Azure DevOps Variable Groups  
✅ Local development uses .env files (not committed)  

### 3. Secure Parameter Files
✅ Template files with placeholders provided  
✅ Actual parameter files added to .gitignore  
✅ Clear instructions on safe parameter management  

### 4. Pipeline Security
✅ Uses Azure DevOps secret variables  
✅ No secrets in YAML files  
✅ Secure password input for local deployments  

---

## Quick Start (Secure)

### Step 1: Clone Repository

```bash
git clone <YOUR_REPO>
cd azure-bicep-vm
```

### Step 2: Set Up .gitignore

```bash
# Copy the template
cp .gitignore-template .gitignore

# Verify it's in Git
git add .gitignore
git commit -m "Add .gitignore to prevent secret leaks"
```

### Step 3: Create Parameter Files

```bash
# Copy templates to working files (these will be ignored by Git)
cp bicep/main-secure.bicepparam bicep/main.bicepparam
cp bicep/keyvault-secure.bicepparam bicep/keyvault.bicepparam

# Edit with your actual values (NOT committed to Git)
nano bicep/main.bicepparam
nano bicep/keyvault.bicepparam
```

### Step 4: Set Up Azure DevOps

1. Go to **Pipelines** > **Library** > **Variable groups**
2. Create group: `bicep-deployment-secrets`
3. Add variables (mark sensitive ones as Secret):
   - AZURE_SUBSCRIPTION_ID (Secret)
   - RESOURCE_GROUP_NAME
   - LOCATION
   - VM_NAME
   - KEY_VAULT_NAME
   - PRINCIPAL_ID (Secret)
   - ADMIN_PASSWORD (Secret)
   - VNET_RESOURCE_ID (Secret)
   - NSG_RESOURCE_ID (Secret)

### Step 5: Deploy

```bash
# Use the secure pipeline
# Push to main branch to trigger deployment
git add azure-pipelines-secure.yml
git commit -m "Add secure pipeline configuration"
git push origin main
```

---

## File Comparison

| Aspect | Old Files | New Files |
|--------|-----------|-----------|
| Subscription ID | Hardcoded ❌ | Parameterized ✅ |
| Resource Group | Hardcoded ❌ | Variable ✅ |
| Resource IDs | Hardcoded ❌ | Parameterized ✅ |
| Passwords | In code ❌ | Never in code ✅ |
| Parameter Files | Committed ❌ | In .gitignore ✅ |
| Pipeline Variables | Hardcoded ❌ | Secret variables ✅ |

---

## Security Best Practices Implemented

### 1. Principle of Least Privilege
- Only required variables are exposed
- Sensitive variables marked as Secret
- Access controlled through Azure DevOps

### 2. Defense in Depth
- Multiple layers of security
- .gitignore prevents accidental commits
- Azure DevOps secret variables for production
- Secure input for local deployments

### 3. Audit Trail
- All deployments logged in Azure DevOps
- Key Vault access logged
- Changes tracked in Git

### 4. Secure by Default
- Template files contain no secrets
- Placeholders guide users
- Clear documentation provided

---

## Files to Commit to Git

✅ **Safe to commit:**
- `main-secure.bicep`
- `main-secure.bicepparam` (template version)
- `keyvault-secure.bicep`
- `keyvault-secure.bicepparam` (template version)
- `azure-pipelines-secure.yml`
- `.gitignore`
- `SECURITY_GUIDE.md`
- `README-SECURE.md`
- `*.md` (all documentation)

❌ **NEVER commit:**
- `main.bicepparam` (actual values)
- `keyvault.bicepparam` (actual values)
- `.env` files
- `credentials.json`
- Any file with passwords or secrets

---

## Local Development Setup

### Create Local Environment File

```bash
# Create .env.local (NOT committed)
cat > .env.local << 'EOF'
export AZURE_SUBSCRIPTION_ID="your-subscription-id"
export RESOURCE_GROUP_NAME="RGAUANSDeploy"
export LOCATION="australiaeast"
export VM_NAME="vmauansvm01"
export KEY_VAULT_NAME="kvaueansdeploy"
export PRINCIPAL_ID="your-principal-id"
export VNET_RESOURCE_ID="/subscriptions/.../virtualNetworks/vnetausclient"
export NSG_RESOURCE_ID="/subscriptions/.../networkSecurityGroups/nsgauejit"
EOF

# Add to .gitignore
echo ".env.local" >> .gitignore

# Source before deployment
source .env.local
```

### Deploy Locally (Development Only)

```bash
# Source environment
source .env.local

# Validate
az bicep build --file bicep/main-secure.bicep

# What-If
az deployment group what-if \
  --resource-group $RESOURCE_GROUP_NAME \
  --template-file bicep/main-secure.bicep \
  --parameters bicep/main.bicepparam

# Deploy
read -s -p "Enter admin password: " ADMIN_PASSWORD
az deployment group create \
  --resource-group $RESOURCE_GROUP_NAME \
  --template-file bicep/main-secure.bicep \
  --parameters bicep/main.bicepparam \
  --parameters adminPassword=$ADMIN_PASSWORD
```

---

## Checking Your Repository

### Verify No Secrets Are Committed

```bash
# Check for common patterns
git log -p | grep -i "password\|secret\|key\|token" | head -20

# Check for subscription IDs
git log -p | grep -E "[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}"

# Check file sizes (large files might contain secrets)
git ls-files -s | sort -k4 -n | tail -10
```

### If You Find Secrets

1. **Immediately rotate** the exposed secret
2. **Remove from history** using BFG Repo-Cleaner
3. **Force push** (only if you own the repo)
4. **Notify team** and security

See `SECURITY_GUIDE.md` for detailed incident response.

---

## Migration from Old Files

If you were using the old insecure files:

```bash
# 1. Back up old files
cp main.bicep main.bicep.backup
cp main.bicepparam main.bicepparam.backup

# 2. Use new secure files
mv main-secure.bicep main.bicep
mv main-secure.bicepparam main.bicepparam
mv keyvault-secure.bicep keyvault.bicep
mv keyvault-secure.bicepparam keyvault.bicepparam

# 3. Update .gitignore
cp .gitignore-template .gitignore

# 4. Remove old files from Git history
git rm --cached *.bicepparam
git commit -m "Remove parameter files with secrets"

# 5. Update pipeline
rm azure-pipelines.yml
mv azure-pipelines-secure.yml azure-pipelines.yml

# 6. Push changes
git push origin main
```

---

## Documentation

For complete security guidance, see:
- **SECURITY_GUIDE.md** - Detailed security procedures
- **blog-post.md** - Complete deployment tutorial
- **SETUP_GUIDE.md** - Development environment setup
- **CHEAT_SHEET.md** - Common commands reference

---

## Support

### Common Questions

**Q: Can I commit my parameter files?**  
A: No. Add them to .gitignore. Only commit template versions with placeholders.

**Q: How do I pass secrets to the pipeline?**  
A: Use Azure DevOps Variable Groups. Mark sensitive variables as "Secret".

**Q: What if I accidentally committed a secret?**  
A: See "Incident Response" in SECURITY_GUIDE.md. Rotate immediately.

**Q: Can I use environment variables locally?**  
A: Yes. Create .env.local (add to .gitignore) and source it before deployment.

**Q: How often should I rotate passwords?**  
A: Every 60-90 days minimum. More frequently for high-security environments.

---

## Checklist Before First Deployment

- [ ] Cloned repository
- [ ] Copied .gitignore-template to .gitignore
- [ ] Copied parameter templates to working files
- [ ] Updated parameter files with actual values
- [ ] Verified parameter files are in .gitignore
- [ ] Created Azure DevOps variable group
- [ ] Added all required variables to variable group
- [ ] Marked sensitive variables as Secret
- [ ] Updated pipeline to use azure-pipelines-secure.yml
- [ ] Tested locally with what-if analysis
- [ ] Verified no secrets in Git history
- [ ] Ready to deploy!

---

## Next Steps

1. Read **SECURITY_GUIDE.md** for detailed security procedures
2. Follow **blog-post.md** for complete deployment tutorial
3. Use **CHEAT_SHEET.md** for common commands
4. Deploy with confidence knowing your secrets are protected!

---

**Remember: Security is not optional. Treat every secret as if it could compromise your entire infrastructure.**
