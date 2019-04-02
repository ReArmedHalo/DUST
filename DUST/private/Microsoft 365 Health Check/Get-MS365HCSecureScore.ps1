Function Get-MS365HCSecureScore {
    [CmdletBinding()] Param (
        [Parameter(Mandatory)]
        [String] $AccessToken,

        [Parameter(Mandatory)]
        [String] $OutputPath
    )

    try {
        $graphRequestUri = 'https://graph.microsoft.com/beta/reports/getTenantSecureScores(period=1)/content'
        $response = Invoke-WebRequest -Method 'GET' -Uri $graphRequestUri -ContentType "application/json" -Headers @{Authorization = "Bearer $AccessToken"} -ErrorAction Stop
        $results = ($response.Content | ConvertFrom-Json)
        $scores = $results | Select-Object secureScore,maxSecureScore,identityScore,dataScore,deviceScore,appsScore,infrastructureScore
        $scores | Export-Csv -Path "$OutputPath\SecureScores.csv" -NoTypeInformation   
    }
    catch {
        Write-Error $_
    }
}