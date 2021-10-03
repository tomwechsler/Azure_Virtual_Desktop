#MSIX app attach registration sample
#region variables 
$packageName = "NotepadPPPackage_1.0.0.0_x64__483eddh1k4v7e" 

$path = "C:\Program Files\WindowsApps\" + $packageName + "\AppxManifest.xml"
#endregion

#region register
Add-AppxPackage -Path $path -DisableDevelopmentMode -Register
#endregion 