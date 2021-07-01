Set-Location c:\
Clear-Host

#Create OU
New-ADOrganizationalUnit 'ToSync' -path 'DC=zodiac,DC=local' -ProtectedFromAccidentalDeletion $false

#Some variables
$ouName = 'ToSync'
$ouPath = "OU=$ouName,DC=zodiac,DC=local"
$adUserNamePrefix = 'aduser'
$adUPNSuffix = 'zodiac.local'
$userCount = 1..9

#loop to create the users
foreach ($counter in $userCount) {
  New-AdUser -Name $adUserNamePrefix$counter -Path $ouPath -Enabled $True `
    -ChangePasswordAtLogon $false -userPrincipalName $adUserNamePrefix$counter@$adUPNSuffix `
    -AccountPassword (ConvertTo-SecureString 'Pa55w.rd1234' -AsPlainText -Force) -passThru
} 

#More variables
$adUserNamePrefix = 'avdadmin1'
$adUPNSuffix = 'zodiac.local'

#Create the user
New-AdUser -Name $adUserNamePrefix -Path $ouPath -Enabled $True `
    -ChangePasswordAtLogon $false -userPrincipalName $adUserNamePrefix@$adUPNSuffix `
    -AccountPassword (ConvertTo-SecureString 'Pa55w.rd1234' -AsPlainText -Force) -passThru

#Set Domain Admin role
Get-ADGroup -Identity 'Domänen-Admins' | Add-AdGroupMember -Members 'wvdadmin1'

#Some new groups
New-ADGroup -Name 'avd-pooled' -GroupScope 'Global' -GroupCategory Security -Path $ouPath
New-ADGroup -Name 'avd-remote-app' -GroupScope 'Global' -GroupCategory Security -Path $ouPath
New-ADGroup -Name 'avd-personal' -GroupScope 'Global' -GroupCategory Security -Path $ouPath
New-ADGroup -Name 'avd-users' -GroupScope 'Global' -GroupCategory Security -Path $ouPath
New-ADGroup -Name 'avd-admins' -GroupScope 'Global' -GroupCategory Security -Path $ouPath

#Assign the users to the groups
Get-ADGroup -Identity 'avd-pooled' | Add-AdGroupMember -Members 'aduser1','aduser2','aduser3','aduser4'
Get-ADGroup -Identity 'avd-remote-app' | Add-AdGroupMember -Members 'aduser1','aduser5','aduser6'
Get-ADGroup -Identity 'avd-personal' | Add-AdGroupMember -Members 'aduser7','aduser8','aduser9'
Get-ADGroup -Identity 'avd-users' | Add-AdGroupMember -Members 'aduser1','aduser2','aduser3','aduser4','aduser5','aduser6','aduser7','aduser8','aduser9'
Get-ADGroup -Identity 'avd-admins' | Add-AdGroupMember -Members 'wvdadmin1'

#List of all the AD Users in the organization
Get-ADUser -Filter * | Sort-Object Name | Format-Table Name, UserPrincipalName

#Change the UPN for all the AD users in the organization
$LocalUsers = Get-ADUser -Filter {UserPrincipalName -like '*zodiac.local'} -Properties UserPrincipalName -ResultSetSize $null
$LocalUsers | foreach {$newUpn = $_.UserPrincipalName.Replace("zodiac.local","tomscloud.ch"); $_ | Set-ADUser -UserPrincipalName $newUpn}

#Confirm that the UPN is changed
Get-ADUser -Filter * | Sort-Object Name | Format-Table Name, UserPrincipalName
