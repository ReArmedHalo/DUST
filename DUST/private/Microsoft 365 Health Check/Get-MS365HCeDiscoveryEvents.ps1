Function Get-MS365HCeDiscoveryEvents {
    [CmdletBinding()] Param (
        [Parameter(Mandatory)]
        [String] $OutputPath,

        # In UTC
        [Parameter(Mandatory)]
        [String] $StartDate
    )

    $eDiscoveryEvents = Search-UnifiedAuditLog -RecordType Discovery -StartDate $StartDate -EndDate (Get-Date -Format 'yyyy-MM-dd 23:59:59')
    
    $outputData = @()
    foreach ($auditRecord in $eDiscoveryEvents) {
        $auditData = $auditRecord.AuditData | ConvertFrom-Json
        $hash = [Ordered]@{
            CreationTime = $auditData.CreationTime
            Operation = $auditData.Operation
            UserId = $auditData.UserId
            Case = $auditData.Case
            ObjectId = $auditData.ObjectId
        }
        $outputEntry = New-object PSObject -Property $hash
        $outputData += $outputEntry
    }
    $outputData | Export-Csv -Path "$OutputPath\eDiscoveryEvents.csv" -NoTypeInformation
}