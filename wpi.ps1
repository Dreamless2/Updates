$TempDir = $env:TEMP
$LogFile = "$env:TEMP\WPI_Log\WPI.log"

Invoke-WebRequest -Uri "https://raw.githubusercontent.com/Dreamless2/Updates/main/DS_PowerShell_Function_Library.psm1" -OutFile "$TempDir\DS_PowerShell_Function_Library.psm1"

if (Test-Path -Path "$TempDir\DS_PowerShell_Function_Library.psm1") {
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
    "FxSoundLLC.FxSound", 
    "Flameshot.Flameshot",
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

    $name = [System.IO.Path]::GetFileName($SourceUri)
     
    try {       
        Invoke-WebRequest -Uri $SourceUri -OutFile $DestinationPath
        DS_WriteLog "I" "Download $name successful." $LogFile
    }
    catch {        
        DS_WriteLog "E" "An error occurred while downloading $name. Error details: $_.Exception.Message" $LogFile
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
     
    $name = [System.IO.Path]::GetFileName($SourceUri)

    try {
        $webClient = New-Object System.Net.WebClient
        $webClient.DownloadFile($SourceUri, $DestinationPath)
        DS_WriteLog "I" "Download $name successful." $LogFile
    }
    catch {
        DS_WriteLog "E" "An error occurred while downloading $name. Error details: $_.Exception.Message" $LogFile
    }
}

# Function to download a file using BitsTransfer
function DownloadFileBitsTransfer {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string]$SourceUri,        
        [Parameter(Mandatory = $true)]
        [string]$DestinationPath,
        [switch]$includeStats
    )
     
    $name = [System.IO.Path]::GetFileName($SourceUri)

    try {
        $bitsJob = Start-BitsTransfer -Source $SourceUri -Destination $DestinationPath -Asynchronous
         
        while (($bitsJob.JobState -eq 'Transferring') -or ($bitsJob.JobState -eq 'Connecting')) {
            filter Get-FileSize {
                "{0:N2} {1}" -f $(
                    if ($_ -lt 1kb) { $_, 'Bytes' }
                    elseif ($_ -lt 1mb) { ($_ / 1kb), 'KB' }
                    elseif ($_ -lt 1gb) { ($_ / 1mb), 'MB' }
                    elseif ($_ -lt 1tb) { ($_ / 1gb), 'GB' }
                    elseif ($_ -lt 1pb) { ($_ / 1tb), 'TB' }
                    else { ($_ / 1pb), 'PB' }
                )
            }               
            $elapsed = ((Get-Date) - $start)
            $averageSpeed = ($job.BytesTransferred * 8 / 1MB) / $elapsed.TotalSeconds
            $elapsed = $elapsed.ToString('hh\:mm\:ss')
            $remainingSeconds = ($job.BytesTotal - $job.BytesTransferred) * 8 / 1MB / $averageSpeed
            $receivedSize = $job.BytesTransferred | Get-FileSize
            $totalSize = $job.BytesTotal | Get-FileSize 
            $progressPercentage = [int]($job.BytesTransferred / $job.BytesTotal * 100)      
            if ($remainingSeconds -as [int]) {
                Write-Progress -Activity (" $url {0:N2} Mbps" -f $averageSpeed) `
                    -Status ("{0} of {1} ({2}% in {3})" -f $receivedSize, $totalSize, $progressPercentage, $elapsed) `
                    -SecondsRemaining $remainingSeconds `
                    -PercentComplete $progressPercentage
            }
        }

        if ($includeStats.IsPresent) {
            ([PSCustomObject]@{Name = $MyInvocation.MyCommand; TotalSize = $totalSize; Time = $elapsed }) | Out-Host
        }
        
        Write-Progress -Activity (" $SourceUri {0:N2} Mbps" -f $averageSpeed) `
            -Status 'Done' -Completed
         
        if ($bitsJob.JobState -eq 'Error') {
            Resume-BitsTransfer -BitsJob $bitsJob
        }
         
        if ($bitsJob.JobState -eq 'Transferred') {
            Complete-BitsTransfer -BitsJob $bitsJob
            Get-Item $DestinationPath | Unblock-File
        }         
        DS_WriteLog "I" "Download $name successful." $LogFile
    }
    catch {
        DS_WriteLog "E" "An error occurred while downloading $name. Error details: $_.Exception.Message" $LogFile
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
    $wallpaperUrl = "https://images.pexels.com/photos/28298948/pexels-photo-28298948/free-photo-of-estrasburgo-petite-france.jpeg"
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
            DownloadFileBitsTransfer -SourceUri $URL -DestinationPath $PackagePath -includeStats
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
            DS_WriteLog "W" "$pkg already installed." $LogFile
        }
        else {
            DS_WriteLog "I" "Installing $pkg ..." $LogFile
            Invoke-Expression -Command "winget install $pkg --accept-package-agreements --accept-source-agreements -h" -ErrorAction SilentlyContinue
            
            if ($?) {
                DS_WriteLog "I" "The package $pkg already installed!" $LogFile
                $count++
            }
            else {
                DS_WriteLog "W" "Failed to install the package $pkg." $LogFile              
            }
        }
    }

    DS_WriteLog "I" "All packages installed." $LogFile
    DS_WriteLog "I" "$count of $($PKGS.Count) packages were installed successful." $LogFile
}

