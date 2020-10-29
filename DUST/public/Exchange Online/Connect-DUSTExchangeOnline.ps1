<#
    .EXTERNALHELP ..\..\Connect-DUSTExchangeOnline-help.xml
#>
Function Connect-DUSTExchangeOnline {
    [CmdletBinding(DefaultParameterSetName='Direct')] Param (
        [Parameter(
            ParameterSetName='Delegated',
            Mandatory,
            Position=0
        )]
        [String] $ClientDomain
    )

    Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope Process -Force
    try {
        if ($ClientDomain) {
            Connect-ExchangeOnline -DelegatedOrganization $ClientDomain -ShowBanner:$false
        } else {
            Connect-ExchangeOnline -ShowBanner:$false
        }
    } catch {
        Write-Error $_
    }
}