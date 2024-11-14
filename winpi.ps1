$AppsDir = "$env:USERPROFILE\Downloads\Apps"
$presets = "$env:HOMEDRIVE\ShanaEncoder\presets"
$shanaSettings = "$env:HOMEDRIVE\ShanaEncoder\settings" 
$Laragon = "$env:HOMEDRIVE\laragon\bin"
$Postgres = "$env:HOMEDRIVE\Postgres"
$LogFile = "$AppsDir\winpi\winpi.log"
$settings = "$AppsDir\Settings.reg"
$idm = "$AppsDir\IDM.reg"
$sysinternals = "$AppsDir\Sysinternals.reg"
$revoLic = "$AppsDir\revouninstallerpro5.lic"
$qbitTorrentConf = "$AppsDir\qt.conf"
$defaultPath = "D:\VS2022"
$vsExePath = "$defaultPath\vs_Enterprise.exe"
$layoutPath = "$defaultPath\VSLayouts"
$configFilePath = "$defaultPath\config.vsconfig"
$certFolder = "$layoutPath\certificates"
$certmgr = "C:\Windows\System32\certutil.exe"
$cert1 = "$certFolder\manifestCounterSignRootCertificate.cer"
$cert2 = "$certFolder\vs_installer_opc.RootCertificate.cer"
$cert3 = "$certFolder\manifestRootCertificate.cer"


if (-not(Test-Path -Path $AppsDir)) {
    New-item -ItemType Directory $AppsDir
}

Start-BitsTransfer -Source "https://github.com/Dreamless2/Updates/blob/main/Nekta.psm1" -Destination $AppsDir

if (Test-Path -Path "$AppsDir\Nekta.psm1") {
    Import-Module Nekta.psm1
}

if (-not(Test-Path -Path $settings)) {
    Start-BitsTransfer -Source "https://github.com/Dreamless2/Updates/releases/download/youpdates/Settings.reg" -Destination $AppsDir
}

if (-not(Test-Path -Path $idm)) {
    Start-BitsTransfer -Source "https://github.com/Dreamless2/Updates/releases/download/youpdates/IDM.reg" -Destination $AppsDir
}

if (-not(Test-Path -Path $sysinternals)) {
    Start-BitsTransfer -Source "https://github.com/Dreamless2/Updates/releases/download/youpdates/Sysinternals.reg" -Destination $AppsDir
}

if (-not(Test-Path -Path $revoLic)) {
    Start-BitsTransfer -Source "https://github.com/Dreamless2/Updates/releases/download/youpdates/revouninstallerpro5.lic" -Destination $AppsDir
}

#==========================================================================

# Início
#==========================================================================

$shanaUrl = "https://github.com/Dreamless2/Updates/releases/download/youpdates/ShanaEncoder6.0.1.7.exe"
$inviskaUrl = "https://github.com/Dreamless2/Updates/releases/download/youpdates/Inviska_MKV_Extract_11.0_x86-64_Setup.exe"
$qBitTorrentUrl = "https://sinalbr.dl.sourceforge.net/project/qbittorrent/qbittorrent-win32/qbittorrent-5.0.1/qbittorrent_5.0.1_qt6_lt20_x64_setup.exe"
$defenderUrl = "https://github.com/ionuttbara/windows-defender-remover/releases/download/release_def_12_8/DefenderRemover.exe"    
$apacheUrl = "https://github.com/Dreamless2/Updates/releases/download/youpdates/httpd-2.4.62-240904-win64-VS17.zip"
$delphiURL = "https://altd.embarcadero.com/download/radstudio/12.0/RADstudio_12_2_i_0329_C2CC.iso"    
$w11sdkUrl = "https://download.microsoft.com/download/e/b/3/eb320eb1-b21e-4e6e-899e-d6aec552ecb0/KIT_BUNDLE_WINDOWSSDK_MEDIACREATION/winsdksetup.exe"
$keypatchUrl = "https://github.com/Dreamless2/Updates/releases/download/youpdates/KeyPatch_new.exe"
$codec32Url = "https://github.com/Dreamless2/Updates/releases/download/youpdates/CodecLibrary.v1.2.x86.7z"
$codec64Url = "https://github.com/Dreamless2/Updates/releases/download/youpdates/CodecLibrary.v1.2.x64.7z"
$rarregUrl = "https://github.com/Dreamless2/Updates/releases/download/youpdates/rarreg.key"    
$postgresUrl = "https://github.com/Dreamless2/Updates/releases/download/youpdates/Server.zip"
$winfindrUrl = "https://winfindr.com/WinFindr_Setup.exe"

