<#
#TODO Update this description further

.SYNOPSIS
    Fetches Azure AD Password Protection Fail events from all writable DCs

.DESCRIPTION
    Remotely connects and fetches the following event IDs from all writable DCs:
    - Audit-only Pass (would have failed customer password policy) : (Change) 30008, (Set) 30007
    - Audit-only Pass (would have failed Microsoft password policy)	: (Change) 30010, (Set) 30009
    - Audit-only Pass (would have failed combined Microsoft and customer password policies)	: (Change) 30028, (Set) 30029
    - Audit-only Pass (would have failed due to user name) : (Change) 30024, (Set) 30023

.PARAMETER StartDateTime
Filter the events to this start date and time.

.PARAMETER EndDateTime
Filter the events to this end date and time.

.EXAMPLE
    PS C:\> Get-AzureADPasswordProtectionEvents
    Fetches failure events from the last day

.EXAMPLE
    PS C:\> Get-AzureADPasswordProtectionEvents -IncludePassEvents
    Fetches all events from the last day, both pass and failures

.EXAMPLE
    PS C:\> Get-AzureADPasswordProtectionEvents -OnlyPassEvents
    Fetches only pass events from the last day

.EXAMPLE
    PS C:\> Get-AzureADPasswordProtectionEvents -StartDateTime ((Get-Date).AddDays(-7))
    Fetches failure events from the 7 days

.EXAMPLE
    PS C:\> Get-AzureADPasswordProtectionEvents -StartDateTime "10/1/2021"
    Fetches failure events since Oct 1, 2021

.EXAMPLE
    PS C:\> Get-AzureADPasswordProtectionEvents -StartDateTime "10/1/2021" -EndDateTime "10/7/2021"
    Fetches failure events between Oct 1, 2021 and Oct 7, 2021
    
.INPUTS
    None
.OUTPUTS
    System.Collections.Generic.List[PSCustomObject]
