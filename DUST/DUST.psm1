$public = (Get-ChildItem -Path $PSScriptRoot\Public\*.ps1 -Recurse -ErrorAction SilentlyContinue)
$private = (Get-ChildItem -Path $PSScriptRoot\Private\*.ps1 -Recurse -ErrorAction SilentlyContinue)

foreach ($import in @($public + $private)) {
    try {
        . $import.fullname
    } catch {
        Write-Error "Failed to import function $($import.fullname): $_"
    }
}

New-Alias -Name Connect-DUSTAzureAD -Value Connect-AzureAD
Export-ModuleMember -Alias Connect-DUSTAzureAD -Function $public.BaseName