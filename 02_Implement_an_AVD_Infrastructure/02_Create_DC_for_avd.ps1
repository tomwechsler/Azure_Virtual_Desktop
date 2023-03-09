############
#This file is not intended to be a script. 
#This will promote the server to a domain controller
############


#Declare variables
$DatabasePath = "C:\windows\NTDS"
$DomainMode = "WinThreshold"

#Change the Domain name and Domain Net BIOS Name to match your public domain name
$DomainName = "tomsazure.ch"
$DomainNetBIOSName = "TOMSAZURE"
$ForestMode = "WinThreshold"
$LogPath = "C:\windows\NTDS"
$SysVolPath = "C:\windows\SYSVOL"
$Password = "P@ssw0rd"

#Install AD DS, DNS and GPMC 
Start-Job -Name addFeature -ScriptBlock { 
Add-WindowsFeature -Name "ad-domain-services" -IncludeAllSubFeature -IncludeManagementTools 
Add-WindowsFeature -Name "dns" -IncludeAllSubFeature -IncludeManagementTools 
Add-WindowsFeature -Name "gpmc" -IncludeAllSubFeature -IncludeManagementTools } 
Wait-Job -Name addFeature 
Get-WindowsFeature | Where-Object {$_.InstallState -eq 'Installed'} | Format-Table DisplayName,Name,InstallState

#Convert Password 
$Password = ConvertTo-SecureString -String $Password -AsPlainText -Force

#Create New AD Forest
Install-ADDSForest -CreateDnsDelegation:$false -DatabasePath $DatabasePath -DomainMode $DomainMode -DomainName $DomainName `
    -SafeModeAdministratorPassword $Password -DomainNetbiosName $DomainNetBIOSName -ForestMode $ForestMode -InstallDns:$true -LogPath $LogPath -NoRebootOnCompletion:$false `
    -SysvolPath $SysVolPath -Force:$true