#>
function Get-AzureADPasswordProtectionEvents {
    [CmdletBinding(DefaultParameterSetName='FailOnlySet')]
    param (
        [Parameter(ParameterSetName='FailOnlySet')]
        [Parameter(ParameterSetName='IncludePassSet')]
        [Parameter(ParameterSetName='OnlyPassSet')]
        [datetime]
        $StartDateTime = (Get-Date).AddDays(-1),

        [Parameter(ParameterSetName='FailOnlySet')]
        [Parameter(ParameterSetName='IncludePassSet')]
        [Parameter(ParameterSetName='OnlyPassSet')]
        [datetime]
        $EndDateTime = (Get-Date),

        [Parameter(ParameterSetName='IncludePassSet')]
        [switch]
        $IncludePassEvents,

        [Parameter(ParameterSetName='OnlyPassSet')]
        [switch]
        $OnlyPassEvents
    )

    $domainControllers = Get-ADDomainController -Filter {IsReadOnly -eq $false} | Select-Object HostName
    
    if ($domainControllers.Count -eq 0) {
        throw 'No domain controllers found!'
    }

    Write-Progress -Activity 'Fetching events...' -Id 0
    
    #region Collection
    $allEvents = New-Object System.Collections.Generic.List[System.Diagnostics.Eventing.Reader.EventLogRecord]
    foreach ($controller in $domainControllers.HostName) {
        $eventScript = {
            param (
                [Parameter()]
                [datetime]
                $StartDateTime,
    
                [Parameter()]
                [datetime]
                $EndDateTime
            )
    
            return Get-WinEvent -FilterHashtable @{
                LogName = 'Microsoft-AzureADPasswordProtection-DCAgent/Admin'
                StartTime = $StartDateTime
                EndTime = $EndDateTime
                ID = 10014,10015,30002,30003,30004,30005,30007,30008,30009,30010,30021,30022,30023,30024,30026,30027,30028,30029
            } -ErrorAction SilentlyContinue
        }
    
        Write-Progress -Activity 'Fetching events...' -Status "Fetching events from: $controller" -Id 0

        try {
            $events = Invoke-Command -ComputerName $controller -ScriptBlock $eventScript -ArgumentList $StartDateTime,$EndDateTime -ErrorAction Stop
            $allEvents += $events
            Write-Verbose "Collected $($events.Count) events from $controller"
        } catch [System.Management.Automation.Remoting.PSRemotingTransportException] {
            $_
        }
    }
    Write-Progress -Activity 'Fetching events...' -Id 0 -Completed
    #endregion

    #region Processing
    # Hash table that maps Event IDs to Type and Reason codes
    $eventMapping = @{
        10014 = @{ # Change Pass
            Type = 'Pass'
            Reason = $null
        }
        10015 = @{ # Set Pass
            Type = 'Pass'
            Reason = $null
        }

        30002 = @{ # Change Fail - Customer Policy
            Type = 'ChangeFail'
            Reason = 'CustomerPolicy'
        }
        30003 = @{ # Set Fail - Customer Policy
            Type = 'SetFail'
            Reason = 'CustomerPolicy'
        }

        30004 = @{ # Change Fail - Microsoft Policy
            Type = 'ChangeFail'
            Reason = 'MicrosoftPolicy'
        }
        30005 = @{ # Set Fail - Microsoft Policy
            Type = 'SetFail'
            Reason = 'MicrosoftPolicy'
        }

        30007 = @{ # Set Audit Fail - Customer Policy
            Type = 'SetAuditFail'
            Reason = 'CustomerPolicy'
        }
        30008 = @{ # Change Audit Fail - Customer Policy
            Type = 'ChangeAuditFail'
            Reason = 'CustomerPolicy'
        }

        30009 = @{ # Set Audit Fail - Microsoft Policy
            Type = 'SetAuditFail'
            Reason = 'MicrosoftPolicy'
        }
        30010 = @{ # Change Audit Fail - Microsoft Policy
            Type = 'ChangeAuditFail'
            Reason = 'MicrosoftPolicy'
        }

        30021 = @{ # Change Fail - Username
            Type = 'ChangeFail'
            Reason = 'Username'
        }
        30022 = @{ # Set Fail - Username
            Type = 'SetFail'
            Reason = 'Username'
        }

        30023 = @{ # Set Audit Fail - Username
            Type = 'SetAuditFail'
            Reason = 'Username'
        }
        30024 = @{ # Change Audit Fail - Username
            Type = 'ChangeAuditFail'
            Reason = 'Username'
        }

        30026 = @{ # Change Fail - Combined Policy
            Type = 'ChangeFail'
            Reason = 'CombinedPolicy'
        }
        30027 = @{ # Set Fail - Combined Policy
            Type = 'SetFail'
            Reason = 'CombinedPolicy'
        }
        
        30028 = @{ # Change Audit Fail - Combined Policy
            Type = 'ChangeAuditFail'
            Reason = 'CombinedPolicy'
        }
        30029 = @{ # Set Audit Fail - Combined Policy
            Type = 'SetAuditFail'
            Reason = 'CombinedPolicy'
        }
    }

    # Parsing events and filtering what we want
    $summary = New-Object System.Collections.Generic.List[PSCustomObject]

    foreach ($event in $allEvents) {
        $samAccountName = ($event.Message | Select-String -Pattern '.*UserName: (.*)').Matches.Groups[1].Value

        $summary.Add([pscustomobject]@{
            DomainController = $event.PSComputerName
            DateTime = ($event.TimeCreated).ToString()
            Type = ($eventMapping.($event.ID).Type)
            Reason = ($eventMapping.($event.ID).Reason)
            samAccountName = $samAccountName
        })
    }
    #endregion

    if ($OnlyPassEvents) {
        return $summary | Where-Object {$_.Type -like '*Pass*'}
    }

    if ($IncludePassEvents) {
        return $summary
    }

    return $summary | Where-Object {$_.Type -like '*Fail*'}
}
