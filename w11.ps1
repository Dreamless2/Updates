$AppsDir = "$env:USERPROFILE\Downloads\Apps"
$presets = "$env:HOMEDRIVE\ShanaEncoder\presets"
$shanaSettings = "$env:HOMEDRIVE\ShanaEncoder\settings" 
$LogFile = "$AppsDir\w11.log"
$settings = "$AppsDir\Settings.reg"
$idm = "$AppsDir\IDM.reg"
$revoLic = "$AppsDir\revouninstallerpro5.lic"

$NektaModule = "$env:TEMP\Nekta.psm1"

New-Item -ItemType Directory -Path $AppsDir | Out-Null
Start-BitsTransfer -Source "https://github.com/Dreamless2/Updates/releases/download/youpdates/Settings.reg" -Destination $AppsDir
Start-BitsTransfer -Source "https://github.com/Dreamless2/Updates/releases/download/youpdates/IDM.reg" -Destination $AppsDir
Start-BitsTransfer -Source "https://github.com/Dreamless2/Updates/releases/download/youpdates/revouninstallerpro5.lic" -Destination $AppsDir

if (-not (Test-Path -Path $NektaModule)) {
    Invoke-WebRequest -Uri "https://raw.githubusercontent.com/Dreamless2/Updates/refs/heads/main/Nekta.psm1" -OutFile $NektaModule
}

Import-Module $NektaModule -Force

#==========================================================================

# Início
#==========================================================================

$shanaUrl = "https://github.com/Dreamless2/Updates/releases/download/youpdates/ShanaEncoder7.4.exe"
$inviskaUrl = "https://github.com/Dreamless2/Updates/releases/download/youpdates/Inviska_MKV_Extract_11.0_x86-64_Setup.exe"
$qBitTorrentUrl = "https://sinalbr.dl.sourceforge.net/project/qbittorrent/qbittorrent-win32/qbittorrent-5.1.2/qbittorrent_5.1.2_qt6_lt20_x64_setup.exe"
$defenderUrl = "https://github.com/ionuttbara/windows-defender-remover/releases/download/release_def_12_8/DefenderRemover.exe"    
$codec32Url = "https://github.com/Dreamless2/Updates/releases/download/youpdates/CodecLibrary.v1.2.x86.7z"
$codec64Url = "https://github.com/Dreamless2/Updates/releases/download/youpdates/CodecLibrary.v1.2.x64.7z"
$rarregUrl = "https://github.com/Dreamless2/Updates/releases/download/youpdates/rarreg.key"    

$shana = [System.IO.Path]::GetFileName($shanaUrl)        
$inviska = [System.IO.Path]::GetFileName($inviskaUrl)
$qBitTorrentName = [System.IO.Path]::GetFileName($qBitTorrentUrl)
$defenderName = [System.IO.Path]::GetFileName($defenderUrl)
$rarregName = [System.IO.Path]::GetFileName($rarregUrl)

$defenderPath = Join-Path $AppsDir $defenderName
$shanaPath = Join-Path $AppsDir $shana      
$inviskaPath = Join-Path $AppsDir $inviska
$qBitTorrentPath = Join-Path $AppsDir $qBitTorrentName
$rarregPath = Join-Path $AppsDir $rarregName

#==========================================================================

# Pacotes winget
#==========================================================================

$PKGS = @(   
    "GeorgieLabs.SoundWireServer",
    "CrystalRich.LockHunter",   
    "Maxthon.Maxthon",
    "Flameshot.Flameshot",
    "VideoLAN.VLC",  
    "Telegram.TelegramDesktop",
    "Kotatogram.Kotatogram",
    "Tonec.InternetDownloadManager",
    "Microsoft.VisualStudioCode",
    "Bitwarden.Bitwarden",
    "voidtools.Everything",
    "Microsoft.PowerShell",
    "Microsoft.PowerToys", 
    "gerardog.gsudo",  
    "Git.Git",
    "RamenSoftware.Windhawk",
    "MoritzBunkus.MKVToolNix",    
    "UnifiedIntents.UnifiedRemote",
    "QL-Win.QuickLook",
    "MediaArea.MediaInfo.GUI",
    "OpenJS.NodeJS.LTS",      
    "EclipseAdoptium.Temurin.21.JDK",
    "Foxit.FoxitReader",
    "kukuruzka165.materialgram",
    "RadolynLabs.AyuGramDesktop"
)

