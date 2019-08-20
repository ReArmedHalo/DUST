| AppVeyor (Master) | AppVeyor (Develop) | PowerShell Gallery |
|-------------------|--------------------|--------------------|
|[![Build status](https://img.shields.io/appveyor/ci/rearmedhalo/DUST/master.svg)](<https://ci.appveyor.com/project/ReArmedHalo/dust/branch/master>) | [![Build status](https://img.shields.io/appveyor/ci/rearmedhalo/DUST/develop.svg)](<https://ci.appveyor.com/project/ReArmedHalo/dust/branch/develop>) | [![PowerShell Gallery](https://img.shields.io/powershellgallery/v/DUST.svg?style=flat-square&label=DUST)](<https://powershellgallery.com/packages/DUST>) [![PowerShell Gallery](https://img.shields.io/powershellgallery/dt/DUST.svg)](<https://powershellgallery.com/packages/DUST>) |

# DUST - Dustin's Utility and Scripting Toolkit

DUST is a set of functions to ease administration and access to various Microsoft services such as Office 365 and AzureAD. This module has support for MFA and delegated access to client tenants.

Currently, this module really only works on Windows as certain dependencies only work on Windows. For example, MFA authentication in the external modules such as the Exchange Online module only have Windows-based installs.

[Documentation](<https://rearmedhalo.github.io/DUST/DUST.html>) | [PowerShell Gallery](<https://www.powershellgallery.com/packages/DUST>)

## Install (PowerShell 5 and PowerShell Core 6)

Compatible with PowerShell 5 and PowerShell Core, run the following from an administrative prompt

```powershell
Install-Module -Name DUST
```

To install without administrative rights

```powershell
Install-Module -Name DUST -Scope CurrentUser
```

## Dependencies

DUST includes a function to handle automatic remediation for dependencies that are required by certain functions. You can have DUST handle this automatically if you run the below command via an elevated adminitrative PowerShell session.

```powershell
Install-DUSTDependencies
```

Optionally, if you don't want to have DUST do this automatically:

```powershell
Install-DUSTDependencies -ListOnly
```

# Credits and Thanks

[Terry Munro - 365admin.com.au](<https://www.365admin.com.au/2017/01/how-to-configure-your-desktop-pc-for.html>): Your article was a great help in configuring the different modules for Office Online to all be usable directly without opening each individual PS module.
