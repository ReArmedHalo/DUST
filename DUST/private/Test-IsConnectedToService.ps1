Function Test-IsConnectedToService {
    [CmdletBinding()] Param (
        [ValidateSet('MsolService','AzureAD','ExchangeOnline','SecurityAndComplianceCenter')]
        [String] $Service
    )

    switch ($Service) {
        'MsolService' {
            try {
                Get-MsolCompanyInformation
            } catch [Microsoft.Online.Administration.Automation.MicrosoftOnlineException] {
                Write-Error 'Not connected to Microsoft Online! Please run ''Connect-OnlineService MsolService'' before using this command.'
            }
        }
        'AzureAD' {
            try {
                Get-AzureADTenantDetail
            } catch [Microsoft.Open.Azure.AD.CommonLibrary.AadNeedAuthenticationException] {
                Write-Error 'Not connected to Azure AD! Please run ''Connect-OnlineService AzureAD'' before using this command.'
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