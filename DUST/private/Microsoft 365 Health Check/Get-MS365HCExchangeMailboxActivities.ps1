Function Get-MS365HCExchangeMailboxActivities {
    [CmdletBinding()] Param (
        [Parameter(Mandatory)]
        [String] $OutputPath,

        [Parameter(Mandatory)]
        [String] $AccessToken,

        # In UTC
        [Parameter(Mandatory)]
        [String] $StartDate
    )

    $results = Search-UnifiedAuditLog -Operations Add-MailboxPermission,Remove-MailboxPermission -StartDate $StartDate -EndDate (Get-Date -Format 'yyyy-MM-dd 23:59:59')
    
    $outputData = @()
    foreach ($auditRecord in $results) {
        $auditData = $auditRecord.AuditData | ConvertFrom-Json
        $hash = [Ordered]@{
            CreationTime = $auditData.CreationTime
            Operation = $auditData.Operation
            UserId = $auditData.UserId
        }
        $outputEntry = New-object PSObject -Property $hash
        $outputData += $outputEntry
    }
    $outputData | Export-Csv -Path "$OutputPath\ExchangeMailboxActivities.csv" -NoTypeInformation
}