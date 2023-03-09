############
#This file is not intended to be a script. 
#You can mark the lines 20 at the end and execute them afterwards. 
#It creates virtual networks, peerings, DNS settings, a VM that serves as a DC and network security groups.
############

Set-Location c:\
Clear-Host

Install-Module -Name Az -Force -AllowClobber -Verbose

#Log into Azure
Connect-AzAccount

#Select the correct subscription
Get-AzSubscription
Get-AzSubscription -SubscriptionName "Azure subscription 1" | Select-AzSubscription

#Disable cost recommendations
Update-AzConfig -DisplayRegionIdentified $false

#Some variables
$RGName = "avd-prod-rg"
$Location = "westeurope"

#Create a resource group
New-AzResourceGroup -ResourceGroupName $RGName -Location $Location

############
#Create virtual networks, peerings and set DNS Server
############

#Create a virtual network 
$virtualNetwork1 = New-AzVirtualNetwork `
  -ResourceGroupName $RGName `
  -Location $Location `
  -Name avd-hub-vnet `
  -AddressPrefix 10.10.0.0/16

#Create a subnet configuration
$subnetConfig = Add-AzVirtualNetworkSubnetConfig `
  -Name avdsubnet `
  -AddressPrefix 10.10.3.0/24 `
  -VirtualNetwork $virtualNetwork1

#Write the subnet configuration to the virtual network
$virtualNetwork1 | Set-AzVirtualNetwork

#Create a virtual network with a 10.1.0.0/16
$virtualNetwork2 = New-AzVirtualNetwork `
  -ResourceGroupName $RGName `
  -Location $Location `
  -Name avd-spoke-vnet `
  -AddressPrefix 10.20.0.0/16

#Create the subnet configuration.
$subnetConfig = Add-AzVirtualNetworkSubnetConfig `
  -Name avdsubnet `
  -AddressPrefix 10.20.3.0/24 `
  -VirtualNetwork $virtualNetwork2

#Write the subnet configuration to the virtual network.
$virtualNetwork2 | Set-AzVirtualNetwork

#Create a peering, the following example peers avd-hub-vnet-avd-spoke-vnet
Add-AzVirtualNetworkPeering `
  -Name avd-hub-vnet-avd-spoke-vnet `
  -VirtualNetwork $virtualNetwork1 `
  -RemoteVirtualNetworkId $virtualNetwork2.Id

#=> PeeringState is Initiated

Add-AzVirtualNetworkPeering `
  -Name avd-spoke-vnet-avd-hub-vnet `
  -VirtualNetwork $virtualNetwork2 `
  -RemoteVirtualNetworkId $virtualNetwork1.Id

#Confirm that the peering state
Get-AzVirtualNetworkPeering `
  -ResourceGroupName $RGName `
  -VirtualNetworkName avd-hub-vnet `
  | Select PeeringState

Get-AzVirtualNetworkPeering `
  -ResourceGroupName $RGName `
  -VirtualNetworkName avd-spoke-vnet `
  | Select PeeringState

#Set the DNS Server for the VNets
$RGName = "avd-prod-rg"
$vNetHub = "avd-hub-vnet"
$vNetSpoke = "avd-spoke-vnet"

$vNet1 = Get-AzVirtualNetwork -ResourceGroupName $RGName -Name $vNetHub 
$vNet2 = Get-AzVirtualNetwork -ResourceGroupName $RGName -Name $vNetSpoke

# Replace the IPs with your DNS server IPs here 
$array = @("10.10.3.4") 
$newObject = New-Object -Type PSObject -Property @{"DnsServers" = $array} 

$vNet1.DhcpOptions = $newObject 
$vNet1 | Set-AzVirtualNetwork

$vNet2.DhcpOptions = $newObject 
$vNet2 | Set-AzVirtualNetwork

############
#Create VM acts as a DC
############

#Some variables
$RGName = "avd-prod-rg"
$VnetName = "avd-hub-vnet"
$Location = "westeurope"
$VMName = "dc01"
$credential = Get-Credential

#We need all infos about the virtual network
$VirtualNetwork = (Get-AzVirtualNetwork -Name $VnetName -ResourceGroupName $RGName)

#Let's have a look at the variable
$VirtualNetwork

#Create a network interface
$nic = New-AzNetworkInterface `
    -ResourceGroupName $RGName `
    -Name "dc01-nic" `
    -Location $Location `
    -SubnetId $VirtualNetwork.Subnets[0].Id

#Define your VM
$vmConfig = New-AzVMConfig -VMName $VMName -VMSize "Standard_D2s_v4"

#Create the rest of your VM configuration
$vmConfig = Set-AzVMOperatingSystem -VM $vmConfig `
    -Windows `
    -ComputerName $VMName `
    -Credential $credential `
    -ProvisionVMAgent `
    -EnableAutoUpdate
$vmConfig = Set-AzVMSourceImage -VM $vmConfig `
    -PublisherName "MicrosoftWindowsServer" `
    -Offer "WindowsServer" `
    -Skus "2022-Datacenter" `
    -Version "latest"

#Attach the network interface that you previously created
$vmConfig = Add-AzVMNetworkInterface -VM $vmConfig -Id $nic.Id

#Create your VM
New-AzVM -VM $vmConfig -ResourceGroupName $RGName -Location $Location

#Create a public IP
New-AzPublicIpAddress -Name myPublicDCIP -ResourceGroupName $RGName -AllocationMethod Dynamic -Location $Location

$vnet = Get-AzVirtualNetwork -Name $VnetName -ResourceGroupName $RGName

$subnet = Get-AzVirtualNetworkSubnetConfig -Name avdsubnet -VirtualNetwork $Vnet

$nic = Get-AzNetworkInterface -Name dc01-nic -ResourceGroupName $RGName

$pip = Get-AzPublicIpAddress -Name myPublicDCIP -ResourceGroupName $RGName

$nic | Set-AzNetworkInterfaceIpConfig -Name ipconfig1 -PublicIPAddress $pip -Subnet $subnet

$nic | Set-AzNetworkInterface

############
#Create NSG for DC
############

#Create a detailed network security group
$rule1 = New-AzNetworkSecurityRuleConfig -Name rdp-rule -Description "Allow RDP" `
    -Access Allow -Protocol Tcp -Direction Inbound -Priority 300 -SourceAddressPrefix `
    Internet -SourcePortRange * -DestinationAddressPrefix * -DestinationPortRange 3389

$nsg = New-AzNetworkSecurityGroup -ResourceGroupName $RGName -Location $location -Name `
    "avd-prod-nsg" -SecurityRules $rule1

#Let's create a variable
$VNet = Get-AzVirtualNetwork -Name $VnetName

#We save the information in a variable
$VNetSubnet = Get-AzVirtualNetworkSubnetConfig -VirtualNetwork $VNet -Name avdsubnet

#We associate the nsg to the subnet
Set-AzVirtualNetworkSubnetConfig -Name $VNetSubnet.Name -VirtualNetwork $VNet -AddressPrefix $VNetSubnet.AddressPrefix -NetworkSecurityGroup $nsg

#Updates our virtual network 
$VNet | Set-AzVirtualNetwork

#Let's check the configuration
(Get-AzVirtualNetwork -Name $VnetName).Subnets