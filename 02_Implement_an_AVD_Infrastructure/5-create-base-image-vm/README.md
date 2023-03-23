# Steps to use this config

Follow the commands found in the `DeployBaseVM.ps1` script.

# After deploy

Once the Azure VM exists, you can customize it as needed through an RDP session. When you're done, simply run sysprep from the %windir%\sysprep directory and choose an out of box experience (OOBE) and to shut down the VM when complete. 

Then you can use the image capture process to create a managed image. The process will generalize your Azure VM and make it unusable. You can run a `terraform destroy` when the capture is complete to remove all these resources from your account.