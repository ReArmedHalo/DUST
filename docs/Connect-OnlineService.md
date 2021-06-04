---
external help file: DUST-help.xml
Module Name: DUST
online version: https://rearmedhalo.github.io/DUST/Connect-OnlineService.html
schema: 2.0.0
---

# Connect-OnlineService

## SYNOPSIS
Connect to (most) Microsoft 365 services with a single command!

## SYNTAX

### Direct (Default)
```
Connect-OnlineService [-Service] <String> [<CommonParameters>]
```

### Delegated
```
Connect-OnlineService [-Service] <String> [-Delegated] [-FindDelegated] [<CommonParameters>]
```

## DESCRIPTION
Provides a single command to connect to (most) Microsoft 365 Cloud Services. Delegated credentials are usable where able via modern authentication. This command makes heavy use of dynamic parameters. I've done my best to outline the parameters in the PARAMETERS section of the help but it can get confusing when review the help documents. Examples are provided for every service both direct and delegated as an aid but every combination may not be covered.

## EXAMPLES

### Example 1 - Azure AD - Direct
```powershell
PS C:\> Connect-OnlineService AzureAD
```

Connect to Azure AD using modern authentication.

### Example 2 - Azure AD - Delegated
```powershell
PS C:\> Connect-OnlineService AzureAD -Delegated x0xxx10-00x0-0x01-0xxx-x0x0x01xx100
```

Connect to Azure AD using modern authentication to the delegated TenantId/CustomerContextId (Most likely you will want to use Example 3 below).

### Example 3 - Azure AD - Delegated Search for Tenant
```powershell
PS C:\> Connect-OnlineService AzureAD -Delegated -FindTenant
```

Connect to Azure AD using modern authentication to the selected delegated tenant. This command will first ask you to connect to your Microsoft Partner Azure tenant so that it can retrieve your "customer" tenant accounts from Microsoft CSP Partner Program (Get-AzureADContract). Once you select a tenant, it will disconnect and reconnect to the new tenant, you may receive a prompt to authenticate again with your "home" credentials.

### Example 4 - Exchange Online - Direct
```powershell
PS C:\> Connect-OnlineService ExchangeOnline
```

Connect to Exchange Online using modern authentication.

### Example 5 - Exchange Online - Delegated
```powershell
PS C:\> Connect-OnlineService ExchangeOnline contoso.com
```

Connect to Exchange Online using modern authentication to a delegated organization.


### Example 6 - Security And Compliance - Direct (Only)
```powershell
PS C:\> Connect-OnlineService SecurityAndCompliance
```

Connect to the Security and Compliance Center. This connection is not available for delegated authentication.

### Example 7 - SharePoint - Direct / Delegated
```powershell
PS C:\> Connect-OnlineService SharePoint https://contoso-admin.sharepoint.com
```

Connect to SharePoint Online using modern authentication. Using the AuthenticationUri required parameter, you can connect to your home tenant or a delegated tenant. The AuthenticationUri must be in the form of https://orgName-admin.sharepoint.com.

### Example 7 - SharePoint - Direct
```powershell
PS C:\> Connect-OnlineService SharePoint https://contoso-admin.sharepoint.com
```

Connect to SharePoint Online using modern authentication. The AuthenticationUri is required, the form of which would be https://orgName-admin.sharepoint.com.

### Example 8 - Teams - Direct
```powershell
PS C:\> Connect-OnlineService Teams
```

Connect to Microsoft Teams using modern authentication.

### Example 9 - Teams - Delegated
```powershell
PS C:\> Connect-OnlineService Teams x0xxx10-00x0-0x01-0xxx-x0x0x01xx100
```

Connect to Microsoft Teams using modern authentication into a delegated organization provided by it's TenantId.

## PARAMETERS

### -Service
This parameter provides the service you wish to connect to. Depending on the service, you may receive additional options dynamically. For example, you may be able to specify which environment or if you want to use delegation.

```yaml
Type: String
Parameter Sets: (All)
Aliases:
Accepted values: AzureAD, ExchangeOnline, SecurityAndCompliance, SharePoint, Teams

Required: True
Position: 0
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Delegated
AzureAD, ExchangeOnline, Teams - This switch informs the command you wish to use delegated credentials with the respective service. This is required as services usually have differenet ways to connect if you are delegated so we will use those methods here. NOTE: You may need additional arguments for services such as Teams. They will dynamically become available if required.

```yaml
Type: Switch
Parameter Sets: Delegated
Aliases:
Accepted values: $true, $false

Required: True
Position: named
Default value: $true
Accept pipeline input: False
Accept wildcard characters: False
```

### -FindTenant
AzureAD - This will display a prompt with all available Contract Ids for you to select. This is useful for Azure AD connections as you need the CustomerContextId to initiate a delegated session.

```yaml
Type: Switch
Parameter Sets: Delegated
Aliases:
Accepted values: $true, $false

Required: False
Position: named
Default value: $false
Accept pipeline input: False
Accept wildcard characters: False
```

### -TenantId
AzureAD (Teams uses this as well, see below) - Connect directly to a tenant provided by this Tenant Id. This value can come from the pipeline output for Get-AzureADContract (CustomerContextId)

```yaml
Type: String
Parameter Sets: Delegated
Aliases: CustomerContextId
Accepted values: 

Required: True
Position: named
Default value: $false
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -AzureEnvironmentName
Available for AzureAD. Specifies the name of the Azure environment. The acceptable values for this parameter are: AzureCloud (Default), AzureChinaCloud, AzureUSGovernment, AzureGermanyCloud.

```yaml
Type: String
Parameter Sets: (All)
Aliases:
Accepted values: AzureCloud, AzureChinaCloud, AzureUSGovernment, AzureGermanyCloud

Required: False
Position: 1
Default value: AzureCloud
Accept pipeline input: False
Accept wildcard characters: False
```

### -DelegatedOrganization
Available for ExchangeOnline. The client domain you wish to connect to via delegated rights. This is only required if you are connecting to a tenant that isn't your home tenant.

```yaml
Type: String
Parameter Sets: Delegated
Aliases:
Accepted values:

Required: True
Position: 1
Default value:
Accept pipeline input: False
Accept wildcard characters: False
```

### -TenantId
Available for Teams. The Microsoft 365 Tenant Id you wish to connect to via delegated rights.

```yaml
Type: String
Parameter Sets: Delegated
Aliases:
Accepted values:

Required: True
Position: 1
Default value:
Accept pipeline input: False
Accept wildcard characters: False
```

### -AuthenticationUrl
Available for SharePoint. The SharePoint admin URL in the format of: https://orgName-admin.sharepoint.com.

```yaml
Type: String
Parameter Sets: (All)
Aliases:
Accepted values:

Required: True
Position: 1
Default value:
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### None

## OUTPUTS

### None
## NOTES

## RELATED LINKS
