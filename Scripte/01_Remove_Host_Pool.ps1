Set-Location c:\
Clear-Host

#Install the Az Module
Install-Module -Name Az -Force -AllowClobber -Verbose

#Import the module if necessary
Import-Module -Name Az

#Verify the WVD Moduel is Installed
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

#Set the host pool variables 
$hostPoolResourceGroup = 'wvd-2020-rg01'
$hostPoolName = 'wvdhostpool'

#Get the Application Groups
$appGroups = Get-AzWvdApplicationGroup -ResourceGroupName $hostPoolResourceGroup

#Remove the Application Groups
foreach ($appGroup in $appGroups) {
    Remove-AzWvdApplicationGroup -Name $appGroup.Name -ResourceGroupName $hostPoolResourceGroup
    Write-Output "Removed: $($appGroup.name)"
}

#Remove the Host Pool
Remove-AzWvdHostPool -Name $hostPoolName -ResourceGroupName $hostPoolResourceGroup -Force:$true