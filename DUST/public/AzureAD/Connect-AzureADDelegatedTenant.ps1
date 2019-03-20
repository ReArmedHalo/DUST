<#
    .EXTERNALHELP ..\..\Connect-AzureADDelegatedTenant-help.xml
#>
Function Connect-AzureADDelegatedTenant {
    [cmdletbinding()] Param (
        [Parameter(Mandatory,ValueFromPipelineByPropertyName)]
        [Alias('CustomerContextId')]
        [String] $TenantId
    )

    if (Test-IsConnectedToService 'AzureADv2' -ErrorAction SilentlyContinue) {
        Disconnect-AzureAD
    }

    Connect-AzureAD -TenantId $TenantId
}