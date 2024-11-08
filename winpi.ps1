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

if (-not(Test-Path -Path $AppsDir)) {
    New-item -ItemType Directory $AppsDir
}

Start-BitsTransfer -Source "https://raw.githubusercontent.com/Dreamless2/Updates/main/Nekta.psm1" -Destination $AppsDir

if (Test-Path -Path "$AppsDir\Nekta.psm1") {
    Import-Module "$AppsDir\Nekta.psm1"
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
$delphiURL = "https://altd.embarcadero.com/download/radstudio/12.0/RADStudio_12_2_i_0329_C2CC.iso"    
$w11sdkUrl = "https://download.microsoft.com/download/e/b/3/eb320eb1-b21e-4e6e-899e-d6aec552ecb0/KIT_BUNDLE_WINDOWSSDK_MEDIACREATION/winsdksetup.exe"
$keypatchUrl = "https://github.com/Dreamless2/Updates/releases/download/youpdates/KeyPatch_new.exe"
$codec32Url = "https://github.com/Dreamless2/Updates/releases/download/youpdates/CodecLibrary.v1.2.x86.7z"
$codec64Url = "https://github.com/Dreamless2/Updates/releases/download/youpdates/CodecLibrary.v1.2.x64.7z"
$rarregUrl = "https://github.com/Dreamless2/Updates/releases/download/youpdates/rarreg.key"    
$postgresUrl = "https://github.com/Dreamless2/Updates/releases/download/youpdates/Server.zip"
$winfindrUrl = "https://winfindr.com/WinFindr_Setup.exe"

$shana = Nekta_GetFilename -F $shanaUrl        
$inviska = Nekta_GetFilename -F $inviskaUrl0
$qBitTorrent = Nekta_GetFilename -F $qBitTorrentUrl
$defenderName = Nekta_GetFilename -F $defenderUrl
$apacheName = Nekta_GetFilename -F $apacheUrl
$delphiName = Nekta_GetFilename -F $delphiURL
$w11sdkName = Nekta_GetFilename -F $w11sdkUrl
$keypatchName = Nekta_GetFilename -F $keypatchUrl
$postgresName = Nekta_GetFilename -F $postgresUrl
$winfindrName = Nekta_GetFilename -F $winfindrUrl
$rarregName = Nekta_GetFilename -F $rarregUrl

$defenderPath = Join-Path $AppsDir $defenderName
$shanaPath = Join-Path $AppsDir $shana      
$inviskaPath = Join-Path $AppsDir $inviska
$qBitTorrentPath = Join-Path $AppsDir $qBitTorrent
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
    $wallpaperUrl = "https://images.pexels.com/photos/3064257/pexels-photo-3064257.jpeg"    
    $wallpaperFileName = Nekta_GetFilename -F $wallpaperUrl
    $wallpaperPath = Join-Path $env:USERPROFILE $wallpaperFileName
    Nekta_Logging INFO "Aplicando novo papel de parede..." $LogFile
    Invoke-WebRequest -Uri $wallpaperUrl -OutFile $wallpaperPath
    Nekta_SetRegKeyValue -K "hkcu:\Control Panel\Desktop" -V "JPEGImportQuality" -KV 100 -T "DWORD"
    Invoke-Expression -Command 'rundll32.exe user32.dll, UpdatePerUserSystemParameters 1, True'
    Nekta_Logging INFO "Personalizações aplicadas. O Windows Explorer será reiniciado." $LogFile       
    Nekta_StartStopProcess "explorer"
    Nekta_Logging SUCCESS "Novo papel de parede aplicado." $LogFile
}

