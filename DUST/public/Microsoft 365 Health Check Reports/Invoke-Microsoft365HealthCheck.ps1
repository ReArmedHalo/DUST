<#
    .EXTERNALHELP ..\..\Invoke-Microsoft365HealthCheck-help.xml
#>
Function Invoke-Microsoft365HealthCheck {
    [CmdletBinding(DefaultParameterSetName='All')] Param (
        [Parameter(Mandatory)]
        [String] $TenantDomain,

        [Parameter()]
        [String] $OutputPath = '.\DUST Microsoft 365 Health Check',

        [Parameter(ParameterSetName='All')]
        [Switch] $All,

        [Parameter(ParameterSetName='Selective')]
        [Switch] $RoleAdministrationActivities
    )

    if (-Not (Test-Path $OutputPath)) {
        New-Item -Path $OutputPath -ItemType Directory
    }
    try {
        Connect-AzureAD | Out-Null
        $application = New-DUSTAzureADApiApplication -TenantDomain $TenantDomain
        $clientCredentials = New-Object System.Management.Automation.PSCredential($application.ClientId,($application.ClientSecret | ConvertTo-SecureString -AsPlainText -Force))
        # It seems if we don't wait, trying to get consent might throw an error that the application doesn't exist
        # Not sure if there is a better way to wait to ensure the consent dialog won't error
        Start-Sleep -Milliseconds 10000
        $accessToken = Get-DUSTAzureADApiApplicationConsent -ClientCredentials $clientCredentials -TenantDomain $TenantDomain
        # -- Do the reports

        If ($All -or $RoleAdministrationActivities) {
            $results = Invoke-MS365HCRoleAdministrationActivitiesAudit -AccessToken $accessToken
            $outputData = @()
            foreach ($record in $results) {
                $entry = New-Object PSObject -Property @{
                    activityDateTime = $record.activityDateTime
                    activityDisplayName = $record.activityDisplayName
                    operationType = $record.operationType
                    initiatedBy = $record.initiatedBy.user.userPrincipalName
                    targetResources = ($record.targetResources | Where-Object {$_.type -eq 'user'}).userPrincipalName
                    roleDisplayName = (($record.targetResources | Where-Object {$_.type -eq 'user'}).modifiedProperties | Where-Object {$_.displayName -eq 'Role.DisplayName'}).newValue
                }
                $outputData += $entry
            }

            $outputData | Export-Csv -Path "$OutputPath\RoleAdministrationActivities.csv" -NoTypeInformation
        }

        # -- Take down the temporary application
        Remove-DUSTAzureADApiApplication -ObjectId $application.ObjectId
    }
    catch {
        Write-Error $_
    }
}