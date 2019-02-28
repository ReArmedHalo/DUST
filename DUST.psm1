foreach($import in @( Get-ChildItem -Path "$PSScriptRoot\Support\*.ps1" -ErrorAction SilentlyContinue )) {
    try {
        . $import.fullname
    } catch {
        Write-Error -Message "Failed to import function $($import.fullname): $_"
    }
}