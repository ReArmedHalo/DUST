<#
    .EXTERNALHELP ..\..\Disconnect-DUSTSecurityAndComplianceCenter-help.xml
#>
Function Disconnect-DUSTSecurityAndComplianceCenter {
    [CmdletBinding()] Param ()
    
    Get-PSSession | Where-Object {$_.Name -like 'DUST-SCC'} | Remove-PSSession
}