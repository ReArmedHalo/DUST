<#
    .EXTERNALHELP ..\..\Get-InboxMailForwarding-help.xml
#>
Function Get-InboxMailForwarding {
    [CmdletBinding()] Param (
        [Parameter()]
        [String] $UserPrincipalName
    )

    Test-IsConnectedToService 'ExchangeOnline'

    $mailboxesToSearch = $null;

    if ($UserPrincipalName) {
        $mailboxesToSearch = Get-InboxRule -Mailbox $UserPrincipalName | Select-Object Mailbox,Name,ForwardTo,ForwardAsAttchmentTo,RedirectTo
    } else {
        $mailboxesToSearch = Get-Mailbox -ResultSize Unlimited
    }

    $outputData = @()

    # Get Inbox Rules with Forwarding or Redirects configured
    ForEach ($mailbox in $mailboxesToSearch) {
        $inboxRules = Get-InboxRule -Mailbox $mailbox.Alias | Select-Object Mailbox,Name,ForwardTo,ForwardAsAttchmentTo,RedirectTo
        ForEach ($rule in $inboxRules) {
            $forwarding = [InboxMailForwardingRule]@{
                Mailbox = $mailbox.UserPrincipalName
                Name = $rule.Name
                ForwardTo = $rule.ForwardTo
                ForwardAsAttachment = $rule.ForwardAsAttchmentTo
                RedirectTo = $rule.RedirectTo
            }

            $outputData += $forwarding
        }
    }

    return $outputData
}