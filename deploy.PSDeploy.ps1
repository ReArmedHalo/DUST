{
    Deploy Module {
        By PSGalleryModule {
            FromSource $ENV:BHProjectName
            To PSGallery
            WithOptions @{
                ApiKey = $ENV:NugetApiKey
            }
        }
    }

    By PlatyPS {
        FromSource 'docs'
        To "$ENV:BHProjectName\en-US"
        WithOptions @{
            Force = $true
        }
    }
}