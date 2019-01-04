Function Write-Verb {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [String]
        $Text
    )

    $caller = (Get-PSCallStack).Command[1]

    Write-Verbose "[$caller] $Text"
}

Function Write-Info {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [String]
        $Text
    )

    $caller = (Get-PSCallStack).Command[1]

    Write-Information "[$caller] $Text"
}