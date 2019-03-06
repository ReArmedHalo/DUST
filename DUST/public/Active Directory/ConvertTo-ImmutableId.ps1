<#
    .EXTERNALHELP ..\..\ConvertTo-ImmutableId-help.xml
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