function Set-ConfigSystem {    
    Nekta_Logging INFO "Configuring computer settings" $LogFile    
    Nekta_SetRegKeyValue -K "hkcu:\Control Panel\Keyboard" -V "PrintScreenKeyForSnippingEnabled" -KV "0" -T "DWORD"
    Nekta_SetRegKeyValue -K "hklm:\SOFTWARE\Policies\Microsoft\OneDrive" -V "KFMBlockOptIn" -KV "1" -T "DWORD"
    Nekta_SetRegKeyValue -K "hkcu:\SOFTWARE\Policies\Microsoft\TabletPC" -V "DisableSnippingTool" -KV "1" -T "DWORD"
    Nekta_SetRegKeyValue -K "hklm:\SOFTWARE\Policies\Microsoft\TabletPC" -V "DisableSnippingTool" -KV "1" -T "DWORD"
    Nekta_SetRegKeyValue -K "hkcu:\Software\Microsoft\Windows\CurrentVersion\Policies\Attachments" -V "SaveZoneInformation" -KV "1" -T "DWORD"
    Nekta_SetRegKeyValue -K "hkcu:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -V "SilentInstalledAppsEnabled" -KV "0" -T "DWORD"
    Nekta_SetRegKeyValue -K "hklm:\SYSTEM\CurrentControlSet\Control\BitLocker" -V "PreventDeviceEncryption" -KV "1" -Type DWORD
    Nekta_SetRegKeyValue -K "hklm:\SYSTEM\CurrentControlSet\Control\FileSystem" -V "LongPathsEnabled" -KV "1" -T "DWORD"
    Nekta_SetRegKeyValue -K "hklm:\Software\Microsoft\Visualstudio\Setup\" -V "CachePath" -KV "D:\Microsoft\VisualStudio\Packages" -T "String"  
    Nekta_SetRegKeyValue -K "hklm:\Software\Microsoft\Visualstudio\Setup\" -V "SharedInstallationPath" -KV "D:\Microsoft\VisualStudio\Shared" -T "String"
    Nekta_Logging SUCCESS "Done." $LogFile
}
function Set-PowerOptions {
    Nekta_Logging INFO "Settings for maximum performance" $LogFile
    Invoke-Expression -Command "powercfg /h off"
    Invoke-Expression -Command "powercfg /s e9a42b02-d5df-448d-aa00-03f14749eb61"
    Invoke-Expression -Command "powercfg /x standby-timeout-ac 0"
    Invoke-Expression -Command "powercfg /x disk-timeout-ac 0"
    Invoke-Expression -Command "powercfg /x monitor-timeout-ac 15"
    Invoke-Expression -Command "powercfg /SETACVALUEINDEX SCHEME_CURRENT 2a737441-1930-4402-8d77-b2bebba308a3 48e6b7a6-50f5-4782-a5d4-53bb8f07e226 0"
    Invoke-Expression -Command "fsutil.exe behavior set disableLastAccess 1"
    Invoke-Expression -Command "fsutil behavior set disable8dot3 1"
    Nekta_Logging SUCCESS "Done." $LogFile
}

#==========================================================================

# Pacotes
#==========================================================================

function Install-WingetPackages {
    Nekta_Logging INFO "Install packages using winget" $LogFile

    $count = 0

    foreach ($pkg in $PKGS) {
        $installed = Invoke-Expression -Command "winget list $pkg --accept-source-agreements --accept-package-agreements"
        if ($installed -match ([regex]::Escape($pkg))) {
            Nekta_Logging WARNING " $pkg installed." $LogFile
        }
        else {
            Nekta_Logging INFO "Starting the installation of $pkg" $LogFile
            Invoke-Expression -Command "winget install $pkg --accept-package-agreements --accept-source-agreements -e -h" -ErrorAction SilentlyContinue
            
            if ($?) {
                Nekta_Logging INFO "The package $pkg was installed!" $LogFile
                $count++
            }
            else {
                Nekta_Logging WARNING " Failed to install package $pkg." $LogFile              
            }
        }
    }

    Nekta_Logging INFO "All packages installed." $LogFile
    Nekta_Logging INFO "$count of $($PKGS.Count) packages are installed." $LogFile
}

