<#
    .EXTERNALHELP ..\..\Connect-AzureADDelegatedTenant-help.xml
#>
Function Connect-AzureADDelegatedTenant {
    [cmdletbinding()] Param (
        [Parameter(Mandatory,ValueFromPipelineByPropertyName)]
        [String] $UserPrincipalName
    )

    try {
        Get-MsolDomain
    } catch {
        Connect-OnlineService -Service MsolService
    }

    try {
        if (Get-MsolUser -UserPrincipalName $UserPrincipalName -ReturnDeletedUsers) {
            # User in trash, let's restore them
            Restore-MsolUser -UserPrincipalName $UserPrincipalName
        }

        if (Get-MsolUser -UserPrincipalName $UserPrincipalName) {
            Set-MsolUser -UserPrincipalName $UserPrincipalName -ImmutableId "$null"
            Write-Output "Immutable ID has been cleared! Be sure the user isn't a member of an Active Directory OU that will cause it to be resynced and rematched to the Azure AD object via SMTP soft-matching otherwise you and I are going to become friends. :)"
        }
    } catch {
        Write-Error "Something went wrong! $_"
    }
}