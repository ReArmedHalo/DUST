Function Get-MS365HCInboxMailForwardOrRedirectRules {
    [CmdletBinding()] param (
        [Parameter(Mandatory)]
        [String] $OutputPath,

        # In UTC
        [Parameter(Mandatory)]
        [String] $StartDate
    )

    try {
        $auditLogResults = Search-UnifiedAuditLog -Operations New-InboxRule,Set-InboxRule -StartDate $StartDate -EndDate (Get-Date -Format 'yyyy-MM-dd 23:59:59')

        $rules = @()
        foreach ($auditEntry in $auditLogResults) {
            $auditData = $auditEntry.AuditData | ConvertFrom-Json

            # Build parameters to have headers
            $parameters = New-Object PSObject
            foreach ($parameter in $auditData.Parameters) {
                $parameters | Add-Member -NotePropertyName $parameter.Name -NotePropertyValue $parameter.Value
            }

            # If this is a forwarding rule
            if ($parameters.ForwardTo -or $parameters.ForwardAsAttachmentTo -or $parameters.RedirectTo) {
                $hash = [Ordered]@{
                    CreationTime = $auditData.CreationTime
                    Operation = $auditData.Operation
                    UserId = $auditData.UserId
                    Type = $parameters.Name
                    RuleFrom = $parameters.From
                    ForwardTo = if ($parameters.ForwardTo) { $parameters.ForwardTo } else { $null }
                    ForwardAsAttachmentTo = if ($parameters.ForwardAsAttachmentTo) { $parameters.ForwardAsAttachmentTo } else { $null }
                    RedirectTo = if ($parameters.RedirectTo) { $parameters.RedirectTo } else { $null }
                }
                $outputEntry = New-object PSObject -Property $hash
                $rules += $outputEntry
            }
        }

        $rules | Export-Csv -Path "$OutputPath\InboxMailForwardOrRedirectRules.csv" -NoTypeInformation
    } catch {
        Write-Error $_
    }
}