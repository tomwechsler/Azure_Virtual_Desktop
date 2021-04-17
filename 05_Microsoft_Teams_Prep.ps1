#Teams install script

#Set the Teams Registry key
$Name = "IsWVDEnvironment"
$value = "1"
#Add Registry Path
if (!(Test-Path "HKLM:\SOFTWARE\Microsoft\Teams")) {
    New-Item -ErrorAction Stop -Path "HKLM:\SOFTWARE\Microsoft\Teams" -Force 
}
#Add VDI Registry Value
New-ItemProperty -ErrorAction Stop -Path "HKLM:\SOFTWARE\Microsoft\Teams" -Name $name -Value $value -PropertyType DWORD -Force


#Create a temp folder for downloads
New-Item -Type Directory -Path 'c:\' -Name "temp"


#Install the WebRTC redirect service
Invoke-WebRequest -uri 'https://query.prod.cms.rt.microsoft.com/cms/api/am/binary/RE4AQBt' -OutFile 'c:\temp\MsRdcWebRTCSvc_x64.msi'
Start-Process -filepath msiexec.exe -Wait -ErrorAction Stop -ArgumentList '/i c:\temp\MsRdcWebRTCSvc_x64.msi /quiet /norestart'


#Install the Visual Studio C++ service
Invoke-WebRequest -uri 'https://aka.ms/vs/16/release/vc_redist.x64.exe' -OutFile 'c:\temp\VC_redist.x64.exe'
Start-Process -filepath c:\temp\VC_redist.x64.exe   -Wait -ErrorAction Stop -ArgumentList '/quiet /log c:\temp\VC_redist.log'


#Download the installer to the C:\temp directory
Invoke-WebRequest -uri 'https://teams.microsoft.com/downloads/desktopurl?env=production&plat=windows&arch=x64&managedInstaller=true&download=true' -OutFile 'c:\temp\Teams_windows_x64.msi'
#Install Teams
Start-Process -filepath msiexec.exe -Wait -ErrorAction Stop -ArgumentList '/i', 'c:\temp\Teams_windows_x64.msi', '/l*v c:\temp\teams.log', 'ALLUSER=1'


#Sysprep the VM with Mode:VM
#Bypass Windows Modules Installer
C:\Windows\system32\sysprep\sysprep.exe /generalize /shutdown /oobe /mode:vm 