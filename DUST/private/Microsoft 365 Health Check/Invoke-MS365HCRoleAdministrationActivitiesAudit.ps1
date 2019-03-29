<#
    .EXTERNALHELP ..\..\Invoke-MS365HCRoleAdministrationActivitiesAudit-help.xml
#>
Function Invoke-MS365HCRoleAdministrationActivitiesAudit {
    [CmdletBinding()] Param (
        [Parameter(Mandatory)]
        [String] $AccessToken
    )

    try {
        $graphRequestUri = "https://graph.microsoft.com/beta/auditlogs/directoryaudits?`$filter=activityDateTime gt 2019-03-27T08:00Z and loggedByService eq 'Core Directory' and activityDisplayName eq 'Remove member from role' or activityDisplayName eq 'Add member to role'"
        $response = Invoke-WebRequest -Method 'GET' -Uri $graphRequestUri -ContentType "application/json" -Headers @{Authorization = "Bearer $AccessToken"} -ErrorAction Stop
        $json = ($response.Content | ConvertFrom-Json)
        return $json.Value
    } catch {
        Write-Error $_
    }
}