#==========================================================================

# Desabilitar Serviços
#==========================================================================

function Disable-Services {
    $services = @(
        "CertPropSvc"                              # Certificates Propagation Service
        "diagnosticshub.standardcollector.service" # Microsoft (R) Diagnostics Hub Standard Collector Service
        "DiagTrack"                                # Diagnostics Tracking Service
        "DPS"                                      # Diagnostic Policies Service
        "dmwappushservice"                         # WAP Push Message Routing Service  
        "iphlpsvc"                                 # Auxiliar IP App
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
        "stisvc"                                   # Windows Image acquisition (WIA) Service        
        "TrkWks"                                   # Distributed Link Tracking Client
        "WbioSrvc"                                 # Windows Biometric Service
        "WlanSvc"                                  # WLAN AutoConfig    
        "WMPNetworkSvc"                            # Windows Media Player Network Sharing Service
        "SysMain"                                  # SuperFetch
        "WSearch"                                  # Windows Search
    )

    foreach ($service in $services) {
        Nekta_Logging INFO "Disabling and stopping unnecessary services" $LogFile
        Nekta_ModifyStartupService -S $service -T "Disabled"
        Nekta_StopService -S $service        
        Nekta_Logging SUCCESS "Service $service disabled and stopped successfully." $LogFile
    }
}

#==========================================================================

# Remover Windows Defender
#==========================================================================

function Remove-WindowsDefender {
    Nekta_Logging INFO "Downloading Windows Defender Removal" $LogFile
    Nekta_NovaDownloader -U $defenderUrl -D $AppsDir
    Nekta_RunProcessNoWait -F $defenderPath
}

#==========================================================================

# Configuração Extras 
#==========================================================================

function Add-ExtrasPackages {  
    Start-BitsTransfer -Source "https://github.com/Dreamless2/Updates/releases/download/youpdates/Settings.reg" -Destination $AppsDir
    if (Test-Path -Path "$env:ProgramFiles\VS Revo Group\Revo Uninstaller Pro\RevoUninPro.exe") {
        Nekta_Logging INFO "Activating Revo Uninstaller Pro" $LogFile        
        Nekta_CopyArchive -F "$AppsDir\revouninstallerpro5.lic" -D "$env:ProgramData\VS Revo Group\Revo Uninstaller Pro"        
        Nekta_Logging SUCCESS "Revo Uninstaller Pro activated successfully." $LogFile
    }

    if (Test-Path -Path "${env:ProgramFiles(x86)}\Internet Download Manager\IDMan.exe") {
        Nekta_Logging INFO "Ativando IDM." $LogFile
        Stop-Process -Name "idm*" -Force
        Nekta_ImportRegFile -F $idm
        Nekta_Logging SUCCESS "IDM activated successfully." $LogFile        
    }

    if (-not(Test-Path -Path "$env:ProgramFiles\WinRAR\rarreg.key")) {
        Nekta_Logging INFO "Activating WinRAR" $LogFile
        Nekta_NovaDownloader -U $rarregUrl -D $AppsDir
        Nekta_CopyArchive -F $rarregPath -D "$env:ProgramFiles\WinRAR"       
        Nekta_Logging SUCCESS "WinRAR activated successfully." $LogFile          
    }
    else {
        Nekta_Logging INFO "Starting configuration" $LogFile
        Nekta_ImportRegFile -F $settings
        Nekta_Logging SUCCESS "Winrar successfully configured." $LogFile           
    }       

    Nekta_Logging SUCCESS "Packages installed successfully." $LogFile   
}

#==========================================================================

