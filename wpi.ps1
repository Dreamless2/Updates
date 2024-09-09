$TempDir = $env:TEMP
$LogFile = "$env:TEMP\WPI_Log\WPI.log"

Invoke-WebRequest -Uri "https://raw.githubusercontent.com/Dreamless2/Updates/main/DS_PowerShell_Function_Library.psm1" -OutFile "$TempDir\DS_PowerShell_Function_Library.psm1"

if (Test-Path "$TempDir\DS_PowerShell_Function_Library.psm1") {
    Import-Module "$TempDir\DS_PowerShell_Function_Library.psm1"
}

# ------------ VARIÁVEIS ------------ #

$PKGS = @(
    "9P7KNL5RWT25",
    "Microsoft.VCRedist.2005.x86",
    "Microsoft.VCRedist.2005.x64",
    "Microsoft.VCRedist.2008.x86",
    "Microsoft.VCRedist.2008.x64",
    "Microsoft.VCRedist.2010.x86",
    "Microsoft.VCRedist.2010.x64",
    "Microsoft.VCRedist.2012.x86",
    "Microsoft.VCRedist.2012.x64",
    "Microsoft.VCRedist.2013.x86",
    "Microsoft.VCRedist.2013.x64",
    "Microsoft.VCRedist.2015+.x86",
    "Microsoft.VCRedist.2015+.x64",
    "Google.Chrome",
    "Mozilla.Firefox",
    "Opera.Opera",
    "VideoLAN.VLC",
    "SomePythonThings.WingetUIStore",
    "KDE.Kdenlive",
    "Telegram.TelegramDesktop",
    "Kotatogram.Kotatogram",
    "RevoUninstaller.RevoUninstallerPro",
    "Tonec.InternetDownloadManager",
    "Microsoft.VisualStudioCode",
    "Bitwarden.Bitwarden",
    "voidtools.Everything",
    "Microsoft.PowerShell",
    "Microsoft.PowerToys",
    "PowerSoftware.PowerISO",
    "RARLab.WinRAR",
    "gerardog.gsudo",
    "arch1t3cht.Aegisub",
    "7zip.7zip",
    "Python.Python.3.12",
    "Git.Git",
    "GitHub.cli",
    "Foxit.FoxitReader",    
    "MoritzBunkus.MKVToolNix", 
    "LeNgocKhoa.Laragon",
    "CodeSector.TeraCopy",
    "CodeSector.DirectFolders",
    "UnifiedIntents.UnifiedRemote",
    "Gyan.FFmpeg",
    "QL-Win.QuickLook",
    "MediaArea.MediaInfo.GUI",
    "ArduinoSA.IDE.stable",
    "Microsoft.VisualStudio.2022.Enterprise"    
)

# ------------ FUNÇÕES DE SAÍDA ------------ #

function Exit-Script {
    Clear-TempFiles   
    DS_WriteLog "I" "Restarting to apply changes..." $LogFile
    try {
        Restart-Computer -Confirm
    }
    catch {
        DS_WriteLog "W" "Failed to restart the system. Please restart manually." $LogFile
    }
    exit 0
}    

# ------------ FUNÇÕES AUXILIARES ------------ #

function DownloadFileWebRequest {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string]$SourceUri,
         
        [Parameter(Mandatory = $true)]
        [string]$DestinationPath
    )
     
    try {       
        Invoke-WebRequest -Uri $SourceUri -OutFile $DestinationPath
        DS_WriteLog "I" "Download successful using Invoke-WebRequest." $LogFile
    }
    catch {        
        DS_WriteLog "E" "An error occurred while downloading using Invoke-WebRequest. Error details: $_.Exception.Message" $LogFile
    }
}

# Function to download a file using System.Net.WebClient
function DownloadFileWebClient {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string]$SourceUri,
         
        [Parameter(Mandatory = $true)]
        [string]$DestinationPath
    )
     
    try {
        $webClient = New-Object System.Net.WebClient
        $webClient.DownloadFile($SourceUri, $DestinationPath)
        DS_WriteLog "I" "Download successful using WebClient." $LogFile
    }
    catch {
        DS_WriteLog "E" "An error occurred while downloading using WebClient. Error details: $_.Exception.Message" $LogFile
    }
}

