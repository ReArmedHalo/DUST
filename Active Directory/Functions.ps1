<#
    .Synopsis
    Converts an Active Directory GUID to an Azure AD Immutable ID.
    .DESCRIPTION
    Given a single or multiple Active Directory user identity, will return the ImmutableId.
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
        $immutableId = [System.Convert]::ToBase64String($guid.tobytearray())

        $row = @()

        $item = New-Object PSObject
        $item | Add-Member -type NoteProperty -Name 'UserPrincipalName' -Value $upn
        $item | Add-Member -type NoteProperty -Name 'ImmutableId' -Value $immutableId
        
        $row += $item

        return $row
    }
}