<#
.EXTERNALHELP ..\..\Connect-OnlineService-help.xml
#>
Function Connect-OnlineService {
    [CmdletBinding(DefaultParameterSetName='Direct')]
    Param (
        [Parameter(ParameterSetName='Direct',Mandatory,Position=0)]
        [Parameter(ParameterSetName='Delegated',Mandatory,Position=0)]
        [Parameter(ParameterSetName='FindDelegated',Mandatory,Position=0)]
        [ValidateSet(
            'Az',
            'AzureAD',
            'ExchangeOnline',
            'SecurityAndCompliance',
            'SharePoint',
            'Teams'
        )]
        [String] $Service
    )

    DynamicParam {
        $RuntimeParameterDictionary = New-Object System.Management.Automation.RuntimeDefinedParameterDictionary

        # --- Az
        if ($Service -eq 'Az') {
            # Tenant
            $attributeCollection = New-Object System.Collections.ObjectModel.Collection[System.Attribute]
            $tenantAttribute = New-Object System.Management.Automation.ParameterAttribute
            $tenantAttribute.Position = 1
            $tenantAttribute.ParameterSetName = 'Delegated'
            $tenantAttribute.ValueFromPipelineByPropertyName = $true
            $parameterAlias = New-Object System.Management.Automation.AliasAttribute -ArgumentList 'CustomerContextId'
            $attributeCollection.Add($tenantAttribute)
            $attributeCollection.Add($parameterAlias)
            $tenantIdParameter = New-Object System.Management.Automation.RuntimeDefinedParameter('Tenant', [String], $attributeCollection)
            $RuntimeParameterDictionary.Add('Tenant', $tenantIdParameter)

            # FindTenant
            $attributeCollection = New-Object System.Collections.ObjectModel.Collection[System.Attribute]
            $findTenantAttribute = New-Object System.Management.Automation.ParameterAttribute
            $findTenantAttribute.Position = 1
            $findTenantAttribute.ParameterSetName = 'FindDelegated'
            $findTenantAttribute.HelpMessage = "Interactively find a delegated tenant to connect to. This only works for partners such Syndication Partners, Breadth Partners, and Reseller Partners. "
            $attributeCollection.Add($findTenantAttribute)
            $findTenantParameter = New-Object System.Management.Automation.RuntimeDefinedParameter('FindTenant', [Switch], $attributeCollection)
            $RuntimeParameterDictionary.Add('FindTenant', $findTenantParameter)
        }
        
        # --- AzureAD
        if ($Service -eq 'AzureAD') {
            # TenantId
            $attributeCollection = New-Object System.Collections.ObjectModel.Collection[System.Attribute]
            $tenantIdAttribute = New-Object System.Management.Automation.ParameterAttribute
            $tenantIdAttribute.Position = 1
            $tenantIdAttribute.ParameterSetName = 'Delegated'
            $tenantIdAttribute.ValueFromPipelineByPropertyName = $true
            $parameterAlias = New-Object System.Management.Automation.AliasAttribute -ArgumentList 'CustomerContextId'
            $attributeCollection.Add($tenantIdAttribute)
            $attributeCollection.Add($parameterAlias)
            $tenantIdParameter = New-Object System.Management.Automation.RuntimeDefinedParameter('TenantId', [String], $attributeCollection)
            $RuntimeParameterDictionary.Add('TenantId', $tenantIdParameter)

            # FindTenant
            $attributeCollection = New-Object System.Collections.ObjectModel.Collection[System.Attribute]
            $findTenantAttribute = New-Object System.Management.Automation.ParameterAttribute
            $findTenantAttribute.Position = 1
            $findTenantAttribute.ParameterSetName = 'FindDelegated'
            $findTenantAttribute.HelpMessage = "Interactively find a delegated tenant to connect to. This only works for partners such Syndication Partners, Breadth Partners, and Reseller Partners. "
            $attributeCollection.Add($findTenantAttribute)
            $findTenantParameter = New-Object System.Management.Automation.RuntimeDefinedParameter('FindTenant', [Switch], $attributeCollection)
            $RuntimeParameterDictionary.Add('FindTenant', $findTenantParameter)
        }

        # --- ExchangeOnline
        if ($Service -eq 'ExchangeOnline') {
            # DelegatedOrganization
            $attributeCollection = New-Object System.Collections.ObjectModel.Collection[System.Attribute]
            $delegatedOrganizationAttribute = New-Object System.Management.Automation.ParameterAttribute
            $delegatedOrganizationAttribute.Position = 1
            $delegatedOrganizationAttribute.ParameterSetName = 'Delegated'
            $delegatedOrganizationAttribute.HelpMessage = "The client domain you wish to connect to via delegated rights. This is only required if you are connecting to a tenant that isn't your home tenant."
            $attributeCollection.Add($delegatedOrganizationAttribute)
            $delegatedOrganizationParameter = New-Object System.Management.Automation.RuntimeDefinedParameter('DelegatedOrganization', [String], $attributeCollection)
            $RuntimeParameterDictionary.Add('DelegatedOrganization', $delegatedOrganizationParameter)
        }
        
        # --- Teams
        if ($Service -eq 'Teams') {
            # AuthenticationUrl
            $attributeCollection = New-Object System.Collections.ObjectModel.Collection[System.Attribute]
            $tenantIdAttribute = New-Object System.Management.Automation.ParameterAttribute
            $tenantIdAttribute.Position = 1
            $tenantIdAttribute.ParameterSetName = 'Delegated'
            $tenantIdAttribute.HelpMessage = "The Microsoft 365 Tenant Id you wish to connect to via delegated rights. This is only required if you are connecting to a tenant that isn't your home tenant."
            $attributeCollection.Add($tenantIdAttribute)
            $tenantIdParameter = New-Object System.Management.Automation.RuntimeDefinedParameter('TenantId', [String], $attributeCollection)
            $RuntimeParameterDictionary.Add('TenantId', $tenantIdParameter)
        }

        # ===== Service specific parameters (Non-delegated)
        
        # --- SharePoint
        if ($Service -eq 'SharePoint') {
            # AuthenticationUrl
            $attributeCollection = New-Object System.Collections.ObjectModel.Collection[System.Attribute]
            $adminUriAttribute = New-Object System.Management.Automation.ParameterAttribute
            $adminUriAttribute.Position = 1
            $adminUriAttribute.ParameterSetName = 'Direct'
            $adminUriAttribute.HelpMessage = "The SharePoint admin URL in the format of: https://orgName-admin.sharepoint.com"
            $attributeCollection.Add($adminUriAttribute)
            $adminUriParameter = New-Object System.Management.Automation.RuntimeDefinedParameter('Uri', [String], $attributeCollection)
            $RuntimeParameterDictionary.Add('Uri', $adminUriParameter)
        }

        if ($RuntimeParameterDictionary.Count -gt 0) {
            return $RuntimeParameterDictionary
        }
    }

    Process {
        if ($PSBoundParameters.FindTenant) {
            # Interactively find a delegated tenant

            if ($Service -eq 'Az') {
                if (!(Get-InstalledModule -Name 'Az' -ErrorAction SilentlyContinue)) {
                    Write-Error "Az module not installed! Please install the module from an elevated PowerShell using 'Install-Module Az -AllowClobber -Force'" -ErrorAction Stop
                }
                
                try { Disconnect-AzureAD -ErrorAction SilentlyContinue; Disconnect-AzAccount -ErrorAction SilentlyContinue } catch {}

                try {
                    Connect-AzureAD -ErrorAction Stop
                    $selectedTenant = Get-AzureADContract -All:$true | Select-Object DisplayName,DefaultDomainName,CustomerContextId | Sort-Object -Property DisplayName  | Out-GridView -OutputMode Single -Title "Select a tenant to connect to."
                    
                    if ($selectedTenant) {
                        Disconnect-AzureAD
                        try {
                            Connect-AzAccount -Tenant $selectedTenant.CustomerContextId -ErrorAction Stop
                        }
                        catch [Microsoft.Open.Azure.AD.CommonLibrary.AadAuthenticationFailedException],[Microsoft.IdentityModel.Clients.ActiveDirectory.AdalServiceException] {
                            Write-Error -Message "Authentication incomplete or failed for Azure AD!" -Exception [Microsoft.Open.Azure.AD.CommonLibrary.AadAuthenticationFailedException] -ErrorAction Stop
                        }
                    } else {
                        Write-Error -Message "You did not select a tenant. Aborting delegated authentication... (You are still connected to your home tenant)" -ErrorAction Stop
                    }    
                }
                catch [Microsoft.Open.Azure.AD.CommonLibrary.AadAuthenticationFailedException],[Microsoft.IdentityModel.Clients.ActiveDirectory.AdalServiceException] {
                    Write-Error -Message "Authentication incomplete or failed for Azure AD!" -Exception [Microsoft.Open.Azure.AD.CommonLibrary.AadAuthenticationFailedException] -ErrorAction Stop
                }
            }

            if ($Service -eq 'AzureAD') {
                try { Disconnect-AzureAD -ErrorAction SilentlyContinue } catch {}

                try {
                    Connect-AzureAD -ErrorAction Stop
                    $account = Get-AzureADCurrentSessionInfo | Select-Object Account
                    $selectedTenant = Get-AzureADContract -All:$true | Select-Object DisplayName,DefaultDomainName,CustomerContextId | Sort-Object -Property DisplayName  | Out-GridView -OutputMode Single -Title "Select a tenant to connect to."
                    
                    if ($selectedTenant) {
                        Disconnect-AzureAD
                        try {
                            Connect-AzureAD -AccountId $account.Account -TenantId $selectedTenant.CustomerContextId -ErrorAction Stop
                        }
                        catch [Microsoft.Open.Azure.AD.CommonLibrary.AadAuthenticationFailedException],[Microsoft.IdentityModel.Clients.ActiveDirectory.AdalServiceException] {
                            Write-Error -Message "Authentication incomplete or failed for Azure AD!" -Exception [Microsoft.Open.Azure.AD.CommonLibrary.AadAuthenticationFailedException] -ErrorAction Stop
                        }
                    } else {
                        Write-Error -Message "You did not select a tenant. Aborting delegated authentication... (You are still connected to your home tenant)" -ErrorAction Stop
                    }    
                }
                catch [Microsoft.Open.Azure.AD.CommonLibrary.AadAuthenticationFailedException],[Microsoft.IdentityModel.Clients.ActiveDirectory.AdalServiceException] {
                    Write-Error -Message "Authentication incomplete or failed for Azure AD!" -Exception [Microsoft.Open.Azure.AD.CommonLibrary.AadAuthenticationFailedException] -ErrorAction Stop
                }
            } 
        }

        if ($PSBoundParameters.Delegated) {
            switch ($Service) {
                'AzureAd' { 
                    Connect-AzureAD -TenantId $PSBoundParameters.TenantId
                }
                'ExchangeOnline' {
                    Connect-ExchangeOnline -DelegatedOrganization $PSBoundParameters.DelegatedOrganization
                }
                'SharePoint' { # Same for direct
                    Connect-SPOService -Uri  $PSBoundParameters.Uri
                }
                'Teams' {
                    Connect-MicrosoftTeams -TenantId $PSBoundParameters.TenantId
                }
                Default {
                    Write-Error 'You should never see this, but if you do, report to https://github.com/ReArmedHalo/DUST'
                }
            }
        } else {
            switch ($Service) {
                'AzureAD' { 
                    Connect-AzureAD
                }
                'ExchangeOnline' {
                    Connect-ExchangeOnline
                }
                'SecurityAndCompliance' {
                    Connect-IPPSSession
                }
                'SharePoint' { # Same for delegated
                    Connect-SPOService -Uri  $PSBoundParameters.Uri
                }
                'SkypeForBusiness' {
                    $sfboSession = New-CsOnlineSession
                    Import-PSSession $sfboSession
                }
                'Teams' {
                    Connect-MicrosoftTeams
                }
                Default {
                    Write-Error 'You should never see this, but if you do, report to https://github.com/ReArmedHalo/DUST'
                }
            }
        }
    }
}