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

#Get Session Hosts drain mode status
Get-AzWvdSessionHost -ResourceGroupName elme-rg -HostPoolName elme-hostpool | Select-Object Name,AllowNewSession

#Enable drain mode on the Session Host
Update-AzWvdSessionHost -ResourceGroupName elme-rg -HostPoolName elme-hostpool -SessionHostName elme-sh-0.prime.pri -AllowNewSession:$false

### Remove a Session Host ###

#Set some variables first
$resourceGroup = "elme-rg"
$hostPool = "elme-hostpool"
$sessionHost = "elme-sh-0.prime.pri"

#Get active sessions on all the Session Host
Get-AzWvdSessionHost -ResourceGroupName $resourceGroup -HostPoolName $hostPool | Select-Object Name,AllowNewSession,Session

#Get active sessions on a Session Host
Get-AzWvdUserSession -ResourceGroupName $resourceGroup -HostPoolName $hostPool -SessionHostName $sessionHost | Select-Object UserPrincipalName,Name,ID | Sort-Object Name

#Send a message to all users on the Session Host session
$sessions = Get-AzWvdUserSession -ResourceGroupName $resourceGroup -HostPoolName $hostPool -SessionHostName $sessionHost
foreach ($session in $sessions) {
    $userMessage = @{
        HostPoolName = $hostPool
        ResourceGroupName = $resourceGroup
        SessionHostName = $sessionHost
        UserSessionId = ($session.id -split '/')[-1]
        MessageTitle = "Time to Log Off"
        MessageBody = "The system will shut down in 10 minute. Please Save and exit."
    }
    Send-AzWvdUserSessionMessage @userMessage
}

#Remove all user sessions from a Session Host
$sessions = Get-AzWvdUserSession -ResourceGroupName $resourceGroup -HostPoolName $hostPool -SessionHostName $sessionHost
foreach ($session in $sessions) {
    $removeSession = @{
        HostPoolName = $hostPool
        ResourceGroupName = $resourceGroup
        SessionHostName = $sessionHost
        UserSessionId = ($session.id -split '/')[-1]
    }
    Remove-AzWvdUserSession @removeSession
}

#Remove a Session Host
Remove-AzWvdSessionHost -ResourceGroupName $resourceGroup -HostPoolName $hostPool -Name $sessionHost
