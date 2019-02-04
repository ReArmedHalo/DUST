<#
    .Synopsis
    Facade to individual connection handlers
    .DESCRIPTION
    Handles calling the proper connection handler for a given service.
    .EXAMPLE
    Connect-OnlineService ExchangeOnline
    .EXAMPLE
    Connect-OnlineService ExchangeOnline -Delegated -ClientDomain fabrikam.com
#>
Function Connect-OnlineService {
    [CmdletBinding()] Param (
        [Parameter(ParameterSetName='Direct',Mandatory,Position=1)]
        [Parameter(ParameterSetName='Delegated',Mandatory,Position=1)]
        [ValidateSet('MicrosoftOnline','AzureADv2','ExchangeOnline','SecurityAndComplianceCenter')]
        [String] $Service,

        [Parameter(ParameterSetName='Delegated',Position=2)]
        [Switch] $Delegated,

        [Parameter(ParameterSetName='Delegated',Mandatory,Position=3)]
        [String] $ClientDomain,

        [Parameter(ParameterSetName='Delegated',Mandatory,Position=4)]
        [PSCredential] $Credential
    )

    if ($Delegated) {
        if ($Service -match 'SecurityAndComplianceCenter') {
            Write-Warning 'Security and Compliance Center does not support delegated access at all. Redirecting your request to the non-delegated connection handler...'
            Connect-SecurityAndComplianceCenter
        } else {
            $cmd = Get-Command "Connect-$Service"
            & $cmd -Delegated -ClientDomain $ClientDomain -Credential $Credential
            #Invoke-Expression -Command "Connect-$Service -Delegated -ClientDomain $ClientDomain -Credential $Credential"
        }
    } else {
        & (Get-Command "Connect-$Service")
    }
}

Function Test-IsConnectedToService {
    [CmdletBinding()] Param (
        [ValidateSet('MicrosoftOnline','AzureADv2','ExchangeOnline','SecurityAndComplianceCenter')]
        [String] $Service
    )

    switch ($Service) {
        'MicrosoftOnline' {
            try {
                Get-MsolCompanyInformation
            } catch [Microsoft.Online.Administration.Automation.MicrosoftOnlineException] {
                Write-Error 'Not connected to Microsoft Online! Please run ''Connect-OnlineService MicrosoftOnline'' before using this command.'
            }
        }
        'AzureADv2' {
            try {
                Get-AzureADTenantDetail
            } catch [Microsoft.Open.Azure.AD.CommonLibrary.AadNeedAuthenticationException] {
                Write-Error 'Not connected to Azure AD! Please run ''Connect-OnlineService AzureADv2'' before using this command.'
            }
        }
        'ExchangeOnline' {
            if (!(Get-PSSession | Where-Object { ($_.Name -like 'DUST-EXO' -or $_.ConfigurationName -like 'Microsoft.Exchange') -and $_.State -like 'Opened' })) {
                Write-Error 'Not connected to Exchange online! Please use ''Connect-OnlineService ExchangeOnline'' before using this command.'
            }
        }
        'SecurityAndComplianceCenter' {
            if (!(Get-PSSession | Where-Object { ($_.Name -like 'DUST-SCC' -or $_.ConfigurationName -like 'Microsoft.Exchange') -and $_.State -like 'Opened' })) {
                Write-Error 'Not connected to the Security and Compliance Center! Please use ''Connect-OnlineService SecurityAndComplianceCenter'' before using this command.'
            }
        }
    }

}

Function Remove-BrokenOrClosedDUSTPSSessions {
    [CmdletBinding()] Param ()

    Write-Verb "Checking for broken or closed connections..."
    $psBroken = Get-PSSession | where-object {$_.State -like "*Broken*" -and $_.Name -like "DUST-*"}
    $psClosed = Get-PSSession | where-object {$_.State -like "*Closed*" -and $_.Name -like "DUST-*"}

    if ($psBroken.count -gt 0)
    {
        for ($index = 0; $index -lt $psBroken.count; $index++)
        {
            Write-Verb "Removing broken session: $psBroken[$index].Name"
            Remove-PSSession -session $psBroken[$index]
        }
    }

    if ($psClosed.count -gt 0)
    {
        for ($index = 0; $index -lt $psClosed.count; $index++)
        {
            Write-Verb "Removing closed session: $psBroken[$index].Name"
            Remove-PSSession -session $psClosed[$index]
        }
    }
    Write-Verb "Done"
}

Function Install-DUSTDependencies {
    [CmdletBinding()] Param ()

    # WORK IN PROGRESS
    # This function currently doesn't operate properly, most code here was thrown down just so dependencies are documented somewhere

    $currentPrincipal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
    
    if ($currentPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
        # We are running as an admin
        # TODO: Write-Progress instead of write-outputs

        # Exchange Online Remote PowerShell Modul
        Write-Information 'Downloading Exchange Online Powershell Module...'
        Invoke-WebRequest -Uri 'https://cmdletpswmodule.blob.core.windows.net/exopsmodule/Microsoft.Online.CSE.PSModule.Client.application' -UseBasicParsing -OutFile "$env:temp\Microsoft.Online.CSE.PSModule.Client.application"
        Write-Output 'You will be prompted to complete the installation of the Exchange Online Powershell Module. Please follow the prompts.'
        Write-Information 'Installing Exchange Online Powershell Module...'
        Start-Process -FilePath "$env:temp\Microsoft.Online.CSE.PSModule.Client.application" -WorkingDirectory "$env:temp" -Wait

        # Microsoft Online Services Sign-In Assistant for IT Professionals RTW (x64)
        Write-Information 'Downloading Microsoft Online Services Sign-In Assistant for IT Professionals RTW x64...'
        Invoke-WebRequest -Uri 'https://download.microsoft.com/download/5/0/1/5017D39B-8E29-48C8-91A8-8D0E4968E6D4/en/msoidcli_64.msi' -UseBasicParsing -OutFile "$env:temp\msoidcli_64.msi"
        Start-Process -FilePath "$env:temp\msoidcli_64.msi" -WorkingDirectory "$env:temp" -Wait

        # Azure AD v1
        if (!Get-InstalledModule -Name 'MSOnline') {
            Install-Module -Name 'MSOnline' -Force
        }

        # Azure AD v2
        if (!Get-InstalledModule -Name 'AzureAD') {
            Install-Module -Name 'AzureAD' -Force
        }
    } else {
        # We are not running as an admin
        Write-Error "You must be running Powershell as an administrator to install all dependencies."
    }
}