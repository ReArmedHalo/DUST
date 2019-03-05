---
external help file: DUST-help.xml
Module Name: DUST
online version:
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
Connect-OnlineService [-Service] <String> [<CommonParameters>]
```

## DESCRIPTION
Handles calling the proper connection handler for a given service.

## EXAMPLES

### EXAMPLE 1
```
Connect-OnlineService ExchangeOnline
```

### EXAMPLE 2
```
Connect-OnlineService ExchangeOnline -Delegated -ClientDomain fabrikam.com
```

## PARAMETERS

### -Service
{{Fill Service Description}}

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

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable.
For more information, see about_CommonParameters (http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

## NOTES

## RELATED LINKS
