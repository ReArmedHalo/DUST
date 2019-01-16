Function Get-AzureTenantId {
    [cmdletbinding()]Param(
        [Parameter(Mandatory)]
        [String] $DisplayName
    )
    
    if (Test-IsConnectedToService 'AzureADv2') {
        Get-AzureADContract -All:$true | Where-Object {$_.DisplayName -Match $DisplayName}
    }
}

Function Connect-CustomerAzureADTenant {
    [cmdletbinding()]Param(
        [Parameter(Mandatory,ValueFromPipelineByPropertyName)]
        [Alias('CustomerContextId')]
        [String] $TenantId
    )

    if (Test-IsConnectedToService 'AzureADv2' -ErrorAction SilentlyContinue) {
        Disconnect-AzureAD
    }

    Connect-AzureAD -TenantId $TenantId
}