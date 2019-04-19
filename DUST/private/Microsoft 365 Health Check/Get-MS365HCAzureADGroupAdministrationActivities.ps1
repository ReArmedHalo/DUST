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
        Write-Verbose "Azure AD Group Administration Activities Access Token: $AccessToken"
        $graphRequestUri = "https://graph.microsoft.com/beta/auditlogs/directoryaudits?`$filter=activityDateTime gt $StartDate and loggedByService eq 'Core Directory' and category eq 'GroupManagement' and (activityDisplayName eq 'Add member to group' or activityDisplayName eq 'Remove member from group' or activityDisplayName eq 'Add owner to group' or activityDisplayName eq 'Remove owner from group')"
        Write-Verbose "Graph URL: $graphRequestUri"
        $response = Invoke-WebRequest -Method 'GET' -Uri $graphRequestUri -ContentType "application/json" -Headers @{Authorization = "Bearer $AccessToken"} -ErrorAction Stop
        write-verbose $response
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