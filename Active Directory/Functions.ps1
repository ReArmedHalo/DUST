<#
    .Synopsis
    Converts an Active Directory GUID to an Azure AD Immutable ID.
    .DESCRIPTION
    Given a single or multiple Active Directory user identities, will return a list with the users UPN and ImmutableId.
    .EXAMPLE
    Convert-ToImmutableId jdoe
    .EXAMPLE
    Get-ADUser -Filter * -SearchBase 'OU=Finance,OU=UserAccounts,DC=FABRIKAM,DC=COM' | Convert-ToImmutableId
#>
Function Convert-ToImmutableId {
    [cmdletbinding()]Param(
        [Parameter(ValueFromPipeline)]
        [String] $Identity
    )

    Process {
        $user = Get-ADUser -Identity $Identity
        $guid = $user.ObjectGuid
        $upn = $user.UserPrincipalName
        [System.Convert]::ToBase64String($guid.tobytearray())

        $row = @(
            'UserPrincipalName'
        )
    }
}