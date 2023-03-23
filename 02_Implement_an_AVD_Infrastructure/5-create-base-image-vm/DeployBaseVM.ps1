# Set a password for the local admin
$env:TF_VAR_vmadmin_password="SET_PASSWORD_HERE"

# Run the standard Terraform workflow
terraform init
terraform apply

#If you don't see a public IP address after the run completes, simply run this command:
terraform apply -refresh-only -auto-approve

# When you're done with the Azure VM you can delete it.
terraform destroy