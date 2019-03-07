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