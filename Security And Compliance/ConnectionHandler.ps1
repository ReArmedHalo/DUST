Function Connect-SecurityAndComplianceCenter {
    [CmdletBinding()] Param ()
    
    Remove-BrokenOrClosedDUSTPSSessions
    
    Import-Module $((Get-ChildItem -Path $($env:LOCALAPPDATA+'\Apps\2.0\') -Filter 'Microsoft.Exchange.Management.ExoPowershellModule.dll' -Recurse).FullName | Where-Object {$_ -notmatch '_none_'} | Select-Object -First 1)
    $SCCSession = New-ExoPSSession -ConnectionUri 'https://ps.compliance.protection.outlook.com/PowerShell-LiveId'

    # If we import the session as a module, then we can make other commands available outside the function scope
    Import-Module (Import-PSSession $SCCSession -AllowClobber -DisableNameChecking) -DisableNameChecking -Global
}

Function Disconnect-SecurityAndComplianceCenter {
    [CmdletBinding()] Param ()
    
    Get-PSSession | Where-Object {$_.Name -like 'DUST-SCC'} | Remove-PSSession
}
