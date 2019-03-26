---
external help file: Connect-OnlineService-help.xml
Module Name: DUST
online version: https://rearmedhalo.github.io/DUST/Connect-OnlineService.html
schema: 2.0.0
---

# Connect-OnlineService

## SYNOPSIS
Facade to individual connection handlers

## SYNTAX

### Direct (Default)
```
Connect-OnlineService [-Service] <String> [<CommonParameters>]
```

### Delegated
```
Connect-OnlineService [-Service] <String> [-Delegated] <Switch> [-ClientDomain] <String> [<CommonParameters>]
```

## DESCRIPTION
Handles calling the proper connection handler for a given service.

The following services support delegated access:
- AzureAD (Supports MFA via delegation)
- - `Connect-OnlineService -Service AzureAD -Delegated -TenantId {TenantId}`
- ExchangeOnline (Does not support MFA)
- - `Connect-OnlineService -Service ExchangeOnline -Delegated -ClientDomain {Verified domain}`

## EXAMPLES

### Connect to Exchange Online (Supports MFA)
```powershell
PS C:\> Connect-OnlineService ExchangeOnline
```

### Delegated connection to Exchange Online (Does not support MFA)
```powershell
PS C:\> Connect-OnlineService -Service ExchangeOnline -Delegated -ClientDomain fabrikam.com
```

## PARAMETERS

### -Service
Defines the service that you wish to connect to. Accepts: `AzureAD`, `ExchangeOnline`, `MsolService`, `SecurityAndComplianceCenter`.

Certain services do not support delegated access. Please review this commands description for more details.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Delegated
Instructs the function that you wish to connect with delegated permissions to a tenent

```yaml
Type: Switch
Parameter Sets: Delegated
Aliases:

Required: True
Position: 2
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -TenantId
Azure Tenant Id (CustomerContextId) used for delegated access to an Azure AD tenant.

```yaml
Type: String
Parameter Sets: Delegated
Aliases:

Required: True
Position: 3
Default value: None
Accept pipeline input: True
Accept wildcard characters: False
```

### -ClientDomain
The tenant domain name (contoso.onmicrosoft.com) or domain name registered with the tenant you wish to connect to (contoso.com)

```yaml
Type: String
Parameter Sets: Delegated
Aliases:

Required: True
Position: 3
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see about_CommonParameters (http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

## NOTES

## RELATED LINKS