function Set-ConfigSystem {
    Nekta_Logging INFO "Definindo configurações do computador" $LogFile    
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
    Nekta_Logging SUCCESS "Configurações Finalizadas." $LogFile
}
function Set-PowerOptions {
    Nekta_Logging INFO "Configurando para DESEMPENHO MÁXIMO" $LogFile
    Invoke-Expression -Command "powercfg /h off"
    Invoke-Expression -Command "powercfg /s e9a42b02-d5df-448d-aa00-03f14749eb61"
    Invoke-Expression -Command "powercfg /x standby-timeout-ac 0"
    Invoke-Expression -Command "powercfg /x disk-timeout-ac 0"
    Invoke-Expression -Command "powercfg /x monitor-timeout-ac 15"
    Invoke-Expression -Command "powercfg /SETACVALUEINDEX SCHEME_CURRENT 2a737441-1930-4402-8d77-b2bebba308a3 48e6b7a6-50f5-4782-a5d4-53bb8f07e226 0"
    Invoke-Expression -Command "fsutil.exe behavior set disableLastAccess 1"
    Invoke-Expression -Command "fsutil behavior set disable8dot3 1"
    Nekta_Logging SUCCESS "Configurações Finalizadas." $LogFile
}
function Set-NetworkPrivate {
    if (1, 3, 4, 5 -contains (Get-WmiObject win32_computersystem).DomainRole) { 
        return 
    }

    $networkListManager = [Activator]::CreateInstance([Type]::GetTypeFromCLSID([Guid]"{DCB00C01-570F-4A9B-8D69-199FDBA5723B}"))
    $connections = $networkListManager.GetNetworkConnections()

    $connections | ForEach-Object {
        Nekta_Logging INFO $_.GetNetwork().GetName()"category was previously set to"$_.GetNetwork().GetCategory() $LogFile
        $_.GetNetwork().SetCategory(1)
        Nekta_Logging INFO $_.GetNetwork().GetName()"changed to category"$_.GetNetwork().GetCategory() $LogFile
    }
}

function Set-DarkMode {
    Nekta_Logging INFO "Ativando Dark Mode." $LogFile
    Nekta_SetRegKeyValue -K "hkcu:\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize" -V "AppsUseLightTheme" -KV "0" -T "DWORD"
    Nekta_SetRegKeyValue -K "hkcu:\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize" -V "SystemUsesLightTheme" -KV "0" -T "DWORD"
    Nekta_Logging SUCCESS "Dark Mode ativado com sucesso." $LogFile
}

#==========================================================================

# Pacotes
#==========================================================================

function Install-WingetPackages {
    Nekta_Logging INFO "Iniciando a instalação de pacotes pelo winget." $LogFile

    $count = 0

    foreach ($pkg in $PKGS) {
        $installed = Invoke-Expression -Command "winget list $pkg --accept-source-agreements"
        if ($installed -match ([regex]::Escape($pkg))) {
            Nekta_Logging WARNING " $pkg instalado." $LogFile
        }
        else {
            Nekta_Logging INFO "Iniciando a instalação de $pkg." $LogFile
            Invoke-Expression -Command "winget install $pkg --accept-package-agreements --accept-source-agreements -h" -ErrorAction SilentlyContinue
            
            if ($?) {
                Nekta_Logging INFO "O pacote $pkg foi instalado!" $LogFile
                $count++
            }
            else {
                Nekta_Logging WARNING " Falha em instalar o pacote $pkg." $LogFile              
            }
        }
    }

    Nekta_Logging INFO "Todos os pacotes foram instalados." $LogFile
    Nekta_Logging INFO "$count de $($PKGS.Count) pacotes foi instalado." $LogFile
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
        Nekta_Logging INFO "Desabilitando e parando serviços desnecessários." $LogFile
        Nekta_ModifyStartupService -S $service -T "Disabled"
        Nekta_StopService -S $service        
        Nekta_Logging SUCCESS "Serviço $service desabilitado e parado com sucesso." $LogFile
    }
}

#==========================================================================

# Remover Windows Defender
#==========================================================================

function Remove-WindowsDefender {
    Nekta_Logging INFO "Baixando Windows Defender Removal" $LogFile
    Nekta_NovaDownloader -U $defenderUrl -D $AppsDir
    Nekta_RunProcess -F $defenderPath
}

#==========================================================================

# Configuração Extras 
#==========================================================================

