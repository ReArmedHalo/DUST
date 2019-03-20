<#
    .EXTERNALHELP ..\..\Connect-AzureADDelegatedTenant-help.xml
#>
Function Connect-AzureADDelegatedTenant {
    [cmdletbinding()] Param (
        [Parameter(Mandatory,ValueFromPipelineByPropertyName)]
        [Alias('CustomerContextId')]
        [String] $TenantId
    )

    if (Test-IsConnectedToService 'AzureAD' -ErrorAction SilentlyContinue) {
        Disconnect-AzureAD
    }

    Connect-AzureAD -TenantId $TenantId
}