function Disable-Services {
    $services = @(
        "CertPropSvc"                              # Certificates Propagation Service
        "diagnosticshub.standardcollector.service" # Microsoft (R) Diagnostics Hub Standard Collector Service
        "DiagTrack"                                # Diagnostics Tracking Service
        "DPS"                                      # Diagnostic Policies Service
        "dmwappushservice"                         # WAP Push Message Routing Service  
        "iphlpsvc"                                 # Auxiliar IP App
        "lfsvc"                                    # Geolocation Service
        "lmhosts"                                  # NetBIOS over TCP/IP Auxiliar App
        "MapsBroker"                               # Downloaded Maps Manager
        "MSiSCSI"                                  # Microsoft iSCSI Initatior Service
        "Netlogon"                                 # NetLogon Service
        "PcaSvc"                                   # Compatibility Programs Assistant Service
        "RemoteRegistry"                           # Remote Registry
        "RemoteAccess"                             # Routing and Remote Access
        "RpcLocator"                               # Remote Procedure Call (RPC) Locator
        "SCardSvr"                                 # Smart card
        "SCPolicySvc"                              # Smart card Extraction Policy Service
        "SharedAccess"                             # Internet Connection Sharing (ICS)
        "SNMPTRAP"                                 # SNMP Capture Service
        "Spooler"                                  # Print Spooler Service
        "stisvc"                                   # Windows Image acquisition (WIA) Service
        "TabletInputService"                       # Handwriting Panel and touch keyboard Service
        "TrkWks"                                   # Distributed Link Tracking Client
        "WbioSrvc"                                 # Windows Biometric Service
        "WlanSvc"                                  # WLAN AutoConfig    
        "WMPNetworkSvc"                            # Windows Media Player Network Sharing Service
        "SysMain"                                  # SuperFetch
        "WSearch"                                  # Windows Search
    )

    foreach ($service in $services) {
        DS_WriteLog "I" "Disabling and stopping unnecessary services..." $LogFile
        DS_ChangeServiceStartupType -ServiceName $service -StartupType "Disabled" 
        DS_StopService -ServiceName $service
        DS_WriteLog "S" "Unnecessary service $service disabled and stopped successful." $LogFile
    }
}

function Remove-WindowsDefender {
    DS_WriteLog "I" "Downloading Windows Defender Removal..."
    $defenderUrl = "https://github.com/ionuttbara/windows-defender-remover/releases/download/release_def_12_8/DefenderRemover.exe"
    $defenderName = [System.IO.Path]::GetFileName($defenderUrl)
    $defenderPath = Join-Path $TempDir $defenderName
    DownloadFileBitsTransfer -SourceUri $defenderUrl -DestinationPath $defenderPath -includeStats
    Start-Process -FilePath $defenderPath -Wait -NoNewWindow
}

