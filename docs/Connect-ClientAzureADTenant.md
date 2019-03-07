---
external help file: Connect-ClientAzureADTenant-help.xml
Module Name: DUST
online version: https://rearmedhalo.github.io/DUST/Connect-ClientAzureADTenant.html
schema: 2.0.0
---

# Connect-ClientAzureADTenant

## SYNOPSIS
Given a valid Azure Tenant ID, will connect via delegated rights to that tenant

## SYNTAX

```
Connect-ClientAzureADTenant [-TenantId] <String> [<CommonParameters>]
```

## DESCRIPTION
Supports MFA - Given a valid Azure Tenant ID, will connect via delegated rights to that tenant

## EXAMPLES

### Connecting with a Tenant ID
```powershell
PS C:\> Connect-ClientAzureADTenant 00000000-0000-0000-0000-000000000000
```

If you have a valid Tenant ID, you can enter it in to connect directly.

### Searching and Connecting
```powershell
PS C:\> Find-AzureTenantIdByName "contoso" | Connect-ClientAzureADTenant
```

Requires first connecting to your tenant that has a partner relationship with the target tenant.

## PARAMETERS

### -TenantId

CustomerContextId that you can find by searching Azure AD using Find-AzureTenantIdByName

```yaml
Type: String
Parameter Sets: (All)
Aliases: CustomerContextId

Required: True
Position: 0
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable.
For more information, see about_CommonParameters (http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### System.String

## OUTPUTS

### None

## NOTES

## RELATED LINKS
[Find-AzureTenantIdByName](https://rearmedhalo.github.io/DUST/Find-AzureTenantIdByName.html)
[Get-AzureADContract](https://docs.microsoft.com/en-us/powershell/module/azuread/get-azureadcontact)