$shana = [System.IO.Path]::GetFileName($shanaUrl)        
$inviska = [System.IO.Path]::GetFileName($inviskaUrl)
$qBitTorrentName = "qbittorrent_5.0.1_qt6_lt20_x64_setup.exe"
$defenderName = [System.IO.Path]::GetFileName($defenderUrl)
$apacheName = [System.IO.Path]::GetFileName($apacheUrl)
$delphiName = [System.IO.Path]::GetFileName($delphiURL)
$w11sdkName = [System.IO.Path]::GetFileName($w11sdkUrl)
$keypatchName = [System.IO.Path]::GetFileName($keypatchUrl)
$postgresName = [System.IO.Path]::GetFileName($postgresUrl)
$winfindrName = [System.IO.Path]::GetFileName($winfindrUrl)
$rarregName = [System.IO.Path]::GetFileName($rarregUrl)

$defenderPath = Join-Path $AppsDir $defenderName
$shanaPath = Join-Path $AppsDir $shana      
$inviskaPath = Join-Path $AppsDir $inviska
$qBitTorrentPath = Join-Path $AppsDir $qBitTorrentName
$apachePath = Join-Path $AppsDir $apacheName
$delphiISOPath = Join-Path $AppsDir $delphiName   
$w11sdkPath = Join-Path $AppsDir $w11sdkName    
$keypatchPath = Join-Path $AppsDir $keypatchName
$postgresPath = Join-Path $AppsDir $postgresName
$winfindrPath = Join-Path $AppsDir $winfindrName
$rarregPath = Join-Path $AppsDir $rarregName

#==========================================================================

# Pacotes winget
#==========================================================================

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
    "GeorgieLabs.SoundWireServer",
    "CrystalRich.LockHunter",
    "Google.Chrome",
    "Maxthon.Maxthon",
    "Opera.Opera",
    "VideoLAN.VLC",  
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
    "Git.Git",
    "GitHub.cli",       
    "MoritzBunkus.MKVToolNix", 
    "LeNgocKhoa.Laragon",
    "CodeSector.TeraCopy",
    "CodeSector.DirectFolders",
    "UnifiedIntents.UnifiedRemote",
    "Gyan.FFmpeg",
    "QL-Win.QuickLook",
    "MediaArea.MediaInfo.GUI",
    "ArduinoSA.IDE.stable",       
    "OpenJS.NodeJS.LTS",
    "Microsoft.DotNet.SDK.5",
    "Microsoft.DotNet.SDK.6",
    "Microsoft.DotNet.SDK.7",
    "Microsoft.DotNet.SDK.8",
    "Flameshot.Flameshot",
    "Glarysoft.GlaryUtilities",
    "EclipseAdoptium.Temurin.21.JDK"
)

function Set-Wallpaper {
    $wallpaperUrl = "https://images.pexels.com/photos/355465/pexels-photo-355465.jpeg"    
    $wallpaperFileName = [System.IO.Path]::GetFileName($wallpaperUrl)
    $wallpaperPath = Join-Path $AppsDir $wallpaperFileName
    Nekta_Logging INFO "Applying new wallpaper" $LogFile
    Nekta_NovaDownloader -U $wallpaperUrl -D $wallpaperPath
    Nekta_SetRegKeyValue -K "hkcu:\Control Panel\Desktop" -V "JPEGImportQuality" -KV "100" -T "DWORD"
    Invoke-Expression -Command 'rundll32.exe user32.dll, UpdatePerUserSystemParameters 1, True'
    Nekta_Logging INFO "Customizations applied. Restarting Windows Explorer for apply new settings" $LogFile           
    Nekta_StartStopProcess -P "explorer" -A "Stop"
    Nekta_StartStopProcess -P "explorer" -A "Start"
    Nekta_Logging SUCCESS "Done." $LogFile
}

