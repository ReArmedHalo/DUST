<#
    .EXTERNALHELP ..\..\Find-AzureTenantIdByName-help.xml
#>
Function Find-AzureTenantIdByName {
    [cmdletbinding()] Param (
        [Parameter(Mandatory)]
        [String] $DisplayName
    )
    
    if (Test-IsConnectedToService 'AzureAD') {
        Get-AzureADContract -All:$true | Where-Object {$_.DisplayName -Match $DisplayName}
    }
}