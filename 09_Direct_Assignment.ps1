Set-Location c:\
Clear-Host

#Install the Az Module
Install-Module -Name Az -Force -AllowClobber -Verbose

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

#Set host pool variables
$resourceGroup = "ResourceGroupName"
$hostPool = "HostPoolName"
$sessionHost = "SessionHost.Domain.com"
$userUpn = "User2@Domain.com"

#Get the Host Pool settings
Get-AzWvdHostPool -ResourceGroupName $resourceGroup -Name $hostPool | Format-List

#Change Host Pool Assignment Type
Update-AzWvdHostPool -ResourceGroupName $resourceGroup -Name $hostPool -PersonalDesktopAssignmentType  Direct

#View Session Host Assignemtn
Get-AzWvdSessionHost -ResourceGroupName $resourceGroup -HostPoolName $hostPool -Name $sessionHost | Format-List

#Update Sessionhost
Update-AzWvdSessionHost -ResourceGroupName $resourceGroup -HostPoolName $hostPool -Name $sessionHost -AssignedUser $userUpn