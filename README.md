[![Build status](https://ci.appveyor.com/api/projects/status/xoa5igrgu1hc65ik?svg=true)](https://ci.appveyor.com/project/ReArmedHalo/dust)

# DUST - Dustin's Utility and Scripting Toolkit

DUST is a set of functions to ease administration and access to various Microsoft services such as Office 365 and AzureAD. This module has support for MFA and delegated access to client tenants.

Currently, this module really only works on Windows as certain dependencies only work on Windows. For example, MFA authentication in the external modules such as the Exchange Online module only have Windows-based installs.

[Documentation](https://rearmedhalo.github.io/DUST/DUST.html) | [PowerShell Gallery](https://www.powershellgallery.com/packages/DUST)

## Install (PowerShell 5 and PowerShell Core 6)
Compatible with PowerShell 5 and PowerShell Core, run the following from an administrative prompt

```powershell
Install-Module -Name DUST
```

To install without administrative rights

```powershell
Install-Module -Name DUST -Scope CurrentUser