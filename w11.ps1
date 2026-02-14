$AppsDir = "$(Get-Location)\Apps"
$presetsDir = "$env:HOMEDRIVE\ShanaEncoder\presets"
$shanaSettings = "$env:HOMEDRIVE\ShanaEncoder\settings" 
$LogDirFile = "$AppsDir\WPI.log"

$NektaModule = "$env:TEMP\Acme.psm1"

# Limpa arquivos antigos
Write-Host "Deleting old files..." -ForegroundColor Red
Remove-Item -Path $AppsDir -Force -Recurse
Write-Host "Creating new directory..." -ForegroundColor Green  
New-Item -ItemType Directory -Path $AppsDir
Write-Host "Directory created." -ForegroundColor Green

if (-not (Test-Path -Path $NektaModule)) {
    Invoke-WebRequest -Uri "https://raw.githubusercontent.com/Dreamless2/Updates/refs/heads/main/Acme.psm1" -OutFile $NektaModule
}

Import-Module $NektaModule -Force

#==========================================================================

# Início
#==========================================================================

# URLs
$shanaUrl = "https://github.com/Dreamless2/Updates/releases/download/youpdates/ShanaEncoder7.4.exe"
$inviskaUrl = "https://github.com/Dreamless2/Updates/releases/download/youpdates/Inviska_MKV_Extract_11.0_x86-64_Setup.exe"
$qBitTorrentUrl = "https://sinalbr.dl.sourceforge.net/project/qbittorrent/qbittorrent-win32/qbittorrent-5.1.4/qbittorrent_5.1.4_qt6_lt20_x64_setup.exe"
$defenderUrl = "https://github.com/ionuttbara/windows-defender-remover/releases/download/release_def_12_8/DefenderRemover.exe"    
$codec32Url = "https://github.com/Dreamless2/Updates/releases/download/youpdates/CodecLibrary.v1.2.x86.7z"
$codec64Url = "https://github.com/Dreamless2/Updates/releases/download/youpdates/CodecLibrary.v1.2.x64.7z"
$rarUrl = "https://github.com/Dreamless2/Updates/releases/download/youpdates/WINRAR.reg"
$idmUrl = "https://github.com/Dreamless2/Updates/releases/download/youpdates/IDM.reg"
$niniteUrl = "https://github.com/Dreamless2/Updates/releases/download/youpdates/Ninite-Wip.exe"
$chasysUrl = "https://www.jpchacha.com/chasysphoto/downloads/chasys_photo_5_38_01.exe"
$hibitUrl = "https://www.hibitsoft.ir/HiBitUninstaller/HiBitUninstaller-setup-4.0.10.exe"
$kotatogramUrl = "https://github.com/kotatogram/kotatogram-desktop/releases/download/k1.4.9/1.4.9-win64-installer.exe"
$amdDriverUrl = "https://drivers.amd.com/drivers/installer/25.30/whql/amd-software-adrenalin-edition-26.1.1-minimalsetup-260119_web.exe"
$pythonUrl = "https://www.python.org/ftp/python/3.12.10/python-3.12.10-amd64.exe"
$semeruUrl = "https://github.com/ibmruntimes/semeru25-binaries/releases/download/jdk-25.0.2%2B10_openj9-0.57.0/ibm-semeru-open-jdk_x64_windows_25.0.2_10_openj9-0.57.0.msi"
$fdkAACUrl = "https://github.com/Dreamless2/Updates/releases/download/youpdates/fdkaac.exe"
$ffmpegUrl = "https://github.com/Dreamless2/Updates/releases/download/youpdates/ffmpeg.exe"
$ffprobeUrl = "https://github.com/Dreamless2/Updates/releases/download/youpdates/ffprobe.exe"
$mp4decryptUrl = "https://github.com/Dreamless2/Updates/releases/download/youpdates/mp4decrypt.exe"
$ffplayUrl = "https://github.com/Dreamless2/Updates/releases/download/youpdates/ffplay.exe"
$edgeAnnoyancesUrl = "https://github.com/Dreamless2/Updates/releases/download/youpdates/Disable-EdgeAnnoyances.reg"
$disableSearchBoxSuggestionsUrl = "https://github.com/Dreamless2/Updates/releases/download/youpdates/DisableSearchBoxSuggestions.reg"
$disableSnippingToolUrl = "https://github.com/Dreamless2/Updates/releases/download/youpdates/DisableSnippingTool.reg"
$edgeRegUrl = "https://github.com/Dreamless2/Updates/releases/download/youpdates/Edge.reg"  
$exemptFileUrl = "https://github.com/Dreamless2/Updates/releases/download/youpdates/ExemptFile.reg"
$edgeSmartScreenUrl = "https://github.com/Dreamless2/Updates/releases/download/youpdates/Turn_OFF_Microsoft_Defender_SmartScreen_for_Microsoft_Edge.reg"