# Apps Principais
#==========================================================================
function Get-QuickLookPlugins {
    Nekta_Logging INFO "Downloading QuickLook plugins" $LogFile
    Nekta_NovaDownloader -U "https://github.com/canheo136/QuickLook.Plugin.ApkViewer/releases/download/1.3.5/QuickLook.Plugin.ApkViewer.qlplugin" -D $AppsDir
    Nekta_NovaDownloader -U "https://github.com/adyanth/QuickLook.Plugin.FolderViewer/releases/download/1.3/QuickLook.Plugin.FolderViewer.qlplugin" -D $AppsDir
    Nekta_NovaDownloader -U "https://github.com/emako/QuickLook.Plugin.TorrentViewer/releases/download/v1.0.3/QuickLook.Plugin.TorrentViewer.qlplugin" -D $AppsDir  
    Nekta_NovaDownloader -U "https://github.com/mooflu/QuickLook.Plugin.WebViewPlus/releases/download/1.6.1/QuickLook.Plugin.WebViewPlus.qlplugin" -D $AppsDir 
    Nekta_Logging SUCCESS "Done." $LogFile
}
function Install-Office365 {
    $officeToolUrl = "https://github.com/YerongAI/Office-Tool/releases/download/v10.24.68.0/Office_Tool_with_runtime_v10.24.68.0_x64.zip"
    $configurationUrl = "https://github.com/Dreamless2/Updates/releases/download/youpdates/Configuration.xml"
    $officeToolName = [System.IO.Path]::GetFileName($officeToolUrl)
    $officeToolPath = Join-Path $AppsDir $officeToolName    
    Nekta_Logging INFO "Installing Office 365" $LogFile
    Nekta_NovaDownloader -U $configurationUrl -D $AppsDir    
    Nekta_NovaDownloader -U $officeToolUrl -D $AppsDir
    Nekta_UnzipArchive -F $officeToolPath -D $AppsDir -P
    Nekta_RunProcess -F "$AppsDir\Office Tool\Office Tool Plus.exe"
    Invoke-RestMethod https://get.activated.win | Invoke-Expression
    Nekta_Logging SUCCESS "Office 365 successfully installed." $LogFile
}
function Install-BitTorrent {
    Nekta_Logging INFO "Starting installation of qBitTorrent..." $LogFile
    if (-not(Test-Path -Path "$env:ProgramFiles\qBittorrent\qbittorrent.exe")) {      
        Nekta_NovaDownloader -U $qBitTorrentUrl -D $AppsDir        
        Nekta_SetupInstall -F $qBitTorrentPath -A "/S"
        Nekta_Logging SUCCESS "qBitTorrent successfully installed." $LogFile                  
    }
    else {
        Nekta_Logging WARNING "qBitTorrent is already installed." $LogFile
    } 
}
function Install-MKVExtractor {
    Nekta_Logging INFO "Starting installation of Inviska MKV Extract..." $LogFile
    if (-not(Test-Path -Path "$env:ProgramFiles\Inviska MKV Extract\InviskaMKVExtract.exe")) {              
        Nekta_NovaDownloader -U $inviskaUrl -D $AppsDir                
        Nekta_SetupInstall -F $inviskaPath
        Nekta_Logging SUCCESS "Inviska MKV Extract successfully installed." $LogFile               
    }
    else {
        Nekta_Logging WARNING "Inviska MKV Extract is already installed." $LogFile
    }         
}
function Get-Python {
    Nekta_Logging INFO "Starting installation of ptyhon." $LogFile   
    
    if (-not(Test-Path -Path "$env:LOCALAPPDATA\Programs\Python\Python313\python.exe")) {                
        $pythonDownloadUrl = "https://www.python.org/downloads/"
        $response = Invoke-WebRequest -Uri $pythonDownloadUrl
        $html = $response.Content
        $regex = [regex]"\bPython (\d+\.\d+\.\d+)\b"
        $python = $regex.Matches($html)
        $latestVersion = $python | Sort-Object { [Version]$_.Groups[1].Value } -Descending | Select-Object -First 1

        if ($latestVersion) {
            $version = $latestVersion.Groups[1].Value
            Nekta_Logging INFO "The latest version of Python is: $version." $LogFile
            $downloadUrl = "https://www.python.org/ftp/python/$version/python-$version-amd64.exe"
            $outputPath = "$AppsDir\python-$version-amd64.exe"
            Nekta_Logging INFO "Downloading Python $version of $downloadUrl for $outputPath." $LogFile  
            Nekta_NovaDownloader -U $downloadUrl -D $AppsDir              
            Nekta_Logging INFO "Download completed successfully! Installer saved in $outputPath." $LogFile  
        }
        else {
            Nekta_Logging INFO "Unable to find the latest version of Python." $LogFile
        }        
    }
    else {
        Nekta_Logging SUCCESS "Python is already installed no sistema." $LogFile
    }
}
function Install-ShanaEncoder {
    Nekta_Logging INFO "Starting installation of Shana Encoder..." $LogFile
    if (-not(Test-Path -Path "$env:HOMEDRIVE\ShanaEncoder")) {        
        Nekta_NovaDownloader -U $codec32Url -D $AppsDir
        Nekta_NovaDownloader -U $codec64Url -D $AppsDir
        Nekta_NovaDownloader -U $shanaUrl -D $AppsDir    
        Nekta_SetupInstall -F $shanaPath
        Nekta_Logging SUCCESS "ShanaEncoder successfully installed." $LogFile
    }

    Nekta_Logging INFO "Starting configuration do Shana Encoder." $LogFile
      
    if (Test-Path -Path "$env:HOMEDRIVE\ShanaEncoder") { 
        Nekta_Logging INFO "Starting configuration de ShanaEncoder." $LogFile 
        $xml = @(
            "https://raw.githubusercontent.com/Dreamless2/Updates/main/MP4%20HD%20Dub.xml",
            "https://raw.githubusercontent.com/Dreamless2/Updates/main/MP4%20HD%20Leg.xml",
            "https://raw.githubusercontent.com/Dreamless2/Updates/main/MP4%20SD%20Dub.xml",
            "https://raw.githubusercontent.com/Dreamless2/Updates/main/MP4%20SD%20Leg.xml",
            "https://raw.githubusercontent.com/Dreamless2/Updates/main/Stream%20Copy%20to%20MP4.xml",
            "https://raw.githubusercontent.com/Dreamless2/Updates/main/shanaapp.xml"
            "https://raw.githubusercontent.com/Dreamless2/Updates/main/Instagram.xml"
        )
          
        $cleanUrls = $xml | ForEach-Object { [uri]::UnescapeDataString($_) }              
          
        foreach ($url in $cleanUrls) {   
            $fileName = [System.IO.Path]::GetFileName($url)
            $filePath = Join-Path $AppsDir $fileName
            Invoke-WebRequest -Uri $url -OutFile $filePath
            Nekta_Logging INFO "Files saved in: $filePath." $LogFile
        }           
        if (Test-Path -Path $presets) {                 
            Nekta_WipeDirectory -D $presets
        }        
  
        if (Test-Path -Path $settings) {    
            Nekta_WipeDirectory -D $settings
        }           

        Nekta_NewDirectory -D "$presets\(Copy)"
        Nekta_NewDirectory -D "$presets\MP4"
        Nekta_NewDirectory -D "$presets\Social"
        Nekta_NewDirectory -D $shanaSettings           
        Nekta_CopyArchive -F "$AppsDir\MP4 HD Dub.xml" -D "$presets\MP4"
        Nekta_CopyArchive -F "$AppsDir\MP4 HD Leg.xml" -D "$presets\MP4"
        Nekta_CopyArchive -F "$AppsDir\MP4 SD Dub.xml" -D "$presets\MP4"
        Nekta_CopyArchive -F "$AppsDir\MP4 SD Leg.xml" -D "$presets\MP4"
        Nekta_CopyArchive -F "$AppsDir\Stream Copy to MP4.xml" -D "$presets\(Copy)"      
        Nekta_CopyArchive -F "$AppsDir\shanaapp.xml" -D "$shanasettings\shanaapp.xml"
        Nekta_CopyArchive -F "$AppsDir\Instagram.xml" -D "$presets\Social"
        Nekta_Logging SUCCESS "ShanaEncoder successfully configured." $LogFile
    }
}

