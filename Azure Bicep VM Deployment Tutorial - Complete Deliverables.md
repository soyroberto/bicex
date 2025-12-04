# Azure Bicep VM Deployment Tutorial - Complete Deliverables

**Project**: Deploy Windows Server 2022 with SQL Server 2019 on Azure  
**Author**: Roberto  
**Date**: December 2024  
**Subscription ID**: f87077b9-ed2e-497d-876f-02c0a33e3774  
**Azure DevOps Project**: https://dev.azure.com/soydevops/AnsibleDeploy

---

## Bicep Infrastructure Code Files

### 1. main.bicep
Main template for Windows Server 2022 VM with SQL Server 2019. Configures VM, NIC, public IP, and Key Vault integration. Includes JIT access configuration. Size: Standard_B2s_v2. Image: MicrosoftSQLServer:sql2019-ws2022:web:latest. Admin Username: roberto.

### 2. main.bicepparam
Parameter file for main.bicep. Contains VM configuration values. References existing network resources. Key Vault references for credential management.

### 3. keyvault.bicep
Template for Azure Key Vault creation. Stores VM administrator password securely. Implements soft delete and purge protection. Configures access policies for secure access.

### 4. keyvault.bicepparam
Parameter file for keyvault.bicep. Contains Key Vault configuration. Placeholder for principal ID and password. Includes security settings.

---

## Azure DevOps Pipeline Configuration

### 5. azure-pipelines.yml
Complete CI/CD pipeline for Azure DevOps with four stages:

**Stage 1: Validate**
- Compiles Bicep to ARM templates
- Validates syntax and structure
- Publishes artifacts

**Stage 2: Test (What-If)**
- Previews changes without applying them
- Shows resource creation/modification details
- Validates parameter files

**Stage 3: Deploy to Production**
- Deploys Key Vault
- Deploys Virtual Machine
- Configures JIT access

**Stage 4: Post-Deployment**
- Verifies resource creation
- Generates deployment report
- Outputs connection details

---

## Alternative CI/CD Configuration

### 6. github-actions-workflow.yml
GitHub Actions workflow as alternative to Azure DevOps. Same stages as Azure DevOps pipeline. Can be used if preferring GitHub Actions over Azure DevOps. Place in .github/workflows/ directory.

---

## Documentation Files

### 7. blog-post.md
Comprehensive end-to-end tutorial (3000+ words) with step-by-step instructions for complete setup. Covers:
- Project structure and setup
- Bicep template creation and explanation
- GitHub repository configuration
- Azure DevOps project setup
- Pipeline creation and execution
- Deployment verification
- JIT access requirements and configuration
- Password rotation best practices

Production-ready blog post format with professional, conversational tone and code examples.

### 8. README.md
Project overview and quick start guide including:
- Prerequisites and requirements
- Project structure explanation
- Configuration details tables
- Troubleshooting guide
- Cost estimation
- Security considerations
- Maintenance guidelines
- Support and documentation links

### 9. SETUP_GUIDE.md
Local development setup for macOS including:
- Step-by-step tool installation
- VS Code configuration with Bicep extension
- Git workflow and best practices
- Local validation commands
- Daily development workflow
- Useful command reference
- Troubleshooting for development environment

### 10. CHEAT_SHEET.md
Quick reference for common commands:
- Azure CLI essentials
- Bicep commands
- Deployment commands
- VM management commands
- Key Vault operations
- Network management
- Git commands
- Azure DevOps CLI
- One-liners for common tasks
- Common errors and solutions

### 11. DELIVERABLES.md
This file - complete list of all deliverables with descriptions.

---

## Research and Reference Files

### 12. research_findings.md
Summary of research on:
- JIT access requirements and networking
- Bicep best practices
- Password rotation guidelines
- Azure DevOps integration
- Key Vault security

---

## Key Features Implemented

### Security
✓ Credentials stored in Azure Key Vault  
✓ Just-In-Time (JIT) access configuration  
✓ Network Security Group (NSG) integration  
✓ Secure password handling with @secure() decorator  
✓ Soft delete and purge protection on Key Vault  
✓ Access policies with least privilege principle  

### Infrastructure as Code
✓ Bicep templates for VM and Key Vault  
✓ Parameter files for flexible deployment  
✓ Modular, reusable code structure  
✓ Comprehensive comments and documentation  
✓ Best practices for naming and organization  

### CI/CD Automation
✓ Multi-stage Azure DevOps pipeline  
✓ Validation stage with Bicep compilation  
✓ What-if analysis before deployment  
✓ Automated deployment on main branch  
✓ Post-deployment verification  
✓ Deployment reports and artifacts  

