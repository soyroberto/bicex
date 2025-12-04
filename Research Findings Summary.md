# Research Findings Summary

## JIT Access Requirements

### Prerequisites for JIT Access:
1. **Microsoft Defender for Servers Plan 2** must be enabled on the subscription
2. **Network Security Group (NSG)** must be configured on the VM
3. **Supported VMs**: VMs deployed through Azure Resource Manager (not classic)
4. **Reader and SecurityReader** permissions required to configure JIT
5. **Policy naming**: Policy name + VM name must not exceed 56 characters total

### Networking Requirements:
- NSG must be associated with the VM's network interface or subnet
- JIT requires NSG to be configured or Azure Firewall (or both)
- Default ports protected:
  - RDP: 3389 (Windows)
  - SSH: 22 (Linux)
  - WinRM: 5985, 5986
- Maximum request time: 3 hours (default)
- Allowed source IPs: Configurable (default: Any)

### Licensing Requirements:
- **Microsoft Defender for Servers Plan 2** subscription required
- This is a paid service (not free)
- Required for JIT VM access functionality

## Bicep Best Practices

1. **Parameters**: Use descriptive names, provide defaults for safe deployments
2. **Naming**: Use lower camelCase for variables and resources
3. **Security**: Use @secure() decorator for sensitive outputs
4. **Dependencies**: Prefer implicit dependencies over explicit dependsOn
5. **API Versions**: Use recent API versions for new features
6. **Modules**: Structure code for collaboration and reusability
7. **Comments**: Use // for documentation

## Password Rotation Best Practices

1. **Rotation Frequency**: Rotate secrets at least every 60 days
2. **Automation**: Use Azure Key Vault's rotation capabilities
3. **Dual Credentials**: For zero-downtime rotation, implement two sets of credentials
4. **Monitoring**: Enable Key Vault logging and alerts
5. **Caching**: Cache secrets in memory for at least 8 hours
6. **Audit**: Review access regularly and remove unnecessary permissions

## Azure DevOps + Bicep Integration

1. Use Azure Resource Manager Template Deployment task (v3.235.0+)
2. Support for .bicepparam files for parameter management
3. Validate with: bicep build, bicep lint, what-if operations
4. Service connection required for Azure subscription access
5. GitHub integration: Configure service connection for GitHub repos
6. Pipeline triggers: Automatic on commit/PR to main branch

## Key Vault Integration

1. Store VM credentials as secrets
2. Use Key Vault references in Bicep templates
3. Implement RBAC for access control
4. Enable soft delete and purge protection
5. Monitor with Azure Monitor and Event Grid
