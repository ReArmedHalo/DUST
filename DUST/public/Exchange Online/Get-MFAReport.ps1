<#
    .EXTERNALHELP ..\..\Get-MFAReport-help.xml
#>

<# INCOMPLETE #>
Function Get-MFAReport {
    [CmdletBinding()] Param (
        [Parameter()]
        [String] $ExportTo
    )

    Write-Progress -Activity "Fetching..." -CurrentOperation "Fetching shared and system mailboxes from Exchange Online..." -PercentComplete -1
    $shared = Get-Mailbox -RecipientTypeDetails SharedMailbox,RoomMailbox,EquipmentMailbox,DiscoveryMailbox -ResultSize Unlimited | Select-Object UserPrincipalName
    Write-Progress -Activity "Fetching..." -CurrentOperation "Fetching users from Azure AD..." -PercentComplete -1
    $users = Get-MsolUser | Select-Object DisplayName,UserPrincipalName,@{Name="MultifactorAuthentication";Expression={$(if($_.StrongAuthenticationMethods.Count -eq 0){ "Unregistered" } else { "Registered" })}}

    Write-Progress -Activity "Compiling..." -Status "Sorting through the data..." -PercentComplete 0
    $i = 1
    $percentComplete = 0
    $stepInterval = (100 / $users.Count)
    foreach ($user in $users) {
        start-sleep 2
        Write-Progress -Activity "Compiling..." -Status "Sorting through the data..." -CurrentOperation "Processing user $($user.UserPrincipalName) ($i of $($users.Count))" -PercentComplete $percentComplete
        if ($shared.UserPrincipalName -contains $user.UserPrincpalName) {
            $user | Export-Csv -Append -Path .\mfa.csv -NoTypeInformation -ErrorAction Stop
        }
        $percentComplete += $stepInterval
        $i++
    }

}