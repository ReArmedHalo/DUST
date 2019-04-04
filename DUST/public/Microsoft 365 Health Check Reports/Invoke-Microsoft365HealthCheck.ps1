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
        [Switch] $MalwareAudit,

        [Parameter(ParameterSetName='Selective')]
        [Switch] $FlaggedAsPhishingAudit
    )

    if (-Not (Test-Path $OutputPath)) {
        New-Item -Path $OutputPath -ItemType Directory
    }

    # Convert time to proper format and UTC
    $utcDateTime = (Get-Date ($StartDate).ToUniversalTime() -Format 'yyyy-MM-ddTHH:mm')

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
            Connect-AzureAD -ErrorAction Stop | Out-Null
        }

        if ( # ExchangeOnline
            $All -or
            $MailboxAuditStatus
        ) {
            Connect-OnlineService -Service ExchangeOnline -ErrorAction Stop | Out-Null   
        }
        
        # If we are asking for a report that requires the Graph API, build the app
        if ($All -or $RoleAdministrationActivities -or $SecureScore) {
            $application = New-DUSTAzureADApiApplication -TenantDomain $TenantDomain
            $clientCredentials = New-Object System.Management.Automation.PSCredential($application.ClientId,($application.ClientSecret | ConvertTo-SecureString -AsPlainText -Force))

            # It seems if we don't wait, trying to get consent might throw an error that the application doesn't exist
            # Not sure if there is a better way to wait to ensure the consent dialog won't error
            Start-Sleep -Milliseconds 10000
            $accessToken = Get-DUSTAzureADApiApplicationConsent -ClientCredentials $clientCredentials -TenantDomain $TenantDomain
        }

        # Do the reports

        # -- Role Administration Activities
        if ($All -or $RoleAdministrationActivities) {
            Get-MS365HCRoleAdministrationActivitiesAudit -AccessToken $accessToken -OutputPath $OutputPath -StartDate $utcDateTime
        }

        # -- Secure Score
        if ($All -or $SecureScore) {
            Get-MS365HCSecureScore -AccessToken $accessToken -OutputPath $OutputPath
        }

        # -- Take down the temporary application, if required
        if ($All -or $accessToken) {
            #Remove-DUSTAzureADApiApplication -ObjectId $application.ObjectId
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
    }
    catch {
        # Try and take down the temporary application
        #Remove-DUSTAzureADApiApplication -ObjectId $application.ObjectId
        Write-Error $_
    }
}