Deploy Module {
    By PSGalleryModule {
        FromSource $ENV:BHModulePath
        To PSGallery
        WithOptions @{
            ApiKey = $env:NuGetApiKey
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