Set-Location c:\
Clear-Host

Install-Module -Name Az -Force -AllowClobber -Verbose

#Log into Azure
Connect-AzAccount

#Select the correct subscription
Get-AzSubscription -SubscriptionName "MSDN Platforms" | Select-AzSubscription
Get-AzContext

#Create the Resource Group
New-AzResourceGroup -Name '<ResourceGroupName>' -Location '<Location>'

#Create a Shared Image Gallery
New-AzGallery -GalleryName '<GalleryName>' -ResourceGroupName '<ResourceGroupName>' -Location '<Location>'

#View existing Shared Image Gallery
Get-AzGallery -ResourceGroupName '<ResourceGroupName>' -Name '<GalleryName>'