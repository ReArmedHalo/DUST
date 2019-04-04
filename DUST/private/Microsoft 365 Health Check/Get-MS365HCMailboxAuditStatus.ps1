Function Get-MS365HCMailboxAuditStatus {
    [CmdletBinding()] param (
        [Parameter(Mandatory)]
        [String] $OutputPath
    )

    try {
        $mailboxes = Get-Mailbox -ResultSize unlimited | Select-Object UserPrincipalName,DisplayName,DefaultAuditSet,AuditEnabled
        $mailboxes | Export-Csv -Path "$OutputPath\MailboxAuditStatus.csv" -NoTypeInformation
    } catch {
        Write-Error $_
    }
}