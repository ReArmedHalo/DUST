<#
    .EXTERNALHELP ..\..\Get-MFAReport-help.xml
#>

<# INCOMPLETE #>
Function Get-MFAReport {
    [CmdletBinding()] Param (
        [Parameter(Mandatory)]
        [String] $Path
    )

    $shared = Get-Mailbox -RecipientTypeDetails SharedMailbox,RoomMailbox,EquipmentMailbox,DiscoveryMailbox -ResultSize Unlimited | Select-Object UserPrincipalName
    $users = Get-MsolUser -All:$true | Select-Object DisplayName,UserPrincipalName,@{Name="MultifactorAuthentication";Expression={$(if($_.StrongAuthenticationMethods.Count -eq 0){ "Unregistered" } else { "Registered" })}}

    foreach ($user in $users) {
        if ($shared.UserPrincipalName -notcontains $user.UserPrincpalName) {
            $user | Export-Csv -Append -Path $Path -NoTypeInformation -ErrorAction Stop
        }
    }
}
