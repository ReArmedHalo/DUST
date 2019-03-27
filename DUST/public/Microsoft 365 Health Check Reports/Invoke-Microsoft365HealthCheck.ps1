<#
    .EXTERNALHELP ..\..\Invoke-Microsoft365HealthCheck-help.xml
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