# Nome dos arquivos
$shana = [System.IO.Path]::GetFileName($shanaUrl)        
$inviska = [System.IO.Path]::GetFileName($inviskaUrl)
$qBitTorrentName = [System.IO.Path]::GetFileName($qBitTorrentUrl)
$defenderName = [System.IO.Path]::GetFileName($defenderUrl)
$rarName = [System.IO.Path]::GetFileName($rarUrl)
$idmName = [System.IO.Path]::GetFileName($idmUrl)
$niniteName = [System.IO.Path]::GetFileName($niniteUrl)
$chasysName = [System.IO.Path]::GetFileName($chasysUrl)
$hibitName = [System.IO.Path]::GetFileName($hibitUrl)
$kotatogramName = [System.IO.Path]::GetFileName($kotatogramUrl)
$amdDriverName = [System.IO.Path]::GetFileName($amdDriverUrl)
$pythonName = [System.IO.Path]::GetFileName($pythonUrl)
$semeruName = [System.IO.Path]::GetFileName($semeruUrl)
$fdkAACName = [System.IO.Path]::GetFileName($fdkAACUrl)
$ffmpegName = [System.IO.Path]::GetFileName($ffmpegUrl)
$ffprobeName = [System.IO.Path]::GetFileName($ffprobeUrl)
$ffplayName = [System.IO.Path]::GetFileName($ffplayUrl)
$mp4decryptName = [System.IO.Path]::GetFileName($mp4decryptUrl)
$edgeAnnoyancesName = [System.IO.Path]::GetFileName($edgeAnnoyancesUrl)
$disableSearchBoxSuggestionsName = [System.IO.Path]::GetFileName($disableSearchBoxSuggestionsUrl)
$disableSnippingToolName = [System.IO.Path]::GetFileName($disableSnippingToolUrl)
$edgeRegName = [System.IO.Path]::GetFileName($edgeRegUrl)
$exemptFileName = [System.IO.Path]::GetFileName($exemptFileUrl)
$edgeSmartScreenName = [System.IO.Path]::GetFileName($edgeSmartScreenUrl)

# Caminho dos arquivos
$defenderPath = Join-Path $AppsDir $defenderName
$shanaPath = Join-Path $AppsDir $shana      
$inviskaPath = Join-Path $AppsDir $inviska
$qBitTorrentPath = Join-Path $AppsDir $qBitTorrentName
$rarPath = Join-Path $AppsDir $rarName
$idmPath = Join-Path $AppsDir $idmName
$ninitePath = Join-Path $AppsDir $niniteName
$chasysPath = Join-Path $AppsDir $chasysName
$hibitPath = Join-Path $AppsDir $hibitName
$kotatogramPath = Join-Path $AppsDir $kotatogramName
$amdDriverPath = Join-Path $AppsDir $amdDriverName
$pythonPath = Join-Path $AppsDir $pythonName
$semeruPath = Join-Path $AppsDir $semeruName
$fdkAACPath = Join-Path $AppsDir $fdkAACName
$ffmpegPath = Join-Path $AppsDir $ffmpegName
$ffprobePath = Join-Path $AppsDir $ffprobeName
$ffplayPath = Join-Path $AppsDir $ffplayName
$mp4decryptPath = Join-Path $AppsDir $mp4decryptName
$edgeAnnoyancesPath = Join-Path $AppsDir $edgeAnnoyancesName
$disableSearchBoxSuggestionsPath = Join-Path $AppsDir $disableSearchBoxSuggestionsName
$disableSnippingToolPath = Join-Path $AppsDir $disableSnippingToolName
$edgeRegPath = Join-Path $AppsDir $edgeRegName
$exemptFilePath = Join-Path $AppsDir $exemptFileName
$edgeSmartScreenPath = Join-Path $AppsDir $edgeSmartScreenName