function Add-ExtrasPackages {  
    if (Nekta_FindPath -P "$env:ProgramFiles\VS Revo Group\Revo Uninstaller Pro\RevoUninPro.exe") {
        Nekta_Logging INFO "Ativando Revo Uninstaller Pro." $LogFile
        Nekta_NovaDownloader -U $revoLic -D $AppsDir
        Nekta_CopyArchive -F "$AppsDir\revouninstallerpro5.lic" -D "$env:ProgramData\VS Revo Group\Revo Uninstaller Pro"        
        Nekta_Logging SUCCESS "Revo Uninstaller Pro registrado com sucesso." $LogFile
    }

    if (Nekta_FindPath -P "${env:ProgramFiles(x86)}\Internet Download Manager\IDMan.exe") {
        Nekta_Logging INFO "Ativando IDM." $LogFile
        Nekta_StopService -S "idm*" 
        Nekta_ImportRegFile -F $idm
        Nekta_Logging SUCCESS "IDM ativado com sucesso." $LogFile        
    }

    if (-not(Nekta_FindPath -P "$env:ProgramFiles\WinRAR\rarreg.key")) {
        Nekta_Logging INFO "Ativando WinRAR..." $LogFile
        Nekta_NovaDownloader -U $rarregUrl -D $AppsDir
        Nekta_CopyArchive -F $rarregPath -D "$env:ProgramFiles\WinRAR"
        Nekta_Logging SUCCESS "WinRAR ativado com sucesso." $LogFile          
    }
    else {
        Nekta_Logging INFO "Winrar já está instalado. Iniciando configuração através do regedit." $LogFile
        Nekta_ImportRegFile -F $settings
        Nekta_Logging SUCCESS "Winrar configurado com sucesso." $LogFile           
    }    

    if (Nekta_FindPath -P "$env:LOCALAPPDATA\Microsoft\WindowsApps\streams.exe") {
        Nekta_Logging INFO "Configurando Sysinternals." $LogFile   
        Nekta_ImportRegFile -F $sysinternals
        Nekta_Logging INFO "Sysinternals configurado com sucesso." $LogFile           
    }

    Nekta_Logging SUCCESS "Pacotes configurados com sucesso." $LogFile   
}

#==========================================================================

