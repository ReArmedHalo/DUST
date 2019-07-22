<#
.EXTERNALHELP ..\..\Install-DUSTDependencies-help.xml
#>
Function Install-DUSTDependencies {
    [CmdletBinding()] Param (
        [Parameter()]
        [Switch] $ListOnly
    )

    if ($ListOnly) {
        Write-Output 'Please manually install the following dependencies:'
        Write-Output 'Exchange Online Remote PowerShell Module - https://docs.microsoft.com/en-us/powershell/exchange/exchange-online/connect-to-exchange-online-powershell/mfa-connect-to-exchange-online-powershell?view=exchange-ps'
        Write-Output 'Microsoft Online Services Sign-In Assistant for IT Professionals RTW (64-bit) - https://www.microsoft.com/en-us/download/details.aspx?id=28177'
        Write-Output 'Microsoft Online PowerShell Module - https://www.powershellgallery.com/packages/MSOnline'
        Write-Output 'Microsoft Azure AD PowerShell Module - https://www.powershellgallery.com/packages/AzureAD'
        Write-Output 'PSMSGraph PowerShell Module (Minimum Version: 1.0.27.60) - https://www.powershellgallery.com/packages/psmsgraph'
    } else {
        $currentPrincipal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
        if ($currentPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
            # We are running as an admin

            $progressActivity = 'Installing Dependencies'
            $stepMax = 8

            Write-Progress -Id 1 -Activity $progressActivity -Status "Preparing" -PercentComplete 5

            if ($IsWindows -or $ENV:OS -like 'Windows_NT') {
                # Exchange Online Remote PowerShell Module
                Write-Progress -Id 1 -Activity $progressActivity -Status "Step 1 of $stepMax" -CurrentOperation 'Installing Exchange Online PowerShell Module (ClickOnce)' -PercentComplete ((100/$stepMax)*1)
                Install-ClickOnce -Manifest 'https://cmdletpswmodule.blob.core.windows.net/exopsmodule/Microsoft.Online.CSE.PSModule.Client.application'

                # Microsoft Online Services Sign-In Assistant for IT Professionals RTW (x64)
                Write-Progress -Id 1 -Activity $progressActivity -Status "Step 2 of $stepMax" -CurrentOperation 'Installing Microsoft Online Services Sign-In Assistant for IT Professionals (x64 MSI)' -PercentComplete ((100/$stepMax)*2)
                Invoke-WebRequest -Uri 'https://download.microsoft.com/download/5/0/1/5017D39B-8E29-48C8-91A8-8D0E4968E6D4/en/msoidcli_64.msi' -UseBasicParsing -OutFile "$env:temp\msoidcli_64.msi"
                Start-Process -FilePath 'C:\Windows\System32\msiexec.exe' -ArgumentList '/qb /I', "$env:temp\msoidcli_64.msi" -WorkingDirectory "$env:temp" -Wait
            }

            Write-Progress -Id 1 -Activity $progressActivity -Status "Step 3 of $stepMax" -CurrentOperation 'Checking for Module: MSOnline' -PercentComplete ((100/$stepMax)*3)
            # Azure AD v1
            if (!(Get-InstalledModule -Name 'MSOnline' -ErrorAction SilentlyContinue)) {
                Write-Progress -Id 1 -Activity $progressActivity -Status "Step 4 of $stepMax" -CurrentOperation 'Installing MSOnline Powershell Module' -PercentComplete ((100/$stepMax)*4)
                Install-Module -Name 'MSOnline' -Force
            }

            Write-Progress -Id 1 -Activity $progressActivity -Status "Step 5 of $stepMax" -CurrentOperation 'Checking for Module: AzureAD' -PercentComplete ((100/$stepMax)*5)
            # Azure AD v2
            if (!(Get-InstalledModule -Name 'AzureAD' -ErrorAction SilentlyContinue)) {
                Write-Progress -Id 1 -Activity $progressActivity -Status "Step 6 of $stepMax" -CurrentOperation 'Installing AzureAD Powershell Module' -PercentComplete ((100/$stepMax)*6)
                Install-Module -Name 'AzureAD' -Force
            }

            Write-Progress -Id 1 -Activity $progressActivity -Status "Step 7 of $stepMax" -CurrentOperation 'Checking for Module: PSMSGraph' -PercentComplete ((100/$stepMax)*7)
            # PSMSGraph
            if (!(Get-InstalledModule -Name 'PSMSGraph' -ErrorAction SilentlyContinue)) {
                Write-Progress -Id 1 -Activity $progressActivity -Status "Step 8 of $stepMax" -CurrentOperation 'Installing PSMSGraph Powershell Module' -PercentComplete ((100/$stepMax)*8)
                Install-Module -Name 'PSMSGraph' -MinimumVersion '1.0.27.60' -Force
            }

        } else {
            # We are not running as an admin
            Write-Error "You must be running Powershell as an administrator to install all dependencies."
        }
    }
}