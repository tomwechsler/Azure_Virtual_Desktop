Set-Location c:\
Clear-Host

#Install the Az Module
Install-Module -Name Az -Force -AllowClobber -Verbose

#Verify the WVD Modul is Installed
Get-InstalledModule -Name Az.Desk*

#Install the WVD module Only
Install-Module -Name Az.DesktopVirtualization

#Update the module
Update-Module Az.DesktopVirtualization

#Log into Azure
Connect-AzAccount

#Select the correct subscription
Get-AzContext
Get-AzSubscription
Get-AzSubscription -SubscriptionName "Nutzungsbasierte Bezahlung" | Select-AzSubscription

#View the current RDP Settings
Get-AzWvdHostPool -ResourceGroupName elme-rg -Name elme-hostpool | Format-list Name, CustomRdpProperty

#Remove existing settings
Update-AzWvdHostPool -ResourceGroupName elme-rg -Name elme-hostpool -CustomRdpProperty ""  

#Add an RDP Property (With this method the values are always overwritten)
Update-AzWvdHostPool -ResourceGroupName elme-rg -Name elme-hostpool -CustomRdpProperty redirectclipboard:i:0
Update-AzWvdHostPool -ResourceGroupName elme-rg -Name elme-hostpool -CustomRdpProperty redirectprinters:i:0

#Add multiple RDP Properties
$properties = "redirectclipboard:i:0;redirectprinters:i:0;drivestoredirect:s:"
Update-AzWvdHostPool -ResourceGroupName elme-rg -Name elme-hostpool -CustomRdpProperty $properties
