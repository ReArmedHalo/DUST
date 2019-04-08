---
external help file: DUST-help.xml
Module Name: DUST
online version: https://rearmedhalo.github.io/DUST/Invoke-Microsoft365HealthCheck.html
schema: 2.0.0
---

# Invoke-Microsoft365HealthCheck

## SYNOPSIS
{{ Fill in the Synopsis }}

## SYNTAX

### All (Default)
```
Invoke-Microsoft365HealthCheck -TenantDomain <String> [-StartDate <DateTime>] [-OutputPath <String>] [-All]
 [<CommonParameters>]
```

### Selective
```
Invoke-Microsoft365HealthCheck -TenantDomain <String> [-StartDate <DateTime>] [-OutputPath <String>]
 [-RoleAdministrationActivities] [-SecureScore] [-OrganizationAuditStatus] [-MailboxAuditStatus]
 [-InboxMailForwardOrRedirectRules] [-MalwareAudit] [-FlaggedAsPhishingAudit] [<CommonParameters>]
```

## DESCRIPTION
{{ Fill in the Description }}

## EXAMPLES

### Example 1
```powershell
PS C:> {{ Add example code here }}
```

{{ Add example description here }}

## PARAMETERS

### -All
{{ Fill All Description }}

```yaml
Type: SwitchParameter
Parameter Sets: All
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -FlaggedAsPhishingAudit
{{ Fill FlaggedAsPhishingAudit Description }}

```yaml
Type: SwitchParameter
Parameter Sets: Selective
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -InboxMailForwardOrRedirectRules
{{ Fill InboxMailForwardOrRedirectRules Description }}

```yaml
Type: SwitchParameter
Parameter Sets: Selective
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -MailboxAuditStatus
{{ Fill MailboxAuditStatus Description }}

```yaml
Type: SwitchParameter
Parameter Sets: Selective
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -MalwareAudit
{{ Fill MalwareAudit Description }}

```yaml
Type: SwitchParameter
Parameter Sets: Selective
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -OrganizationAuditStatus
{{ Fill OrganizationAuditStatus Description }}

```yaml
Type: SwitchParameter
Parameter Sets: Selective
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -OutputPath
{{ Fill OutputPath Description }}

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -RoleAdministrationActivities
{{ Fill RoleAdministrationActivities Description }}

```yaml
Type: SwitchParameter
Parameter Sets: Selective
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -SecureScore
{{ Fill SecureScore Description }}

```yaml
Type: SwitchParameter
Parameter Sets: Selective
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -StartDate
{{ Fill StartDate Description }}

```yaml
Type: DateTime
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -TenantDomain
{{ Fill TenantDomain Description }}

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see about_CommonParameters (http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### None

## OUTPUTS

### System.Object
## NOTES

## RELATED LINKS
