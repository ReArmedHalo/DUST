<#
    .EXTERNALHELP ..\..\Invoke-Microsoft365HealthCheck-help.xml
#>
Function Invoke-Microsoft365HealthCheck {
    [CmdletBinding(DefaultParameterSetName='All')] Param (
        [Parameter(Mandatory)]
        [String] $TenantDomain,

        [Parameter(ParameterSetName='All')]
        [Switch] $All,

        [Parameter(ParameterSetName='Selective')]
        [Switch] $RoleAdministrationActivities
    )

    try {
        Connect-AzureAD | Out-Null
        $application = New-DUSTAzureADApiApplication -TenantDomain $TenantDomain
        $clientCredentials = New-Object System.Management.Automation.PSCredential($application.ClientId,($application.ClientSecret | ConvertTo-SecureString -AsPlainText -Force))
        # It seems if we don't wait, trying to get consent might throw an error that the application doesn't exist
        Start-Sleep -Milliseconds 5000
        $accessToken = Get-DUSTAzureADApiApplicationConsent -ClientCredentials $clientCredentials -TenantDomain $TenantDomain
        
    }
    catch {
        Write-Error $_
    }
}