# Function to download a file using BitsTransfer
function DownloadFileBitsTransfer {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string]$SourceUri,        
        [Parameter(Mandatory = $true)]
        [string]$DestinationPath
    )
     
    try {
        $bitsJob = Start-BitsTransfer -Source $SourceUri -Destination $DestinationPath -Asynchronous
         
        while (($bitsJob.JobState -eq 'Transferring') -or ($bitsJob.JobState -eq 'Connecting')) {
            Start-Sleep -Seconds 10
        }
         
        if ($bitsJob.JobState -eq 'Error') {
            Resume-BitsTransfer -BitsJob $bitsJob
        }
         
        if ($bitsJob.JobState -eq 'Transferred') {
            Complete-BitsTransfer -BitsJob $bitsJob
        }
         
        DS_WriteLog "I" "Download successful using BitsTransfer." $LogFile
    }
    catch {
        DS_WriteLog "E" "An error occurred while downloading using BitsTransfer. Error details: $_.Exception.Message" $LogFile
    }
}

function Clear-TempFiles {
    try {
        DS_WriteLog "I" "Clean all files on $TempDir..." $LogFile

        $tempFiles = Get-ChildItem -Path $TempDir -Recurse

        foreach ($file in $tempFiles) {
            try {
                DS_CleanupDirectory -Directory $file.FullName
                DS_WriteLog "I" "Removed: $($file.FullName)" $LogFile
            }
            catch {
                DS_WriteLog "W" "Failed to remove: $($file.FullName). Reason: $_" $LogFile
            }
        }
        DS_WriteLog "I" "Cleaning completed." $LogFile
    }
    catch {
        DS_WriteLog "E" "An error occurred when trying to clear the TEMP folder: $_" $LogFile
    }
}

function Set-Ensure-Admin {
    if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
        DS_WriteLog "E" "This script must be run as Administrator!" $LogFile
    }
}

function Set-Ensure-InternetConnection {
    DS_WriteLog "I" "Checking internet connection..." $LogFile
    Test-Connection 8.8.8.8 -Count 1 -ErrorAction SilentlyContinue | Out-Null
    
    if (-not $?) {
        DS_WriteLog "E" "The computer needs to be connected to the internet to run this script!" $LogFile
    }
}

function Set-Ensure-OSCompatibility {
    DS_WriteLog "I" "Checking system compatibility..." $LogFile
    $OS_name = Get-CimInstance Win32_OperatingSystem | Select-Object -ExpandProperty Caption
    
    if (-not $OS_name) {
        DS_WriteLog "E" "Unknown or unsupported Windows version!" $LogFile
    } 
    else {
        DS_WriteLog "I" "Operating system identified: $OS_name" $LogFile
        $OS_version = ($OS_name -split ' ')[2]
    
        if ($OS_version -lt 10) {
            DS_WriteLog "I" "Unknown or unsupported Windows version!" $LogFile
        } 
        else {
            DS_WriteLog "I" "Operating system version: $OS_version" $LogFile
        }
    }
}

