# Set the resource group and hostpool names
$resource_group_name="W10-D"
$hostpool_name="W10-D"

az desktopvirtualization hostpool list --resource-group $resource_group_name
az desktopvirtualization hostpool list --resource-group $resource_group_name --query [].name

az desktopvirtualization hostpool show --name $hostpool_name --resource-group $resource_group_name