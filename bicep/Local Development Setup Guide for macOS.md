# Local Development Setup Guide for macOS

This guide walks you through setting up your development environment on macOS to work with Bicep templates and Azure DevOps.

## Prerequisites

Ensure you have the following installed:
- macOS 10.15 or later
- Homebrew (optional but recommended)
- Administrator access to your machine

## Step 1: Install Required Tools

### Install Homebrew (Optional)

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

### Install Git

Using Homebrew:
```bash
brew install git
```

Or download from: https://git-scm.com/download/mac

Verify installation:
```bash
git --version
```

### Install Azure CLI

Using Homebrew:
```bash
brew install azure-cli
```

Or download from: https://docs.microsoft.com/en-us/cli/azure/install-azure-cli-macos

Verify installation:
```bash
az --version
```

### Install Visual Studio Code

Download from: https://code.visualstudio.com/Download

Or using Homebrew:
```bash
brew install --cask visual-studio-code
```

### Install .NET 7 SDK (Required for Bicep)

Using Homebrew:
```bash
brew install dotnet
```

Or download from: https://dotnet.microsoft.com/download/dotnet/7.0

Verify installation:
```bash
dotnet --version
```

## Step 2: Configure Azure CLI

### Login to Azure

```bash
az login
```

This will open a browser window for authentication. Sign in with your Azure account.

### Set Default Subscription

```bash
az account set --subscription f87077b9-ed2e-497d-876f-02c0a33e3774
```

### Verify Configuration

```bash
az account show
```

## Step 3: Install Bicep CLI

```bash
az bicep install
```

Verify installation:
```bash
az bicep version
```

## Step 4: Configure Visual Studio Code

### Install Extensions

1. Open VS Code
2. Go to **Extensions** (Cmd+Shift+X)
3. Search for and install:
   - **Bicep** (by Microsoft)
   - **Azure Tools** (by Microsoft)
   - **Azure Account** (by Microsoft)
   - **GitHub Copilot** (optional, for AI assistance)
   - **GitLens** (optional, for Git integration)

### Configure VS Code Settings

1. Open **Preferences** > **Settings** (Cmd+,)
2. Search for "bicep"
3. Ensure Bicep extension is properly configured
4. Optionally, set up formatting on save:
   - Search for "Format on Save"
   - Enable the option

### Create VS Code Workspace Settings

Create a `.vscode/settings.json` file in your project root:

```json
{
  "[bicep]": {
    "editor.defaultFormatter": "ms-azuretools.vscode-bicep",
    "editor.formatOnSave": true,
    "editor.formatOnPaste": true
  },
  "[yaml]": {
    "editor.defaultFormatter": "esbenp.prettier-vscode",
    "editor.formatOnSave": true
  },
  "files.exclude": {
    "**/.git": true,
    "**/node_modules": true
  }
}
```

## Step 5: Clone the Repository

### Generate SSH Key (Recommended)

```bash
ssh-keygen -t ed25519 -C "your-email@example.com"
```

Press Enter for all prompts to use default settings.

### Add SSH Key to GitHub

1. Copy your public key:
   ```bash
   cat ~/.ssh/id_ed25519.pub | pbcopy
   ```

2. Go to GitHub Settings > SSH and GPG keys
3. Click "New SSH key"
4. Paste your public key and save

### Clone Repository

```bash
git clone git@github.com:YOUR_USERNAME/azure-bicep-vm.git
cd azure-bicep-vm
```

## Step 6: Local Validation Workflow

### Validate Bicep Files

Before pushing changes, validate locally:

```bash
# Validate Key Vault template
az bicep build --file bicep/keyvault.bicep --outfile keyvault.json

# Validate VM template
az bicep build --file bicep/main.bicep --outfile main.json
```

### Run What-If Locally

To preview changes without applying them:

```bash
# What-If for Key Vault
az deployment group what-if \
  --resource-group RGAUANSDeploy \
  --template-file bicep/keyvault.bicep \
  --parameters bicep/keyvault.bicepparam

# What-If for VM
az deployment group what-if \
  --resource-group RGAUANSDeploy \
  --template-file bicep/main.bicep \
  --parameters bicep/main.bicepparam
```

## Step 7: Git Workflow

### Create a Feature Branch

```bash
git checkout -b feature/your-feature-name
```

### Make Changes

Edit your Bicep files in VS Code. The extension will provide:
- Syntax highlighting
- IntelliSense
- Error checking
- Formatting

### Commit Changes

```bash
# Stage changes
git add .

# Commit with descriptive message
git commit -m "Add description of changes"

# Push to GitHub
git push origin feature/your-feature-name
```

### Create Pull Request

1. Go to your GitHub repository
2. Click "Compare & pull request"
3. Add description of changes
4. Request review
5. Wait for Azure DevOps pipeline to run
6. Merge after approval

