# Publish to PSGallery
if (
    $env:BHPSModulePath -and
    $ENV:BHBuildSystem -ne 'Unknown' -and
    $env:BHBranchName -eq "master" -and
    $ENV:BHCommitMessage -match '!deploy'
)
{
    Deploy Module {
        By PSGalleryModule {
            FromSource $ENV:BHModulePath
            To PSGallery
            WithOptions @{
                ApiKey = $ENV:NuGetApiKey
            }
        }

        By PlatyPS {
            FromSource 'docs'
            To "$($ENV:BHModulePath)\en-US"
            Tagged docs
            WithOptions @{
                Force = $true
            }
        }
    }
} else {
    "Skipping deployment: To deploy, ensure that...`n" +
    "`t* You are in a known build system (Current: $ENV:BHBuildSystem)`n" +
    "`t* You are committing to the master branch (Current: $ENV:BHBranchName) `n" +
    "`t* Your commit message includes !deploy (Current: $ENV:BHCommitMessage)" | 
        Write-Host
}

# Publish to AppVeyor if we're in AppVeyor
if (
    $env:BHModulePath -and
    $env:BHBuildSystem -eq 'AppVeyor'
)
{
    Deploy DeveloperBuild {
        By AppVeyorModule {
            FromSource $ENV:BHModulePath
            To AppVeyor
            WithOptions @{
                Version = $env:APPVEYOR_BUILD_VERSION
            }
        }

        By PlatyPS {
            FromSource 'docs'
            To "$($ENV:BHModulePath)\en-US"
            Tagged docs
            WithOptions @{
                Force = $true
            }
        }
    }
}