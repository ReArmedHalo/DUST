<#
.EXTERNALHELP ..\..\Resolve-DUSTDependency-help.xml
#>
<#
    Checks that a module is installed, provides instruction for installation if not found
#>
Function Resolve-DUSTDependency {
    [CmdletBinding()]
    param (
        # Module name to check for
        [Parameter(Mandatory,Position=0)]
        [String]
        $Name,

        # Installs the module in the specified scope, defaults to the AllUsers scope
        [Parameter(ParameterSetName="Install",Position=1)]
        [ValidateSet(
            'AllUsers',
            'CurrentUser'
        )]
        [String]
        $Scope = 'AllUsers'
    )

    Write-Verbose "Checking for module: $Name"
    if ((Get-Module -ListAvailable -Name $Name).Count -gt 0 ) {
        Write-Verbose "Module installed! Returning to caller..."
        return
    }

    Write-Verbose "Module, $Name, not found! Should we install it?"
    $yes = New-Object System.Management.Automation.Host.ChoiceDescription "&Yes", "Install the module in the $Scope scope."
    $no = New-Object System.Management.Automation.Host.ChoiceDescription "&No", "Do not install the module, aborts the requested operation."
    $response = $Host.UI.PromptForChoice('Module Installation Requested!', "Can I install the following module in the $Scope scope? $Name", @($yes, $no), 0)
    if ($response -eq 1) {
        throw New-Object System.FormatException 'Module installation aborted! Cannot continue.'
    }

    # Attempt to install to the AllUsers (or $Scope passed to function) scope
    try {
        Write-Verbose "Attempting install with scope: $Scope"
        Install-Module -Name $Name -Scope $Scope -Force
    } catch {
        Write-Verbose "Exception occured, checking if it is a permission related error..."
        if ($_.FullyQualifiedErrorId -like "*InstallModuleNeedsCurrentUserScopeParameterForNonAdminUser*") {
            Write-Error 'Attempted to install module to AllUsers scope but we do not have administrative privilages to install to the scope!'
            $yes = New-Object System.Management.Automation.Host.ChoiceDescription "&Yes", "Install the module in the CurrentUser scope."
            $no = New-Object System.Management.Automation.Host.ChoiceDescription "&No", "Do not install the module, aborts the requested operation."
            $response = $Host.UI.PromptForChoice('Module Installation Requested!', "Can I install the following module in the CurrentUser scope instead? $Name", @($yes, $no), 0)
        
            if ($response -eq 1) {
                Write-Verbose "Installing module to the CurrentUser scope"
                try {
                    Install-Module -Name $Name -Scope CurrentUser -Force
                } catch {
                    Write-Verbose "Failed to install using CurrentUser scope!"
                    throw
                }
            }
        } else {
            Write-Error "Unhandled error occured while trying to install the module '$Name' under the '$Scope' scope!"
            throw
        }
    }
}