#==========================================================================

# Pacotes winget
#==========================================================================

# Lista de pacotes
$packages = @(   
    "gerardog.gsudo", 
    "Microsoft.VisualStudioCode",
    "RARLab.WinRAR",
    "Klocman.BulkCrapUninstaller",
    "DuongDieuPhap.ImageGlass",
    "SaeraSoft.CaesiumImageCompressor",
    "Pinta.Pinta",
    "RevoUninstaller.RevoUninstallerPro",
    "FxSound.FxSound",
    "Google.Chrome",
    "Mozilla.Firefox",
    "Opera.Opera", 
    "Maxthon.Maxthon",
    "Flameshot.Flameshot",
    "VideoLAN.VLC",  
    "Bitwarden.Bitwarden",   
    "Microsoft.PowerShell",
    "Microsoft.PowerToys",     
    "Telegram.TelegramDesktop",  
    "SartoxOnlyGNU.Audacium",
    "OpenJS.NodeJS.LTS",
    "Cognirush.MassImageCompressor",
    "GeorgieLabs.SoundWireServer",
    "CrystalRich.LockHunter",   
    "Git.Git",
    "RamenSoftware.Windhawk",
    "MoritzBunkus.MKVToolNix",    
    "UnifiedIntents.UnifiedRemote",
    "QL-Win.QuickLook",
    "MediaArea.MediaInfo.GUI",
    "nomacs.nomacs"
)

function Set-ConfigSystem {    
    # Configurações do sistema
    Acme_Logging I "Configuring computer settings" $LogDirFile    
    Acme_SetRegKeyValue -K "hkcu:\Control Panel\Keyboard" -V "PrintScreenKeyForSnippingEnabled" -KV "0" -T "DWORD"
    Acme_SetRegKeyValue -K "hklm:\SOFTWARE\Policies\Microsoft\OneDrive" -V "KFMBlockOptIn" -KV "1" -T "DWORD"
    Acme_SetRegKeyValue -K "hkcu:\SOFTWARE\Policies\Microsoft\TabletPC" -V "DisableSnippingTool" -KV "1" -T "DWORD"
    Acme_SetRegKeyValue -K "hklm:\SOFTWARE\Policies\Microsoft\TabletPC" -V "DisableSnippingTool" -KV "1" -T "DWORD"
    Acme_SetRegKeyValue -K "hkcu:\Software\Microsoft\Windows\CurrentVersion\Policies\Attachments" -V "SaveZoneInformation" -KV "1" -T "DWORD"
    Acme_SetRegKeyValue -K "hkcu:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -V "SilentInstalledAppsEnabled" -KV "0" -T "DWORD"
    Acme_SetRegKeyValue -K "hklm:\SYSTEM\CurrentControlSet\Control\BitLocker" -V "PreventDeviceEncryption" -KV "1" -Type DWORD
    Acme_SetRegKeyValue -K "hklm:\SYSTEM\CurrentControlSet\Control\FileSystem" -V "LongPathsEnabled" -KV "1" -T "DWORD"
    Acme_SetRegKeyValue -K "hklm:\Software\Microsoft\Visualstudio\Setup\" -V "CachePath" -KV "D:\Microsoft\VisualStudio\Packages" -T "String"  
    Acme_SetRegKeyValue -K "hklm:\Software\Microsoft\Visualstudio\Setup\" -V "SharedInstallationPath" -KV "D:\Microsoft\VisualStudio\Shared" -T "String"
    Acme_Logging S "Done." $LogDirFile
}
function Set-PowerOptions {
    # Configurações de energia
    Acme_Logging I "Settings for maximum performance" $LogDirFile
    Acme_InvokeCommand -C "powercfg /h off"
    Acme_InvokeCommand -C "powercfg /s e9a42b02-d5df-448d-aa00-03f14749eb61"
    Acme_InvokeCommand -C "powercfg /x standby-timeout-ac 0"
    Acme_InvokeCommand -C "powercfg /x disk-timeout-ac 0"
    Acme_InvokeCommand -C "powercfg /x monitor-timeout-ac 15"
    Acme_InvokeCommand -C "powercfg /SETACVALUEINDEX SCHEME_CURRENT 2a737441-1930-4402-8d77-b2bebba308a3 48e6b7a6-50f5-4782-a5d4-53bb8f07e226 0"
    Acme_InvokeCommand -C "fsutil.exe behavior set disableLastAccess 1"
    Acme_InvokeCommand -C "fsutil behavior set disable8dot3 1"
    Acme_InvokeCommand -C "netsh int tcp set global autotuninglevel=disabled"
    Acme_Logging S "Done." $LogDirFile
}