## Step 8: Connect to Azure DevOps

### Install Azure DevOps Extension

```bash
az extension add --name azure-devops
```

### Configure Default Organization and Project

```bash
az devops configure --defaults organization=https://dev.azure.com/soydevops project=AnsibleDeploy
```

### View Pipeline Status

```bash
az pipelines build list --top 10
```

## Step 9: Daily Development Workflow

### Start Your Day

```bash
# Navigate to project
cd ~/Projects/azure-bicep-vm

# Update from main branch
git fetch origin
git pull origin main

# Create feature branch
git checkout -b feature/your-task
```

### During Development

1. Edit Bicep files in VS Code
2. Validate locally with `az bicep build`
3. Test with `az deployment group what-if`
4. Use Git to track changes

### End of Day

```bash
# Review changes
git status
git diff

# Commit work
git add .
git commit -m "WIP: Description of work in progress"

# Push to GitHub
git push origin feature/your-task
```

### When Ready to Submit

```bash
# Ensure latest main is merged
git fetch origin
git rebase origin/main

# Resolve any conflicts in VS Code
# Validate again
az bicep build --file bicep/main.bicep

# Force push (after rebase)
git push origin feature/your-task --force-with-lease

# Create/update pull request on GitHub
```

## Useful Commands Reference

### Azure CLI

```bash
# Login
az login

# List subscriptions
az account list --output table

# Set subscription
az account set --subscription <SUBSCRIPTION_ID>

# List resource groups
az group list --output table

# List VMs
az vm list --resource-group RGAUANSDeploy --output table

# Get VM details
az vm show -d --resource-group RGAUANSDeploy --name vmauansvm01

# Get public IP
az vm show -d --resource-group RGAUANSDeploy --name vmauansvm01 --query publicIps -o tsv
```

### Bicep

```bash
# Validate Bicep file
az bicep build --file bicep/main.bicep

# Decompile ARM template to Bicep
az bicep decompile --file template.json

# Lint Bicep file (check for best practices)
az bicep lint --file bicep/main.bicep
```

### Git

```bash
# Check status
git status

# View changes
git diff

# View commit history
git log --oneline -10

# Undo last commit (before push)
git reset --soft HEAD~1

# Stash changes temporarily
git stash

# Apply stashed changes
git stash pop
```

## Troubleshooting

### Bicep Extension Not Working

**Solution**:
1. Ensure .NET SDK is installed: `dotnet --version`
2. Reinstall Bicep CLI: `az bicep install --target-platform osx-arm64` (for Apple Silicon)
3. Reload VS Code window: Cmd+Shift+P > "Reload Window"

### Git SSH Connection Issues

**Solution**:
1. Test SSH connection: `ssh -T git@github.com`
2. Ensure SSH key is added to ssh-agent: `ssh-add ~/.ssh/id_ed25519`
3. Verify key permissions: `chmod 600 ~/.ssh/id_ed25519`

### Azure CLI Authentication Fails

**Solution**:
1. Clear cached credentials: `az account clear`
2. Login again: `az login`
3. For service principal: `az login --service-principal -u <CLIENT_ID> -p <CLIENT_SECRET> --tenant <TENANT_ID>`

### VS Code Bicep Intellisense Not Working

**Solution**:
1. Ensure Bicep extension is enabled
2. Restart VS Code
3. Check extension logs: View > Output > Bicep

## Tips for Productive Development

1. **Use Keyboard Shortcuts**:
   - Cmd+Shift+P: Command palette
   - Cmd+K Cmd+F: Format document
   - Cmd+/: Toggle comment

2. **Leverage IntelliSense**:
   - Type `res-` to create a new resource
   - Type `param-` to create a parameter
   - Type `var-` to create a variable

3. **Use Git Aliases** (Optional):
   ```bash
   git config --global alias.st status
   git config --global alias.co checkout
   git config --global alias.br branch
   git config --global alias.ci commit
   ```

4. **Keep Branches Clean**:
   - Delete merged branches: `git branch -d feature/branch-name`
   - Sync fork with upstream regularly

5. **Review Before Pushing**:
   - Always run `az bicep build` before committing
   - Use `git diff` to review changes
   - Write meaningful commit messages

## Next Steps

1. Complete the main tutorial in `blog-post.md`
2. Set up your Azure DevOps service connection
3. Create your first pipeline run
4. Monitor the deployment in Azure portal

## Support

For issues or questions:
- Check the main `README.md`
- Review the `blog-post.md` tutorial
- Consult Microsoft documentation:
  - [Bicep Documentation](https://learn.microsoft.com/en-us/azure/azure-resource-manager/bicep/)
  - [Azure CLI Documentation](https://learn.microsoft.com/en-us/cli/azure/)
  - [VS Code Bicep Extension](https://marketplace.visualstudio.com/items?itemName=ms-azure-tools.bicep)