# Apps Principais
#==========================================================================
function Get-QuickLookPlugins {
    Nekta_Logging INFO "Baixando plugins do QuickLook." $LogFile
    Nekta_NovaDownloader -U "https://github.com/canheo136/QuickLook.Plugin.ApkViewer/releases/download/1.3.5/QuickLook.Plugin.ApkViewer.qlplugin" -D $AppsDir
    Nekta_NovaDownloader -U "https://github.com/adyanth/QuickLook.Plugin.FolderViewer/releases/download/1.3/QuickLook.Plugin.FolderViewer.qlplugin" -D $AppsDir
    Nekta_NovaDownloader -U "https://github.com/emako/QuickLook.Plugin.TorrentViewer/releases/download/v1.0.3/QuickLook.Plugin.TorrentViewer.qlplugin" -D $AppsDir    
    Nekta_Logging SUCCESS "Plugins doQuickLook baixados com sucesso." $LogFile
}
function Install-Office365 {
    $officeToolUrl = "https://github.com/YerongAI/Office-Tool/releases/download/v10.17.9.0/Office_Tool_with_runtime_v10.17.9.0_x64.zip"   
    $configurationUrl = "https://github.com/Dreamless2/Updates/releases/download/youpdates/Configuration.xml"
    $officeToolName = Nekta_GetFilename -F $officeToolUrl
    $officeToolPath = Join-Path $AppsDir $officeToolName    
    Nekta_Logging INFO "Instalando Office 365" $LogFile
    Nekta_NovaDownloader -U $configurationUrl -D $AppsDir    
    Nekta_NovaDownloader -U $officeToolUrl -D $AppsDir
    Nekta_UnzipArchive -F $officeToolPath -D $AppsDir -P
    Nekta_RunProcess F "$AppsDir\Office Tool\Office Tool Plus.exe"
    Invoke-RestMethod https://get.activated.win | Invoke-Expression
    Nekta_Logging SUCCESS "Office 365 instalado com sucesso." $LogFile
}
function Install-BitTorrent {
    Nekta_Logging INFO "Iniciando instalação do qBitTorrent." $LogFile
    if (-not(Nekta_FindPath -P "$env:ProgramFiles\qBittorrent\qbittorrent.exe")) {      
        Nekta_NovaDownloader -U $qBitTorrentUrl -D $AppsDir        
        Nekta_SetupInstall -F $qBitTorrentPath -A "/S"
        Nekta_Logging SUCCESS "qBitTorrent instalado com sucesso."                   
    }
    
    if (Nekta_FindPath -P "$env:ProgramFiles\qBittorrent\qbittorrent.exe") {    
        Nekta_Logging INFO "Iniciando configuração do qBitTorrent." $LogFile
        Nekta_NovaDownloader -U "https://github.com/Dreamless2/Updates/releases/download/youpdates/qt.conf" -D $AppsDir
        Nekta_CopyArchive -F "$qbitTorrentConf" -D "$env:ProgramFiles\qBittorrent"          
        Nekta_Logging WARNING " Configuração do qBitTorrent feita com sucesso." $LogFile
    }
}
function Install-MKVExtractor {
    Nekta_Logging INFO "Iniciando instalação do Inviska MKV Extract..." $LogFile
    if (-not(Nekta_FindPath -P "$env:ProgramFiles\Inviska MKV Extract\InviskaMKVExtract.exe")) {              
        Nekta_NovaDownloader -U $inviskaUrl -D $AppsDir                
        Nekta_SetupInstall -F $inviskaPath
        Nekta_Logging SUCCESS "Inviska MKV Extract instalado com sucesso." $LogFile               
    }
    else {
        Nekta_Logging WARNING " Inviska MKV Extract já está instalado." $LogFile
    }         
}
function Get-Python {
    Nekta_Logging INFO "Iniciando instalação do ptyhon." $LogFile   
    
    if (-not(Nekta_FindPath -P "$env:LOCALAPPDATA\Programs\Python\Python313\python.exe")) {                
        $pythonDownloadUrl = "https://www.python.org/downloads/"
        $response = Invoke-WebRequest -Uri $pythonDownloadUrl
        $html = $response.Content
        $regex = [regex]"\bPython (\d+\.\d+\.\d+)\b"
        $python = $regex.Matches($html)
        $latestVersion = $python | Sort-Object { [Version]$_.Groups[1].Value } -Descending | Select-Object -First 1

        if ($latestVersion) {
            $version = $latestVersion.Groups[1].Value
            Nekta_Logging INFO "A versão mais recente do Python é: $version." $LogFile
            $downloadUrl = "https://www.python.org/ftp/python/$version/python-$version-amd64.exe"
            $outputPath = "$AppsDir\python-$version-amd64.exe"
            Nekta_Logging INFO "Baixando Python $version de $downloadUrl para $outputPath." $LogFile  
            Nekta_NovaDownloader -U $downloadUrl -D $AppsDir              
            Nekta_Logging INFO "Download concluído com sucesso! Instalador salvo em $outputPath." $LogFile  
        }
        else {
            Nekta_Logging INFO "Não foi possível encontrar a versão mais recente do Python." $LogFile
        }        
    }
    else {
        Nekta_Logging SUCCESS "Python já está instalado no sistema." $LogFile
    }
}
function Install-ShanaEncoder {
    Nekta_Logging INFO "Iniciando instalação do Shana Encoder..." $LogFile
    if (-not(Nekta_FindPath -P "C:\ShanaEncoder")) {        
        Nekta_NovaDownloader -U $codec32Url -D $AppsDir
        Nekta_NovaDownloader -U $codec64Url -D $AppsDir
        Nekta_NovaDownloader -U $shanaUrl -D $AppsDir    
        Nekta_SetupInstall -F $shanaPath
        Nekta_Logging SUCCESS "ShanaEncoder instalado com sucesso." $LogFile
    }

    Nekta_Logging INFO "Iniciando configuração do Shana Encoder." $LogFile
      
    if (Nekta_FindPath -P "$env:HOMEDRIVE\ShanaEncoder") { 
        Nekta_Logging INFO "Iniciando configuração de ShanaEncoder." $LogFile 
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
            $fileName = Nekta_GetFilename -F $url
            $filePath = Join-Path $AppsDir $fileName
            Invoke-WebRequest -Uri $url -OutFile $filePath
            Nekta_Logging INFO "Arquivos salvos em: $filePath." $LogFile
        }           
        if (Nekta_FindPath -P $presets) {                 
            Nekta_WipeDirectory -D $presets
        }        
  
        if (Nekta_FindPath -P $settings) {    
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
        Nekta_Logging SUCCESS "ShanaEncoder configurado com sucesso." $LogFile
    }
}
function Install-W11SDK {
    Nekta_Logging INFO "Instalando Windows 11 SDK." $LogFile
    Nekta_NovaDownloader -U $w11sdkUrl -D $AppsDir
    Nekta_SetupInstall -F $w11sdkPath -A "/features OptionId.DesktopCPPx64 /quiet /norestart"
    Nekta_Logging SUCCESS "Windows 11 SDK instalado com sucesso." $LogFile
}
function Install-Delphi12 {         
    Nekta_Logging INFO "Baixando Key Patch." $LogFile
    Nekta_NovaDownloader -U $keypatchUrl -D $AppsDir
    Nekta_Logging INFO "Instalando Delphi 12.2." $LogFile
    Nekta_NovaDownloader -U $delphiURL -D $AppsDir      
    Nekta_RunProcessNoWait -F $keypatchPath             

    if (Nekta_FindPath -P $delphiISOPath) {        
        Nekta_ISOSetupInstall -I $delphiISOPath -N "radstudio_12_esd_120329a.exe"       
    }

    if (Nekta_FindPath -P "${env:ProgramFiles(x86)}\Embarcadero\Studio\23.0\bin") {
        Nekta_Logging WARNING "Delphi já está instalado." $LogFile
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

    Nekta_UnzipArchive -F $postgresPath -D $Postgres -P 

    if (Nekta_FindPath -Path "$Postgres\Server\bin\initdb.exe") {   
        Nekta_Logging INFO "Postgresql já está instalando na pasta: [$Postgres]." $LogFile        
    }
    else {
        Nekta_NewDirectory -D $Postgres
    }

    Nekta_Logging INFO "Iniciando novo cluster Postgres usando initdb." $LogFile   

    Nekta_AddStream -F temp_pgsql.pw -C $PG_PASSWORD

    try {
        & "$PG_SERVERHOME\bin\initdb.exe" -A "$PG_AUTHMETHOD" -D "$PG_DATAHOME" -E UTF8 -U "$PG_SUPERUSER" --locale-provider="$PG_LOCALE_PROVIDER" --icu-locale="$PG_ICU_LOCALE" --locale="$PG_LOCALE" --lc-collate="$PG_LOCALE" --lc-ctype="$PG_LOCALE" --lc-messages="$PG_LOCALE" --lc-monetary="$PG_LOCALE" --lc-numeric="$PG_LOCALE" --lc-time="$PG_LOCALE" --pwfile=temp_pgsql.pw --no-instructions    
    }
    finally {
        Nekta_DeleteFile -File temp_pgsql.pw 
    }

    Nekta_Logging INFO "Adicionando novo serviço: '$ServiceName'." $LogFile

    & "$PG_SERVERHOME\bin\pg_ctl.exe" register -N "$ServiceName" -U LocalSystem -D "$PG_DATAHOME"

    Nekta_ModifyStartupService -S $ServiceName -StartupType "Automatic"
    Nekta_StartingService -S $ServiceName
    $serviceState = (Get-Service -Name $ServiceName).Status
    
    if ($serviceState -ne "Running") {
        Throw "Falha em iniciar serviço $ServiceName."
    }
    Nekta_Logging SUCCESS "PostgreSQL instalado com sucesso!" $LogFile
}

#==========================================================================

# Extras
#==========================================================================
function Set-BitTorrentFolders {
    $bitTorrent = "D:\BitTorrent"
    $folders = @(, 'Compressed', 'Documents', 'ISO', 'Logs', 'Music', 'Programs', 'Temp', 'Torrents', 'Video')  

    if (-not(Nekta_FindPath -P $bitTorrent)) {
        Nekta_NewDirectory -D $bitTorrent
        foreach ($folder in $folders) {
            Nekta_NewDirectory -D$bitTorrent\$folder
        }
    }
    else {
        Nekta_Logging WARNING "Pastas já foram criadas." $LogFile
    }
}
function Set-IDMFolders {
    $idmDir = "D:\IDM"
    $folders = @(, 'Compressed', 'Documents', 'Music', 'Programs', 'Temp', 'Video', 'APK', 'ISO', 'General')  

    if (-not(Nekta_FindPath -P $idmDir)) {
        Nekta_NewDirectory -D $idmDir
        foreach ($folder in $folders) {            
            Nekta_NewDirectory -D "$idmDir\$folder"
        }
    }
    else {
        Nekta_Logging WARNING "Pastas já foram criadas." $LogFile
    }
}
function Set-WinRARFolders {
    $rarDir = "D:\RAR"
    $folders = @(, 'Extracted', 'Output', 'Temp')  

    if (-not(Nekta_FindPath -P $rarDir)) {
        Nekta_NewDirectory -D $rarDir 
        foreach ($folder in $folders) {
            Nekta_NewDirectory -D "$rarDir\$folder"
        }
    }
    else {
        Nekta_Logging WARNING "Pastas já foram criadas." $LogFile
    }
}
function Set-KotatogramFolders {
    $kotatogramDir = "D:\Kotatogram Desktop"

    if (-not(Nekta_FindPath -P $kotatogramDir)) {
        Nekta_NewDirectory -D $kotatogramDir   
    }
    else {
        Nekta_Logging WARNING "Pastas já foram criadas." $LogFile
    }
}   

function Set-TelegramFolders {
    $telegramDir = "D:\Telegram Desktop"
    
    if (-not(Nekta_FindPath -P $telegramDir)) {
        Nekta_NewDirectory -D $telegramDir
    }
    else {
        Nekta_Logging WARNING "Pastas já foram criadas." $LogFile
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
        Nekta_Logging INFO "Baixando Notepad++ versão $latestVersion." $LogFile
        Nekta_NovaDownloader -U $downloadUrl -D $outputFile
        #$webClient.DownloadFile($downloadUrl, $outputFile)
        Nekta_Logging INFO "Download concluído: $outputFile" $LogFile
    }
    catch {
        Nekta_Logging ERROR" Ocorreu um erro ao tentar verificar ou baixar a última versão do Notepad++." $LogFile
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
        Nekta_Logging INFO "Baixando PHP da URL: $downloadLink." $LogFile
        Nekta_NovaDownloader -U $downloadLink -D $AppsDir
        Nekta_Logging SUCCESS "Download concluído. PHP salvo em $outputPath." $LogFile
    }
    else {
        Nekta_Logging ERROR" Não foi possível encontrar a última versão do PHP." $LogFile
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
            Nekta_Logging INFO "Baixando Nginx de: $nginxZipUrl" $LogFile
            Nekta_NovaDownloader -U $nginxZipUrl -D $AppsDir
            Nekta_Logging SUCCESS "Download do Nginx concluído e salvo em: $nginxZipFile" $LogFile
        }
        else {
            Nekta_Logging ERROR" Erro: link para o arquivo zip não encontrado." $LogFile
        }
    }
    catch {
        Nekta_Logging ERROR" Ocorreu um erro ao tentar baixar o Nginx." $LogFile
        Nekta_Logging ERROR $_.Exception.Message $LogFile
    }
}

