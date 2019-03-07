---
external help file: Connect-AzureADv2-help.xml
Module Name: DUST
online version: https://rearmedhalo.github.io/DUST/Connect-AzureADv2.html
schema: 2.0.0
---

# Connect-AzureADv2

## SYNOPSIS
Mostly here just so we can handle connecting via our own connection handler to AzureAD for Connect-OnlineService

## SYNTAX

```
Connect-AzureADv2 [<CommonParameters>]
```

## DESCRIPTION
We have a seperate handler for connecting to a client's Azure tenant currently so this mostly just serves as a wrapper to Connect-AzureAD from the AzureAD module.

## EXAMPLES

### Example 1
```powershell
PS C:\> Connect-AzureADv2
```

Supports MFA and prompts for valid Azure credentials

## PARAMETERS

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable.
For more information, see about_CommonParameters (http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### None

## OUTPUTS

### None

## NOTES

## RELATED LINKS
