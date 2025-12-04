# Azure SQL Server VM Deployment with Bicep and Azure DevOps

A complete, production-ready solution for deploying a Windows Server 2022 VM with SQL Server 2019 on Azure using Infrastructure as Code (Bicep), with CI/CD automation via Azure DevOps.

## Overview

This project provides an end-to-end tutorial and implementation for deploying secure, manageable Azure infrastructure. It includes:

- **Bicep Infrastructure as Code** for VM and Key Vault deployment
- **Azure DevOps CI/CD Pipeline** with validation, testing (what-if), and deployment stages
- **Azure Key Vault Integration** for secure credential storage
- **Just-In-Time (JIT) Access** configuration for enhanced security
- **GitHub Repository Integration** for source control
- **Automated Validation and Testing** before production deployment

## Project Structure

```
azure-bicep-vm/
├── bicep/
│   ├── main.bicep              # VM deployment template
│   ├── main.bicepparam         # VM parameters
│   ├── keyvault.bicep          # Key Vault template
│   └── keyvault.bicepparam     # Key Vault parameters
├── azure-pipelines.yml         # Azure DevOps pipeline configuration
├── github-actions-workflow.yml # Alternative GitHub Actions workflow
├── blog-post.md               # Complete tutorial documentation
└── README.md                  # This file
```

## Prerequisites

### Required Software

