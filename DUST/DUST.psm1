$public = (Get-ChildItem -Path $PSScriptRoot\Public\*.ps1 -Recurse -ErrorAction SilentlyContinue)
$private = (Get-ChildItem -Path $PSScriptRoot\Private\*.ps1 -Recurse -ErrorAction SilentlyContinue)

foreach ($import in @($public + $private)) {
    try {
        . $import.fullname
    } catch {
        Write-Error "Failed to import function $($import.fullname): $_"
    }
}

$local = Get-Module -Name DUST
if ($local) { # In case the module is loaded via source
    $online = Find-Module -Repository PSGallery -Name DUST
    if ($online.Version -gt $local.Version) {
        Write-Host "DUST Module Update Available!"
        Write-Host "Latest: $($online.Version)"
        Write-Host "Installed: $($local.Version)"
    } 
}

New-Alias -Name Connect-DUSTAzureAD -Value Connect-AzureAD
Export-ModuleMember -Alias Connect-DUSTAzureAD -Function $public.BaseName