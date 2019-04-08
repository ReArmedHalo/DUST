Function Get-MS365HCUserAdministrationActivities {
    [CmdletBinding()] Param (
        [Parameter(Mandatory)]
        [String] $OutputPath,

        # In UTC
        [Parameter(Mandatory)]
        [String] $StartDate
    )

    try {
        $graphRequestUri = "https://graph.microsoft.com/beta/auditlogs/directoryaudits?`$filter=activityDateTime gt $StartDate and loggedByService eq 'Core Directory' and category eq 'UserManagement' and activityDisplayName eq 'Add user' or activityDisplayName eq 'Remove user'"
        $response = Invoke-WebRequest -Method 'GET' -Uri $graphRequestUri -ContentType "application/json" -Headers @{Authorization = "Bearer $AccessToken"} -ErrorAction Stop
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
            }
            $outputData += $entry
        }
        $outputData | Export-Csv -Path "$OutputPath\UserAdministrationActivities.csv" -NoTypeInformation
    } catch {
        Write-Error $_
    }

}