Write-Host "Branch Name: $ENV:BHBranchName"
Write-Host "Test Secure String: $ENV:NuGetApiKey"

Deploy Module {
    By PSGalleryModule {
        FromSource $ENV:BHModulePath
        To PSGallery
        WithOptions @{
            ApiKey = $ENV:NuGetApiKey
        }
    }
}