function Install-Apache {
    if (-not(Nekta_FindPath -P $apachePath)) {      
        Nekta_NovaDownloader -U $apacheUrl -D $AppsDir 
    }

    if (Nekta_FindPath -P $apachePath) {      
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
        Nekta_Logging INFO "Arquivo encontrado: $($notepadPlusPlusZipFile.Name). Descompactando para $ExtractDir" $LogFile
        Nekta_Logging INFO $notepadPlusPlusZipFile.Name $LogFile
        Nekta_UnzipArchive -F $notepadPlusPlusZipFile.FullName -D $ExtractDir -P
    }
    else {
        Nekta_Logging INFO "Arquivo não encontrado. Baixando nova versão." $LogFile
        Get-NotepadPlusPlus
    }
}

function Install-Nginx {
    $nginxZipFile = Get-ChildItem -Path $AppsDir -Filter "nginx*.zip" -Recurse -ErrorAction SilentlyContinue
    $ExtractDir = "$Laragon\nginx"

    if ($nginxZipFile -and $nginxZipFile.FullName -is [string]) {
        Nekta_Logging INFO "Arquivo encontrado: $($nginxZipFile.Name). Descompactando para $ExtractDir" $LogFile
        Nekta_Logging INFO $nginxZipFile.Name $LogFile
        Nekta_UnzipArchive -F $nginxZipFile.FullName -D $ExtractDir -P
    }
    else {
        Nekta_Logging INFO "Arquivo não encontrado. Baixando nova versão." $LogFile
        Get-Nginx
    }
}