function Set-ConfigSystem {    
    Nekta_Logging INFO "Configuring computer settings" $LogFile    
    Disable-ComputerRestore "C:\"    
    Disable-WindowsOptionalFeature -Online -FeatureName MicrosoftWindowsPowerShellV2
    DISM /Online /Remove-Capability /CapabilityName:Microsoft.Windows.PowerShell.ISE~~~~0.0.1.0
    # Check if PowerShell 2.0 is disabled 
    $feature = Get-WindowsOptionalFeature -Online -FeatureName MicrosoftWindowsPowerShellV2
    if ($feature.State -eq "Disabled") {
        Nekta_Logging INFO "PowerShell 2.0 has been disabled." $LogFile
    }
    else {
        Nekta_Logging ERROR "Failed to disable PowerShell 2.0." $LogFile
    }
 
    Set-ExecutionPolicy -ExecutionPolicy RemoteSigned
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
function Set-DarkMode {
    Nekta_Logging INFO "Trying to activate active dark mode" $LogFile
    Nekta_SetRegKeyValue -K "hkcu:\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize" -V "AppsUseLightTheme" -KV "0" -T "DWORD"
    Nekta_SetRegKeyValue -K "hkcu:\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize" -V "SystemUsesLightTheme" -KV "0" -T "DWORD"
    Nekta_Logging SUCCESS "Dark Mode activated." $LogFile
}

#==========================================================================

# Pacotes
#==========================================================================

function Install-WingetPackages {
    Nekta_Logging INFO "Install packages using winget" $LogFile

    $count = 0

    foreach ($pkg in $PKGS) {
        $installed = Invoke-Expression -Command "winget list $pkg --accept-source-agreements"
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
    Nekta_RunProcess -F $defenderPath
}

#==========================================================================

# Configuração Extras 
#==========================================================================

function Add-ExtrasPackages {  
    if (Test-Path -Path "$env:ProgramFiles\VS Revo Group\Revo Uninstaller Pro\RevoUninPro.exe") {
        Nekta_Logging INFO "Activating Revo Uninstaller Pro" $LogFile        
        Nekta_CopyArchive -F "$AppsDir\revouninstallerpro5.lic" -D "$env:ProgramData\VS Revo Group\Revo Uninstaller Pro"        
        Nekta_Logging SUCCESS "Revo Uninstaller Pro activated successfully." $LogFile
    }

    if (Test-Path -Path "${env:ProgramFiles(x86)}\Internet Download Manager\IDMan.exe") {
        Nekta_Logging INFO "Ativando IDM." $LogFile
        Nekta_StopService -S "idm*" 
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

    if (Test-Path -Path "$env:LOCALAPPDATA\Microsoft\WindowsApps\streams.exe") {
        Nekta_Logging INFO "Configuring Sysinternals." $LogFile   
        Nekta_ImportRegFile -F $sysinternals
        Nekta_Logging INFO "Sysinternals successfully configured." $LogFile           
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
    Nekta_Logging SUCCESS "Done." $LogFile
}
function Install-Office365 {
    $officeToolUrl = "https://github.com/YerongAI/Office-Tool/releases/download/v10.17.9.0/Office_Tool_with_runtime_v10.17.9.0_x64.zip"   
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
    Nekta_Logging INFO "Starting installation of qBitTorrent." $LogFile
    if (-not(Test-Path -Path "$env:ProgramFiles\qBittorrent\qbittorrent.exe")) {      
        Nekta_NovaDownloader -U $qBitTorrentUrl -D $AppsDir        
        Nekta_SetupInstall -F $qBitTorrentPath -A "/S"
        Nekta_Logging SUCCESS "qBitTorrent successfully installed."                   
    }
    
    if (Test-Path -Path "$env:ProgramFiles\qBittorrent\qbittorrent.exe") {    
        Nekta_Logging INFO "Starting configuration do qBitTorrent." $LogFile
        Nekta_NovaDownloader -U "https://github.com/Dreamless2/Updates/releases/download/youpdates/qt.conf" -D $AppsDir
        Nekta_CopyArchive -F "$qbitTorrentConf" -D "$env:ProgramFiles\qBittorrent"          
        Nekta_Logging SUCCESS "Done." $LogFile
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
    if (-not(Test-Path -Path "C:\ShanaEncoder")) {        
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
        Nekta_NewDirectory -D $shanaSettings           
        Nekta_CopyArchive -F "$AppsDir\MP4 HD Dub.xml" -D "$presets\MP4"
        Nekta_CopyArchive -F "$AppsDir\MP4 HD Leg.xml" -D "$presets\MP4"
        Nekta_CopyArchive -F "$AppsDir\MP4 SD Dub.xml" -D "$presets\MP4"
        Nekta_CopyArchive -F "$AppsDir\MP4 SD Leg.xml" -D "$presets\MP4"
        Nekta_CopyArchive -F "$AppsDir\Stream Copy to MP4.xml" -D "$presets\(Copy)"      
        Nekta_CopyArchive -F "$AppsDir\shanaapp.xml" -D "$settings\shanaapp.xml"
        Nekta_Logging SUCCESS "ShanaEncoder successfully configured." $LogFile
    }
}
function Install-W11SDK {
    Nekta_Logging INFO "Installing Windows 11 SDK" $LogFile
    Nekta_NovaDownloader -U $w11sdkUrl -D $AppsDir
    Nekta_SetupInstall -F $w11sdkPath -A "/features OptionId.DesktopCPPx64 /quiet /norestart"
    Nekta_Logging SUCCESS "Windows 11 SDK successfully installed." $LogFile
}
function Install-Delphi12 {         
    Nekta_Logging INFO "Downloading Patch" $LogFile
    Nekta_NovaDownloader -U $keypatchUrl -D $AppsDir
    Start-Process -FilePath $keypatchPath             
    Nekta_Logging INFO "Installing Delphi 12.2" $LogFile
    Start-BitsTransfer -Source $delphiURL -Destination $AppsDir      
    if (Test-Path -Path $delphiISOPath) {        
        Nekta_ISOSetupInstall -I $delphiISOPath -N "radstudio_12_esd_120329a.exe"       
    }

    if (Test-Path -Path "${env:ProgramFiles(x86)}\Embarcadero\Studio\23.0\bin") {
        Nekta_Logging WARNING "Delphi is already installed." $LogFile
    }
}

function Install-Postgres {
    $ServiceName = "postgres"
    $PG_SUPERUSER = "postgres"
    $PG_SERVERHOME = "$Postgres\Server"    
    $PG_DATAHOME = "$Postgres\Data"
    $PG_AUTHMETHOD = "scram-sha-256"
    $PG_PASSWORD = "KY55x#W7Tql3"
    $PG_LOCALE = "pt_BR.UTF-8"
    $PG_LOCALE_PROVIDER = "icu"
    $PG_ICU_LOCALE = "pt-BR"       

    Nekta_NovaDownloader -U $postgresUrl -D $AppsDir
    Nekta_UnzipArchive -F $postgresPath -D $Postgres -P 

    if (Test-Path -Path "$Postgres\Server\bin\initdb.exe") {   
        Nekta_Logging INFO "Postgresql is already installed: [$Postgres]." $LogFile        
    }
    else {
        Nekta_NewDirectory -D $Postgres
    }

    Nekta_Logging INFO "Starting new Postgres cluster using initdb" $LogFile   

    Nekta_AddStream -F temp_pgsql.pw -C $PG_PASSWORD

    try {
        & "$PG_SERVERHOME\bin\initdb.exe" -A "$PG_AUTHMETHOD" -D "$PG_DATAHOME" -E UTF8 -U "$PG_SUPERUSER" --locale-provider="$PG_LOCALE_PROVIDER" --icu-locale="$PG_ICU_LOCALE" --locale="$PG_LOCALE" --lc-collate="$PG_LOCALE" --lc-ctype="$PG_LOCALE" --lc-messages="$PG_LOCALE" --lc-monetary="$PG_LOCALE" --lc-numeric="$PG_LOCALE" --lc-time="$PG_LOCALE" --pwfile=temp_pgsql.pw --no-instructions    
    }
    finally {
        Nekta_DeleteFile -File temp_pgsql.pw 
    }

    Nekta_Logging INFO "Adding new service: '$ServiceName'." $LogFile

    & "$PG_SERVERHOME\bin\pg_ctl.exe" register -N "$ServiceName" -U LocalSystem -D "$PG_DATAHOME"

    Nekta_ModifyStartupService -S $ServiceName -StartupType "Automatic"
    Nekta_StartingService -S $ServiceName
    $serviceState = (Get-Service -Name $ServiceName).Status
    
    if ($serviceState -ne "Running") {
        Throw "Failed to start service $ServiceName."
    }
    Nekta_Logging SUCCESS "PostgreSQL successfully installed!" $LogFile
}

#==========================================================================

# Extras
#==========================================================================
function Set-BitTorrentFolders {
    $bitTorrent = "D:\BitTorrent"
    $folders = @(, 'Compressed', 'Documents', 'ISO', 'Logs', 'Music', 'Programs', 'Temp', 'Torrents', 'Video')  

    if (-not(Test-Path -Path $bitTorrent)) {
        Nekta_NewDirectory -D $bitTorrent
        foreach ($folder in $folders) {
            Nekta_NewDirectory -D $bitTorrent\$folder
        }
    }
    else {
        Nekta_Logging WARNING "Folder already exists." $LogFile
    }
}
function Set-IDMFolders {
    $idmDir = "D:\IDM"
    $folders = @(, 'Compressed', 'Documents', 'Music', 'Programs', 'Temp', 'Video', 'APK', 'ISO', 'General')  

    if (-not(Test-Path -Path $idmDir)) {
        Nekta_NewDirectory -D $idmDir
        foreach ($folder in $folders) {            
            Nekta_NewDirectory -D "$idmDir\$folder"
        }
    }
    else {
        Nekta_Logging WARNING "Folder already exists." $LogFile
    }
}
function Set-WinRARFolders {
    $rarDir = "D:\RAR"
    $folders = @(, 'Extracted', 'Output', 'Temp')  

    if (-not(Test-Path -Path $rarDir)) {
        Nekta_NewDirectory -D $rarDir 
        foreach ($folder in $folders) {
            Nekta_NewDirectory -D "$rarDir\$folder"
        }
    }
    else {
        Nekta_Logging WARNING "Folder already exists." $LogFile
    }
}
function Set-KotatogramFolders {
    $kotatogramDir = "D:\Kotatogram Desktop"

    if (-not(Test-Path -Path $kotatogramDir)) {
        Nekta_NewDirectory -D $kotatogramDir   
    }
    else {
        Nekta_Logging WARNING "Folder already exists." $LogFile
    }
}   

function Set-TelegramFolders {
    $telegramDir = "D:\Telegram Desktop"
    
    if (-not(Test-Path -Path $telegramDir)) {
        Nekta_NewDirectory -D $telegramDir
    }
    else {
        Nekta_Logging WARNING "Folder already exists." $LogFile
    }
}
function Get-NotepadPlusPlus {
    $apiUrl = "https://api.github.com/repos/notepad-plus-plus/notepad-plus-plus/releases/latest"
    $outputFile = "$AppsDir\NotepadPlusPlus.zip"

    try {
        $webClient = New-Object System.Net.WebClient
        $webClient.Headers.Add("User-Agent", "PowerShell")    
        $releaseData = Invoke-RestMethod -Uri $apiUrl -Headers @{ "User-Agent" = "PowerShell" }    
        $latestVersion = $releaseData.tag_name
        $downloadUrl = "https://github.com/notepad-plus-plus/notepad-plus-plus/releases/download/$latestVersion/npp.$($latestVersion.TrimStart('v')).portable.x64.zip"    
        Nekta_Logging INFO "Downloading Notepad++ version $latestVersion." $LogFile
        Nekta_NovaDownloader -U $downloadUrl -D $outputFile
        #$webClient.DownloadFile($downloadUrl, $outputFile)
        Nekta_Logging INFO "Download completed: $outputFile" $LogFile
    }
    catch {
        Nekta_Logging ERROR "An error occurred when trying to check or download the latest version of Notepad++." $LogFile
        Nekta_Logging ERROR $_.Exception.Message $LogFile
    }
}

function Get-PHP {
    $url = "https://windows.php.net/downloads/releases/"
    function Get-LatestPHPVersion {
        $pageContent = Invoke-WebRequest -Uri $url
        $versionLinks = $pageContent.Links | Where-Object { $_.href -match 'php-(\d+\.\d+\.\d+)-Win32-vs16-x64.zip' }
        $latestVersionLink = $versionLinks | Sort-Object {
            $_.href -match 'php-(\d+\.\d+\.\d+)'
            [version]$matches[1]
        } -Descending | Select-Object -First 1

        $latestVersionLink = $latestVersionLink.href -replace '^/downloads/releases/', ''
        return $latestVersionLink
    }

    $latestPHP = Get-LatestPHPVersion
    if ($latestPHP) {
        $downloadLink = "$url$latestPHP"
        $outputPath = "$AppsDir\$($latestPHP -split '/' | Select-Object -Last 1)"
        Nekta_Logging INFO "Downloading PHP from: $downloadLink." $LogFile
        Nekta_NovaDownloader -U $downloadLink -D $AppsDir
        Nekta_Logging SUCCESS "Download completed: $outputPath." $LogFile
    }
    else {
        Nekta_Logging ERROR "An error occurred when trying to check or download the latest version of PHP." $LogFile
    }
}

function Get-Nginx {
    $downloadPageUrl = "https://nginx.org/en/download.html"
    $nginxZipFile = "$AppsDir\nginx.zip"

    try {
        $webClient = New-Object System.Net.WebClient
        $webClient.Headers.Add("User-Agent", "PowerShell")
        $pageContent = $webClient.DownloadString($downloadPageUrl)

        $zipUrlMatch = [regex]::Match($pageContent, 'href=\"(/download/nginx-[\d\.]+\.zip)\"')

        if ($zipUrlMatch.Success) {
            $nginxZipUrl = "https://nginx.org" + $zipUrlMatch.Groups[1].Value
            Nekta_Logging INFO "Downloading Nginx from: $nginxZipUrl" $LogFile
            Nekta_NovaDownloader -U $nginxZipUrl -D $AppsDir
            Nekta_Logging SUCCESS "Download completed: $nginxZipFile" $LogFile
        }
        else {
            Nekta_Logging ERROR "Zipped version of nginx not found." $LogFile
        }
    }
    catch {
        Nekta_Logging ERROR "An error occurred when trying to check or download the latest version of nginx." $LogFile
        Nekta_Logging ERROR $_.Exception.Message $LogFile
    }
}

function Install-Apache {
    if (-not(Test-Path -Path $apachePath)) {      
        Nekta_NovaDownloader -U $apacheUrl -D $AppsDir 
    }

    if (Test-Path -Path $apachePath) {      
        Nekta_UnzipArchive -F $apachePath -D "$Laragon\apache" -P
        Nekta_DeleteFile -F "$Laragon\apache\-- Win64 VS17  --"        
        Nekta_DeleteFile -F "$Laragon\apache\ReadMe.txt"
        Nekta_DeleteFile -F "$Laragon\apache\Apache24\README*"
        Nekta_DeleteFile -F "$Laragon\apache\Apache24\ABOUT*"
        Nekta_DeleteFile -F "$Laragon\apache\Apache24\CHANGES*"
        Nekta_DeleteFile -F "$Laragon\apache\Apache24\INSTALL*"
        Nekta_DeleteFile -F "$Laragon\apache\Apache24\NOTICE*"        
    }    
}

function Install-NotepadPlusPlus {
    $notepadPlusPlusZipFile = Get-ChildItem -Path $AppsDir -Filter "notepad*.zip" -Recurse -ErrorAction SilentlyContinue
    $ExtractDir = "$Laragon\notepad++"

    if ($notepadPlusPlusZipFile -and $notepadPlusPlusZipFile.FullName -is [string]) {
        Nekta_Logging INFO "File found: $($notepadPlusPlusZipFile.Name). Unzipping to $ExtractDir" $LogFile
        Nekta_Logging INFO $notepadPlusPlusZipFile.Name $LogFile
        Nekta_UnzipArchive -F $notepadPlusPlusZipFile.FullName -D $ExtractDir -P
    }
    else {
        Nekta_Logging INFO "File not found. Downloading new version." $LogFile
        Get-NotepadPlusPlus
    }
}

function Install-Nginx {
    $nginxZipFile = Get-ChildItem -Path $AppsDir -Filter "nginx*.zip" -Recurse -ErrorAction SilentlyContinue
    $ExtractDir = "$Laragon\nginx"

    if ($nginxZipFile -and $nginxZipFile.FullName -is [string]) {
        Nekta_Logging INFO "File found: $($nginxZipFile.Name). Unzipping to $ExtractDir" $LogFile
        Nekta_Logging INFO $nginxZipFile.Name $LogFile
        Nekta_UnzipArchive -F $nginxZipFile.FullName -D $ExtractDir -P
    }
    else {
        Nekta_Logging INFO "File not found. Downloading new version." $LogFile
        Get-Nginx
    }
}

function Install-PHP {
    $phpZipFile = Get-ChildItem -Path $AppsDir -Filter "php*.zip" -Recurse -ErrorAction SilentlyContinue
    $ExtractDir = "$Laragon\php\php8"

    if ($phpZipFile -and $phpZipFile.FullName -is [string]) {
        Nekta_Logging INFO "File found: $($phpZipFile.Name). Unzipping to $ExtractDir" $LogFile
        Nekta_Logging INFO $phpZipFile.Name $LogFile
        Nekta_UnzipArchive -F $phpZipFile.FullName -D $ExtractDir -P        
    }
    else {
        Nekta_Logging INFO "File not found. Downloading new version." $LogFile
        Get-PHP    
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
function Install-WinFindr {    
    Nekta_Logging INFO "Installing WinFindr." $LogFile
    if (Test-Path -Path $winfindrPath) {        
        Nekta_SetupInstall -F $winfindrPath 
    }
    elseif (-not(Test-Path -Path "${env:ProgramFiles(x86)}\WinFindr\WinFindr.exe")) {
        Nekta_NovaDownloader -U $winfindrUrl -D $winfindrPath
    }
    else {
        Nekta_Logging ERROR "WinFindr is already installed." $LogFile
    }  
}

function Set-LaragonConfiguration {    
    Nekta_Logging INFO "Starting Laragon configuration" $LogFile
    Nekta_PurgeFiles -D "$Laragon\php"
    Nekta_PurgeFiles -D "$Laragon\apache"
    Nekta_PurgeFiles -D "$Laragon\git"
    Nekta_PurgeFiles -D "$Laragon\heidisql"
    Nekta_PurgeFiles -D "$Laragon\mysql"
    Nekta_PurgeFiles -D "$Laragon\nodejs"
    Nekta_PurgeFiles -D "$Laragon\notepad++"
    Nekta_PurgeFiles -D "$Laragon\nginx"
    Nekta_PurgeFiles -D "$Laragon\python"
    Nekta_NewDirectory -D "$Laragon\php\php8"
    Nekta_WipeDirectory -D "$Laragon\git"
    Nekta_WipeDirectory -D "$Laragon\heidisql"
    Nekta_WipeDirectory -D "$Laragon\mysql"
    Nekta_WipeDirectory -D "$Laragon\nodejs"
    Nekta_WipeDirectory -D "$Laragon\python" 
    Install-Apache
    Install-PHP
    Install-NotepadPlusPlus   
    Install-Nginx
    Nekta_Logging INFO "Done." $LogFile
}

function Install-VS2022 {
    if (-not(Test-Path -Path $defaultPath)) {
        Nekta_NewDirectory -D $defaultPath
        Nekta_NovaDownloader -U "https://github.com/Dreamless2/Updates/releases/download/youpdates/vs_Enterprise.exe" -D $defaultPath
        Nekta_NovaDownloader -U "https://github.com/Dreamless2/Updates/releases/download/youpdates/config.vsconfig" -D $defaultPath
    }
    
    Nekta_Logging INFO "Starting Visual Studio 2022 Layout for local installation" $LogFile
    if (-not(Test-Path -Path $layoutPath)) {
        Nekta_RunProcess -F $vsExePath -A "--layout $layoutPath --config $configFilePath"
    }
    
    if (Test-Path -Path $certFolder) {
        Nekta_Logging INFO "Install certificates on local machine" $LogFile
        Nekta_RunProcess -F $certmgr -A "-addstore -f 'Root' $cert1"
        Nekta_RunProcess -F $certmgr -A "-addstore -f 'Root' $cert2"    
        Nekta_RunProcess -F $certmgr -A "-addstore -f 'Root' $cert3"
    }
    
    Nekta_DeleteFile -F "$layoutPath\Response.json" 
    Nekta_NovaDownloader -U "https://github.com/Dreamless2/Updates/releases/download/youpdates/Response.json" -D $layoutPath
    Nekta_RunProcess -F "$layoutPath\vs_Enterprise.exe"

    if (Test-Path -Path "C:\VS2022\Common7\IDE\Extensions\1uhdb54f.02w\Visual.Micro.Processing.Sketch.dll") {
        Nekta_DeleteFile -F "C:\VS2022\Common7\IDE\Extensions\1uhdb54f.02w\Visual.Micro.Processing.Sketch.dll"
        Nekta_NovaDownloader -U "https://github.com/Dreamless2/Updates/releases/download/youpdates/Visual.Micro.Processing.Sketch.dll" -D $AppsDir
        Nekta_CopyArchive -F "$AppsDir\Visual.Micro.Processing.Sketch.dll" -D "C:\VS2022\Common7\IDE\Extensions\1uhdb54f.02w\Visual.Micro.Processing.Sketch.dll"
    }
}

#==========================================================================

# Execução
#==========================================================================

Set-Wallpaper
Start-Sleep -Seconds 5
Set-ConfigSystem
Start-Sleep -Seconds 5
Set-PowerOptions
Start-Sleep -Seconds 5
Set-DarkMode
Start-Sleep -Seconds 5
Get-QuickLookPlugins
Start-Sleep -Seconds 5
Add-ExtrasPackages
Start-Sleep -Seconds 5
Install-VS2022
Start-Sleep -Seconds 5
Install-WingetPackages
Start-Sleep -Seconds 5
Install-Office365
Start-Sleep -Seconds 5
Install-Delphi12
Start-Sleep -Seconds 5
Install-ShanaEncoder
Start-Sleep -Seconds 5
Install-BitTorrent
Start-Sleep -Seconds 5
Install-MKVExtractor
Start-Sleep -Seconds 5
Install-Python
Start-Sleep -Seconds 5
Install-Postgres
Start-Sleep -Seconds 5
Disable-Services
Start-Sleep -Seconds 5
Set-LaragonConfiguration
Start-Sleep -Seconds 5
Set-BitTorrentFolders
Start-Sleep -Seconds 5
Set-IDMFolders
Start-Sleep -Seconds 5
Set-WinRARFolders
Start-Sleep -Seconds 5
Set-TelegramFolders
Start-Sleep -Seconds 5
Set-KotatogramFolders
Start-Sleep -Seconds 5
Remove-WindowsDefender
