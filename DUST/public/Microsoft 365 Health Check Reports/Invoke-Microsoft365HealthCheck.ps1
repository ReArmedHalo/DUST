# TODO: Clean this mess of a function up!

<#
    .EXTERNALHELP ..\..\Invoke-Microsoft365HealthCheck-help.xml
#>
Function Invoke-Microsoft365HealthCheck {
    [CmdletBinding(DefaultParameterSetName='All')] Param (
        # Converts to UTC from users local timezone
        [Parameter()]
        [DateTime] $StartDate = ((Get-Date).AddDays(-30)),

        #[Parameter()]
        #[Switch] $ConvertOutputTimeToLocalTimezone = $false,

        [Parameter()]
        [String] $OutputPath = 'DUST Microsoft 365 Health Check',

        [Parameter(ParameterSetName='All')]
        [Switch] $All,

        # Get-MS365HCAzureADGroupAdministrationActivities
        [Parameter(ParameterSetName='Selective')]
        [Switch] $AzureADGroupAdministrationActivities,

        # Get-MS365HCeDiscoveryEvents
        [Parameter(ParameterSetName='Selective')]
        [Switch] $eDiscoveryEvents,

        # Get-MS365HCExchangeMailboxActivities
        [Parameter(ParameterSetName='Selective')]
        [Switch] $ExchangeMailboxActivities,

        # Get-MS365HCInboxMailForwardOrRedirectRules
        [Parameter(ParameterSetName='Selective')]
        [Switch] $InboxMailForwardOrRedirectRules,

        # Get-MS365HCMailboxAuditStatus
        [Parameter(ParameterSetName='Selective')]
        [Switch] $MailboxAuditStatus,

        # Get-MS365HCOrganizationAuditStatus
        [Parameter(ParameterSetName='Selective')]
        [Switch] $OrganizationAuditStatus,

        # Get-MS365HCRoleAdministrationActiviiesAudit
        [Parameter(ParameterSetName='Selective')]
        [Switch] $RoleAdministrationActivities,

        # Get-MS365HCSecureScore
        [Parameter(ParameterSetName='Selective')]
        [Switch] $SecureScore,

        # Get-MS365HCUserAdministrationActivities
        [Parameter(ParameterSetName='Selective')]
        [Switch] $UserAdministrationActivities
    )

    Write-Verbose "Checking for output folder: $(Get-Location)\$OutputPath"
    if (Test-Path $OutputPath) {
        Write-Verbose 'Directory exists, is it empty?'
        $count = (Get-ChildItem -Path $OutputPath | Measure-Object).Count
        Write-Verbose "Directory contains: $count items!"
        if ($count -gt 0) {
            Write-Error "Output directory '$OutputPath' not empty! Please empty the directory or specify a new output folder." -ErrorAction Stop
        }
    } else {
        Write-Verbose "Creating directory: $(Get-Location)\$OutputPath"
        New-Item -Path $OutputPath -ItemType Directory
    }

    Write-Verbose "Input Start Timestamp: $StartDate"
    # Convert time to proper format and UTC
    $utcDateTime = "$(Get-Date ($StartDate).ToUniversalTime() -Format 'yyyy-MM-ddTHH:mm')Z"
    Write-Verbose "UTC Date Time: $utcDateTime"

    # Needed for Graph API
    $accessToken = $null
    $application = $null

    $azureADRequired = $false

    try {
        #region Login to services
        # Determine which services we need to login to
        if ( # AzureAD
            $All -or
            $AzureADGroupAdministrationActivities -or
            $RoleAdministrationActivities -or
            $SecureScore -or 
            $UserAdministrationActivities
        ) {
            $azureADRequired = $true
            Write-Verbose 'Reports requested require access to the Azure Graph API, connecting to AzureAD'
            Connect-AzureAD -ErrorAction Stop | Out-Null
        }

        if ( # ExchangeOnline
            $All -or
            $eDiscoveryEvents -or
            $ExchangeMailboxActivities -or
            $InboxMailForwardOrRedirectRules -or
            $MailboxAuditStatus -or
            $OrganizationAuditStatus
        ) {
            Write-Verbose 'Reports requested require Exchange Online, connecting to Exchange Online'
            Connect-OnlineService -Service ExchangeOnline -ErrorAction Stop | Out-Null   
        }
        #endregion Login to services

        # If we are asking for a report that requires the Graph API, build the app and get administrator approval for permissions
        if ( $azureADRequired ) {
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
            Write-Verbose "Consent Url: $consentUrl"

            #region I hate this method...
            # Prefer chrome, because chrome, but fallback to Internet Explore
            if ((Get-Item (Get-ItemProperty 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\App Paths\chrome.exe').'(Default)').VersionInfo) {
                [System.Diagnostics.Process]::Start('chrome.exe',"--incognito $consentUrl")   
            } else {
                [System.Diagnostics.Process]::Start('iexplore.exe',"$consentUrl -private")
            }

            Read-host 'Press enter to continue after authorizating the application'
            # Sleeping again for a few seconds just to be safe
            Start-Sleep -Milliseconds 2000

            # common may need to be $TenantDomain
            $uri = "https://login.microsoftonline.com/common/oauth2/v2.0/token"
            $body = @{
                client_id     = $application.ClientId
                scope         = 'https://graph.microsoft.com'
                client_secret = $application.ClientSecret
                grant_type    = 'client_credentials'
            }
            # Get OAuth 2.0 Token
            $tokenRequest = Invoke-WebRequest -Method Post -Uri $uri -ContentType 'application/x-www-form-urlencoded' -Body $body -UseBasicParsing
            # Access Token
            $accessToken = ($tokenRequest.Content | ConvertFrom-Json).access_token
            Write-Verbose "    Received: $accessToken"

            if (-Not ($accessToken)) {
                Write-Error 'We ran into an issue getting an access token.'
                Write-Error $tokenRequest.Content -ErrorAction Stop
            }
            #endregion I hate this method
        }

        #region Call Report Functions
        if ($All -or $AzureADGroupAdministrationActivities) {
            Get-MS365HCAzureADGroupAdministrationActivities -OutputPath $OutputPath -AccessToken $accessToken -StartDate $utcDateTime
        }
        
        # -- eDiscovery Events
        if ($All -or $eDiscoveryEvents) {
            Get-MS365HCeDiscoveryEvents -OutputPath $OutputPath -StartDate $StartDate
        }

        if ($All -or $ExchangeMailboxActivities) {
            Get-MS365HCExchangeMailboxActivities -OutputPath $OutputPath -StartDate $StartDate
        }

        # -- Forward or Redirect Mailbox rules
        if ($All -or $InboxMailForwardOrRedirectRules) {
            Get-MS365HCInboxMailForwardOrRedirectRules -OutputPath $OutputPath -StartDate $utcDateTime
        }

        if ($All -or $MailboxAuditStatus) {
            Get-MS365HCMailboxAuditStatus -OutputPath $OutputPath
        }

        # -- Organization and Mailbox auditing
        if ($All -or $OrganizationAuditStatus) {
            Get-MS365HCOrganizationMailboxAuditStatus -OutputPath $OutputPath
        }

        # -- Role Administration Activities
        if ($All -or $RoleAdministrationActivities) {
            Get-MS365HCRoleAdministrationActivities -OutputPath $OutputPath -AccessToken $accessToken -StartDate $utcDateTime
        }

        # -- Secure Score
        if ($All -or $SecureScore) {
            Get-MS365HCSecureScore -OutputPath $OutputPath -AccessToken $accessToken
        }

        # -- User creation or deletion rules
        if ($All -or $UserAdministrationActivities) {
            Get-MS365HCUserAdministrationActivities -OutputPath $OutputPath -AccessToken $accessToken -StartDate $utcDateTime
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
        Write-Verbose "Taking down Azure AD application with ObjectId: $($application.ObjectId)"
        Remove-DUSTAzureADApiApplication -ObjectId $application.ObjectId
        Write-Verbose 'Disconnecting any remote PowerShell sessions...'

        Remove-BrokenOrClosedDUSTPSSessions
        Write-Error "Below are any remaining PowerShell sessions, you may need to close them manually with Remove-PSSession"
        Get-PSSession

        Write-Error $_ -ErrorAction Stop
    }
}