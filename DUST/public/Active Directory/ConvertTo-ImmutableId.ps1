<#
    .Synopsis
    Converts an Active Directory GUID to an Azure AD Immutable ID.
    .DESCRIPTION
    Given a single or multiple Active Directory user identity, will return the ImmutableId.
    .EXAMPLE
    ConvertTo-ImmutableId jdoe

    ConvertTo-ImmutableId -UserGUID '00000000-0000-0000-0000-00000000000'
    .EXAMPLE
    Get-ADUser -Filter * -SearchBase 'OU=Finance,OU=UserAccounts,DC=FABRIKAM,DC=COM' | Convert-ToImmutableId

    $guid = Get-AdUser -Identity jdoe | Select ObjectGUID
    ConvertTo-ImmutableId -UserGUID $guid
#>
Function ConvertTo-ImmutableId {
    [cmdletbinding()]Param(
        [Parameter(ParameterSetName='FromADIdentity',Mandatory,Position=1,ValueFromPipeline)]
        [String] $Identity,

        [Parameter(ParameterSetName='FromGUIDString',Mandatory,Position=1)]
        [GUID] $UserGUID
    )

    Process {
        if ($UserGUID) {
            return [System.Convert]::ToBase64String($UserGUID.ToByteArray())
        } else {
            try {
                $user = Get-ADUser -Identity $Identity
                $guid = $user.ObjectGuid
                $upn = $user.UserPrincipalName
                $immutableId = [System.Convert]::ToBase64String($guid.ToByteArray())

                $row = @()

                $item = New-Object PSObject
                $item | Add-Member -type NoteProperty -Name 'UserPrincipalName' -Value $upn
                $item | Add-Member -type NoteProperty -Name 'ImmutableId' -Value $immutableId
                
                $row += $item
                return $row
            }
            catch {
                Write-Error $_
            }
        }
    }
}