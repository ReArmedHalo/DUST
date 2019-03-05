foreach($import in @( Get-ChildItem -Path "$PSScriptRoot\Support\*.ps1" -ErrorAction SilentlyContinue )) {
    try {
        . $import.fullname
    } catch {
        Write-Error -Message "Failed to import function $($import.fullname): $_"
    }
}

# Update Check
<#if (Test-Connection -ComputerName '8.8.8.8' -Count 1 -Quiet) {
    $installedDUST = Get-InstalledModule -Name DUST -ErrorAction SilentlyContinue
    if ($installedDUST) {
        $installedVersion = ($installedDUST.Version)
        $latestVersion = ((Find-Module -Name DUST).Version)
        if ([System.Version]$installedVersion -lt [System.Version]$latestVersion) {
            Write-Output 'Newer version of DUST module available!'
            Write-Output "Installed: $installedVersion | Latest Available: $latestVersion"
            Write-Output 'Run "Update-Module DUST" from an administrative prompt to install the update'
        }
    }
}#>