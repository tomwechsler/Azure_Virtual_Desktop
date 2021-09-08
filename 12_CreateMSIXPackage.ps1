#Notepad++
#https://github.com/notepad-plus-plus/notepad-plus-plus/releases/download/v8.1.4/npp.8.1.4.Installer.exe
#MSIX Packaging Tool Download
#https://docs.microsoft.com/en-us/windows/msix/packaging-tool/tool-overview
#Time stamp URL
#http://timestamp.verisign.com/scripts/timstamp.dll

#Add the package to the OS (link to the package)
Add-AppxPackage '<MSIX Package>'

#Get the appx
Get-AppxPackage | where-object { $_.name -like "*notepad*" }

#Remove with the PackageFullName
Remove-AppxPackage -Package <FullPackageName>
