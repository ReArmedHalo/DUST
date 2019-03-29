
Function Remove-BrokenOrClosedDUSTPSSessions {
    [CmdletBinding(SupportsShouldProcess)] Param ()

    if ($PSCmdlet.ShouldProcess('Find and remove any closed or broken PSSessions that start with "DUST-".')) {
        $psBroken = Get-PSSession | where-object {$_.State -like "*Broken*" -and $_.Name -like "DUST-*"}
        $psClosed = Get-PSSession | where-object {$_.State -like "*Closed*" -and $_.Name -like "DUST-*"}

        if ($psBroken.count -gt 0) {
            for ($index = 0; $index -lt $psBroken.count; $index++) {
                Write-Verbose "Removing broken session: $psBroken[$index].Name"
                Remove-PSSession -session $psBroken[$index]
            }
        }

        if ($psClosed.count -gt 0) {
            for ($index = 0; $index -lt $psClosed.count; $index++) {
                Write-Verbose "Removing closed session: $psBroken[$index].Name"
                Remove-PSSession -session $psClosed[$index]
            }
        }
    }
}