Set-Location c:\
Clear-Host

Install-Module -Name Az -Force -AllowClobber -Verbose

#Log into Azure
Connect-AzAccount

#Select the correct subscription
Get-AzSubscription -SubscriptionName "MSDN Platforms" | Select-AzSubscription
Get-AzContext

#Set SIG Variables
$resourceGroup = '<SIGResourceGroup>'
$galleryName = '<SIGGalleryName>'
$imageDefName = '<ImageDefinition>'
$imageVersion = '<ImageVersion>'

#Enable Exclude from latest
Update-AzGalleryImageVersion -ResourceGroupName $resourceGroup `
-GalleryName $galleryName `
-GalleryImageDefinitionName $imageDefName `
-Name $imageVersion `
-PublishingProfileExcludeFromLatest 

#View the settings
Get-AzGalleryImageversion -ResourceGroupName $resourceGroup -GalleryName $galleryName `
-GalleryImageDefinitionName $imageDefName -Name $imageVersion


#Disable Exclude from latest
Update-AzGalleryImageVersion -ResourceGroupName $resourceGroup `
-GalleryName $galleryName `
-GalleryImageDefinitionName $imageDefName `
-Name $imageVersion `
-PublishingProfileExcludeFromLatest:$False

#View the settings
Get-AzGalleryImageversion -ResourceGroupName $resourceGroup -GalleryName $galleryName `
-GalleryImageDefinitionName $imageDefName -Name $imageVersion 