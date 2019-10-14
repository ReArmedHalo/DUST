---
external help file: Set-AzureADUserPasswordExpiration-help.xml
Module Name: DUST
online version: https://rearmedhalo.github.io/DUST/Install-DUSTDependencies.html
schema: 2.0.0
---

# Set-AzureADUserPasswordExpiration

## SYNOPSIS
Quickly set the password policy for Azure AD users

## SYNTAX

### AllExpire
```
Set-AzureADUserPasswordExpiration [-All] [-Expire] [<CommonParameters>]
```

### AllNoExpire
```
Set-AzureADUserPasswordExpiration [-All] [-None] [<CommonParameters>]
```

### SearchStringExpire
```
Set-AzureADUserPasswordExpiration [-SearchString <String>] [-Expire] [<CommonParameters>]
```

### SearchStringNoExpire
```
Set-AzureADUserPasswordExpiration [-SearchString <String>] [-None] [<CommonParameters>]
```

## DESCRIPTION
Set all or a subset of users to have their Azure AD password expire or not expire, overriding the tenant's password expiration policy.

## EXAMPLES

### Set a specific user to expire
```powershell
PS C:\> Set-AzureADUserPasswordExpiration -SearchString john.doe -Expire
```

This is the default when the tenant has a password expiration policy configured so you might use this to reset the password policy back to allowing a user's password to expire.

## PARAMETERS

### -All
Select all users in the tenant

```yaml
Type: SwitchParameter
Parameter Sets: AllExpire, AllNoExpire
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Expire
Set the given user(s) to have their password expire

```yaml
Type: SwitchParameter
Parameter Sets: AllExpire, SearchStringExpire
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -None
Set the given user(s) password to never expire

```yaml
Type: SwitchParameter
Parameter Sets: AllNoExpire, SearchStringNoExpire
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -SearchString
Use Azure AD's -SearchString parameter of Get-AzureADUser to filter to a single or specific user set

```yaml
Type: String
Parameter Sets: SearchStringExpire, SearchStringNoExpire
Aliases:

Required: False
Position: 0
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### None

## OUTPUTS

### System.Object
## NOTES

## RELATED LINKS

[Microsoft Docs - Set the password expiration policy for your organization](https://docs.microsoft.com/en-us/office365/admin/add-users/set-password-to-never-expire?view=o365-worldwide)