#==========================================================================

# Pacotes
#==========================================================================

function Install-WingetPackages {
    Acme_Logging I "Install packages using winget" $LogDirFile

    $count = 0

    foreach ($pkg in $packages) {
        $installed = Acme_InvokeCommand -C "winget list $pkg --accept-source-agreements --accept-package-agreements"
        if ($installed -match ([regex]::Escape($pkg))) {
            Acme_Logging WARNING " $pkg installed." $LogDirFile
        }
        else {
            Acme_Logging I "Starting the installation of $pkg" $LogDirFile
            Acme_InvokeCommand -C "winget install $pkg --accept-package-agreements --accept-source-agreements -e -h" -ErrorAction SilentlyContinue
            
            if ($?) {
                Acme_Logging I "The package $pkg was installed!" $LogDirFile
                $count++
            }
            else {
                Acme_Logging WARNING " Failed to install package $pkg." $LogDirFile              
            }
        }
    }

    Acme_Logging I "All packages installed." $LogDirFile
    Acme_Logging I "$count of $($packages.Count) packages are installed." $LogDirFile
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
        Acme_Logging I "Disabling and stopping unnecessary services" $LogDirFile
        Acme_ModifyStartupService -S $service -T "Disabled"
        Acme_StopService -S $service        
        Acme_Logging S "Service $service disabled and stopped successfully." $LogDirFile
    }
}

#==========================================================================

# Remover Windows Defender
#==========================================================================

function Remove-WindowsDefender {
    Acme_Logging I "Downloading Windows Defender Removal" $LogDirFile
    Acme_NovaDownloader -U $defenderUrl -D $AppsDir
    Acme_RunProcessNoWait -F $defenderPath
}

#==========================================================================

# Configuração Extras 
#==========================================================================

function Install-Ninite {  
    Acme_Logging I "Installing extra packages" $LogDirFile
    Acme_Logging I "Downloading Ninite Installer" $LogDirFile
    Acme_NovaDownloader -U $niniteInstallerUrl -D $AppsDir
    Acme_Logging I "Running Ninite Installer" $LogDirFile
    Acme_RunProcess -F $ninitePath
    Acme_Logging S "Ninite packages installed successfully." $LogDirFile
}  
function Install-ChasysDraw {
    Acme_Logging I "Downloading Chasys" $LogDirFile
    Acme_NovaDownloader -U $chasysUrl -D $AppsDir
    Acme_Logging I "Installing Chasys" $LogDirFile
    Acme_SetupInstall -F $chasysPath
    Acme_Logging S "Chasys installed successfully." $LogDirFile
}
function Install-HibitUninstaller {
    Acme_Logging I "Downloading Hibit" $LogDirFile
    Acme_NovaDownloader -U $hibitUrl -D $AppsDir    
    Acme_Logging I "Installing Hibit Installer" $LogDirFile
    Acme_SetupInstall -F $hibitPath
    Acme_Logging S "Hibit installed successfully." $LogDirFile
}