function Set-Wallpaper {
    $wallpaperUrl = "https://images.pexels.com/photos/20775596/pexels-photo-20775596/free-photo-of-mar-panorama-vista-paisagem.jpeg"
    $wallpaperFileName = [System.IO.Path]::GetFileName($wallpaperUrl)
    $wallpaperPath = Join-Path -Path $env:USERPROFILE -ChildPath $wallpaperFileName
    DS_WriteLog "I" "Applying new wallpaper..." $LogFile
    DS_SetRegistryValue -RegKeyPath "hkcu:\Control Panel\Desktop" -RegValueName "JPEGImportQuality" -RegValue "100" -Type "DWORD"
    DownloadFileWebRequest -SourceUri $wallpaperUrl -DestinationPath $wallpaperPath
    DS_SetRegistryValue -RegKeyPath "hkcu:\Control Panel\Desktop" -RegValueName "Wallpaper" -RegValue "$wallpaperPath" -Type "String"
    Invoke-Expression -Command 'rundll32.exe user32.dll, UpdatePerUserSystemParameters 1, True'
    DS_WriteLog "I" "Customizations applied. Windows Explorer will restart." $LogFile
    Stop-Process -Name explorer -Force ; Start-Process explorer    
}
function Set-ConfigSystem {
    Set-Ensure-Admin
    Set-Ensure-InternetConnection
    Set-Ensure-OSCompatibility     
    DS_SetRegistryValue -RegKeyPath "hkcu:\Control Panel\Keyboard" -RegValueName "PrintScreenKeyForSnippingEnabled" -RegValue "0" -Type "DWORD"
    DS_SetRegistryValue -RegKeyPath "hklm:\SOFTWARE\Policies\Microsoft\OneDrive" -RegValueName "KFMBlockOptIn" -RegValue "1" -Type "DWORD"
    DS_SetRegistryValue -RegKeyPath "hkcu:\SOFTWARE\Policies\Microsoft\TabletPC" -RegValueName "DisableSnippingTool" -RegValue "1" -Type "DWORD"
    DS_SetRegistryValue -RegKeyPath "hklm:\SOFTWARE\Policies\Microsoft\TabletPC" -RegValueName "DisableSnippingTool" -RegValue "1" -Type "DWORD"
}

# ------------ INSTALAÇÃO DO WINGET ------------ #

function Install-WingetDependency {
    param (
        [string]$URL
    )
    $PackageName = [System.IO.Path]::GetFileName($URL)
    $PackagePath = Join-Path -Path $TempDir -ChildPath $PackageName
    
    try {
        if (-not (Test-Path $PackagePath)) {
            DS_WriteLog "I" "Downloading $PackageName..." $LogFile
            DownloadFileBitsTransfer -SourceUri $URL -DestinationPath $PackagePath
        }
        Add-AppxPackage -Path $PackagePath -ErrorAction Stop | Out-Null
    }
    catch {
        DS_WriteLog "E" "Error downloading or installing $PackageName" $LogFile
    }
}
function Install-Winget {
    DS_WriteLog "I" "Starting the download and installation of Winget and its dependencies..." $LogFile
    Install-WingetDependency "https://download.microsoft.com/download/4/7/c/47c6134b-d61f-4024-83bd-b9c9ea951c25/Microsoft.VCLibs.x64.14.00.Desktop.appx"
    Install-WingetDependency "https://github.com/microsoft/microsoft-ui-xaml/releases/download/v2.8.6/Microsoft.UI.Xaml.2.8.x64.appx"
    Install-WingetDependency "https://github.com/microsoft/winget-cli/releases/latest/download/Microsoft.DesktopAppInstaller_8wekyb3d8bbwe.msixbundle"    
    winget list --accept-source-agreements -ErrorAction Stop | Out-Null
    DS_WriteLog "I" "Winget has been properly updated and is ready to use." $LogFile
}


# ------------ INSTALAÇÃO DOS PACOTES ------------ #

function Install-WingetPackages {
    DS_WriteLog "I" "Starting Winget package installation..." $LogFile

    $count = 0

    foreach ($pkg in $PKGS) {
        $installed = Invoke-Expression -Command "winget list $pkg --accept-source-agreements"
        if ($installed -match ([regex]::Escape($pkg))) {
            DS_WriteLog "W" "$pkg are installed." $LogFile
        }
        else {
            DS_WriteLog "I" "Installing $pkg ..." $LogFile
            Invoke-Expression -Command "winget install $pkg --accept-package-agreements --accept-source-agreements -h" -ErrorAction SilentlyContinue
            
            if ($?) {
                DS_WriteLog "I" "The package $pkg are installed!" $LogFile
                $count++
            }
            else {
                DS_WriteLog "W" "Failed to install the package $pkg." $LogFile              
            }
        }
    }

    DS_WriteLog "I" "Packages Installed with Successfully." $LogFile
    DS_WriteLog "I" "$count of $($PKGS.Count) packages were installed successfully." $LogFile
}

function Disable-Superfetch {
    DS_ChangeServiceStartupType -ServiceName "SysMain" -StartupType "Disabled" 
    DS_StopService -ServiceName "SysMain" 
}

