Function Get-DUSTAzureADApiApplicationConsent {
    [CmdletBinding()] param (
        [Parameter(Mandatory)]
        [PSCredential] $ClientCredentials,

        [Parameter(Mandatory)]
        [String] $TenantDomain
    )
    try {
        $graphAppParams = @{
            Name = 'DUST PS Module Graph API Access'
            ClientCredential = $ClientCredentials
            RedirectUri = 'https://localhost/'
            Tenant = $TenantDomain
        }
        $graphApplication = New-GraphApplication @GraphAppParams
        $authenticationCode = $graphApplication | Get-GraphOauthAuthorizationCode 
        $accessToken = $authenticationCode | Get-GraphOauthAccessToken -Resource 'https://graph.microsoft.com'
        return $accessToken
    } catch {
        Write-Error $_
    }
}