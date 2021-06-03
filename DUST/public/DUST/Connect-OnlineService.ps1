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
            'AzureAD', # ✔
            'ExchangeOnline', # ✔
            'SecurityAndCompliance', # ✔
            'SharePoint', # ✔
            'Teams' # ✔
        )]
        [String] $Service
    )

    DynamicParam {
        $RuntimeParameterDictionary = New-Object System.Management.Automation.RuntimeDefinedParameterDictionary
        
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

            # AzureEnvironmentName
            $attributeCollection = New-Object System.Collections.ObjectModel.Collection[System.Attribute]
            $azureEnvironmentNameAttribute = New-Object System.Management.Automation.ParameterAttribute
            $azureEnvironmentNameAttribute.Position = 2
            $azureEnvironmentNameAttribute.HelpMessage = "Specifies the name of the Azure environment. The acceptable values for this parameter are: AzureCloud (Default), AzureChinaCloud, AzureUSGovernment, AzureGermanyCloud."
            $attributeCollection.Add((New-Object System.Management.Automation.ValidateSetAttribute(@('AzureCloud','AzureChinaCloud','AzureUSGovernment','AzureGermanyCloud'))))
            $attributeCollection.Add($azureEnvironmentNameAttribute)
            $azureEnvironmentNameParameter = New-Object System.Management.Automation.RuntimeDefinedParameter('AzureEnvironmentName', [String], $attributeCollection)
            $RuntimeParameterDictionary.Add('AzureEnvironmentName', $azureEnvironmentNameParameter)
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
        if (!$PSBoundParameters.AzureEnvironmentName) {
            # Hack, setting default value on parameter doesn't make it's way down here
            $PSBoundParameters.AzureEnvironmentName = 'AzureCloud'
        }
        
        if ($PSBoundParameters.FindTenant) {
            # Interactively find a delegated tenant

            if ($Service -eq 'AzureAD') {
                Write-Verbose "Azure AD Environment: $($PSBoundParameters.AzureEnvironmentName)"
                Resolve-DUSTDependency AzureAD

                try {
                    Write-Verbose "Connected to Azure AD! As we are not sure if this is the users home tenant, disconnecting..." # TODO: Can we determine this and avoid a reconnect?
                    Get-AzureADTenantDetail # GOTO: Catch if not connected
                    Disconnect-AzureAD
                } catch [Microsoft.Open.Azure.AD.CommonLibrary.AadNeedAuthenticationException] {
                    Write-Verbose "Not connected to Azure AD! (This is good)"
                }

                try {
                    Write-Verbose "Connecting to home tenant..."
                    Connect-AzureAD
                    $account = Get-AzureADCurrentSessionInfo | Select-Object Account
                    $selectedTenant = Get-AzureADContract -All:$true | Select-Object DisplayName,DefaultDomainName,CustomerContextId | Sort-Object -Property DisplayName | Out-GridView -OutputMode Single -Title "Select a tenant to connect to."
                    
                    if ($selectedTenant) {
                        Write-Verbose "User selected: $($selectedTenant.defaultDomainName)"
                        Disconnect-AzureAD
                        Write-Verbose "Connecting to $($selectedTenant.DisplayName) - $($selectedTenant.defaultDomainName) - $($selectedTenant.CustomerContextId)"
                        Connect-AzureAD -AccountId $account.Account -TenantId $selectedTenant.CustomerContextId -AzureEnvironmentName $AzureEnvironmentName
                    } else {
                        throw "You did not select a tenant. Aborting delegated authentication... (You are still connected to your home tenant)"
                    }
                } catch {
                    throw
                }
            } 
        }

        if ($PSBoundParameters.Delegated) {
            switch ($Service) {
                'AzureAD' {
                    Write-Verbose "Azure AD Environment: $($PSBoundParameters.AzureEnvironmentName)"
                    Resolve-DUSTDependency AzureAD
                    Connect-AzureAD -TenantId $PSBoundParameters.TenantId -AzureEnvironmentName $PSBoundParameters.AzureEnvironmentName
                }
                'ExchangeOnline' {
                    Resolve-DUSTDependency ExchangeOnlineManagement
                    Connect-ExchangeOnline -DelegatedOrganization $PSBoundParameters.DelegatedOrganization
                }
                'SharePoint' { # Same for direct
                    Resolve-DUSTDependency Microsoft.Online.SharePoint.PowerShell
                    Connect-SPOService -Uri $PSBoundParameters.Uri
                }
                'Teams' {
                    Resolve-DUSTDependency MicrosoftTeams
                    Connect-MicrosoftTeams -TenantId $PSBoundParameters.TenantId
                }
                Default {
                    throw 'You should never see this, but if you do, re-run the command with the -Verbose argument and report the output as an issue at https://github.com/ReArmedHalo/DUST'
                }
            }
        } else {
            # Direct authentication
            switch ($Service) {
                'AzureAD' {
                    Write-Verbose "Azure AD Environment: $($PSBoundParameters.AzureEnvironmentName)"
                    Resolve-DUSTDependency AzureAD
                    Connect-AzureAD -AzureEnvironmentName $PSBoundParameters.AzureEnvironmentName
                }
                'ExchangeOnline' {
                    Resolve-DUSTDependency ExchangeOnlineManagement
                    Connect-ExchangeOnline
                }
                'SecurityAndCompliance' {
                    Resolve-DUSTDependency ExchangeOnlineManagement
                    Connect-IPPSSession
                }
                'SharePoint' { # Same for delegated
                    Resolve-DUSTDependency Microsoft.Online.SharePoint.PowerShell
                    Connect-SPOService -Uri $PSBoundParameters.Uri
                }
                'Teams' {
                    Resolve-DUSTDependency MicrosoftTeams
                    Connect-MicrosoftTeams
                }
                Default {
                    throw 'You should never see this, but if you do, re-run the command with the -Verbose argument and report the output as an issue at https://github.com/ReArmedHalo/DUST'
                }
            }
        }
    }
}