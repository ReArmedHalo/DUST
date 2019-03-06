---
external help file: Install-DUSTDependencies-help.xml
Module Name: DUST
online version: https://rearmedhalo.github.io/DUST/Install-DUSTDependencies.html
schema: 2.0.0
---

# Install-DUSTDependencies

## SYNOPSIS
Handles automatically installing all the required dependencies for the module. Must be ran under an administrative Powershell session.

## SYNTAX

```
Install-DUSTDependencies [<CommonParameters>]
```

## DESCRIPTION
This function handles the installation of the following:
* [Exchange Online Remote PowerShell Module](https://docs.microsoft.com/en-us/powershell/exchange/exchange-online/connect-to-exchange-online-powershell/mfa-connect-to-exchange-online-powershell?view=exchange-ps)
* [Microsoft Online Services Sign-In Assistant for IT Professionals RTW (64-bit)](https://www.microsoft.com/en-us/download/details.aspx?id=28177)
* [Microsoft Online PowerShell Module](https://www.powershellgallery.com/packages/MSOnline)
* [Microsoft Azure AD PowerShell Module](https://www.powershellgallery.com/packages/AzureAD/2.0.2.4)

## EXAMPLES

### Automatically Install All Dependencies
```powershell
PS C:\> Install-DUSTDependencies
```

Checks if the session is running as an administrator and automatically downloads and installs all required modules.

### Get a list of dependencies, with links, so you can manually install them
```powershell
PS C:\> Install-DUSTDependencies -ListOnly
```

Outputs a list of dependencies with links for manual installation

## PARAMETERS

### -ListOnly
Outputs a list of dependencies with links for manual installation

```yaml
Type: Switch
Parameter Sets: (All)
Aliases:

Required: False
Position: 0
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable.
For more information, see about_CommonParameters (http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### None

## OUTPUTS

### None

## NOTES

## RELATED LINKS
