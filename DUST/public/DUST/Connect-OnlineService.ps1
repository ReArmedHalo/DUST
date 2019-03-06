<# 
.EXTERNALHELP ..\..\Connect-OnlineService-help.xml
#>
Function Connect-OnlineService {
    [CmdletBinding(DefaultParameterSetName='Direct')]
    Param (
        [Parameter(ParameterSetName='Direct',Mandatory,Position=0)]
        [Parameter(ParameterSetName='Delegated',Mandatory,Position=0)]
        [ValidateSet('MicrosoftOnline','AzureADv2','ExchangeOnline','SecurityAndComplianceCenter')]
        [String] $Service
    )

    DynamicParam {
        $services = @('MicrosoftOnline','AzureADv2','ExchangeOnline')

        if ($services -contains $Service) {
            # Delegated attribute
            $attributeCollection = New-Object System.Collections.ObjectModel.Collection[System.Attribute]
            $delegatedAttribute = New-Object System.Management.Automation.ParameterAttribute
            $delegatedAttribute.Position = 1
            $delegatedAttribute.ParameterSetName = 'Delegated'
            $RuntimeParameterDictionary = New-Object System.Management.Automation.RuntimeDefinedParameterDictionary
            $attributeCollection.Add($delegatedAttribute)
            $delegatedParam = New-Object System.Management.Automation.RuntimeDefinedParameter('Delegated', [Switch], $attributeCollection)
            $RuntimeParameterDictionary.Add('Delegated', $delegatedParam)

            # ClientDomain attribute
            $attributeCollection = New-Object System.Collections.ObjectModel.Collection[System.Attribute]
            $clientDomainAttribute = New-Object System.Management.Automation.ParameterAttribute
            $clientDomainAttribute.Position = 2
            $clientDomainAttribute.ParameterSetName = 'Delegated'
            $clientDomainAttribute.Mandatory = $true
            $attributeCollection.Add($clientDomainAttribute)
            $clientDomainParam = New-Object System.Management.Automation.RuntimeDefinedParameter('ClientDomain', [String], $attributeCollection)
            $RuntimeParameterDictionary.Add('ClientDomain', $clientDomainParam)

            # Credential
            $attributeCollection = New-Object System.Collections.ObjectModel.Collection[System.Attribute]
            $credentialAttribute = New-Object System.Management.Automation.ParameterAttribute
            $credentialAttribute.Position = 3
            $credentialAttribute.ParameterSetName = "Delegated"
            $credentialAttribute.Mandatory = $true
            $attributeCollection.Add($credentialAttribute)
            $credentialParam = New-Object System.Management.Automation.RuntimeDefinedParameter('Credential', [PSCredential], $attributeCollection)
            $RuntimeParameterDictionary.Add('Credential', $credentialParam)

            return $RuntimeParameterDictionary
        }
    }

    Process {
        if ($PSBoundParameters.Delegated) {
            $cmd = Get-Command "Connect-$Service"
            & $cmd -Delegated -ClientDomain ($PSBoundParameters.ClientDomain) -Credential ($PSBoundParameters.Credential)
        } else {
            & (Get-Command "Connect-$Service")
        }
    }
}