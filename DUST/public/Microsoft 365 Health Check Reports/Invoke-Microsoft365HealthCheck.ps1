# TODO: Clean this mess of a function up!

<#
    ISSUES

    Inbox forward rules
        RuleFrom blank

    Graph returns data in UTC
#>

<#
    .EXTERNALHELP ..\..\Invoke-Microsoft365HealthCheck-help.xml
#>
Function Invoke-Microsoft365HealthCheck {
    [CmdletBinding(DefaultParameterSetName='All')] Param (
        [Parameter(Mandatory)]
        [String] $TenantDomain,

        [Parameter()]
        [String] $ClientId,

        [Parameter()]
        [String] $ClientSecret,

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
    $application = [PSCustomObject]@{}
    [String]$accessToken = ''

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
            try {
                if ($ClientId -and $ClientSecret) {
                    Write-Verbose 'Using client credentials instead!'
                } else {
                    Connect-AzureAD -ErrorAction Stop | Out-Null
                }
            } catch {
                throw "Failed to connect to Azure AD. Will not continue."
            }
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
            try {
                if ($ClientId -and $ClientSecret) {
                    Write-Verbose 'Using client credentials instead!'
                } else {
                    Connect-OnlineService -Service ExchangeOnline -ErrorAction Stop | Out-Null   
                }
            } catch {
                throw "Failed to connect to Exchange Online. Will not continue."
            }
        }
        #endregion Login to services

        # If we are asking for a report that requires the Graph API, build the app and get administrator approval for permissions
        if ( $azureADRequired ) {
            if ($ClientId -and $ClientSecret) {
                $application = [PSCustomObject]@{
                    ObjectId = $null
                    ClientId = $ClientId
                    ClientSecret = $ClientSecret
                }

                $bodyParameters = @{
                    client_id = $application.ClientId
                    client_secret = $application.ClientSecret
                    scope = "https://graph.microsoft.com/.default"
                    grant_type = 'client_credentials'
                }
        
                Write-Verbose "Making token request: https://login.microsoftonline.com/$TenantDomain/oauth2/v2.0/token"
                $response = Invoke-RestMethod -Uri "https://login.microsoftonline.com/$TenantDomain/oauth2/v2.0/token" -Method "POST" -ContentType "application/x-www-form-urlencoded" -Body $bodyParameters
                $accessToken = $response.access_token
            } else {
                # Service Principals
                $application = New-DUSTAzureADApiApplication

                Write-Verbose 'Application Details:'
                Write-Verbose "    Object ID: $($application.ObjectId)"
                Write-Verbose "    Client ID / App ID: $($application.ClientId)"
                Write-Verbose "    Client Secret: $($application.ClientSecret)"

                # It seems if we don't wait, trying to get consent might throw an error that the application doesn't exist
                # Not sure if there is a better way to wait to ensure the consent dialog won't error, putting this in as a temporary fix
                Start-Sleep -Milliseconds 10000

                $accessToken = Get-DUSTAzureADApiApplicationConsent -Application $application -TenantDomain $TenantDomain
            }
            Write-Verbose 'Application Details:'
            Write-Verbose "    Object ID: $($application.ObjectId)"
            Write-Verbose "    Client ID / App ID: $($application.ClientId)"
            Write-Verbose "    Client Secret: $($application.ClientSecret)"
            Write-Verbose "    Access Token: $($accessToken)"
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
        if (($All -or $application) -and $application.ObjectId) {
            Write-Verbose "Taking down Azure AD application with ObjectId: $($application.ObjectId)"
            Remove-DUSTAzureADApiApplication -ObjectId $application.ObjectId
        }
    } catch {
        # Try and take down the temporary application
        if ($application.ObjectId) {
            Write-Verbose "Taking down Azure AD application with ObjectId: $($application.ObjectId)"
            Remove-DUSTAzureADApiApplication -ObjectId $application.ObjectId
        }
        Write-Verbose 'Disconnecting any remote PowerShell sessions...'

        Remove-BrokenOrClosedDUSTPSSessions
        Write-Error "Below are any remaining PowerShell sessions, you may need to close them manually with Remove-PSSession"
        Get-PSSession

        Write-Error $_ -ErrorAction Stop
    }
}