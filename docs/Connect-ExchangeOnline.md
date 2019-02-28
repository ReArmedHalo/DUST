---
external help file: DUST-help.xml
Module Name: dust
online version:
schema: 2.0.0
---

# Connect-ExchangeOnline

## SYNOPSIS
Establish a connection to Exchange Online

## SYNTAX

### Delegated
```
Connect-ExchangeOnline [-Delegated] [-ClientDomain] <String> [-Credential] <PSCredential> [<CommonParameters>]
```

### Direct
```
Connect-ExchangeOnline [-Delegated] [<CommonParameters>]
```

## DESCRIPTION
Handles delegated access and supports MFA access.

## EXAMPLES

### EXAMPLE 1
```
Connect-ExchangeOnline
```

### EXAMPLE 2
```
Connect-ExchangeOnline -Delegated -ClientDomain fabrikam.com
```

## PARAMETERS

### -Delegated
{{Fill Delegated Description}}

```yaml
Type: SwitchParameter
Parameter Sets: Delegated
Aliases:

Required: True
Position: 2
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

```yaml
Type: SwitchParameter
Parameter Sets: Direct
Aliases:

Required: False
Position: 2
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -ClientDomain
{{Fill ClientDomain Description}}

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

### -Credential
{{Fill Credential Description}}

```yaml
Type: PSCredential
Parameter Sets: Delegated
Aliases:

Required: True
Position: 4
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
