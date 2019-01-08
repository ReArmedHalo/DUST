Function Convert-ToImmutableId {
    [cmdletbinding()]Param(
        [Parameter(ValueFromPipeline)]
        [String] $Identity
    )

    Process {
        $guid = (Get-AdUser -Identity $Identity).ObjectGuid
        [System.Convert]::ToBase64String($guid.tobytearray())
    }
}