---
external help file: Connect-ExchangeOnline-help.xml
Module Name: DUST
online version: https://rearmedhalo.github.io/DUST/Connect-ExchangeOnline.html
schema: 2.0.0
---

# Connect-ExchangeOnline

## SYNOPSIS
Establish a connection to Exchange Online

## SYNTAX

### Direct (Default)
```
Connect-ExchangeOnline [-Delegated] [<CommonParameters>]
```

### Delegated
```
Connect-ExchangeOnline [-Delegated] [-ClientDomain] <String> [-Credential] <PSCredential> [<CommonParameters>]
```

## DESCRIPTION
Handles delegated access and supports MFA access (only with direct connection)

## EXAMPLES

### Direct Connection
```
Connect-ExchangeOnline
```

### Delegated Access
```
Connect-ExchangeOnline -Delegated -ClientDomain fabrikam.com
```

## PARAMETERS

### -Delegated
Inform the function that you wish to connect via delegated credentials

```yaml
Type: SwitchParameter
Parameter Sets: Direct
Aliases:

Required: False
Position: 1
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

```yaml
Type: SwitchParameter
Parameter Sets: Delegated
Aliases:

Required: True
Position: 1
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -ClientDomain
Primary SMTP address or onmicrosoft.com tenant address of the Exchange Online tenant that you wish to connect to.

```yaml
Type: String
Parameter Sets: Delegated
Aliases:

Required: True
Position: 2
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Credential
PSCredential object for delegated access

```yaml
Type: PSCredential
Parameter Sets: Delegated
Aliases:

Required: True
Position: 3
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
