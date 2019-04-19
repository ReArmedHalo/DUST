Function Get-MS365HCExchangeMailboxActivities {
    [CmdletBinding()] Param (
        [Parameter(Mandatory)]
        [String] $OutputPath,

        # In UTC
        [Parameter(Mandatory)]
        [String] $StartDate
    )

    $results = Search-UnifiedAuditLog -Operations Add-MailboxPermission,Remove-MailboxPermission -StartDate $StartDate -EndDate (Get-Date -Format 'yyyy-MM-dd 23:59:59')
    
    $outputData = @()
    foreach ($auditRecord in $results) {
        $auditData = $auditRecord.AuditData | ConvertFrom-Json
        $parameters = New-Object PSObject
        foreach ($parameter in $auditData.Parameters) {
            $parameters | Add-Member -NotePropertyName $parameter.Name -NotePropertyValue $parameter.Value
        }
        $hash = [Ordered]@{
            CreationTime = $auditData.CreationTime
            Operation = $auditData.Operation
            UserId = $auditData.UserId
            UserPrincipalName = (Get-Mailbox -Identity $auditData.Identity | Select-Object UserPrincipalName)
            User = $parameters.User
            AccessRights = $parameters.AccessRights
        }
        $outputEntry = New-object PSObject -Property $hash
        $outputData += $outputEntry
    }
    $outputData | Export-Csv -Path "$OutputPath\ExchangeMailboxActivities.csv" -NoTypeInformation
}