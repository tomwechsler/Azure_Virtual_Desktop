Set-Location c:\
Clear-Host

Install-Module -Name Az -Force -AllowClobber -Verbose

#Log into Azure
Connect-AzAccount

#Select the correct subscription
Get-AzSubscription -SubscriptionName "MSDN Platforms" | Select-AzSubscription
Get-AzContext

#Get a list of galleries
Get-AzResource -ResourceType Microsoft.Compute/galleries | Format-Table

#Assign the gallery to a variable
$gallery = Get-AzGallery -Name '<SIGGalleryName>' -ResourceGroupName '<SIGResourceGroup>'


#Create Splat for image definition settings and create definition
$imageDefParams = @{
    GalleryName       = $gallery.Name
    ResourceGroupName = $gallery.ResourceGroupName
    Location          = $gallery.Location
    Name              = '<ImageDefName>'
    OsState           = 'generalized'
    OsType            = 'Windows'
    Publisher         = '<Publisher>'
    Offer             = '<Offer>'
    Sku               = '<SKU>'
}
New-AzGalleryImageDefinition @imageDefParams

#Verify the definition was added and add the image definition to a variable
$imageDefinition = Get-AzGalleryImageDefinition -GalleryName $imageDefParams.GalleryName -ResourceGroupName $imageDefParams.ResourceGroupName


#### Add the first image version ####
# View the available images
Get-AzImage -ResourceGroupName CustomImagesRG | Select-Object Name, ResourceGroupName

#Update with your image name and Resource Group
$managedImage = Get-AzImage -ImageName Win10Multi2004V1 -ResourceGroupName CustomImagesRG

#Create the image version
#Define the replica regions
$region1 = @{Name = 'Central US'; ReplicaCount = 1 }
$region2 = @{Name = 'West Central US'; ReplicaCount = 2 }
$targetRegions = @($region1, $region2)

#Add the image
$imageParams = @{
    GalleryImageDefinitionName     = $imageDefinition.Name
    GalleryImageVersionName        = '<VersionNumber>'
    GalleryName                    = $gallery.Name
    ResourceGroupName              = $imageDefinition.ResourceGroupName
    Location                       = $imageDefinition.Location
    TargetRegion                   = $targetRegions
    Source                         = $managedImage.Id.ToString()
    PublishingProfileEndOfLifeDate = '2021-12-31'
    StorageAccountType             = 'Standard_LRS'
    asJob                          = $true
}
$job = $imageVersion = New-AzGalleryImageVersion @imageParams

#View the status of the job
$job.State

#Verify the image version
Get-AzGalleryImageversion -ResourceGroupName $imageParams.ResourceGroupName -GalleryName $imageParams.GalleryName `
-GalleryImageDefinitionName $imageParams.GalleryImageDefinitionName | Select-Object name, ProvisioningState


#### Add the second image version ####
# View the available images
Get-AzImage -ResourceGroupName CustomImagesRG | Select-Object Name, ResourceGroupName

#Update with your image name and Resource Group
$managedImage = Get-AzImage -ImageName Win10Multi2004V2 -ResourceGroupName CustomImagesRG

#Create the image version
#Define the replica regions
$region1 = @{Name = 'Central US'; ReplicaCount = 1 }
$targetRegions = @($region1)

#Add the image
$imageParams = @{
    GalleryImageDefinitionName     = $imageDefinition.Name
    GalleryImageVersionName        = '<ImageNumber>'
    GalleryName                    = $gallery.Name
    ResourceGroupName              = $imageDefinition.ResourceGroupName
    Location                       = $imageDefinition.Location
    TargetRegion                   = $targetRegions
    Source                         = $managedImage.Id.ToString()
    PublishingProfileEndOfLifeDate = '2021-12-31'
    StorageAccountType             = 'Standard_LRS'
    asJob                          = $true
}
$job = $imageVersion = New-AzGalleryImageVersion @imageParams

#View the status of the job
$job.State

#Verify the image version
Get-AzGalleryImageversion -ResourceGroupName $imageParams.ResourceGroupName -GalleryName $imageParams.GalleryName `
-GalleryImageDefinitionName $imageParams.GalleryImageDefinitionName | Select-Object name, ProvisioningState