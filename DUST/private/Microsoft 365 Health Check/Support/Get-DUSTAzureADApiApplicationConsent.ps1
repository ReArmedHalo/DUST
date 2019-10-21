Function Get-DUSTAzureADApiApplicationConsent {
    [CmdletBinding()] param (
        [Parameter(Mandatory)]
        [PSObject] $Application,

        [Parameter(Mandatory)]
        [String] $TenantDomain
    )

    Write-Verbose "Parameter: Application"
    Write-Verbose $Application

    $applicationProvisioningComplete = $false
    while (!($applicationProvisioningComplete)) {
        $azureADApplications = Get-AzureADApplication | Select-Object ObjectId
        if ($azureADApplications.ObjectId -contains $Application.ObjectId) {
            $applicationProvisioningComplete = $true
        }
        Start-Sleep -Milliseconds 5000
    }
    
    try {
        Write-Verbose "Building PS Credentials needed for Graph App..."
        $clientCredentials = New-Object System.Management.Automation.PSCredential($Application.ClientId,($Application.ClientSecret | ConvertTo-SecureString -AsPlainText -Force))
        $graphAppParams = @{
            Name = 'DUST PS Module Graph API Access'
            ClientCredential = $clientCredentials
            RedirectUri = 'https://localhost/'
            Tenant = $TenantDomain
        }
        
        Write-Verbose "Creating Graph app configuration..."
        $graphApp = New-GraphApplication @graphAppParams
        Write-Verbose $graphApp

        $authCode = $GraphApp | Get-GraphOauthAuthorizationCode -ForcePrompt admin_consent -verbose
        $graphAccessToken = Get-GraphOauthAccessToken -AuthenticationCode $authCode -Resource "https://graph.microsoft.com" -Verbose

        [String]$accessToken = $graphAccessToken.GetAccessToken()
        Write-Verbose "Access Token Details:"
        Write-Verbose $graphAccessToken
        Write-Verbose "    Access Token:"
        Write-Verbose $accessToken

        return $accessToken
    } catch {
        Write-Error $_
    }
}