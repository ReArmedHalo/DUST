<#
    .EXTERNALHELP ..\..\Disconnect-ExchangeOnline-help.xml
#>
Function Disconnect-ExchangeOnline {
    [CmdletBinding()] Param ()
    
    Get-PSSession | Where-Object {$_.Name -like 'DUST-EXO'} | Remove-PSSession
}