function Add-ExtrasPackages {
    $presets = "C:\ShanaEncoder\presets"
    $settings = "C:\ShanaEncoder\settings" 
    $shanaUrl = "https://www.videohelp.com/download/ShanaEncoder6.0.1.7.exe"
    $codecUrl = "https://file.shana.pe.kr/lib/CodecLibrary.v1.2.x64.7z"
    $regUrl = "https://gist.githubusercontent.com/MuhammadSaim/de84d1ca59952cf1efaa8c061aab81a1/raw/ca31cbda01412e85949810d52d03573af281f826/rarreg.key"
    $cnPackUrl = "https://github.com/cnpack/cnwizards/releases/download/CNWIZARDS_1.3.1.1181_20240404/CnWizards_1.3.1.1181.exe"
    $qBitTorrentUrl = "https://sinalbr.dl.sourceforge.net/project/qbittorrent/qbittorrent-win32/qbittorrent-4.6.6/qbittorrent_4.6.6_lt20_qt6_x64_setup.exe"
    $inviskaUrl = "https://www.videohelp.com/download/Inviska_MKV_Extract_11.0_x86-64_Setup.exe"
    $jdkUrl = "https://github.com/adoptium/temurin21-binaries/releases/download/jdk-21.0.4%2B7/OpenJDK21U-jdk_x64_windows_hotspot_21.0.4_7.msi"  

    $shana = [System.IO.Path]::GetFileName($shanaUrl)
    $codecs = [System.IO.Path]::GetFileName($codecUrl)
    $cnPack = [System.IO.Path]::GetFileName($cnPackUrl)
    $inviska = [System.IO.Path]::GetFileName($inviskaUrl)
    $qBitTorrent = [System.IO.Path]::GetFileName($qBitTorrentUrl)
    $jdkName = [System.IO.Path]::GetFileName($jdkUrl)
    $shanaPath = Join-Path -Path $TempDir -ChildPath $shana
    $codecsPath = Join-Path -Path $TempDir -ChildPath $codecs  
    $cnPackPath = Join-Path -Path $TempDir -ChildPath $cnPack    
    $inviskaPath = Join-Path -Path $TempDir -ChildPath $inviska
    $qBitTorrentPath = Join-Path -Path $TempDir -ChildPath $qBitTorrent
    $jdkPath = Join-Path $TempDir $jdkName

    DS_WriteLog "I" "Installing Extras Packages" $LogFile
    
    if (-not(Test-Path "C:\ShanaEncoder")) {        
        DS_WriteLog "I" "Downloading Shana Encoder..." $LogFile
        DownloadFileBitsTransfer -SourceUri $codecUrl -DestinationPath $codecsPath
        DownloadFileBitsTransfer -SourceUri $shanaUrl -DestinationPath $shanaPath                
        Start-Process -FilePath $shanaPath -Wait -NoNewWindow
        $xml = @(
            "https://raw.githubusercontent.com/Dreamless2/Updates/main/MP4%20HD%20Dub.xml",
            "https://raw.githubusercontent.com/Dreamless2/Updates/main/MP4%20HD%20Leg.xml",
            "https://raw.githubusercontent.com/Dreamless2/Updates/main/MP4%20SD%20Dub.xml",
            "https://raw.githubusercontent.com/Dreamless2/Updates/main/MP4%20SD%20Leg.xml",
            "https://raw.githubusercontent.com/Dreamless2/Updates/main/Stream%20Copy%20to%20MP4.xml",
            "https://raw.githubusercontent.com/Dreamless2/Updates/main/shanaapp.xml"
        )
        
        $cleanUrls = $xml | ForEach-Object { [uri]::UnescapeDataString($_) }              
        
        foreach ($url in $cleanUrls) {   
            $fileName = [System.IO.Path]::GetFileName($url)
            $filePath = Join-Path $TempDir $fileName
            DownloadFileBitsTransfer -SourceUri $url -DestinationPath $filePath
            DS_WriteLog "I" "Files Saved on: $filePath" $LogFile     
        }
              
        if (Test-Path -Path $presets) {        
            Remove-Item -Path $presets -Force -Recurse
            DS_DeleteDirectory -Directory $presets            
        }        

        if (Test-Path -Path $settings) {            
            DS_DeleteDirectory -File $settings
        }     
       
        DS_CreateDirectory -Directory "$presets\(Copy)"
        DS_CreateDirectory -Directory "$presets\MP4"     
        DS_CreateDirectory -Directory $settings                  
        DS_CopyFile -SourceFiles "$TempDir\MP4 HD Dub.xml" -Destination "$presets\MP4"
        DS_CopyFile -SourceFiles "$TempDir\MP4 HD Leg.xml" -Destination "$presets\MP4"
        DS_CopyFile -SourceFiles "$TempDir\MP4 SD Dub.xml" -Destination "$presets\MP4"
        DS_CopyFile -SourceFiles "$TempDir\MP4 SD Leg.xml" -Destination "$presets\MP4"
        DS_CopyFile -SourceFiles "$TempDir\Stream Copy to MP4.xml" -Destination "$presets\(Copy)"           
        DS_CopyFile -SourceFiles "$TempDir\shanaapp.xml" -Destination "$settings\shanaapp.xml" -Force        
    }
    else {
        DS_WriteLog "W" "Shana Encoder already installed." $LogFile
    }

    if (-not(Test-Path "C:\Program Files\WinRAR\rarreg.key")) {
        DS_WriteLog "I" "Registering WinRAR..." $LogFile
        DownloadFileBitsTransfer -SourceUri $regUrl -DestinationPath $TempDir
        DS_CopyFile -SourceFiles "$TempDir\rarreg.key" -Destination "C:\Program Files\WinRAR"
    }
    else {
        DS_WriteLog "W" "Winrar already registered." $LogFile        
    }

    if (-not(Test-Path "C:\Program Files (x86)\CnPack")) {
        DS_WriteLog "I" "Installing CNPACK Wizard..." $LogFile
        DownloadFileBitsTransfer -SourceUri $cnPackUrl -DestinationPath $cnPackPath  
        Start-Process -FilePath $cnPackPath -Wait -NoNewWindow            
    }
    else {
        DS_WriteLog "W" "CnPack already installed." $LogFile
    }  

    if (-not(Test-Path "C:\Program Files\qBittorrent\qbittorrent.exe")) {
        DS_WriteLog "I" "Installing qBitTorrent..." $LogFile
        DownloadFileBitsTransfer -SourceUri $qBitTorrentUrl -DestinationPath $qBitTorrentPath             
        Start-Process -FilePath $qBitTorrentPath -ArgumentList "/S"
    }
    else {
        DS_WriteLog "W" "qBitTorrent already installed." $LogFile
    }
    
    if (-not(Test-Path "C:\Program Files\Inviska MKV Extract\InviskaMKVExtract.exe")) {        
        DS_WriteLog "I" "Installing Inviska MKV Extract" $LogFile
        DownloadFileBitsTransfer -SourceUri $inviskaUrl -DestinationPath $inviskaPath
        Start-Process -FilePath $inviskaPath -Wait -NoNewWindow
    }
    else {
        DS_WriteLog "W" "Inviska MKV Extract already installed." $LogFile
    }

    if (-not(Test-Path "C:\Program Files\Eclipse Adoptium\jdk-21.0.4.7-hotspot\bin\javac.exe")) {
        DS_WriteLog "I" "Downloading JDK Temurin 21" $LogFile
        DownloadFileBitsTransfer -SourceUri $jdkUrl -DestinationPath $jdkPath
        Start-Process "msiexec.exe" -ArgumentList "/i ADDLOCAL=FeatureMain,FeatureEnvironment,FeatureJarFileRunWith,FeatureJavaHome /quiet"    }
    else {
        DS_WriteLog "W" "JDK Temurin 21 already installed." $LogFile
    }

    DS_WriteLog "I" "Downloading QuickLook Plugins" $LogFile
    DownloadFileBitsTransfer -SourceUri "https://github.com/canheo136/QuickLook.Plugin.ApkViewer/releases/download/1.3.5/QuickLook.Plugin.ApkViewer.qlplugin" -DestinationPath "$env:USERPROFILE\Downloads"
    DownloadFileBitsTransfer -SourceUri "https://github.com/adyanth/QuickLook.Plugin.FolderViewer/releases/download/1.3/QuickLook.Plugin.FolderViewer.qlplugin" -DestinationPath "$env:USERPROFILE\Downloads"
    DownloadFileBitsTransfer -SourceUri "https://github.com/Cologler/QuickLook.Plugin.TorrentViewer/releases/download/0.2.1/QuickLook.Plugin.TorrentViewer.qlplugin" -DestinationPath "$env:USERPROFILE\Downloads"   
    DS_WriteLog "I" "Packages Installed Successfully." $LogFile
}

