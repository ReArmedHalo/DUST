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
        Write-Output '(Optional) Azure PowerShell Az Module - '
        Write-Output 'Azure AD PowerShell Module - https://www.powershellgallery.com/packages/AzureAD'
        Write-Output 'Exchange Online PowerShell V2 Module - https://www.powershellgallery.com/packages/ExchangeOnlineManagement'
        Write-Output 'SharePoint Online Management Shell - https://www.powershellgallery.com/packages/Microsoft.Online.SharePoint.PowerShell'
        Write-Output 'Teams PowerShell - https://www.powershellgallery.com/packages/MicrosoftTeams'
    } else {
        $currentPrincipal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
        if ($currentPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
            # We are running as an admin

            $progressActivity = 'Installing Dependencies'

            Write-Progress -Id 1 -Activity $progressActivity -Status "Preparing" -PercentComplete 5

            # Azure AD
            if (!(Get-InstalledModule -Name 'AzureAD' -ErrorAction SilentlyContinue)) {
                Write-Progress -Id 1 -Activity $progressActivity -Status 'Installing AzureAD Powershell Module'
                Install-Module -Name 'AzureAD' -Force
            }

            # Exchange Online Management PowerShell Module
            if (!(Get-InstalledModule -Name 'ExchangeOnlineManagement' -ErrorAction SilentlyContinue)) {
                Write-Progress -Id 1 -Activity $progressActivity -Status 'Installing Exchange Online PowerShell Module'
                Install-Module -Name 'ExchangeOnlineManagement' -Force -AcceptLicense
            }

            # SharePoint
            if (!(Get-InstalledModule -Name 'Microsoft.Online.SharePoint.PowerShell' -ErrorAction SilentlyContinue)) {
                Write-Progress -Id 1 -Activity $progressActivity -Status 'Installing SharePoint Online Management Shell PowerShell Module'
                Install-Module -Name 'Microsoft.Online.SharePoint.PowerShell' -Force
            }

            # Teams
            if (!(Get-InstalledModule -Name 'Microsoft.Online.SharePoint.PowerShell' -ErrorAction SilentlyContinue)) {
                Write-Progress -Id 1 -Activity $progressActivity -Status 'Installing Teams Powershell Module'
                Install-Module -Name 'Microsoft.Online.SharePoint.PowerShell' -Force
            }
        } else {
            # We are not running as an admin
            Write-Error "You must be running Powershell as an administrator to install all dependencies."
        }
    }
}