Function New-DUSTAzureADApiApplication {
    [CmdletBinding()] param ()
    
    try {
        # Service Principals
        $msGraphServicePrincipal = Get-AzureADServicePrincipal -All:$true | Where-Object {$_.DisplayName -eq 'Microsoft Graph'}
        $requiredResourceAccess = New-Object -TypeName 'Microsoft.Open.AzureAD.Model.RequiredResourceAccess'
        $requiredResourceAccess.ResourceAppId = $msGraphServicePrincipal.AppId

        # App Roles
        $auditLogAppRole = (Get-AzureADServicePrincipal -All:$true).AppRoles | Where-Object {$_.Value -eq 'AuditLog.Read.All'}
        $directoryAppRole = (Get-AzureADServicePrincipal -All:$true).AppRoles | Where-Object {$_.Value -eq "Directory.Read.All" -and $_.Description -like "*a signed-in user."}
        $reportsAppRole = (Get-AzureADServicePrincipal -All:$true).AppRoles | Where-Object {$_.Value -eq 'Reports.Read.All'}

        # - Microsoft Graph : AuditLog.Read.All
        $auditLogResourceAccess = New-Object -TypeName 'Microsoft.Open.AzureAD.Model.ResourceAccess' -ArgumentList ($auditLogAppRole.Id),'Role'

        # - Microsoft Graph : Directory.Read.All
        $directoryResourceAccess = New-Object -TypeName 'Microsoft.Open.AzureAD.Model.ResourceAccess' -ArgumentList ($directoryAppRole.Id),'Role'

        # - Microsoft Graph : Reports.Read.All
        $reportsResourceAccess = New-Object -TypeName 'Microsoft.Open.AzureAD.Model.ResourceAccess' -ArgumentList ($reportsAppRole.Id),'Role'

        $requiredResourceAccess.ResourceAccess = $auditLogResourceAccess, $directoryResourceAccess, $reportsResourceAccess
        
        # - Application Registration and Access Key
        $dustAzureADApp = New-AzureADApplication -DisplayName 'DUST PS Module Graph API Access' -RequiredResourceAccess $requiredResourceAccess -ReplyUrls 'https://localhost'
        $accessKey = New-AzureADApplicationPasswordCredential -ObjectId $dustAzureADApp.ObjectId -CustomKeyIdentifier 'Access Key' -EndDate ((Get-Date).AddDays(1))
        
        Write-Verbose "Azure AD Object ID: $($dustAzureADApp.ObjectId)"
        Write-Verbose "Azure AD App ID / Client ID: $($dustAzureADApp.AppId)"
        Write-Verbose "Azure AD Client Secret: $($accessKey.Value)"

        return [PSCustomObject]@{
            ObjectId = $dustAzureADApp.ObjectId
            ClientId = $dustAzureADApp.AppId
            ClientSecret = $accessKey.Value
        }
    }
    catch {
        Write-Error $_
    }
    
}