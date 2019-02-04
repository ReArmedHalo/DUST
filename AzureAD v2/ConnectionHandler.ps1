Function Connect-AzureADv2 {
    [CmdletBinding()] Param ()
    
    try {
        Get-AzureADTenantDetail
    } catch [Microsoft.Open.Azure.AD.CommonLibrary.AadNeedAuthenticationException] {
        Connect-AzureAD
    }
}