#==========================================================================

# Extras
#==========================================================================
function Set-BitTorrentFolders {
    $dir = "D:\BitTorrent"
    $folders = @(, 'Compressed', 'Documents', 'ISO', 'Logs', 'Music', 'Programs', 'Temp', 'Torrents', 'Video')  

    if (-not(Test-Path -Path $dir)) {
        Nekta_NewDirectory -D $dir
        foreach ($folder in $folders) {
            Nekta_NewDirectory -D $dir\$folder
        }
    }
    else {
        Nekta_Logging WARNING "Folder already exists." $LogFile
    }
}
function Set-IDMFolders {
    $dir = "D:\IDM"
    $folders = @(, 'Compressed', 'Documents', 'Music', 'Programs', 'Temp', 'Video', 'APK', 'ISO', 'General')  

    if (-not(Test-Path -Path $dir)) {
        Nekta_NewDirectory -D $dir
        foreach ($folder in $folders) {            
            Nekta_NewDirectory -D "$dir\$folder"
        }
    }
    else {
        Nekta_Logging WARNING "Folder already exists." $LogFile
    }
}
function Set-WinRARFolders {
    $dir = "D:\RAR"
    $folders = @(, 'Extracted', 'Output', 'Temp')  

    if (-not(Test-Path -Path $dir)) {
        Nekta_NewDirectory -D $dir 
        foreach ($folder in $folders) {
            Nekta_NewDirectory -D "$dir\$folder"
        }
    }
    else {
        Nekta_Logging WARNING "Folder already exists." $LogFile
    }
}
function Set-KotatogramFolders {
    $dir = "D:\Kotatogram"

    if (-not(Test-Path -Path $dir)) {
        Nekta_NewDirectory -D $dir   
    }
    else {
        Nekta_Logging WARNING "Folder already exists." $LogFile
    }
}   

