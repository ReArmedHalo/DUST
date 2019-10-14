<#
    .EXTERNALHELP ..\..\Set-AzureADUserPasswordExpiration-help.xml
#>
Function Set-AzureADUserPasswordExpiration {
    [CmdletBinding()]
    param (
        [Parameter(ParameterSetName="AllNoExpire")]
        [Parameter(ParameterSetName="AllExpire")]
        [Switch]
        $All,

        [Parameter(ParameterSetName="SearchStringNoExpire",Position=0)]
        [Parameter(ParameterSetName="SearchStringExpire",Position=0)]
        [String]
        $SearchString,

        [Parameter(ParameterSetName="AllNoExpire")]
        [Parameter(ParameterSetName="SearchStringNoExpire")]
        [Switch]
        $None,

        [Parameter(ParameterSetName="AllExpire")]
        [Parameter(ParameterSetName="SearchStringExpire")]
        [Switch]
        $Expire
    )

    $users = $null
    if ($PSCmdlet.ParameterSetName -like 'SearchString*') {
        $users = Get-AzureADUser -SearchString $SearchString
    }
    if ($PSCmdlet.ParameterSetName -like 'All*') {
        $users = Get-AzureADUser -All $true
    }

    if ($users) {
        if ($None) {
            $users | Set-AzureADUser -PasswordPolicies DisablePasswordExpiration
        }
        if ($Expire) {
            $users | Set-AzureADUser -PasswordPolicies None 
        }
    } else {
        throw 'No users selected to update.'
    }
}