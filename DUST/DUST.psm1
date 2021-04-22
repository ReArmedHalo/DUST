$public = (Get-ChildItem -Path $PSScriptRoot\Public\*.ps1 -Recurse -ErrorAction SilentlyContinue)

foreach ($import in @($public + $private)) {
    try {
        . $import.fullname
    } catch {
        Write-Error "Failed to import function $($import.fullname): $_"
    }
}

Export-ModuleMember -Function $public.BaseName