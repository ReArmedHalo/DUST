Write-Host "Get-ChildItems"
Get-ChildItem env:

Deploy Module {
    By PSGalleryModule {
        FromSource $ENV:BHModulePath
        To PSGallery
        WithOptions @{
            ApiKey = $ENV:NuGetApiKey
        }
    }
}