function Set-AuygramFolders {
    $dir = "D:\Auygram"

    if (-not(Test-Path -Path $dir)) {
        Nekta_NewDirectory -D $dir
    }
    else {
        Nekta_Logging WARNING "Folder already exists." $LogFile
    }
}   
function Set-MaterialgramFolders {
    $dir = "D:\Materialgram"

    if (-not(Test-Path -Path $dir)) {
        Nekta_NewDirectory -D $dir
    }
    else {
        Nekta_Logging WARNING "Folder already exists." $LogFile
    }
}   

function Set-TelegramFolders {
    $dir = "D:\Telegram"
    
    if (-not(Test-Path -Path $dir)) {
        Nekta_NewDirectory -D $dir
    }
    else {
        Nekta_Logging WARNING "Folder already exists." $LogFile
    }
}
function Install-Python {
    $python = Get-ChildItem -Path $AppsDir -Filter "python*.exe" -Recurse -ErrorAction SilentlyContinue

    if ($python -and $python.FullName -is [string]) {
        Nekta_Logging INFO "File found: $($python.Name)." $LogFile
        Nekta_Logging INFO $python.Name $LogFile
        Nekta_SetupInstall -F $python.FullName -A "/quiet InstallAllUsers=0 Include_pip=1 Include_exe=1 Include_dev=0 PrependPath=1 Include_lib=1 Include_tcltk=1 Include_launcher=1 Include_doc=0 Include_test=0 Include_symbols=0 Include_debug=0 AssociateFiles=1"
    }
    else {
        Nekta_Logging INFO "File not found. Downloading new version." $LogFile
        Get-Python    
    }
}

#==========================================================================

# Execução
#==========================================================================

Disable-Services
Set-ConfigSystem
Set-PowerOptions
Get-QuickLookPlugins
Install-WingetPackages
Install-Office365
Install-ShanaEncoder
Install-BitTorrent
Install-MKVExtractor
Install-Python
Set-BitTorrentFolders
Set-IDMFolders
Set-WinRARFolders
Set-TelegramFolders
Set-KotatogramFolders
Set-AuygramFolders
Set-MaterialgramFolders
Add-ExtrasPackages
Remove-WindowsDefender
