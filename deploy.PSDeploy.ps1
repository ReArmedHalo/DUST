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

if ( $env:BHModulePath -and $env:BHBuildSystem -eq 'AppVeyor' ) {
    Deploy DeveloperBuild {
        By AppVeyorModule {
            FromSource $ENV:BHModulePath
            To AppVeyor
            WithOptions @{
                Version = $env:APPVEYOR_BUILD_VERSION
            }
        }
    }
}