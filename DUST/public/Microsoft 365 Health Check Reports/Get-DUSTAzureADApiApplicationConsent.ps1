Function Get-DUSTAzureADApiApplicationConsent {
    [CmdletBinding()] param (
        [Parameter(Mandatory)]
        [PSCredential] $ClientCredentials,

        [Parameter(Mandatory)]
        [String] $TenantDomain
    )

    Write-Host "CliendId: $($ClientCredentials.UserName)"
    Write-Host "ClientSecret: $($ClientCredentials.GetNetworkCredential().Password)"
    Write-Host "TenantDomain: $TenantDomain"

    try {
        $graphAppParams = @{
            Name = 'DUST PS Module Graph API Access'
            ClientCredential = $ClientCredentials
            RedirectUri = 'https://localhost/'
            Tenant = $TenantDomain
        }
        $graphApplication = New-GraphApplication @GraphAppParams
        $authenticationCode = $graphApplication | Get-GraphOauthAuthorizationCode
        # Sleep again! Ran into occassional issues with it not allowing the function to return properly
        Start-Sleep -Milliseconds 10000
        $accessToken = Get-GraphOauthAccessToken -Resource 'https://graph.microsoft.com' -AuthenticationCode $authenticationCode
        if (!($accessToken)) {
            Start-Sleep -Milliseconds 10000
            $accessToken = Get-GraphOauthAccessToken -Resource 'https://graph.microsoft.com' -AuthenticationCode $authenticationCode
        }
        return $accessToken.GetAccessToken()
    } catch {
        Write-Error $_
    }
}