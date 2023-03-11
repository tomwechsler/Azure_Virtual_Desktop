# Creating a Domain Controller

This Terraform code will create the following resources:

* An Azure Virtual Network to be used as the hub network
* A subnet for an Azure Firewall, which may be added later
* A subnet for the domain controller
* A subnet for the host pool
* An Azure Virtual Machine with ADDS installed and configured

You can update the `terraform.tfvars` file as needed with the domain you want to use.

## Preparing your Azure and Azure AD environment

You will need an Azure AD tenant and ideally a custom DNS domain name. Before setting up Azure AD Connect, you can add the custom domain name that matches you Active Directory domain to your Azure AD tenant. Be sure to verify the custom domain name as well. That should involve adding a TXT record to the custom domain name zone to verify you control the domain.

The resources you deploy from the Terraform script should use a subscription associated with the Azure AD tenant you'll be using for Azure Virtual Desktop.

## Deploying the infrastructure

Before you try to use the Terraform config, you'll need to use the Azure CLI to authenticate to Azure. Terraform can use the cached credentials to create the target infrastructure.

```bash
# Login to Azure
az login

# Select the subscription you want to use
az account set -S SUBSCRIPTION_NAME
```

After that, simply follow the standard Terraform workflow:

```bash
terraform init
terraform plan
terraform apply
```

The outputs from the the configuration will be used by later Terraform configurations to add components like the Azure Firewall or create a peering connection to a spoke virtual network. The default username for the domain admin is avdDCAdmin. The password will be one of the outputs from the configuration.

## Creating users and OUs

You'll want to have some domain users and an OU structure on your brand new domain controller. The `files` directory has a PowerShell script and csv file to populate your Active Directory environment. After the domain controller has been provisioned, you will need to log in via RDP and save both files to your DC/ Then open an Administrative PowerShell window and run the script. It should create three OUs and about 500 users. The password for all users will be the same and can be changed from within the script contents.

## Configuring Azure AD Connect

To get your newly created users synced to Azure AD you'll need to install the [Azure AD Connect software](https://www.microsoft.com/en-us/download/details.aspx?id=47594). Download the installer to the domain controller and run the installer to kick off the process. You'll probably need to turn off enhanced IE protection from the Server Manager main window before opening Internet Explorer 11.

To complete the Azure AD Connect wizard, you will need the Domain Administrator and Global Administrator credentials. Run the insallation and walk through the wizard. Ideally, I'd love to use PowerShell to automate the Azure AD Connect install and config. At the time of writing, there is no way to script the installation and configuration of Azure AD Connect. Am I happy about that? No. Is it the reality? Yes.

In the wizard, choose the following options:

* Customize the install (**Do not use express settings**)
* Click *Install* without ticking any boxes
* User sign-in: select *Password Hash Synchronization* and *Enable single sign-on*
* Enter your Global Admin credentials on the *Connect to Azure AD* page
* Your domain and forest should be preselected, click on *Add Directory*
* Enter your Domain Admin credentials on the *AD forest account* page
* Leave the defaults on *Azure AD sign-in configuration*
* Leave the default on *Domains and OU filtering*
* Leave the default on *Uniquely identifying your users*
* Leave the default on *Filter users and devices*
* Check the box for *Password writeback*
* Enter your domain administrator account again on the *Enable single sign-on* page
* Click on Install to start the configuration process

After the configuration is complete, you will need to go back in to update some device settings to enable Azure AD-joined devices in hybrid mode. Click on *Exit* to close out and wait about 15 minutes for the first sync to complete. Go get a coffee, tea, or other beverage. Live a little! Start that woodworking project you've been putting off. Or learn how to shoe a horse. The world is your oyster.

Back already? Cool. 

* Launch Azure AD Connect again and select *Configure device options* and click *Next*. 
* Click *Next* again and enter your Global Admin credentials on the *Connect to Azure AD* page. 
* Leave the radio button on *Configure Hybrid Azure AD join* and click *Next*. 
* Leave the checkbox selected for Windows 10 or later domain-joined devices and click *Next*.
* Create an SCP for your current forest and enter the Domain Admin credentials in the *Enterprise Admin Credentials* box
* Click *Next* and then click *Configure* and finally *Exit*

Congratulations! Your environment is all set for deploying some host pools.