function Install-Kotatogram {
    Acme_Logging I "Downloading Kotatogram" $LogDirFile
    Acme_NovaDownloader -U $kotatogramUrl -D $AppsDir    
    Acme_Logging I "Installing Kotatogram" $LogDirFile   
    Acme_SetupInstall -F $kotatogramPath -A "/VERYSILENT /NORESTART"
    Acme_Logging S "Kotatogram installed successfully." $LogDirFile    
}
function Install-AMDRadeonSoftware {
    Acme_Logging I "Downloading AMD Radeon Software" $LogDirFile
    Acme_NovaDownloader -U $amdDriverUrl -D $AppsDir
    Acme_Logging I "Installing AMD Radeon Software" $LogDirFile
    Acme_SetupInstall -F $amdDriverPath
    Acme_Logging S "AMD Radeon Software installed successfully." $LogDirFile
}
function Install-Python {    
    Acme_Logging I "Downloading Python" $LogDirFile
    Acme_NovaDownloader -U $pythonUrl -D $AppsDir
    Acme_Logging I "Installing Python" $LogDirFile
    Acme_SetupInstall -F $pythonPath -A "/quiet InstallAllUsers=0 Include_pip=1 Include_exe=1 Include_dev=0 PrependPath=1 Include_lib=1 Include_tcltk=1 Include_launcher=1 Include_doc=0 Include_test=0 Include_symbols=0 Include_debug=0 AssociateFiles=1"
    Acme_Logging S "Python installed successfully." $LogDirFile
}

function Install-Semeru {
    Acme_Logging I "Downloading Semeru" $LogDirFile
    Acme_NovaDownloader -U $semeruUrl -D $AppsDir
    Acme_Logging I "Installing Semeru" $LogDirFile
    Acme_MSIInstall -F $semeruPath -A "ADDLOCAL=FeatureMain,FeatureEnvironment,FeatureJarFileRunWith,FeatureJavaHome /quiet"
    Acme_Logging S "Semeru installed successfully." $LogDirFile
}  
function Update-WinRAR {
    Acme_Logging I "Activating WinRAR" $LogDirFile    
    Invoke-RestMethod "https://dub.sh/licenserar" | Invoke-Expression
    Acme_Logging S "WinRAR activated successfully." $LogDirFile
}

function Update-FFMPEG {
    Acme_Logging I "Downloading FFMPEG" $LogDirFile
    Acme_NovaDownloader -U $fdkAACUrl -D $fdkAACPath
    Acme_NovaDownloader -U $ffmpegUrl -D $ffmpegPath
    Acme_NovaDownloader -U $ffprobeUrl -D $ffprobePath
    Acme_NovaDownloader -U $ffplayUrl -D $ffplayPath
    Acme_NovaDownloader -U $mp4decryptUrl -D $mp4decryptPath
    Acme_Logging S "FFMPEG downloaded successfully." $LogDirFile    
    Acme_Logging I "Copying FFMPEG to folder" $LogDirFile
    Acme_CopyWithProgress -F $fdkAACPath -D "$env:HOMEDRIVE\ffmpeg"
    Acme_CopyWithProgress -F $ffmpegPath -D "$env:HOMEDRIVE\ffmpeg"
    Acme_CopyWithProgress -F $ffprobePath -D "$env:HOMEDRIVE\ffmpeg"
    Acme_CopyWithProgress -F $ffplayPath -D "$env:HOMEDRIVE\ffmpeg"
    Acme_CopyWithProgress -F $mp4decryptPath -D "$env:HOMEDRIVE\ffmpeg"
    Acme_Logging S "FFMPEG copied successfully." $LogDirFile        
}

function Update-Windows {
    Acme_Logging I "Updating Registry" $LogDirFile
    Acme_ImportRegFile -F $edgeAnnoyancesPath
    Acme_ImportRegFile -F $disableSearchBoxSuggestionsPatH
    Acme_ImportRegFile -F $disableSnippingToolPath
    Acme_ImportRegFile -F $edgeRegPath
    Acme_ImportRegFile -F $exemptFilePath
    Acme_ImportRegFile -F $edgeSmartScreenPath
    Acme_Logging S "Registry updated." $LogDirFile
}

#==========================================================================

