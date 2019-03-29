Function Remove-DUSTAzureADApiApplication {
    [CmdletBinding()] Param (
        [Parameter(Mandatory)]
        [String] $ObjectId
    )

    try {
        if ($app = Get-AzureADApplication -ObjectId $ObjectId) {
            if ($app.DisplayName -eq 'DUST PS Module Graph API Access') {
                Remove-AzureADApplication -ObjectId $ObjectId
            } else {
                Write-Error 'We could not confirm the expected ObjectId matches the application DUST created.'
            }
        }
    } catch {
        Write-Error $_
    }
}