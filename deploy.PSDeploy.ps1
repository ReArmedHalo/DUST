Deploy Module {
    By PSGalleryModule {
        FromSource $ENV:BHModulePath
        To PSGallery
        WithOptions @{
            ApiKey = $env:NuGetApiKey
        }
    }
}