function Add-ExtrasPackages {
    $presets = "C:\ShanaEncoder\presets"
    $settings = "C:\ShanaEncoder\settings" 
    $shanaUrl = "https://github.com/Dreamless2/Updates/releases/download/youpdates/ShanaEncoder6.0.1.7.exe"
    $codecUrl = "https://github.com/Dreamless2/Updates/releases/download/youpdates/CodecLibrary.v1.2.x64.7z"
    $regUrl = "https://github.com/Dreamless2/Updates/releases/download/youpdates/rarreg.key"
    $cnPackUrl = "https://github.com/cnpack/cnwizards/releases/download/CNWIZARDS_1.3.1.1181_20240404/CnWizards_1.3.1.1181.exe"
    $qBitTorrentUrl = "https://github.com/Dreamless2/Updates/releases/download/youpdates/qbittorrent_4.6.6_lt20_qt6_x64_setup.exe"
    $inviskaUrl = "https://github.com/Dreamless2/Updates/releases/download/youpdates/Inviska_MKV_Extract_11.0_x86-64_Setup.exe"
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
    
    if (-not(Test-Path -Path "C:\ShanaEncoder")) {        
        DS_WriteLog "I" "Downloading Shana Encoder..." $LogFile
        DownloadFileBitsTransfer -SourceUri $codecUrl -DestinationPath $codecsPath -includeStats
        DownloadFileBitsTransfer -SourceUri $shanaUrl -DestinationPath $shanaPath -includeStats        
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
            DownloadFileBitsTransfer -SourceUri $url -DestinationPath $filePath -includeStats
            DS_WriteLog "I" "Files Saved on: $filePath" $LogFile     
        }           
    }
    else {
        DS_WriteLog "I" "Shana Encoder already installed. Starting configuration..." $LogFile
        if (Test-Path -Path $presets) {                    
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
        DS_WriteLog "S" "Shana Encoder configured succesful." $LogFile
    }

    if (-not(Test-Path -Path "C:\Program Files\WinRAR\rarreg.key")) {
        DS_WriteLog "I" "Registering WinRAR..." $LogFile
        DownloadFileBitsTransfer -SourceUri $regUrl -DestinationPath $TempDir -includeStats
        DS_CopyFile -SourceFiles "$TempDir\rarreg.key" -Destination "C:\Program Files\WinRAR" -includeStats
    }
    else {
        DS_WriteLog "W" "Winrar already registered." $LogFile        
    }

    if (-not(Test-Path -Path "C:\Program Files (x86)\CnPack")) {
        DS_WriteLog "I" "Installing CnPack Wizard..." $LogFile
        DownloadFileBitsTransfer -SourceUri $cnPackUrl -DestinationPath $cnPackPath -includeStats
        Start-Process -FilePath $cnPackPath -Wait -NoNewWindow             
    }
    else {
        DS_WriteLog "W" "CnPack already installed." $LogFile
    }  

    if (-not(Test-Path -Path "C:\Program Files\qBittorrent\qbittorrent.exe")) {
        DS_WriteLog "I" "Installing qBitTorrent..." $LogFile
        DownloadFileBitsTransfer -SourceUri $qBitTorrentUrl -DestinationPath $qBitTorrentPath -includeStats      
        Start-Process -FilePath $qBitTorrentPath -ArgumentList "/S" -Wait -NoNewWindow                     
    }
    else {
        DS_WriteLog "W" "qBitTorrent already installed." $LogFile
    }
    
    if (-not(Test-Path -Path "C:\Program Files\Inviska MKV Extract\InviskaMKVExtract.exe")) {        
        DS_WriteLog "I" "Installing Inviska MKV Extract..." $LogFile
        DownloadFileBitsTransfer -SourceUri $inviskaUrl -DestinationPath $inviskaPath -includeStats
        Start-Process -FilePath $inviskaPath -Wait -NoNewWindow        
    }
    else {
        DS_WriteLog "W" "Inviska MKV Extract already installed." $LogFile
    }

    if (-not(Test-Path -Path "C:\Program Files\Eclipse Adoptium\jdk-21.0.4.7-hotspot\bin\javac.exe")) {
        DS_WriteLog "I" "Downloading JDK Temurin 21..." $LogFile
        DownloadFileBitsTransfer -SourceUri $jdkUrl -DestinationPath $jdkPath -includeStats
        Start-Process "msiexec" -ArgumentList "/i $jdkPath ADDLOCAL=FeatureMain,FeatureEnvironment,FeatureJarFileRunWith,FeatureJavaHome /quiet"    
    }
    else {
        DS_WriteLog "W" "JDK Temurin 21 already installed." $LogFile
    }

    DS_WriteLog "I" "Downloading QuickLook Plugins" $LogFile
    DownloadFileBitsTransfer -SourceUri "https://github.com/canheo136/QuickLook.Plugin.ApkViewer/releases/download/1.3.5/QuickLook.Plugin.ApkViewer.qlplugin" -DestinationPath "$env:USERPROFILE\Downloads" -includeStats
    DownloadFileBitsTransfer -SourceUri "https://github.com/adyanth/QuickLook.Plugin.FolderViewer/releases/download/1.3/QuickLook.Plugin.FolderViewer.qlplugin" -DestinationPath "$env:USERPROFILE\Downloads" -includeStats
    DownloadFileBitsTransfer -SourceUri "https://github.com/Cologler/QuickLook.Plugin.TorrentViewer/releases/download/0.2.1/QuickLook.Plugin.TorrentViewer.qlplugin" -DestinationPath "$env:USERPROFILE\Downloads" -includeStats
    DS_WriteLog "S" "Plugins QuickLook downloaded successful." $LogFile
    DS_WriteLog "S" "Packages Installed successful." $LogFile
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
        DS_WriteLog "W" "Folders already exists." $LogFile
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
        DS_WriteLog "W" "Folders already exists." $LogFile
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
        DS_WriteLog "W" "Folders already exists." $LogFile
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
        DS_WriteLog "W" "Folders already exists." $LogFile
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
    DownloadFileBitsTransfer -SourceUri $php -DestinationPath $phpPath -includeStats
    DownloadFileBitsTransfer -SourceUri $apache -DestinationPath $apachePath -includeStats
    DownloadFileBitsTransfer -SourceUri $notepadplusplus -DestinationPath $notepadplusplusPath -includeStats
    DownloadFileBitsTransfer -SourceUri $nginx -DestinationPath $nginxPath -includeStats
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
        [string] $ExeName,  		
        [parameter(Mandatory = $False)]
        [string] $ExeArgs = ""
    )

    DS_WriteLog "I" "Mounting $ISO" $LogFile
    Mount-DiskImage -ImagePath $ISO -ErrorAction Stop | Out-Null
    DS_WriteLog "S" "Mounting Image $ISO successfully." $LogFile

    $driveLetter = (Get-DiskImage $ISO | Get-Volume).DriveLetter   

    if ($driveLetter) {
        $exeFullPath = "$($driveLetter):\$ExeName"      
       
        if (Test-Path $exeFullPath) {
            if ([string]::IsNullOrEmpty($ExeArgs)) {
                Start-Process -FilePath $exeFullPath -Wait -NoNewWindow
            }
            else {
                Start-Process -FilePath $exeFullPath -ArgumentList $ExeArgs -Wait -NoNewWindow 
            }
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
        DownloadFileBitsTransfer -SourceUri $delphiURL -DestinationPath "$env:USERPROFILE\Downloads" -includeStats  
    }
    else {
        Invoke-ISOExe -ISO $ISOPath -ExeName "radstudio_12_esd_117529a.exe"
    }
}

# ------------ EXECUÇÃO ------------ #

Disable-Services
Set-ConfigSystem
Set-Wallpaper
Install-Winget
Install-WingetPackages
Get-Delphi12
Set-BitTorrentFolders
Set-IDMFolders
Set-WinRARFolders
Set-TelegramFolders
Set-LaragonConfiguration
Add-ExtrasPackages
Remove-WindowsDefender
Exit-Script