function Install-PHP {
    $phpZipFile = Get-ChildItem -Path $AppsDir -Filter "php*.zip" -Recurse -ErrorAction SilentlyContinue
    $ExtractDir = "$Laragon\php\php8"

    if ($phpZipFile -and $phpZipFile.FullName -is [string]) {
        Nekta_Logging INFO "Arquivo encontrado: $($phpZipFile.Name). Descompactando para $ExtractDir" $LogFile
        Nekta_Logging INFO $phpZipFile.Name $LogFile
        Nekta_UnzipArchive -F $phpZipFile.FullName -D $ExtractDir -P        
    }
    else {
        Nekta_Logging INFO "Arquivo não encontrado. Baixando nova versão." $LogFile
        Get-PHP    
    }
}

function Install-Python {
    $python = Get-ChildItem -Path $AppsDir -Filter "python*.exe" -Recurse -ErrorAction SilentlyContinue

    if ($python -and $python.FullName -is [string]) {
        Nekta_Logging INFO "Arquivo encontrado: $($python.Name)." $LogFile
        Nekta_Logging INFO $python.Name $LogFile
        Nekta_SetupInstall -F $python.FullName -A "/quiet InstallAllUsers=0 Include_pip=1 Include_exe=1 Include_dev=0 PrependPath=1 Include_lib=1 Include_tcltk=1 Include_launcher=1 Include_doc=0 Include_test=0 Include_symbols=0 Include_debug=0 AssociateFiles=1"
    }
    else {
        Nekta_Logging INFO "Arquivo não encontrado. Baixando nova versão." $LogFile
        Get-Python    
    }
}
function Install-WinFindr {    
    Nekta_Logging INFO "Instalando WinFindr." $LogFile
    if (Nekta_FindPath -P $winfindrPath) {        
        Nekta_SetupInstall -F $winfindrPath 
    }
    elseif (-not(Nekta_FindPath -P "${env:ProgramFiles(x86)}\WinFindr\WinFindr.exe")) {
        Nekta_NovaDownloader -U $winfindrUrl -D $winfindrPath
    }
    else {
        Nekta_Logging ERROR" WinFindr já está instalado." $LogFile
    }  
}

function Set-LaragonConfiguration {    
    Nekta_Logging INFO "Iniciando configuração do Laragon." $LogFile
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
    Nekta_Logging INFO "Laragon configured." $LogFile
}

#==========================================================================

# Execução
#==========================================================================

Get-QuickLookPlugins
Set-DarkMode
Install-WingetPackages
Install-Office365
Install-Delphi12
Install-ShanaEncoder
Install-BitTorrent
Install-MKVExtractor
Install-Python
Install-Postgres
Disable-Services
Set-ConfigSystem
Set-PowerOptions
Set-NetworkPrivate
Set-Wallpaper
Set-BitTorrentFolders
Set-IDMFolders
Set-WinRARFolders
Set-TelegramFolders
Set-KotatogramFolders
Add-ExtrasPackages
Set-LaragonConfiguration
Remove-WindowsDefender