# Apps Principais
#==========================================================================
function Get-QuickLookPlugins {
    Acme_Logging I "Downloading QuickLook plugins" $LogDirFile
    Acme_NovaDownloader -U "https://github.com/canheo136/QuickLook.Plugin.ApkViewer/releases/download/1.3.5/QuickLook.Plugin.ApkViewer.qlplugin" -D $AppsDir
    Acme_NovaDownloader -U "https://github.com/adyanth/QuickLook.Plugin.FolderViewer/releases/download/1.3/QuickLook.Plugin.FolderViewer.qlplugin" -D $AppsDir
    Acme_NovaDownloader -U "https://github.com/emako/QuickLook.Plugin.TorrentViewer/releases/download/v1.0.4/QuickLook.Plugin.TorrentViewer.qlplugin" -D $AppsDir  
    Acme_NovaDownloader -U "https://github.com/mooflu/QuickLook.Plugin.WebViewPlus/releases/download/1.6.4/QuickLook.Plugin.WebViewPlus.qlplugin" -D $AppsDir 
    Acme_Logging S "Done." $LogDirFile
}
function Install-Office365 {
    $officeToolUrl = "https://github.com/YerongAI/Office-Tool/releases/download/v11.0.27.0/Office_Tool_with_runtime_v11.0.27.0_x64.zip"
    $configurationUrl = "https://github.com/Dreamless2/Updates/releases/download/youpdates/Configuration.xml"
    $officeToolName = [System.IO.Path]::GetFileName($officeToolUrl)
    $officeToolPath = Join-Path $AppsDir $officeToolName    
    Acme_Logging I "Installing Office 365" $LogDirFile
    Acme_NovaDownloader -U $configurationUrl -D $AppsDir    
    Acme_NovaDownloader -U $officeToolUrl -D $AppsDir
    Acme_UnzipArchive -F $officeToolPath -D $AppsDir -P
    Acme_RunProcess -F "$AppsDir\Office Tool\Office Tool Plus.exe"
    Invoke-RestMethod https://get.activated.win | Invoke-Expression
    Acme_Logging S "Office 365 successfully installed." $LogDirFile
}
function Install-BitTorrent {
    Acme_Logging I "Starting installation of qBitTorrent..." $LogDirFile
    if (-not(Acme_CheckPath -P "$env:ProgramFiles\qBittorrent\qbittorrent.exe")) {      
        Acme_NovaDownloader -U $qBitTorrentUrl -D $AppsDir        
        Acme_SetupInstall -F $qBitTorrentPath -A "/S"
        Acme_Logging S "qBitTorrent successfully installed." $LogDirFile                  
    }
    else {
        Acme_Logging WARNING "qBitTorrent is already installed." $LogDirFile
    } 
}
function Install-MKVExtractor {
    Acme_Logging I "Starting installation of Inviska MKV Extract..." $LogDirFile    
    Acme_NovaDownloader -U $inviskaUrl -D $AppsDir                
    Acme_SetupInstall -F $inviskaPath
    Acme_Logging S "Inviska MKV Extract successfully installed." $LogDirFile                            
}

