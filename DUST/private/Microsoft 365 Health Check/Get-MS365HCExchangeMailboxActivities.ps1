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
        if ($parameters.Identity -notlike "*DiscoverySearchMailbox*") {
            $hash = [Ordered]@{
                CreationTime = $auditData.CreationTime
                Operation = $auditData.Operation
                InitiatorUserId = $auditData.UserId
                TargetUserPrincipalName = (Get-Mailbox -Identity $parameters.Identity).UserPrincipalName
                User = (Get-Mailbox -Identity $parameters.User).UserPrincipalName
                AccessRights = $parameters.AccessRights
            }
            $outputData += New-object PSObject -Property $hash
        }
    }
    $outputData | Export-Csv -Path "$OutputPath\ExchangeMailboxActivities.csv" -NoTypeInformation
}