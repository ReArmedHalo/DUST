Function Get-MailboxForwarding {
    [CmdletBinding()]Param(
        [Parameter()]
        [String] $UserPrincipalName
    )

    Test-IsConnectedToService 'ExchangeOnline'

    $mailboxesToSearch = $null;

    if ($UserPrincipalName) {
        $mailboxesToSearch = Get-Mailbox -Identity $UserPrincipalName
    } else {
        $mailboxesToSearch = Get-Mailbox -ResultSize Unlimited
    }

    $outputData = @()

    # Get Mailbox Forwarding
    # Forwarding can be set by the user in Mail Forwarding options of OWA or by an admin in Office 365 admin center
    $mailboxForwards = $mailboxesToSearch | Where-Object {$_.ForwardingSmtpAddress -gt ''} | Select-Object UserPrincipalName,ForwardingSmtpAddress,DeliverToMailboxAndForward

    ForEach ($rule in $mailboxForwards) {
        $forwarding = [MailboxForwardingRule]@{
            Mailbox = $rule.UserPrincipalName
            ForwardTo = $rule.ForwardingSmtpAddress
            DeliverToMailboxAndForward = $rule.DeliverToMailboxAndForward
        }

        $outputData += $forwarding
    }

    return $outputData
}

Function Get-InboxMailForwarding {
    [CmdletBinding()]Param(
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