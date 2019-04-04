Function Get-MS365HCOrganizationMailboxAuditStatus {
        [CmdletBinding()] param (
            [Parameter(Mandatory)]
            [String] $OutputPath
        )

        try {
            $auditStatus = Get-OrganizationConfig | Select-Object AuditDisabled
            $auditStatus | Export-Csv -Path "$OutputPath\OrganizationAuditStatus.csv" -NoTypeInformation
        } catch {
            Write-Error $_
        }
}