function Install-ShanaEncoder {
    Acme_Logging I "Starting installation of Shana Encoder..." $LogDirFile    
    Acme_NovaDownloader -U $codec32Url -D $AppsDir
    Acme_NovaDownloader -U $codec64Url -D $AppsDir
    Acme_NovaDownloader -U $shanaUrl -D $AppsDir    
    Acme_SetupInstall -F $shanaPath
    Acme_Logging S "ShanaEncoder successfully installed." $LogDirFile    

    Acme_Logging I "Starting configuration do Shana Encoder." $LogDirFile
      
    if (Acme_CheckPath -P "$env:HOMEDRIVE\ShanaEncoder") { 
        Acme_Logging I "Starting configuration de ShanaEncoder." $LogDirFile 
        $xml = @(
            "https://raw.githubusercontent.com/Dreamless2/Updates/main/MP4%20Animation%20FHD%20Dub%20(CPU).xml",
            "https://raw.githubusercontent.com/Dreamless2/Updates/main/MP4%20Animation%20FHD%20Leg%20(CPU).xml",
            "https://raw.githubusercontent.com/Dreamless2/Updates/main/MP4%20Animation%20HD%20Dub%20(CPU).xml",
            "https://raw.githubusercontent.com/Dreamless2/Updates/main/MP4%20Animation%20HD%20Leg%20(CPU).xml",
            "https://raw.githubusercontent.com/Dreamless2/Updates/main/MP4%20Animation%20SD%20Dub%20(CPU).xml",
            "https://raw.githubusercontent.com/Dreamless2/Updates/main/MP4%20Animation%20SD%20Leg%20(CPU).xml",
            "https://raw.githubusercontent.com/Dreamless2/Updates/main/MP4%20FHD%20Dub%20(CPU).xml",
            "https://raw.githubusercontent.com/Dreamless2/Updates/main/MP4%20FHD%20Leg%20(CPU).xml",
            "https://raw.githubusercontent.com/Dreamless2/Updates/main/MP4%20HD%20Dub%20(CPU).xml",
            "https://raw.githubusercontent.com/Dreamless2/Updates/main/MP4%20HD%20Leg%20(CPU).xml",
            "https://raw.githubusercontent.com/Dreamless2/Updates/main/MP4%20SD%20Dub%20(CPU).xml",
            "https://raw.githubusercontent.com/Dreamless2/Updates/main/MP4%20SD%20Leg%20(CPU).xml",
            "https://raw.githubusercontent.com/Dreamless2/Updates/main/MP4%20FHD%20Dub%20(GPU).xml",
            "https://raw.githubusercontent.com/Dreamless2/Updates/main/MP4%20FHD%20Leg%20(GPU).xml",
            "https://raw.githubusercontent.com/Dreamless2/Updates/main/MP4%20HD%20Dub%20(GPU).xml",
            "https://raw.githubusercontent.com/Dreamless2/Updates/main/MP4%20HD%20Leg%20(GPU).xml",
            "https://raw.githubusercontent.com/Dreamless2/Updates/main/MP4%20SD%20Dub%20(GPU).xml",
            "https://raw.githubusercontent.com/Dreamless2/Updates/main/MP4%20SD%20Leg%20(GPU).xml",
            "https://raw.githubusercontent.com/Dreamless2/Updates/main/Stream%20Copy%20to%20MP4.xml",
            "https://raw.githubusercontent.com/Dreamless2/Updates/main/Copy%20to%20MP4.xml",
            "https://raw.githubusercontent.com/Dreamless2/Updates/main/Copy%20to%20MKV.xml",                  
            "https://raw.githubusercontent.com/Dreamless2/Updates/main/shanaapp.xml",
            "https://raw.githubusercontent.com/Dreamless2/Updates/main/Instagram.xml"
        )
          
        $cleanUrls = $xml | ForEach-Object { [uri]::UnescapeDataString($_) }              
          
        foreach ($url in $cleanUrls) {   
            $fileName = [System.IO.Path]::GetFileName($url)
            $filePath = Join-Path $AppsDir $fileName
            Invoke-WebRequest -Uri $url -OutFile $filePath
            Acme_Logging I "Files saved in: $filePath." $LogDirFile
        }           
        if (Acme_CheckPath -P $presetsDir) {                 
            Acme_WipeDirectory -D $presetsDir
        }        
  
        if (Acme_CheckPath -P $shanaSettings) {    
            Acme_WipeDirectory -D $shanaSettings
        }           

        Acme_NewDirectory -D "$presetsDir\(Copy)"
        Acme_NewDirectory -D "$presetsDir\CPU"
        Acme_NewDirectory -D "$presetsDir\GPU"
        Acme_NewDirectory -D "$presetsDir\Social"
        Acme_NewDirectory -D $shanaSettings                   
        Acme_CopyArchive -F "$AppsDir\MP4 Animation FHD Dub (CPU)" -D "$presetsDir\CPU"
        Acme_CopyArchive -F "$AppsDir\MP4 Animation FHD Leg (CPU)" -D "$presetsDir\CPU"
        Acme_CopyArchive -F "$AppsDir\MP4 Animation HD Dub (CPU)" -D "$presetsDir\CPU"
        Acme_CopyArchive -F "$AppsDir\MP4 Animation HD Leg (CPU)" -D "$presetsDir\CPU"
        Acme_CopyArchive -F "$AppsDir\MP4 Animation SD Dub (CPU)" -D "$presetsDir\CPU"
        Acme_CopyArchive -F "$AppsDir\MP4 Animation SD Leg (CPU)" -D "$presetsDir\CPU"
        Acme_CopyArchive -F "$AppsDir\MP4 FHD Dub (CPU).xml" -D "$presetsDir\CPU"
        Acme_CopyArchive -F "$AppsDir\MP4 FHD Leg (CPU).xml" -D "$presetsDir\CPU"
        Acme_CopyArchive -F "$AppsDir\MP4 HD Dub (CPU).xml" -D "$presetsDir\CPU"
        Acme_CopyArchive -F "$AppsDir\MP4 HD Leg (CPU).xml" -D "$presetsDir\CPU"
        Acme_CopyArchive -F "$AppsDir\MP4 SD Dub (CPU).xml" -D "$presetsDir\CPU"
        Acme_CopyArchive -F "$AppsDir\MP4 SD Leg (CPU).xml" -D "$presetsDir\CPU"
        Acme_CopyArchive -F "$AppsDir\MP4 FHD Dub (GPU)" -D "$presetsDir\GPU"
        Acme_CopyArchive -F "$AppsDir\MP4 FHD Leg (GPU)" -D "$presetsDir\GPU"
        Acme_CopyArchive -F "$AppsDir\MP4 HD Dub (GPU)" -D "$presetsDir\GPU"
        Acme_CopyArchive -F "$AppsDir\MP4 HD Leg (GPU)" -D "$presetsDir\GPU"
        Acme_CopyArchive -F "$AppsDir\MP4 SD Dub (GPU)" -D "$presetsDir\GPU"
        Acme_CopyArchive -F "$AppsDir\MP4 SD Leg (GPU)" -D "$presetsDir\GPU"
        Acme_CopyArchive -F "$AppsDir\Stream Copy to MP4.xml" -D "$presetsDir\(Copy)"      
        Acme_CopyArchive -F "$AppsDir\Copy to MP4.xml" -D "$presetsDir\(Copy)"
        Acme_CopyArchive -F "$AppsDir\Copy to MKV.xml" -D "$presetsDir\(Copy)"        
        Acme_CopyArchive -F "$AppsDir\shanaapp.xml" -D "$shanasettings\shanaapp.xml"
        Acme_CopyArchive -F "$AppsDir\Instagram.xml" -D "$presetsDir\Social"
        Acme_Logging S "ShanaEncoder successfully configured." $LogDirFile
    }
}

