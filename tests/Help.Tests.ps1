$projectRoot = Resolve-Path "$PSScriptRoot\.."
$moduleRoot = Split-Path (Resolve-Path "$projectRoot\*\*.psm1")
$moduleName = Split-Path $moduleRoot -Leaf

Describe "Help validation: $moduleName" {
    Import-Module (Join-Path $moduleRoot "$moduleName.psd1") -force
    $functions = Get-Command -Module $moduleName -CommandType Function

    foreach($Function in $Functions) {
        $help = Get-Help $Function.Name

        Context $help.name {
            it "Has Markdown file" {
                "$projectRoot\docs\$Function.md" | Should Exist
            }
            it "Has a HelpUri" {
                $Function.HelpUri | Should Not BeNullOrEmpty
            }
            It "Has Related Links" {
                $help.relatedLinks.navigationLink.uri.count | Should BeGreaterThan 0
            }
            it "Has a Description" {
                $help.description | Should Not BeNullOrEmpty
            }
            it "Has an Example" {
                    $help.examples | Should Not BeNullOrEmpty
            }
            foreach($parameter in $help.parameters.parameter)
            {
                if($parameter -notmatch 'whatif|confirm')
                {
                    it "Has a Parameter Description for '$($parameter.name)'" {
                        $parameter.Description.text | Should Not BeNullOrEmpty
                    }
                }
            }
        }
    }
}