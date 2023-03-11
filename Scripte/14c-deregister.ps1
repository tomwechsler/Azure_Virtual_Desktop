#MSIX app attach deregistration sample
#region variables 
$packageName = "NotepadPPPackage_1.0.0.0_x64__483eddh1k4v7e" 
#endregion

#region deregister
Remove-AppxPackage -PreserveRoamableApplicationData $packageName 
#endregion 