#MSIX app attach de staging sample
#region variables 
$packageName = "NotepadPPPackage_1.0.0.0_x64__483eddh1k4v7e" 

$msixJunction = "C:\temp\AppAttach\" 
#endregion

#region derregister
Remove-AppxPackage -AllUsers -Package $packageName

cd $msixJunction 
rmdir $packageName -Force -Verbose 
#endregion 