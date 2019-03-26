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
    [version]$nextGalleryVersion = Get-NextNugetPackageVersion -Name $env:BHProjectName -ErrorAction Stop
    [version]$sourceVersion = Get-MetaData -Path $env:BHPSModuleManifest -PropertyName ModuleVersion -ErrorAction Stop
    [version]$devBuildVersion = $null

    if ($nextGalleryVersion -ge $sourceVersion) {
        # Gallery version is newer than source, trust gallery
        [version]$devBuildVersion = $nextGalleryVersion
    } else {
        # Source is overriding next version purposed by Gallery, trusting source
        [version]$devBuildVersion = $sourceVersion
    }
    
    [version]$devBuildVersion = "$devBuildVersion.$($env:APPVEYOR_BUILD_NUMBER)"

    Deploy DeveloperBuild {
        By AppVeyorModule {
            FromSource $ENV:BHModulePath
            To AppVeyor
            WithOptions @{
                Version = $devBuildVersion
            }
        }
    }
}