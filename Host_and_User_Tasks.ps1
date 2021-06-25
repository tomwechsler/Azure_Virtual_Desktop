Set-Location c:\
Clear-Host

#Install the Az Module
Install-Module -Name Az -Force -AllowClobber -Verbose

#Verify the AVD Moduel is Installed
Get-InstalledModule -Name Az.Desk*

#Install the AVD module Only
Install-Module -Name Az.DesktopVirtualization

#Update the module
Update-Module Az.DesktopVirtualization

#Log into Azure
Connect-AzAccount

#Select the correct subscription
Get-AzContext
Get-AzSubscription
Get-AzSubscription -SubscriptionName "Nutzungsbasierte Bezahlung" | Select-AzSubscription

#List the Hostpools
Get-AzWvdHostPool

#Get Session Hosts drain mode status
Get-AzWvdSessionHost -ResourceGroupName elme-rg -HostPoolName elme-hostpool | Select-Object Name,AllowNewSession

#About the user session
Get-AzWvdUserSession -HostPoolName "elme-hostpool" -ResourceGroupName "elme-rg" | ft *
Get-AzWvdUserSession -HostPoolName "elme-hostpool" -ResourceGroupName "elme-rg" | where {$_.userprincipalname -like "adam.*"}

#Send Message
Send-AzWvdUserSessionMessage -ResourceGroupName "elme-rg" -HostPoolName "elme-hostpool" -SessionHostName "elme-sh-6.prime.pri" -UserSessionId 2 -MessageBody "Logoff now!" -MessageTitle "Logoff now!"

#Remove
Remove-AzWvdUserSession -HostPoolName "elme-hostpool" -id 2 -ResourceGroupName "elme-rg" -SessionHostName "elme-sh-6.prime.pri"

#Disconnect
Disconnect-AzWvdUserSession -HostPoolName "elme-hostpool" -id 2 -ResourceGroupName "elme-rg" -SessionHostName "elme-sh-6.prime.pri"