function Set-BitTorrentFolders {
    $bitTorrent = "D:\BitTorrent"
    $folders = @(, 'Compressed', 'Documents', 'Logs', 'Music', 'Programs', 'Temp', 'Torrents', 'Video')  

    if (-not(Test-Path $bitTorrent)) {
        DS_CreateDirectory -Directory $bitTorrent
        foreach ($folder in $folders) {
            DS_CreateDirectory -Directory $bitTorrent\$folder
        }
    }
    else {
        DS_WriteLog "W" "Folders Already Exists." $LogFile
    }
}
function Set-IDMFolders {
    $idmDir = "D:\IDM"
    $folders = @(, 'Compressed', 'Documents', 'Music', 'Programs', 'Temp', 'Video', 'APK', 'ISO', 'General')  

    if (-not(Test-Path $idmDir)) {
        DS_CreateDirectory -Directory $idmDir
        foreach ($folder in $folders) {
            DS_CreateDirectory -Directory $idmDir\$folder
        }
    }
    else {
        DS_WriteLog "W" "Folders Already Exists." $LogFile
    }
}

function Set-WinRARFolders {
    $rarDir = "D:\RAR"
    $folders = @(, 'Extracted', 'Output', 'Temp')  

    if (-not(Test-Path $rarDir)) {
        DS_CreateDirectory -Directory $rarDir 
        foreach ($folder in $folders) {
            DS_CreateDirectory -Directory $rarDir\$folder 
        }
    }
    else {
        DS_WriteLog "W" "Folders Already Exists." $LogFile
    }
}

