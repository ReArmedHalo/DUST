<#
.EXTERNALHELP ..\..\Connect-OnlineService-help.xml
#>
Function Connect-OnlineService {
    [CmdletBinding(DefaultParameterSetName='Direct')]
    Param (
        [Parameter(ParameterSetName='Direct',Mandatory,Position=0)]
        [Parameter(ParameterSetName='Delegated',Mandatory,Position=0)]
        [ValidateSet('AzureAD','ExchangeOnline','MsolService','SecurityAndComplianceCenter')]
        [String] $Service
    )

    DynamicParam {
        # --- AzureAD
        if ($Service -eq 'AzureAD') {
            # Delegated attribute
            $attributeCollection = New-Object System.Collections.ObjectModel.Collection[System.Attribute]
            $delegatedAttribute = New-Object System.Management.Automation.ParameterAttribute
            $delegatedAttribute.Position = 1
            $delegatedAttribute.ParameterSetName = 'Delegated'
            $RuntimeParameterDictionary = New-Object System.Management.Automation.RuntimeDefinedParameterDictionary
            $attributeCollection.Add($delegatedAttribute)
            $delegatedParam = New-Object System.Management.Automation.RuntimeDefinedParameter('Delegated', [Switch], $attributeCollection)
            $RuntimeParameterDictionary.Add('Delegated', $delegatedParam)

            # TenantId attribute
            $attributeCollection = New-Object System.Collections.ObjectModel.Collection[System.Attribute]
            $tenantIdAttribute = New-Object System.Management.Automation.ParameterAttribute
            $tenantIdAttribute.Position = 2
            $tenantIdAttribute.ParameterSetName = 'Delegated'
            $tenantIdAttribute.Mandatory = $true
            $tenantIdAttribute.ValueFromPipelineByPropertyName = $true
            $parameterAlias = New-Object System.Management.Automation.AliasAttribute -ArgumentList 'CustomerContextId'
            $attributeCollection.Add($tenantIdAttribute)
            $attributeCollection.Add($parameterAlias)
            $tenantIdParam = New-Object System.Management.Automation.RuntimeDefinedParameter('TenantId', [String], $attributeCollection)
            $RuntimeParameterDictionary.Add('TenantId', $tenantIdParam)
        }

        # --- ExchangeOnline
        if ($Service -eq 'ExchangeOnline') {
            # Delegated
            $attributeCollection = New-Object System.Collections.ObjectModel.Collection[System.Attribute]
            $delegatedAttribute = New-Object System.Management.Automation.ParameterAttribute
            $delegatedAttribute.Position = 1
            $delegatedAttribute.ParameterSetName = 'Delegated'
            $RuntimeParameterDictionary = New-Object System.Management.Automation.RuntimeDefinedParameterDictionary
            $attributeCollection.Add($delegatedAttribute)
            $delegatedParam = New-Object System.Management.Automation.RuntimeDefinedParameter('Delegated', [Switch], $attributeCollection)
            $RuntimeParameterDictionary.Add('Delegated', $delegatedParam)

            # ClientDomain
            $attributeCollection = New-Object System.Collections.ObjectModel.Collection[System.Attribute]
            $clientDomainAttribute = New-Object System.Management.Automation.ParameterAttribute
            $clientDomainAttribute.Position = 2
            $clientDomainAttribute.ParameterSetName = 'Delegated'
            $clientDomainAttribute.Mandatory = $true
            $attributeCollection.Add($clientDomainAttribute)
            $clientDomainParam = New-Object System.Management.Automation.RuntimeDefinedParameter('ClientDomain', [String], $attributeCollection)
            $RuntimeParameterDictionary.Add('ClientDomain', $clientDomainParam)
        }

        # --- MsolService
        # We are not supporting MsolService at this time for delegation

        # --- SecurityAndComplianceCenter
        # Delegation not supported by SCC

        # Credential
        <#
        $attributeCollection = New-Object System.Collections.ObjectModel.Collection[System.Attribute]
        $credentialAttribute = New-Object System.Management.Automation.ParameterAttribute
        $credentialAttribute.Position = 3
        $credentialAttribute.ParameterSetName = "Delegated"
        $credentialAttribute.Mandatory = $true
        $attributeCollection.Add($credentialAttribute)
        $credentialParam = New-Object System.Management.Automation.RuntimeDefinedParameter('Credential', [PSCredential], $attributeCollection)
        $RuntimeParameterDictionary.Add('Credential', $credentialParam)
        #>

        if ($RuntimeParameterDictionary) {
            return $RuntimeParameterDictionary
        }
    }

    Process {
        if ($PSBoundParameters.Delegated) {
            if ($Service -eq 'AzureAD') {
                # Azure AD has a different method of handling delegated access, this one supports MFA!
                Connect-AzureAD -TenantId $PSBoundParameters.TenantId
            } else {
                $cmd = Get-Command "Connect-DUST$Service"
                & $cmd -Delegated -ClientDomain ($PSBoundParameters.ClientDomain) -Credential ($PSBoundParameters.Credential)
            }
        } else {
            & (Get-Command "Connect-DUST$Service")
        }
    }
}