#==========================================================================

# Extras
#==========================================================================
function Set-BitTorrentFolders {
    $dir = "D:\BitTorrent"
    $folders = @(, 'Compressed', 'Documents', 'ISO', 'Logs', 'Music', 'Programs', 'Temp', 'Torrents', 'Video')  

    
    Acme_NewDirectory -D $dir
    foreach ($folder in $folders) {
        Acme_NewDirectory -D $dir\$folder
    }
    
}
function Set-IDMFolders {
    $dir = "D:\IDM"
    $folders = @(, 'Compressed', 'Documents', 'Music', 'Programs', 'Temp', 'Video', 'APK', 'ISO', 'General')  

    Acme_NewDirectory -D $dir
    foreach ($folder in $folders) {            
        Acme_NewDirectory -D "$dir\$folder"
    }
    
}
function Set-WinRARFolders {
    $dir = "D:\RAR"
    $folders = @(, 'Extracted', 'Output', 'Temp')  
    
    Acme_NewDirectory -D $dir 
    
    foreach ($folder in $folders) {
        Acme_NewDirectory -D "$dir\$folder"
    }    
}
function Set-KotatogramFolders {
    $dir = "D:\Kotatogram"
    Acme_NewDirectory -D $dir   
}  
function Set-TelegramFolders {
    $dir = "D:\Telegram"    
    Acme_NewDirectory -D $dir    
}
function Set-WinrarIDM {
    Acme_Logging I "Configuring WinRAR and IDM..." $LogDirFile
    Acme_ImportRegFile -F $rarPath
    Acme_ImportRegFile -F $idmPath
    Acme_Logging S "WinRAR and IDM successfully configured." $LogDirFile
}

#==========================================================================

# Execução
#==========================================================================

Disable-Services
Set-ConfigSystem
Set-PowerOptions
Get-QuickLookPlugins
Update-Windows
Update-FFMPEG
Install-Ninite
Install-HibitUninstaller
Install-ChasysDraw
Install-Kotatogram
Install-AMDRadeonSoftware
Install-Python
Install-Semeru
Install-WingetPackages
Install-ShanaEncoder
Install-BitTorrent
Install-MKVExtractor
Install-Office365
Set-BitTorrentFolders
Set-IDMFolders
Set-WinRARFolders
Set-TelegramFolders
Set-KotatogramFolders
Update-WinRAR
Set-WinrarIDM
Remove-WindowsDefender
