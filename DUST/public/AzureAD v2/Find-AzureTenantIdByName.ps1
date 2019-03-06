Function Find-AzureTenantIdByName {
    [cmdletbinding()] Param (
        [Parameter(Mandatory)]
        [String] $DisplayName
    )
    
    if (Test-IsConnectedToService 'AzureADv2') {
        Get-AzureADContract -All:$true | Where-Object {$_.DisplayName -Match $DisplayName}
    }
}