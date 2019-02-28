# Use only for debug output, use standard Write-Verbose otherwise
Function Write-Verb {
    [CmdletBinding()] Param (
        [Parameter(Mandatory)]
        [String] $Message
    )

    $caller = (Get-PSCallStack).Command[1]

    Write-Verbose "[$caller] $Message"
}

# Use only for debug output, use standard Write-Information otherwise
Function Write-Info {
    [CmdletBinding()] Param (
        [Parameter(Mandatory)]
        [String] $Message
    )

    $caller = (Get-PSCallStack).Command[1]

    Write-Information "[$caller] $Message"
}