### Developer Experience
✓ Local development setup guide  
✓ VS Code configuration  
✓ Git workflow documentation  
✓ Command reference cheat sheet  
✓ Troubleshooting guides  
✓ Quick start instructions  

---

## Deployment Specifications

### Virtual Machine
- **Name**: vmauansvm01
- **Image**: MicrosoftSQLServer:sql2019-ws2022:web:latest
- **Size**: Standard_B2s_v2
- **OS Disk**: Premium_LRS (256 GB)
- **Admin Username**: roberto
- **Location**: australiaeast
- **Resource Group**: RGAUANSDeploy

### Networking
- **Virtual Network**: vnetausclient (in RGAUSNetCh)
- **Subnet**: misc
- **NSG**: nsgauejit (in RGAUSNetCh)
- **Public IP**: Static, Standard SKU
- **NIC**: Dynamic private IP

### Key Vault
- **Name**: kvaueansdeploy
- **Location**: australiaeast
- **SKU**: Standard
- **Soft Delete**: Enabled (90 days)
- **Purge Protection**: Enabled
- **Secret**: vmAdminPassword (expires in 365 days)

### Azure DevOps
- **Organization**: https://dev.azure.com/soydevops
- **Project**: AnsibleDeploy
- **Service Connection**: AzureServiceConnection
- **Subscription ID**: f87077b9-ed2e-497d-876f-02c0a33e3774

---

## Usage Instructions

### 1. Initial Setup
- Clone GitHub repository
- Install prerequisites (Azure CLI, Bicep, VS Code)
- Configure Azure CLI with subscription
- Update parameter files with your values

### 2. Local Development
- Follow SETUP_GUIDE.md for macOS setup
- Edit Bicep files in VS Code
- Validate locally with: `az bicep build --file main.bicep`
- Test with: `az deployment group what-if ...`

### 3. Push to GitHub
- Create feature branch
- Commit changes with git
- Push to GitHub
- Create pull request

### 4. Azure DevOps Pipeline
- Create service connection to Azure
- Create pipeline from azure-pipelines.yml
- Pipeline runs automatically on push to main
- Monitor stages: Validate → Test → Deploy → Verify

### 5. Verify Deployment
- Check Azure portal for resources
- Review pipeline artifacts
- Test VM connectivity
- Configure JIT access through Defender for Cloud

---

## Best Practices Included

### Bicep Best Practices
✓ Descriptive parameter names  
✓ Comprehensive comments  
✓ Secure password handling  
✓ Implicit dependencies  
✓ Recent API versions  
✓ Proper resource naming conventions  
✓ Metadata declarations  

### Security Best Practices
✓ Credentials in Key Vault (not in code)  
✓ JIT access for RDP  
✓ NSG rules for network security  
✓ Soft delete and purge protection  
✓ Access policies with least privilege  
✓ Password expiration settings  
✓ Regular rotation guidelines  

### DevOps Best Practices
✓ Infrastructure as Code  
✓ Automated validation  
✓ What-if analysis before deployment  
✓ Multi-stage pipeline  
✓ Artifact management  
✓ Deployment reports  
✓ Version control integration  

---

## Support and Maintenance

### Documentation
- Comprehensive blog post with step-by-step instructions
- README with quick start and troubleshooting
- Setup guide for local development
- Cheat sheet for common commands
- Research findings on security and best practices

### Troubleshooting
- Common errors and solutions documented
- Validation commands provided
- What-if analysis for safe testing
- Deployment verification steps included

### Maintenance
- Password rotation guidelines (every 60-90 days)
- Regular Key Vault access reviews
- VM patching and updates
- Resource monitoring recommendations

---

## Total Deliverables: 12 Files

This complete package provides everything needed to:

1. **Understand** the deployment architecture
2. **Set up** local development environment
3. **Create and manage** Bicep infrastructure code
4. **Build and run** CI/CD pipelines in Azure DevOps
5. **Deploy** secure, production-ready infrastructure
6. **Maintain and update** deployments over time

All files are production-ready and follow industry best practices.

---

## File Summary Table

| File | Type | Purpose |
|------|------|---------|
| main.bicep | Code | VM deployment template |
| main.bicepparam | Code | VM parameters |
| keyvault.bicep | Code | Key Vault template |
| keyvault.bicepparam | Code | Key Vault parameters |
| azure-pipelines.yml | Config | Azure DevOps pipeline |
| github-actions-workflow.yml | Config | GitHub Actions alternative |
| blog-post.md | Docs | Complete tutorial |
| README.md | Docs | Project overview |
| SETUP_GUIDE.md | Docs | Development setup |
| CHEAT_SHEET.md | Docs | Command reference |
| DELIVERABLES.md | Docs | This file |
| research_findings.md | Docs | Research summary |

---

**Ready to deploy!** Follow the blog-post.md for complete step-by-step instructions.
