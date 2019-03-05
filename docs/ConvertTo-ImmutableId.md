---
external help file: DUST-help.xml
Module Name: DUST
online version:
schema: 2.0.0
---

# ConvertTo-ImmutableId

## SYNOPSIS
Converts an Active Directory GUID to an Azure AD Immutable ID.

## SYNTAX

### FromADIdentity
```
ConvertTo-ImmutableId [-Identity] <String> [<CommonParameters>]
```

### FromGUIDString
```
ConvertTo-ImmutableId [-UserGUID] <Guid> [<CommonParameters>]
```

## DESCRIPTION
Given a single or multiple Active Directory user identity, will return the ImmutableId.

## EXAMPLES

### EXAMPLE 1
```
ConvertTo-ImmutableId jdoe
```

ConvertTo-ImmutableId -UserGUID '00000000-0000-0000-0000-00000000000'

### EXAMPLE 2
```
Get-ADUser -Filter * -SearchBase 'OU=Finance,OU=UserAccounts,DC=FABRIKAM,DC=COM' | Convert-ToImmutableId
```

$guid = Get-AdUser -Identity jdoe | Select ObjectGUID
ConvertTo-ImmutableId -UserGUID $guid

## PARAMETERS

### -Identity
{{Fill Identity Description}}

```yaml
Type: String
Parameter Sets: FromADIdentity
Aliases:

Required: True
Position: 2
Default value: None
Accept pipeline input: True (ByValue)
Accept wildcard characters: False
```

### -UserGUID
{{Fill UserGUID Description}}

```yaml
Type: Guid
Parameter Sets: FromGUIDString
Aliases:

Required: True
Position: 2
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable.
For more information, see about_CommonParameters (http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

## NOTES

## RELATED LINKS
