Function Get-DUSTAzureADApiApplicationConsent {
    [CmdletBinding()] param (
        [Parameter(Mandatory)]
        [PSObject] $Application,

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
        $clientCredentials = New-Object System.Management.Automation.PSCredential($Application.ClientId,($Application.ClientSecret | ConvertTo-SecureString -AsPlainText -Force))
        $GraphAppParams = @{
            Name = 'DUST PS Module Graph API Access'
            ClientCredential = $clientCredentials
            RedirectUri = 'https://localhost/'
            Tenant = 'biohivetech.onmicrosoft.com'
        }
        $graphApp = New-GraphApplication @GraphAppParams
        $authCode = $GraphApp | Get-GraphOauthAuthorizationCode
        Write-Verbose "Auth Code: $authCode"
        $graphAccessToken = Get-GraphOauthAccessToken -AuthenticationCode $authCode -Verbose
        Write-Verbose "Access Token Details: $graphAccessToken"
        $graphAccessToken.
        $accessToken = $graphAccessToken.GetAccessToken()
        Write-Verbose "Access Token: $accessToken"
        return $accessToken
    } catch {
        Write-Error $_
    }
}