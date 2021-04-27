Function Get-MS365HCAzureADGroupAdministrationActivities {
    [CmdletBinding()] Param (
        [Parameter(Mandatory)]
        [String] $OutputPath,

        [Parameter(Mandatory)]
        [String] $AccessToken,

        # In UTC
        [Parameter(Mandatory)]
        [String] $StartDate
    )

    try {
        $graphRequestUri = "https://graph.microsoft.com/v1.0/auditlogs/directoryaudits?`$filter=activityDateTime gt $StartDate and loggedByService eq 'Core Directory' and category eq 'GroupManagement' and (activityDisplayName eq 'Add member to group' or activityDisplayName eq 'Remove member from group' or activityDisplayName eq 'Add owner to group' or activityDisplayName eq 'Remove owner from group' or activityDisplayName eq 'Add group' or activityDisplayName eq 'Delete group')"
        $response = Invoke-WebRequest -Method 'GET' -Uri $graphRequestUri -ContentType "application/json" -Headers @{Authorization = "Bearer $AccessToken"} -ErrorAction Stop
        $json = ($response.Content | ConvertFrom-Json)
        $results = $json.Value

        $outputData = @()
        foreach ($record in $results) {
            $entry = New-Object PSObject -Property @{
                activityDateTime = $record.activityDateTime
                activityDisplayName = $record.activityDisplayName
                operationType = $record.operationType
                targetGroup = $null
                targetResource = $null
                targetResourceType = $null
                initiatedBy = $null
                initiatedByType = $null
            }
            
            if (($record.activityDisplayName -like '*from group') -or ($record.activityDisplayName -like '*to group')) {
                # Add/Remove members
                if ($record.activityDisplayName -like '*to group') { # Add
                    $entry.targetGroup = ((($record.targetResources | Where-Object {$_.type -eq 'User'}).modifiedProperties | Where-Object {$_.DisplayName -eq 'Group.DisplayName'}).newValue) -replace '"', ""
                }
                if ($record.activityDisplayName -like '*from group') { # Remove
                    $entry.targetGroup = ((($record.targetResources | Where-Object {$_.type -eq 'User'}).modifiedProperties | Where-Object {$_.DisplayName -eq 'Group.DisplayName'}).oldValue) -replace '"', ""
                }
            }

            if (($record.activityDisplayName -like 'Add group') -or ($record.activityDisplayName -like 'Delete group')) {
                # Add/Delete group
                $entry.targetGroup = ($record.targetResources | Where-Object {$_.type -eq 'Group'}).DisplayName
            }

            if ($record.targetResources.type -contains 'Device') { # Device
                $entry.targetResource = ($record.targetResources | Where-Object {$_.type -eq 'Device'}).displayName
                $entry.targetResourceType = 'Device'
            } elseif ($record.targetResources.type -contains 'User') { # User
                $entry.targetResource = ($record.targetResources | Where-Object {$_.type -eq 'User'}).userPrincipalName
                $entry.targetResourceType = 'User'
            } elseif ($record.targetResources.type -contains 'Group') { # Group
                $entry.targetResource = ($record.targetResources | Where-Object {$_.type -eq 'Group'}).displayName
                $entry.targetResourceType = 'Group'
            }

            if ($record.initiatedBy.app) {
                $entry.initiatedBy = $record.initiatedBy.app.displayName
                $entry.initiatedByType = 'App'
            } elseif ($record.initiatedBy.user) {
                $entry.initiatedBy = $record.initiatedBy.user.userPrincipalName
                $entry.initiatedByType = 'User'
            }

            $outputData += $entry
        }
        $outputData | Export-Csv -Path "$OutputPath\AzureADGroupAdministrationActivities.csv" -NoTypeInformation
    } catch {
        Write-Error $_
    }
}