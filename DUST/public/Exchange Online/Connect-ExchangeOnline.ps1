<#
    .EXTERNALHELP ..\..\Connect-ExchangeOnline-help.xml
#>
Function Connect-ExchangeOnline {
    [CmdletBinding(DefaultParameterSetName='Direct')] Param (
        [Parameter(ParameterSetName='Direct',Position=0)]
        [Parameter(ParameterSetName='Delegated',Mandatory,Position=0)]
        [Switch] $Delegated,

        [Parameter(ParameterSetName='Delegated',Mandatory,Position=1)]
        [String] $ClientDomain, 

        [Parameter(ParameterSetName='Delegated',Mandatory,Position=2)]
        [PSCredential] $Credential
    )
    
    Remove-BrokenOrClosedDUSTPSSessions
    
    if ($Delegated) {
        # MFA is not supported using delegated admin
        # Saving this for my hopes and dreams of it one day being supported
        #$EXOSession = New-ExoPSSession -ConnectionUri 'https://ps.outlook.com/powershell-liveid?DelegatedOrg=$ClientDomain'
        $EXOSession = New-PSSession -Name 'DUST-EXO' -ConfigurationName Microsoft.Exchange -ConnectionUri ('https://ps.outlook.com/powershell-liveid?DelegatedOrg='+$ClientDomain) -Credential $Credential -Authentication Basic -AllowRedirection        
    } else {
        # We only need the Exchange Online PS module if we are using MFA
        Import-Module $((Get-ChildItem -Path $($env:LOCALAPPDATA+'\Apps\2.0\') -Filter 'Microsoft.Exchange.Management.ExoPowershellModule.dll' -Recurse).FullName | Where-Object {$_ -notmatch '_none_'} | Select-Object -First 1)
        $EXOSession = New-ExoPSSession
    }
    Import-Module (Import-PSSession $EXOSession -AllowClobber -DisableNameChecking) -DisableNameChecking -Global
}