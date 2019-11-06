Function Get-MS365HCRoleAdministrationActivities {
    [CmdletBinding()] Param (
        [Parameter(Mandatory)]
        [String] $OutputPath,

        [Parameter(Mandatory)]
        [String] $AccessToken,

        # In UTC
        [Parameter(Mandatory)]
        [String] $StartDate
    )

    try {0
        $graphRequestUri = "https://graph.microsoft.com/v1.0/auditlogs/directoryaudits?`$filter=activityDateTime gt $StartDate and loggedByService eq 'Core Directory' and category eq 'RoleManagement' and (activityDisplayName eq 'Add member to role' or activityDisplayName eq 'Remove member from role')"
        Write-Verbose "Request URL: $graphRequestUri"
        $response = Invoke-WebRequest -Method 'GET' -Uri $graphRequestUri -ContentType "application/json" -Headers @{Authorization = "Bearer $AccessToken"} -ErrorAction Stop
        Write-Verbose $response
        $json = ($response.Content | ConvertFrom-Json)
        $results = $json.Value
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
    } catch {
        Write-Error $_
    }
}