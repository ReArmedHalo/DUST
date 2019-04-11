Function Get-DUSTAzureADApiApplicationConsent {
    [CmdletBinding()] param (
        [Parameter(Mandatory)]
        [String] $ClientId,

        [Parameter(Mandatory)]
        [String] $TenantDomain
    )

    $applicationProvisioningComplete = $false
    while (!($applicationProvisioningComplete)) {
        $azureADApplications = Get-AzureADApplication | Select-Object ObjectId
        if ($azureADApplications.ObjectId -contains $Application.ObjectId) {
            $applicationProvisioningComplete = $true
        }
        Start-Sleep -Milliseconds 5000
    }
    
    try {
        $authContext = New-Object 'Microsoft.IdentityModel.Clients.ActiveDirectory.AuthenticationContext' -ArgumentList "https://login.microsoftonline.com/$TenantDomain"
        $platformParameters = New-Object "Microsoft.IdentityModel.Clients.ActiveDirectory.PlatformParameters" -ArgumentList "Auto"
        $authResult = $authContext.AcquireTokenAsync('https://graph.microsoft.com', $ClientId, 'https://localhost', $platformParameters).Result
        if ($authResult) {
            return $authResult.AccessToken
        }
    } catch {
        Write-Error $_
    }
}