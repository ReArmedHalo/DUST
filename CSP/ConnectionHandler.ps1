Function Connect-CloudSolutionsProvider {
    [CmdletBinding()]Param()
    
    try {
        Get-AzureADTenantDetail
    } catch [Microsoft.Open.Azure.AD.CommonLibrary.AadNeedAuthenticationException] {
        Connect-AzureAD
    }
}