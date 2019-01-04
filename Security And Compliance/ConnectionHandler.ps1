Function Connect-SecurityAndCompliance {
    [CmdletBinding(DefaultParameterSetName='Direct')]Param(
        [Parameter(ParameterSetName='Delegated')]
        [Switch] $Delegated,

        [Parameter(ParameterSetName='Delegated',Mandatory=$true)]
        [String] $ClientDomain,

        [Parameter(ParameterSetName='Delegated',Mandatory=$true)]
        [PSCredential] $Credential
    )
    
    Remove-BrokenOrClosedDUSTPSSessions

    Import-Module $((Get-ChildItem -Path $($env:LOCALAPPDATA+'\Apps\2.0\') -Filter Microsoft.Exchange.Management.ExoPowershellModule.dll -Recurse ).FullName|?{$_ -notmatch '_none_'}|select -First 1)
    
    if ($Delegated) {
        # MFA is not supported using delegated admin
        $SCCSession = New-PSSession -Name 'DUST-SCC' -ConfigurationName Microsoft.Exchange -ConnectionUri 'https://ps.compliance.protection.outlook.com/PowerShell-LiveId='+$ClientDomain -Credential $Credential -Authentication Basic -AllowRedirection
    } else {
        $SCCSession = New-ExoPSSession -ConnectionUri 'https://ps.compliance.protection.outlook.com/PowerShell-LiveId'
    }
    Import-Module (Import-PSSession $SCCSession -AllowClobber -DisableNameChecking) -DisableNameChecking -Global
}

Function Disconnect-SecurityAndCompliance {
    [CmdletBinding()]Param()
    
    Get-PSSession | Where-Object {$_.Name -like 'DUST-SCC'} | Remove-PSSession
}
