Function Disconnect-SecurityAndComplianceCenter {
    [CmdletBinding()] Param ()
    
    Get-PSSession | Where-Object {$_.Name -like 'DUST-SCC'} | Remove-PSSession
}