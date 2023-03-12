#Run through a host pool deployment using Windows Server 2019 in the portal but DO NOT DEPLOY
#Save the template and parameter files to avd-host-pool.json and avd-host-pool-params.json

#The json files in this directory can serve as an example, but they do have some hard coded values you would need to change.
#You can either update the values or create your own json files from the Azure portal.

#Get credentials for the domain admin and local vmadmin
$domainAdmin = get-credential -Message "Enter domain admin credentials"
$vmAdmin = get-credential -Message "Enter vm admin credentials"

#Set a token expire time of 1 day
$tokenExpireTime = (Get-Date).AddDays(1) | Get-Date -Format yyyy-MM-ddTHH:mm:ssZ

#Create the target resource group
$resourceGroup = New-AzResourceGroup -Name "WS19" -Location "westeurope"

#Deploy the template with the parameters file and some extra information
New-AzResourceGroupDeployment -Name "HostPool" `
 -ResourceGroupName $resourceGroup.ResourceGroupName `
 -Mode Incremental `
 -TemplateParameterFile ".\avd-host-pool-params.json" `
 -TemplateFile ".\avd-host-pool.json" `
 -administratorAccountPassword $domainAdmin.Password `
 -vmAdministratorAccountPassword $vmAdmin.Password `
 -tokenExpirationTime $tokenExpireTime