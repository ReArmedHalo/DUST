<#
    .EXTERNALHELP ..\..\Disconnect-DUSTExchangeOnline-help.xml
#>
Function Disconnect-DUSTExchangeOnline {
    [CmdletBinding()] Param ()

    Get-PSSession | Where-Object {$_.Name -like 'DUST-EXO'} | Remove-PSSession
}