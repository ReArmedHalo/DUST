Function Connect-ExchangeOnline {
    [CmdletBinding(DefaultParameterSetName='Direct')]Param(
        [Parameter(ParameterSetName='Delegated')]
        [Switch] $Delegated,

        [Parameter(ParameterSetName='Delegated',Mandatory=$true)]
        [String] $ClientDomain,

        [Parameter(ParameterSetName='Delegated',Mandatory=$true)]
        [PSCredential] $Credential
    )
    
    Remove-BrokenOrClosedDUSTPSSessions

    Import-Module $((Get-ChildItem -Path $($env:LOCALAPPDATA+'\Apps\2.0\') -Filter Microsoft.Exchange.Management.ExoPowershellModule.dll -Recurse ).FullName | Where-Object {$_ -notmatch '_none_'} | Select-Object -First 1)
    
    if ($Delegated) {
        # MFA is not supported using delegated admin
        # Saving this for my hopes and dreams of it one day being supported
        #$EXOSession = New-ExoPSSession -ConnectionUri 'https://ps.outlook.com/powershell-liveid?DelegatedOrg=$ClientDomain'
        $EXOSession = New-PSSession -Name 'DUST-EXO' -ConfigurationName Microsoft.Exchange -ConnectionUri ('https://ps.outlook.com/powershell-liveid?DelegatedOrg='+$ClientDomain) -Credential $Credential -Authentication Basic -AllowRedirection        
    } else {
        $EXOSession = New-ExoPSSession
    }
    Import-Module (Import-PSSession $EXOSession -AllowClobber -DisableNameChecking) -DisableNameChecking -Global
}

Function Disconnect-ExchangeOnline {
    [CmdletBinding()]Param()
    
    Get-PSSession | Where-Object {$_.Name -like 'DUST-EXO'} | Remove-PSSession
}