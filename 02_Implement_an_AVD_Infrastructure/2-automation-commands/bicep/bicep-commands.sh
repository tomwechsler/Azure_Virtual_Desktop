# We are going to use Azure CLI authentication to deploy the Bicep template
# If you aren't already logged in
az login

# Set the subscription you want to deploy to
az account set -s "Your_Subscription_Name"

# Deploy the template to the subscription
az deployment sub create --location "westeurope" --template-file "main.bicep" \
  --parameters location="westeurope" prefix="avd" 