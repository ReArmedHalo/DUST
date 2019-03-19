Deploy Module {
    By PSGalleryModule {
        FromSource $ENV:BHModulePath
        To PSGallery
        WithOptions @{
            NuGetApiKey = $ENV:NuGetApiKey
        }
    }
}