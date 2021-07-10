# Create the self signed cert
# List of country codes can be found at:
# https://www.digicert.com/kb/ssl-certificate-country-codes.htm
$friendlyName = "MSIXAPPDIGCERT"
$commonName = "DigCert"
$orgName = "elme"
$countryCode = "CH"
New-SelfSignedCertificate -Type Custom -Subject "CN=$commonName, O=$orgName, C=$countryCode" -KeyUsage DigitalSignature -FriendlyName $friendlyName `
-CertStoreLocation "Cert:\CurrentUser\My" -TextExtension @("2.5.29.37={text}1.3.6.1.5.5.7.3.3", "2.5.29.19={text}")

#Get the Cert
Set-Location Cert:\CurrentUser\My
Get-ChildItem | Format-Table Subject, FriendlyName, Thumbprint

#Export the code signing .pfx Cert
$pass = Read-Host "Enter Password" -AsSecureString

Set-Location Cert:\CurrentUser\My

$cert = Get-ChildItem | where-object {$_.FriendlyName -eq $friendlyName}
$thumbprint = $cert.thumbprint
Export-PfxCertificate -cert "Cert:\CurrentUser\My\$thumbprint" -FilePath $env:USERPROFILE\Documents\MSIXCert.pfx -Password $pass

#Export the .cer certificate
Export-Certificate -Cert $cert -FilePath $env:USERPROFILE\Documents\MSIXCert.cer


#Export the .cer file, import it into the computer trusted root store
Import-Certificate -ErrorAction Stop -FilePath $env:USERPROFILE\Documents\MSIXCert.cer -CertStoreLocation Cert:\LocalMachine\Root