- **Azure CLI**: [Install Azure CLI](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli)
- **Visual Studio Code**: [Download VS Code](https://code.visualstudio.com/)
- **Bicep Extension for VS Code**: Install from the VS Code marketplace
- **Git**: [Install Git](https://git-scm.com/)

### Azure Requirements

- **Active Azure Subscription**: [Create a free account](https://azure.microsoft.com/en-us/free/)
- **Azure DevOps Organization**: [Create an organization](https://dev.azure.com/)
- **GitHub Account**: [Create a GitHub account](https://github.com/)
- **Resource Group**: `RGAUANSDeploy` (must be created in advance)
- **Virtual Network**: `vnetausclient` in resource group `RGAUSNetCh`
- **Network Security Group**: `nsgauejit` in resource group `RGAUSNetCh`
- **Subscription ID**: `f87077b9-ed2e-497d-876f-02c0a33e3774`

### Permissions Required

- **Azure**: Contributor or Owner role on the subscription
- **Azure DevOps**: Project Administrator
- **GitHub**: Repository admin access

## Quick Start

### 1. Clone the Repository

```bash
git clone <YOUR_GITHUB_REPO_URL>
cd azure-bicep-vm
```

### 2. Get Your Principal ID

```bash
az ad signed-in-user show --query id -o tsv
```

### 3. Update Parameter Files

Edit `bicep/keyvault.bicepparam` and replace:
- `<YOUR_PRINCIPAL_ID>`: Use the value from step 2
- `<SECURE_PASSWORD_HERE>`: Use a strong password

### 4. Create Azure DevOps Service Connection

In Azure DevOps:
1. Go to **Project Settings** > **Service Connections**
2. Create new **Azure Resource Manager** service connection
3. Name it `AzureServiceConnection`

### 5. Create Pipeline in Azure DevOps

1. Go to **Pipelines** > **Create Pipeline**
2. Select **GitHub** as source
3. Select your repository
4. Choose **Existing Azure Pipelines YAML file**
5. Point to `/azure-pipelines.yml`
6. Click **Run**

## Deployment Process

### Stage 1: Validate
- Compiles Bicep files to ARM templates
- Validates syntax and structure
- Publishes artifacts

### Stage 2: Test (What-If)
- Runs `az deployment group what-if` for both Key Vault and VM
- Shows what resources will be created/modified
- Does NOT apply any changes

### Stage 3: Deploy to Production
- Deploys Key Vault (with admin password secret)
- Deploys Virtual Machine
- Configures JIT access settings

### Stage 4: Post-Deployment
- Verifies all resources were created successfully
- Generates deployment report
- Outputs VM connection details

## Configuration Details

### Virtual Machine Specifications

| Property | Value |
|----------|-------|
| Image | MicrosoftSQLServer:sql2019-ws2022:web:latest |
| Size | Standard_B2s_v2 |
| OS Disk | Premium_LRS (256 GB) |
| Admin Username | roberto |
| Location | australiaeast |

### Network Configuration

| Resource | Name | Resource Group |
|----------|------|-----------------|
| Virtual Network | vnetausclient | RGAUSNetCh |
| Subnet | misc | RGAUSNetCh |
| NSG | nsgauejit | RGAUSNetCh |
| Public IP | vmauansvm01-pip | RGAUANSDeploy |
| NIC | vmauansvm01-nic | RGAUANSDeploy |

### Key Vault Configuration

| Property | Value |
|----------|-------|
| Name | kvaueansdeploy |
| SKU | Standard |
| Soft Delete | Enabled (90 days) |
| Purge Protection | Enabled |
| Secret Name | vmAdminPassword |
| Secret Expiry | 365 days |

## Just-In-Time (JIT) Access

### Requirements

- **Microsoft Defender for Servers Plan 2** must be enabled on the subscription
- **Network Security Group** must be configured (already done with `nsgauejit`)
- **Reader** and **SecurityReader** permissions to view JIT status

### Enabling JIT

1. Navigate to **Microsoft Defender for Cloud** in Azure Portal
2. Go to **Workload protections** > **Just-in-time VM access**
3. Find `vmauansvm01` in the "Not configured" tab
4. Click **Enable JIT on VMs**
5. Configure ports (default: RDP 3389)
6. Set maximum request time (default: 3 hours)
7. Click **Save**

### Using JIT

When JIT is enabled:
1. RDP port 3389 is blocked by default
2. To connect, request access through Defender for Cloud
3. Specify your IP address and request duration
4. Once approved, port opens for the specified time
5. Port automatically closes when time expires

## Password Rotation Best Practices

### Rotation Schedule

- **Frequency**: Every 60-90 days minimum
- **High-Security Environments**: Every 30 days
- **Compliance**: Follow your organization's policy

### Manual Rotation

```bash
# Generate new password
NEW_PASSWORD=$(openssl rand -base64 32)

# Update Key Vault secret
az keyvault secret set \
  --vault-name kvaueansdeploy \
  --name vmAdminPassword \
  --value "$NEW_PASSWORD"

# Update VM password (requires RDP access)
# Use Remote Desktop to change password through Windows
```

### Automated Rotation (Advanced)

For automated rotation, implement an Azure Function that:
1. Generates a new password
2. Updates the VM password via VM Run Command
3. Updates the Key Vault secret
4. Logs the rotation event

## Troubleshooting

### Pipeline Fails at Validation Stage

**Issue**: Bicep files won't compile
**Solution**:
1. Verify Bicep syntax in VS Code
2. Run `az bicep build --file bicep/main.bicep` locally
3. Check for typos in resource names

### What-If Stage Shows Unexpected Changes

**Issue**: What-if shows changes you didn't expect
**Solution**:
1. Review the parameter files
2. Check if resource names are correct
3. Verify existing resource IDs in parameter files

### Deployment Fails with Permission Error

**Issue**: "The client does not have permission..."
**Solution**:
1. Verify service connection has Contributor role
2. Check subscription ID is correct
3. Ensure resource group exists

### Cannot Connect to VM After Deployment

**Issue**: RDP connection fails
**Solution**:
1. Verify public IP was assigned (check portal)
2. Check NSG rules allow RDP (port 3389)
3. Wait 5-10 minutes for VM to fully initialize
4. Verify username and password are correct

## Security Considerations

### Key Vault Security

- ✅ Soft delete enabled (90-day recovery window)
- ✅ Purge protection enabled
- ✅ Access policies restrict who can access secrets
- ✅ Secrets expire after 365 days

### Network Security

- ✅ VM behind NSG with restrictive rules
- ✅ JIT access locks down RDP port by default
- ✅ Static public IP for consistent access
- ✅ Premium storage for OS disk

### Credential Management

- ✅ Passwords stored in Key Vault, not in code
- ✅ Service principal used for deployments
- ✅ Secrets marked as secure in Bicep
- ✅ Regular rotation recommended

## Cost Estimation

| Resource | SKU | Estimated Monthly Cost |
|----------|-----|------------------------|
| Virtual Machine | Standard_B2s_v2 | $30-40 |
| Public IP | Standard | $3 |
| Key Vault | Standard | $0.60 |
| Storage (OS Disk) | Premium_LRS | $15-20 |
| **Total** | | **$50-65** |

*Note: Costs vary by region and actual usage. Use [Azure Pricing Calculator](https://azure.microsoft.com/en-us/pricing/calculator/) for accurate estimates.*

## Maintenance

### Regular Tasks

- **Weekly**: Monitor VM performance and logs
- **Monthly**: Review Key Vault access logs
- **Quarterly**: Rotate VM password
- **Annually**: Review and update Bicep templates

### Updates

- Keep Azure CLI updated: `az upgrade`
- Update Bicep CLI: `az bicep install`
- Review Azure service updates for SQL Server

## Support and Documentation

- **Bicep Documentation**: [Microsoft Bicep Docs](https://learn.microsoft.com/en-us/azure/azure-resource-manager/bicep/)
- **Azure DevOps Pipelines**: [Azure Pipelines Documentation](https://learn.microsoft.com/en-us/azure/devops/pipelines/)
- **Azure Key Vault**: [Key Vault Documentation](https://learn.microsoft.com/en-us/azure/key-vault/)
- **Just-In-Time Access**: [JIT Access Guide](https://learn.microsoft.com/en-us/azure/defender-for-cloud/just-in-time-access-overview)

## License

This project is provided as-is for educational and production use.

## Author

**Roberto** - Cloud Infrastructure Specialist

## Contributing

To contribute improvements to this project:

1. Create a feature branch: `git checkout -b feature/improvement`
2. Commit your changes: `git commit -am 'Add improvement'`
3. Push to the branch: `git push origin feature/improvement`
4. Create a Pull Request

## Changelog

### Version 1.0.0 (Initial Release)

- Initial Bicep templates for VM and Key Vault
- Complete Azure DevOps pipeline
- Comprehensive documentation
- JIT access configuration
- Password rotation guidelines