function Set-TelegramFolders {
    $kotatogramDir = "D:\Kotatogram Desktop"
    $telegramDir = "D:\Telegram Desktop"
    
    if (-not(Test-Path $kotatogramDir)) {
        DS_CreateDirectory -Directory $kotatogramDir   
    }
    elseif (-not(Test-Path $telegramDir)) {
        DS_CreateDirectory -Directory $telegramDir 
    }
    else {
        DS_WriteLog "W" "Folders Already Exists." $LogFile
    }
}

function Set-LaragonConfiguration {    
    $php = "https://windows.php.net/downloads/releases/php-8.3.11-nts-Win32-vs16-x64.zip"
    $apache = "https://www.apachelounge.com/download/VS17/binaries/httpd-2.4.62-240904-win64-VS17.zip"
    $notepadplusplus = "https://github.com/notepad-plus-plus/notepad-plus-plus/releases/download/v8.6.9/npp.8.6.9.portable.x64.zip"
    $nginx = "https://nginx.org/download/nginx-1.27.1.zip"
    $apacheName = [System.IO.Path]::GetFileName($apache)
    $phpName = [System.IO.Path]::GetFileName($php)
    $notepadplusplusName = [System.IO.Path]::GetFileName($notepadplusplus)
    $nginxName = [System.IO.Path]::GetFileName($nginx)
    $phpPath = Join-Path $TempDir $phpName
    $apachePath = Join-Path $TempDir $apacheName
    $notepadplusplusPath = Join-Path $TempDir $notepadplusplusName
    $nginxPath = Join-Path $TempDir $nginxName
    DS_CleanupDirectory -Directory "C:\laragon\bin\php"
    DS_CleanupDirectory -Directory "C:\laragon\bin\apache"
    DS_CleanupDirectory -Directory "C:\laragon\bin\git"
    DS_CleanupDirectory -Directory "C:\laragon\bin\heidisql"
    DS_CleanupDirectory -Directory "C:\laragon\bin\mysql"
    DS_CleanupDirectory -Directory "C:\laragon\bin\nodejs"
    DS_CleanupDirectory -Directory "C:\laragon\bin\notepad++"
    DS_CleanupDirectory -Directory "C:\laragon\bin\nginx"
    DS_CleanupDirectory -Directory "C:\laragon\bin\python"
    DS_CreateDirectory -Directory "C:\laragon\bin\php\php8"
    DownloadFileBitsTransfer -SourceUri $php -DestinationPath $phpPath
    DownloadFileBitsTransfer -SourceUri $apache -DestinationPath $apachePath
    DownloadFileBitsTransfer -SourceUri $notepadplusplus -DestinationPath $notepadplusplusPath
    DownloadFileBitsTransfer -SourceUri $nginx -DestinationPath $nginxPath
    Expand-Archive -LiteralPath $apachePath -DestinationPath "C:\laragon\bin\apache" -Force
    Expand-Archive -LiteralPath $phpPath -DestinationPath "C:\laragon\bin\php\php8" -Force
    Expand-Archive -LiteralPath $notepadplusplusPath -DestinationPath "C:\laragon\bin\notepad++" -Force
    Expand-Archive -LiteralPath $nginxPath -DestinationPath "C:\laragon\bin\nginx" -Force
    DS_DeleteFile "C:\laragon\bin\apache\-- Win64 VS17  --"
    DS_DeleteFile "C:\laragon\bin\apache\ReadMe.txt"
    DS_WriteLog "I" "Laragon configured." $LogFile
}
function Invoke-ISOExe {
    param (
        [parameter(Mandatory = $True)]
        [string] $ISO,  
        [parameter(Mandatory = $True)]
        [string] $ExeName    		
    )

    DS_WriteLog "I" "Mounting $ISO" $LogFile
    Mount-DiskImage -ImagePath $ISO -ErrorAction Stop | Out-Null
    DS_WriteLog "S" "Mounting Image $ISO successfully." $LogFile

    $driveLetter = (Get-DiskImage $ISO | Get-Volume).DriveLetter   

    if ($driveLetter) {
        $exeFullPath = "$($driveLetter):\$ExeName"      

        if (Test-Path $exeFullPath) {
            Start-Process -FilePath $exeFullPath -Wait
        }
        else {
            DS_WriteLog "E" "The file '$exeFullPath' not found." $LogFile
        }
    }
    else {
        DS_WriteLog "E" "Unable to determine the drive letter for the ISO image." $LogFile
    }
    
    DS_WriteLog "I" "Unmounting Image $ISO" $LogFile
    Dismount-DiskImage -ImagePath $ISO -ErrorAction Stop | Out-Null   
    DS_WriteLog "S" "Unmounting Image $ISO successfully." $LogFile
}
function Get-Delphi12 {
    $delphiURL = "https://altd.embarcadero.com/download/radstudio/12.0/RADStudio_12_1_61_7529.iso"    
    $delphi = [System.IO.Path]::GetFileName($delphiURL)
    $ISOPath = "$env:USERPROFILE\Downloads\$delphi"
    DS_WriteLog "I" "Installing Delphi 12.1..." $LogFile
    if (-not(Test-Path -Path $ISOPath)) {   
        DownloadFileBitsTransfer -SourceUri $delphiURL -DestinationPath "$env:USERPROFILE\Downloads"  
    }
    else {
        Invoke-ISOExe -ISO $ISOPath -ExeName "radstudio_12_esd_117529a.exe"
    }
}

# ------------ EXECUÇÃO ------------ #

Set-ConfigSystem
Install-Winget
Install-WingetPackages
Disable-Superfetch
Set-Wallpaper
Set-BitTorrentFolders
Set-IDMFolders
Set-WinRARFolders
Set-TelegramFolders
Add-ExtrasPackages
Set-LaragonConfiguration
Get-Delphi12
Exit-Script
