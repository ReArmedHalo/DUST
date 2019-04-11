Function New-DUSTAzureADApiApplication {
    [CmdletBinding()] param ()
    
    try {
        # Service Principals
        $msGraphServicePrincipal = Get-AzureADServicePrincipal -All:$true | Where-Object {$_.DisplayName -eq 'Microsoft Graph'}
        $requiredResourceAccess = New-Object -TypeName 'Microsoft.Open.AzureAD.Model.RequiredResourceAccess'
        $requiredResourceAccess.ResourceAppId = $msGraphServicePrincipal.AppId

        # App Roles
        $auditLogAppRole = (Get-AzureADServicePrincipal -All:$true).AppRoles | Where-Object {$_.Value -eq 'AuditLog.Read.All'}
        $reportsAppRole = (Get-AzureADServicePrincipal -All:$true).AppRoles | Where-Object {$_.Value -eq 'Reports.Read.All'}

        # - Microsoft Graph : AuditLog.Read.All
        $auditLogResourceAccess = New-Object -TypeName 'Microsoft.Open.AzureAD.Model.ResourceAccess' -ArgumentList ($auditLogAppRole.Id),'Scope'

        # - Microsoft Graph : Reports.Read.All
        $reportsResourceAccess = New-Object -TypeName 'Microsoft.Open.AzureAD.Model.ResourceAccess' -ArgumentList ($reportsAppRole.Id),'Scope'

        $requiredResourceAccess.ResourceAccess = $auditLogResourceAccess, $reportsResourceAccess
        
        # - Application Registration and Access Key
        $dustAzureADApp = New-AzureADApplication -DisplayName 'DUST PS Module Graph API Access' -PublicClient $true -RequiredResourceAccess $requiredResourceAccess -ReplyUrls 'https://localhost'

        return @{
            ObjectId = $dustAzureADApp.ObjectId
            ClientId = $dustAzureADApp.AppId
        }
    }
    catch {
        Write-Error $_
    }
    
}