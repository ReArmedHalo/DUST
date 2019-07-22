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
            Tenant = $TenantDomain
        }
        $graphApp = New-GraphApplication @GraphAppParams
        $tokenSuccess = $false
        while (!$tokenSuccess) {
            Write-Output "Requesting application permissions... If you receive an error, close the dialog and it will automatically be attempted again."
            $authCode = $GraphApp | Get-GraphOauthAuthorizationCode
            if ($authCode.Success) {
                $tokenSuccess = $true
            } else {
                $tryAgain = Read-Host -Prompt 'Try again? (y/n): [y] '
                if ([string]::IsNullOrWhiteSpace($tryAgain)) {
                    Start-Sleep -Milliseconds 5000
                    throw 'User aborted.'
                }
            }
        }
        Write-Verbose "Auth Code: $authCode"
        $graphAccessToken = Get-GraphOauthAccessToken -AuthenticationCode $authCode
        Write-Verbose "Access Token Details: $graphAccessToken"
        
        $accessToken = $graphAccessToken.GetAccessToken()
        Write-Verbose "Access Token: $accessToken"
        return $accessToken
    } catch {
        Write-Error $_
    }
}