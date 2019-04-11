<#
    .EXTERNALHELP ..\..\Invoke-Microsoft365HealthCheck-help.xml
#>
Function Invoke-Microsoft365HealthCheck {
    [CmdletBinding(DefaultParameterSetName='All')] Param (
        [Parameter(Mandatory)]
        [String] $TenantDomain,

        # Converts to UTC from users local timezone
        [Parameter()]
        [DateTime] $StartDate = "$(Get-Date (Get-Date).AddDays(-30).ToUniversalTime() -Format 'yyyy-MM-ddTHH:mm')Z",

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
        [Switch] $UserAdministrationActivities
    )

    if (-Not (Test-Path $OutputPath)) {
        New-Item -Path $OutputPath -ItemType Directory
    }

    # Convert time to proper format and UTC
    $utcDateTime = (Get-Date ($StartDate).ToUniversalTime() -Format 'yyyy-MM-ddTHH:mm')

    Write-Verbose "Input Date Time: $StartDate"
    Write-Verbose "UTC Date Time: $utcDateTime"

    # Needed for Graph API
    $accessToken = $null
    $application = $null

    try {
        # Determine which services we need to login to
        if ( # AzureAD
            $All -or
            $RoleAdministrationActivities -or
            $SecureScore
        ) {
            Write-Verbose 'Reports requested require access to the Azure Graph API, connecting to AzureAD'
            Connect-AzureAD -ErrorAction Stop | Out-Null
        }

        if ( # ExchangeOnline
            $All -or
            $MailboxAuditStatus
        ) {
            Write-Verbose 'Reports requested require Exchange Online, connecting to Exchange Online'
            Connect-OnlineService -Service ExchangeOnline -ErrorAction Stop | Out-Null   
        }
        
        # If we are asking for a report that requires the Graph API, build the app and get administrator approval for permissions
        if ($All -or $RoleAdministrationActivities -or $SecureScore -or $UserAdministrationActivities) {
            Write-Verbose 'Preparing to build Azure AD Application...'
            $application = New-DUSTAzureADApiApplication
            Write-Verbose 'Application Details:'
            Write-Verbose "    Object ID: $($application.ObjectId)"
            Write-Verbose "    Client ID / App ID: $($application.ClientId)"

            # It seems if we don't wait, trying to get consent might throw an error that the application doesn't exist
            # Not sure if there is a better way to wait to ensure the consent dialog won't error
            Start-Sleep -Milliseconds 10000
            Write-Verbose 'Fetching access token'
            $accessToken = Get-DUSTAzureADApiApplicationConsent -ClientId $application.ClientId -TenantDomain $TenantDomain
            Write-Verbose "    Received: $accessToken"
            if (!($accessToken)) {
                Write-Error 'Failed to obtain access token!'
            }
        }

        # Do the reports

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

        # -- Take down the temporary application, if required
        if ($All -or $accessToken) {
            Write-Verbose 'Taking down Azure AD application'
            #Remove-DUSTAzureADApiApplication -ObjectId $application.ObjectId
        }
    }
    catch {
        # Try and take down the temporary application
        Write-Verbose 'Taking down Azure AD application'
        #Remove-DUSTAzureADApiApplication -ObjectId $application.ObjectId
        Write-Error $_
    }
}