# TODO: Clean this mess of a function up!

<#
    .EXTERNALHELP ..\..\Invoke-Microsoft365HealthCheck-help.xml
#>
Function Invoke-Microsoft365HealthCheck {
    [CmdletBinding(DefaultParameterSetName='All')] Param (
        [Parameter(Mandatory)]
        [String] $TenantDomain,

        # Converts to UTC from users local timezone
        [Parameter()]
        [DateTime] $StartDate = ((Get-Date).AddDays(-30)),

        #[Parameter()]
        #[Switch] $ConvertOutputTimeToLocalTimezone = $false,

        [Parameter()]
        [String] $OutputPath = '.\DUST Microsoft 365 Health Check',

        [Parameter(ParameterSetName='All')]
        [Switch] $All,

        # Get-MS365HCRoleAdministrationActiviiesAudit
        [Parameter(ParameterSetName='Selective')]
        [Switch] $RoleAdministrationActivities,

        # Get-MS365HCSecureScore
        [Parameter(ParameterSetName='Selective')]
        [Switch] $SecureScore,

        [Parameter(ParameterSetName='Selective')]
        [Switch] $OrganizationAuditStatus,

        [Parameter(ParameterSetName='Selective')]
        [Switch] $MailboxAuditStatus,

        [Parameter(ParameterSetName='Selective')]
        [Switch] $InboxMailForwardOrRedirectRules,

        [Parameter(ParameterSetName='Selective')]
        [Switch] $UserAdministrationActivities,

        [Parameter(ParameterSetName='Selective')]
        [Switch] $eDiscoveryEvents,

        [Parameter(ParameterSetName='Selective')]
        [Switch] $AzureADGroupAdministrationActivities,

        [Parameter(ParameterSetName='Selective')]
        [Switch] $ExchangeMailboxActivities
    )

    if (-Not (Test-Path $OutputPath)) {
        New-Item -Path $OutputPath -ItemType Directory
    }

    # Convert time to proper format and UTC
    $utcDateTime = "$(Get-Date ($StartDate).ToUniversalTime() -Format 'yyyy-MM-ddTHH:mm')Z"

    Write-Verbose "Input Date Time: $StartDate"
    Write-Verbose "UTC Date Time: $utcDateTime"

    # Needed for Graph API
    $accessToken = $null
    $application = $null

    try {
        #region Login to services
        # Determine which services we need to login to
        if ( # AzureAD
            $All -or
            $RoleAdministrationActivities -or
            $SecureScore -or
            $UserAdministrationActivities
        ) {
            Write-Verbose 'Reports requested require access to the Azure Graph API, connecting to AzureAD'
            Connect-AzureAD -ErrorAction Stop | Out-Null
        }

        if ( # ExchangeOnline
            $All -or
            $MailboxAuditStatus -or
            $eDiscoveryEvents -or
            $AzureADGroupAdministrationActivities -or
            $ExchangeMailboxActivities
        ) {
            Write-Verbose 'Reports requested require Exchange Online, connecting to Exchange Online'
            Connect-OnlineService -Service ExchangeOnline -ErrorAction Stop | Out-Null   
        }
        #endregion Login to services

        # If we are asking for a report that requires the Graph API, build the app and get administrator approval for permissions
        if ( # Azure AD
            $All -or
            $RoleAdministrationActivities -or
            $SecureScore -or
            $UserAdministrationActivities
        ) {
            Write-Verbose 'Preparing to build Azure AD Application...'
            $application = New-DUSTAzureADApiApplication
            Write-Verbose 'Application Details:'
            Write-Verbose "    Object ID: $($application.ObjectId)"
            Write-Verbose "    Client ID / App ID: $($application.ClientId)"
            Write-Verbose "    Client Secret: $($application.ClientSecret)"

            # It seems if we don't wait, trying to get consent might throw an error that the application doesn't exist
            # Not sure if there is a better way to wait to ensure the consent dialog won't error
            Start-Sleep -Milliseconds 10000
            Write-Verbose 'Fetching access token'

            $consentUrl = "https://login.microsoftonline.com/common/adminconsent?client_id=$($application.ClientId)"

            [System.Diagnostics.Process]::Start('chrome.exe',"--incognito $consentUrl")

            Read-host 'Press enter to continue after authorizating the application'

            $uri = "https://login.microsoftonline.com/$TenantDomain/oauth2/v2.0/token"
            # Construct Body
            $body = @{
                client_id     = $application.ClientId
                scope         = "https://graph.microsoft.com/.default"
                client_secret = $application.ClientSecret
                grant_type    = "client_credentials"
            }
            # Get OAuth 2.0 Token
            $tokenRequest = Invoke-WebRequest -Method Post -Uri $uri -ContentType "application/x-www-form-urlencoded" -Body $body -UseBasicParsing
            # Access Token
            $accessToken = ($tokenRequest.Content | ConvertFrom-Json).access_token

            Write-Verbose "    Received: $accessToken"
        }

        #region Call Report Functions
        # -- Role Administration Activities
        if ($All -or $RoleAdministrationActivities) {
            Get-MS365HCRoleAdministrationActivities -OutputPath $OutputPath -AccessToken $accessToken -StartDate $utcDateTime
        }

        # -- Secure Score
        if ($All -or $SecureScore) {
            Get-MS365HCSecureScore -OutputPath $OutputPath -AccessToken $accessToken
        }

        # -- Organization and Mailbox auditing
        if ($All -or $OrganizationAuditStatus) {
            Get-MS365HCOrganizationMailboxAuditStatus -OutputPath $OutputPath
        }

        if ($All -or $MailboxAuditStatus) {
            Get-MS365HCMailboxAuditStatus -OutputPath $OutputPath
        }

        # -- Forward or Redirect Mailbox rules
        if ($All -or $InboxMailForwardOrRedirectRules) {
            Get-MS365HCInboxMailForwardOrRedirectRules -OutputPath $OutputPath -StartDate $utcDateTime
        }

        # -- User creation or deletion rules
        if ($All -or $UserAdministrationActivities) {
            Get-MS365HCUserAdministrationActivities -OutputPath $OutputPath -AccessToken $accessToken -StartDate $utcDateTime
        }

        # -- eDiscovery Events
        if ($All -or $eDiscoveryEvents) {
            Get-MS365HCeDiscoveryEvents -OutputPath $OutputPath -StartDate $StartDate
        }
        #endregion Call Report Functions

        # -- Take down the temporary application, if required
        if ($All -or $application) {
            Write-Verbose 'Taking down Azure AD application'
            Remove-DUSTAzureADApiApplication -ObjectId $application.ObjectId
        }
    }
    catch {
        # Try and take down the temporary application
        Write-Verbose 'Taking down Azure AD application'
        Remove-DUSTAzureADApiApplication -ObjectId $application.ObjectId
        Write-Error $_
    }
}