Function Connect-OnlineService {
    [CmdletBinding()] Param(
        [ValidateSet('AzureADv1','AzureAD','ExchangeOnline','SecurityAndComplianceCenter')]
        [String] $Service,

        [Parameter(ParameterSetName='Delegated')]
        [Switch] $Delegated,

        [Parameter(ParameterSetName='Delegated')]
        [String] $ClientDomain
    )
}