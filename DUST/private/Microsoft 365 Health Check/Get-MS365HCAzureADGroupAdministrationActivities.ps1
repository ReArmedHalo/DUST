Function Get-MS365HCAzureADGroupAdministrationActivities {
    [CmdletBinding()] Param (
        [Parameter(Mandatory)]
        [String] $OutputPath,

        [Parameter(Mandatory)]
        [String] $AccessToken,

        # In UTC
        [Parameter(Mandatory)]
        [String] $StartDate
    )

}