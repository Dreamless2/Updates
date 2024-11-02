$AppsDir = "$env:USERPROFILE\Downloads\Apps"
$Laragon = "$env:HOMEDRIVE\laragon\bin"
$Postgres = "$env:HOMEDRIVE\Postgres"
$LogFile = "$AppsDir\WinPI\WinPI.log"
$aria2c = "$AppsDir\aria2c.exe"
$aria2conf = "$AppsDir\aria2.conf"
$settings = "$AppsDir\Settings.reg"
$idm = "$AppsDir\IDM.reg"
$sysinternals = "$AppsDir\Sysinternals.reg"
$revoLic = "$AppsDir\revouninstallerpro5.lic"
$presets = "$env:HOMEDRIVE\ShanaEncoder\presets"
$settings = "$env:HOMEDRIVE\ShanaEncoder\settings" 
$AppsDir = "$env:USERPROFILE\Downloads\Apps"

if (!(Test-Path -Path $AppsDir)) {
    New-item -ItemType Directory $AppsDir
}

Start-BitsTransfer -Source "https://raw.githubusercontent.com/Dreamless2/Updates/main/Utility.psm1" -Destination $AppsDir

if (!(Test-Path -Path $aria2c)) {
    Start-BitsTransfer -Source "https://github.com/Dreamless2/Updates/releases/download/youpdates/aria2c.exe" -Destination $AppsDir
}

if (!(Test-Path -Path $aria2conf)) {
    Start-BitsTransfer -Source "https://raw.githubusercontent.com/Dreamless2/Updates/main/aria2.conf" -Destination $AppsDir
}

if (!(Test-Path -Path $settings)) {
    Start-BitsTransfer -Source "https://github.com/Dreamless2/Updates/releases/download/youpdates/Settings.reg" -Destination $AppsDir
}

if (!(Test-Path -Path $idm)) {
    Start-BitsTransfer -Source "https://github.com/Dreamless2/Updates/releases/download/youpdates/IDM.reg" -Destination $AppsDir
}

if (!(Test-Path -Path $sysinternals)) {

    Start-BitsTransfer -Source "https://github.com/Dreamless2/Updates/releases/download/youpdates/Sysinternals.reg" -Destination $AppsDir
}

if (!(Test-Path -Path $revoLic)) {
    Start-BitsTransfer -Source "https://github.com/Dreamless2/Updates/releases/download/youpdates/revouninstallerpro5.lic" -Destination $AppsDir
}

if (Test-Path -Path "$AppsDir\Utility.psm1") {
    Import-Module "$AppsDir\Utility.psm1"
}

#==========================================================================

# Início
#==========================================================================

$shanaUrl = "https://github.com/Dreamless2/Updates/releases/download/youpdates/ShanaEncoder6.0.1.7.exe"
$inviskaUrl = "https://github.com/Dreamless2/Updates/releases/download/youpdates/Inviska_MKV_Extract_11.0_x86-64_Setup.exe"
$qBitTorrentUrl = "https://sinalbr.dl.sourceforge.net/project/qbittorrent/qbittorrent-win32/qbittorrent-5.0.1/qbittorrent_5.0.1_qt6_lt20_x64_setup.exe"
$defenderUrl = "https://github.com/ionuttbara/windows-defender-remover/releases/download/release_def_12_8/DefenderRemover.exe"    
$apacheUrl = "https://github.com/Dreamless2/Updates/releases/download/youpdates/httpd-2.4.62-240904-win64-VS17.zip"
$odbcUrl = "https://www.postgresql.org/ftp/odbc/releases/REL-17_00_0002-mimalloc/psqlodbc_x86.msi"  
$delphiURL = "https://altd.embarcadero.com/download/radstudio/12.0/RADStudio_12_2_i_0329_C2CC.iso"    
$w11sdkUrl = "https://download.microsoft.com/download/e/b/3/eb320eb1-b21e-4e6e-899e-d6aec552ecb0/KIT_BUNDLE_WINDOWSSDK_MEDIACREATION/winsdksetup.exe"
$keypatchUrl = "https://github.com/Dreamless2/Updates/releases/download/youpdates/KeyPatch_new.exe"
$codec32Url = "https://github.com/Dreamless2/Updates/releases/download/youpdates/CodecLibrary.v1.2.x86.7z"
$codec64Url = "https://github.com/Dreamless2/Updates/releases/download/youpdates/CodecLibrary.v1.2.x64.7z"
$rarregUrl = "https://github.com/Dreamless2/Updates/releases/download/youpdates/rarreg.key"    
$postgresUrl = "https://github.com/Dreamless2/Updates/releases/download/youpdates/Server.zip"
$winfindrUrl = "https://winfindr.com/WinFindr_Setup.exe"

$shana = [System.IO.Path]::GetFileName($shanaUrl)        
$inviska = [System.IO.Path]::GetFileName($inviskaUrl)
$qBitTorrent = [System.IO.Path]::GetFileName($qBitTorrentUrl)
$defenderName = [System.IO.Path]::GetFileName($defenderUrl)
$apacheName = [System.IO.Path]::GetFileName($apacheUrl)
$odbcName = [System.IO.Path]::GetFileName($odbcUrl)
$delphiName = [System.IO.Path]::GetFileName($delphiURL)
$w11sdkName = [System.IO.Path]::GetFileName($w11sdkUrl)
$keypatchName = [System.IO.Path]::GetFileName($keypatchUrl)
$postgresName = [System.IO.Path]::GetFileName($postgresUrl)
$winfindrName = [System.IO.Path]::GetFileName($winfindrUrl)

$defenderPath = Join-Path $AppsDir $defenderName
$shanaPath = Join-Path $AppsDir $shana      
$inviskaPath = Join-Path $AppsDir $inviska
$qBitTorrentPath = Join-Path $AppsDir $qBitTorrent
$apachePath = Join-Path $AppsDir $apacheName
$odbcPath = Join-Path $AppsDir $odbcName
$delphiISOPath = Join-Path $AppsDir $delphiName   
$w11sdkPath = Join-Path $AppsDir $w11sdkName    
$keypatchPath = Join-Path $AppsDir $keypatchName
$postgresPath = Join-Path $AppsDir $postgresName
$winfindrPath = Join-Path $AppsDir $winfindrName

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

#==========================================================================

# Sair do script
#==========================================================================
function Exit-Script {
    Clear-TempFiles   
    DS_WriteLog I "Restarting to apply changes..." $LogFile
    try {
        Restart-Computer -Confirm
    }
    catch {
        DS_WriteLog W "Failed to restart the system. Please restart manually." $LogFile
    }
    exit 0
}    

#==========================================================================

# Download usando web request
#==========================================================================
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
        DS_WriteLog I "Arquivo $name baixado com sucesso." $LogFile
    }
    catch {        
        DS_WriteLog E "Ocorreu um erro no download do arquivo $name. Erro: $_.Exception.Message" $LogFile
    }
}

#==========================================================================

# Download usando webclient
#==========================================================================
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
        DS_WriteLog I "Arquivo $name baixado com sucesso." $LogFile
    }
    catch {
        DS_WriteLog E "Ocorreu um erro no download do arquivo $name. Erro: $_.Exception.Message" $LogFile
    }
}

#==========================================================================

# Download usando bitstransfer assíncrono
#==========================================================================
function DownloadFileBitsTransfer {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string]$SourceUri,        
        [Parameter(Mandatory = $true)]
        [string]$DestinationPath       
    )
     
    $name = [System.IO.Path]::GetFileName($SourceUri)

    try {
        $bitsJob = Start-BitsTransfer -Source $SourceUri -Destination $DestinationPath -Asynchronous        
         
        if ($bitsJob.JobState -eq 'Error') {
            Resume-BitsTransfer -BitsJob $bitsJob
        }
         
        if ($bitsJob.JobState -eq 'Transferred') {
            Complete-BitsTransfer -BitsJob $bitsJob           
        }         

        DS_WriteLog I "Arquivo $name baixado com sucesso." $LogFile
    }
    catch {
        DS_WriteLog E "Ocorreu um erro no download do arquivo $name. Erro: $_.Exception.Message" $LogFile
    }
}

#==========================================================================

# Download usando ARIA2
#==========================================================================
function DownloadAria2 {
    param (
        [Parameter(Mandatory = $true)]
        [string]$SourceUri,
        [Parameter()]
        [string]$DestinationPath = "$env:TEMP"           
    )

    $Aria2ConfigPath = "$AppsDir\aria2.conf"
    $Aria2ExePath = "$AppsDir\aria2c.exe"    

    if (-not $SourceUri -or $SourceUri -notmatch '^(http|https|ftp)://') {
        DS_WriteLog E "Erro: URL inválido. Forneça um URL válido." $LogFile
        return
    } 

    if (!(DS_CheckPathExist -Path $Aria2ExePath)) {
        DS_WriteLog E "Erro: aria2 não encontrado em $Aria2ExePath." $LogFile
        return
    }  

    $fileName = [System.IO.Path]::GetFileName($Url)
    $aria2Command = "$Aria2ExePath --conf-path=$Aria2ConfigPath --dir=$DestinationPath --out=$fileName $Url"

    DS_WriteLog I "- Executando comando: $aria2Command." $LogFile

    try {
        $arguments = @(
            "--conf-path=`"$Aria2ConfigPath`"",
            "--dir=`"$DestinationPath`"",
            "--out=`"$fileName`"",
            "`"$SourceUri`""
        ) -join " "

        $process = DS_ExecuteProcess $Aria2ExePath -Arguments $arguments
        if ($process.ExitCode -eq 0) {
            DS_WriteLog I "- Arquivo $fileName baixado com sucesso." $LogFile
        }
        else {
            DS_WriteLog E "- Erro: Falha no download com código de saída: $($process.ExitCode)." $LogFile
        }
    }
    catch {
        DS_WriteLog E "- Erro ao executar o comando aria2: $_." $LogFile
    }
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

    DS_WriteLog I "- Montando $ISO." $LogFile
    Mount-DiskImage -ImagePath $ISO -ErrorAction Stop | Out-Null
    DS_WriteLog S "- Imagem $ISO montada com sucesso." $LogFile

    $driveLetter = (Get-DiskImage $ISO | Get-Volume).DriveLetter   

    if ($driveLetter) {
        $exeFullPath = "$($driveLetter):\$ExeName"      
       
        if (DS_CheckPathExist -Path $exeFullPath) {
            if ([string]::IsNullOrEmpty($ExeArgs)) {
                DS_ExecuteProcess -FileName $exeFullPath                
            }
            else {
                DS_ExecuteProcess -FileName $exeFullPath -Arguments $ExeArgs                
            }
        }
        else {
            DS_WriteLog E "- O arquivo '$exeFullPath' não existe." $LogFile
        }
    }
    else {
        DS_WriteLog E "- Não foi possível determinar a letra da unidade da imagem ISO." $LogFile
    }
    
    DS_WriteLog I "- Desmontando Imagem $ISO." $LogFile
    Dismount-DiskImage -ImagePath $ISO -ErrorAction Stop | Out-Null   
    DS_WriteLog S "- Imagem $ISO desmontada com sucesso." $LogFile
}
function Set-Wallpaper {
    $wallpaperUrl = "https://images.pexels.com/photos/3064257/pexels-photo-3064257.jpeg"    
    $wallpaperFileName = [System.IO.Path]::GetFileName($wallpaperUrl)
    $wallpaperPath = DS_JoinPaths -Paths $env:USERPROFILE, $wallpaperFileName
    DS_WriteLog I "- Aplicando novo papel de parede..." $LogFile
    DS_SetRegistryValue -RegKeyPath "hkcu:\Control Panel\Desktop" -RegValueName "JPEGImportQuality" -RegValue "100" -Type "DWORD"       
    DownloadFileWebRequest -SourceUri $wallpaperUrl -DestinationPath $wallpaperPath
    DS_SetRegistryValue -RegKeyPath "hkcu:\Control Panel\Desktop" -RegValueName "Wallpaper" -RegValue "$wallpaperPath" -Type "String"
    Invoke-Expression -Command 'rundll32.exe user32.dll, UpdatePerUserSystemParameters 1, True'
    DS_WriteLog I "- Personalizações aplicadas. O Windows Explorer será reiniciado." $LogFile       
    DS_StartStopProcess -ProcessName "explorer" -Action "Stop"
    DS_StartStopProcess -ProcessName "explorer" -Action "Start"
    DS_WriteLog S "- Novo papel de parede aplicado." $LogFile     
}

function Set-ConfigSystem {
    DS_WriteLog I "- Definindo configurações do computador" $LogFile
    DS_ClearPrefetchFolder
    Set-ExecutionPolicy -ExecutionPolicy RemoteSigned
    DS_SetRegistryValue -RegKeyPath "hkcu:\Control Panel\Keyboard" -RegValueName "PrintScreenKeyForSnippingEnabled" -RegValue "0" -Type "DWORD"
    DS_SetRegistryValue -RegKeyPath "hklm:\SOFTWARE\Policies\Microsoft\OneDrive" -RegValueName "KFMBlockOptIn" -RegValue "1" -Type "DWORD"
    DS_SetRegistryValue -RegKeyPath "hkcu:\SOFTWARE\Policies\Microsoft\TabletPC" -RegValueName "DisableSnippingTool" -RegValue "1" -Type "DWORD"
    DS_SetRegistryValue -RegKeyPath "hklm:\SOFTWARE\Policies\Microsoft\TabletPC" -RegValueName "DisableSnippingTool" -RegValue "1" -Type "DWORD"
    DS_SetRegistryValue -RegKeyPath "hkcu:\Software\Microsoft\Windows\CurrentVersion\Policies\Attachments" -RegValueName "SaveZoneInformation" -RegValue "1" -Type "DWORD" 
    DS_SetRegistryValue -RegKeyPath "hkcu:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -RegValueName "SilentInstalledAppsEnabled" -RegValue "0" -Type "DWORD"
    DS_SetRegistryValue -RegKeyPath "hklm:\SYSTEM\CurrentControlSet\Control\BitLocker" -RegValueName "PreventDeviceEncryption" -RegValue "1" -Type "DWORD"
    DS_SetRegistryValue -RegKeyPath "hklm:\SYSTEM\CurrentControlSet\Control\FileSystem" -RegValueName "LongPathsEnabled" -RegValue "1" -Type "DWORD"   
    DS_SetRegistryValue -RegKeyPath "hklm:\Software\Microsoft\Visualstudio\Setup\" -RegValue "CachePath" -RegValue "" -Type "String"
    DS_WriteLog S "- Configurações Finalizadas." $LogFile
}
function Set-PowerOptions {
    DS_WriteLog I "- Configuração de energia" $LogFile
    Invoke-Expression -Command "powercfg /h off"
    Invoke-Expression -Command "powercfg /s e9a42b02-d5df-448d-aa00-03f14749eb61"
    Invoke-Expression -Command "powercfg /x standby-timeout-ac 0"
    Invoke-Expression -Command "powercfg /x disk-timeout-ac 0"
    Invoke-Expression -Command "powercfg /x monitor-timeout-ac 15"
    Invoke-Expression -Command "powercfg /SETACVALUEINDEX SCHEME_CURRENT 2a737441-1930-4402-8d77-b2bebba308a3 48e6b7a6-50f5-4782-a5d4-53bb8f07e226 0"
    Invoke-Expression -Command "fsutil.exe behavior set disableLastAccess 1"
    Invoke-Expression -Command "fsutil behavior set disable8dot3 1"
    DS_WriteLog S "- Configurações Finalizadas." $LogFile
}
function Set-NetworkPrivate {
    if (1, 3, 4, 5 -contains (Get-WmiObject win32_computersystem).DomainRole) { 
        return 
    }

    $networkListManager = [Activator]::CreateInstance([Type]::GetTypeFromCLSID([Guid]"{DCB00C01-570F-4A9B-8D69-199FDBA5723B}"))
    $connections = $networkListManager.GetNetworkConnections()

    $connections | ForEach-Object {
        DS_WriteLog I $_.GetNetwork().GetName()"category was previously set to"$_.GetNetwork().GetCategory() $LogFile
        $_.GetNetwork().SetCategory(1)
        DS_WriteLog S $_.GetNetwork().GetName()"changed to category"$_.GetNetwork().GetCategory() $LogFile
    }
}

function Set-DarkMode {
    DS_WriteLog I "- Ativando Dark Mode" $LogFile
    DS_SetRegistryValue -RegKeyPath "hkcu:\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize" -RegValueName "AppsUseLightTheme" -RegValue "0" -Type "DWORD"
    DS_SetRegistryValue -RegKeyPath "hkcu:\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize" -RegValueName "SystemUsesLightTheme" -RegValue "0" -Type "DWORD"
    DS_WriteLog S "- Dark Mode ativado com sucesso." $LogFile
}

#==========================================================================

# Pacotes
#==========================================================================

function Install-WingetPackages {
    DS_WriteLog I "- Iniciando a instalação de pacotes pelo winget." $LogFile

    $count = 0

    foreach ($pkg in $PKGS) {
        $installed = Invoke-Expression -Command "winget list $pkg --accept-source-agreements"
        if ($installed -match ([regex]::Escape($pkg))) {
            DS_WriteLog W "- $pkg instalado." $LogFile
        }
        else {
            DS_WriteLog I "- Iniciando a instalação de $pkg." $LogFile		
            Invoke-Expression -Command "winget install $pkg --accept-package-agreements --accept-source-agreements -h" -ErrorAction SilentlyContinue
            
            if ($?) {
                DS_WriteLog I "- O pacote $pkg foi instalado!" $LogFile
                $count++
            }
            else {
                DS_WriteLog W "- Falha em instalar o pacote $pkg." $LogFile              
            }
        }
    }

    DS_WriteLog I "- Todos os pacotes foram instalados." $LogFile
    DS_WriteLog I "- $count de $($PKGS.Count) pacotes foi instalado." $LogFile
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
        DS_WriteLog I "- Desabilitando e parando serviços desnecessários." $LogFile
        DS_ChangeServiceStartupType -ServiceName $service -StartupType "Disabled" 
        DS_StopService -ServiceName $service
        DS_WriteLog S "- Serviço $service desabilitado e parado com sucesso." $LogFile
    }
}

#==========================================================================

# Remover Windows Defender
#==========================================================================

function Remove-WindowsDefender {
    DS_WriteLog I "- Baixando Windows Defender Removal..." $LogFile
    DownloadAria2 -SourceUri $defenderUrl -DestinationPath $AppsDir
    DS_ExecuteProcess -FileName $defenderPath
}

#==========================================================================

# Configuração Extras 
#==========================================================================

function Add-ExtrasPackages {  
    if (DS_CheckPathExist -Path "$env:ProgramFiles\VS Revo Group\Revo Uninstaller Pro\RevoUninPro.exe") {
        DS_WriteLog I "- Ativando Revo Uninstaller Pro." $LogFile
        DownloadAria2 -SourceUri $rarregUrl -DestinationPath $AppsDir
        DS_CopyFile -SourceFiles "$AppsDir\revouninstallerpro5.lic" -Destination "$env:ProgramData\VS Revo Group\Revo Uninstaller Pro"        
        DS_WriteLog S "- Revo Uninstaller Pro registrado com sucesso." $LogFile          
    }

    if (DS_CheckPathExist -Path "${env:ProgramFiles(x86)}\Internet Download Manager\IDMan.exe") {
        DS_WriteLog I "- Ativando IDM." $LogFile
        DS_StartStopProcess -ProcessName "idm*" -Action "Stop"
        DS_ImportRegistryFile -FileName "$AppsDir\IDM.reg"
        DS_WriteLog S "- IDM ativado com sucesso." $LogFile        
    }

    if (!(DS_CheckPathExist -Path "$env:ProgramFiles\WinRAR\rarreg.key")) {
        DS_WriteLog I "- Ativando WinRAR..." $LogFile
        DownloadAria2 -SourceUri $rarregUrl -DestinationPath $AppsDir
        DS_CopyFile -SourceFiles "$AppsDir\rarreg.key" -Destination "$env:ProgramFiles\WinRAR"        
        DS_WriteLog S "- WinRAR ativado com sucesso." $LogFile          
    }
    else {
        DS_WriteLog I "Winrar já está instalado. Iniciando configuração através do regedit." $LogFile 
        DS_ImportRegistryFile -FileName "$AppsDir\Settings.reg"       
        DS_WriteLog W "- Winrar configurado com sucesso." $LogFile        
    }    

    if (DS_CheckPathExist -Path "$env:LOCALAPPDATA\Microsoft\WindowsApps\streams.exe") {
        DS_WriteLog I "- Configurando Sysinternals." $LogFile
        DS_ImportRegistryFile -FileName "$AppsDir\Sysinternals.reg"
        DS_WriteLog I "- Sysinternals configurado com sucesso." $LogFile
        Read-Host -Prompt "Press any key to continue"
    }

    DS_WriteLog S "- Pacotes configurados com sucesso." $LogFile
}

#==========================================================================

# Apps Principais
#==========================================================================
function Get-QuickLookPlugins {
    DS_WriteLog I "- Baixando plugins do QuickLook." $LogFile
    DownloadAria2 -SourceUri "https://github.com/canheo136/QuickLook.Plugin.ApkViewer/releases/download/1.3.5/QuickLook.Plugin.ApkViewer.qlplugin" -DestinationPath $AppsDir
    DownloadAria2 -SourceUri "https://github.com/adyanth/QuickLook.Plugin.FolderViewer/releases/download/1.3/QuickLook.Plugin.FolderViewer.qlplugin" -DestinationPath $AppsDir
    DownloadAria2 -SourceUri "https://github.com/emako/QuickLook.Plugin.TorrentViewer/releases/download/v1.0.3/QuickLook.Plugin.TorrentViewer.qlplugin" -DestinationPath $AppsDir    
    DS_WriteLog S "- Plugins doQuickLook baixados com sucesso." $LogFile
}
function Install-Office365 {
    $officeToolUrl = "https://github.com/YerongAI/Office-Tool/releases/download/v10.17.9.0/Office_Tool_with_runtime_v10.17.9.0_x64.zip"   
    $configurationUrl = "https://github.com/Dreamless2/Updates/releases/download/youpdates/Configuration.xml"
    $officeToolName = [System.IO.Path]::GetFileName($officeToolUrl)
    $officeToolPath = Join-Path $AppsDir $officeToolName    
    DS_WriteLog I "- Instalando Office 365" $LogFile
    DownloadAria2 -SourceUri $configurationUrl -DestinationPath $AppsDir
    DownloadAria2 -SourceUri $officeToolUrl -DestinationPath $AppsDir
    DS_ExpandArchive -SourceFile $officeToolPath -DestinationPath $AppsDir -Overwrite $true   
    DS_ExecuteProcess -FileName "$AppsDir\Office Tool\Office Tool Plus.exe"
    Invoke-RestMethod https://get.activated.win | Invoke-Expression
    DS_WriteLog S "- Office 365 instalado com sucesso." $LogFile
}
function Install-BitTorrent {
    DS_WriteLog I "- Iniciando instalação do qBitTorrent." $LogFile
    if (!(DS_CheckPathExist -Path "$env:ProgramFiles\qBittorrent\qbittorrent.exe")) {      
        DownloadAria2 -SourceUri $qBitTorrentUrl -DestinationPath $AppsDir        
        DS_ExecuteProcess -FileName $qBitTorrentPath -Arguments "/S"
        DS_WriteLog S "- qBitTorrent instalado com sucesso." $LogFile                   
    }
    
    if (DS_CheckPathExist -Path "$env:ProgramFiles\qBittorrent\qbittorrent.exe") {    
        DS_WriteLog I "- Iniciando configuração do qBitTorrent." $LogFile
        DownloadAria2 -SourceUri "https://github.com/Dreamless2/Updates/releases/download/youpdates/qt.conf" -DestinationPath $AppsDir
        DS_CopyFile -SourceFiles "$AppsDir\qt.conf" -Destination "$env:ProgramFiles\qBittorrent"          
        DS_WriteLog W "- Configuração do qBitTorrent feita com sucesso." $LogFile
    }
}
function Install-MKVExtractor {
    DS_WriteLog I "- Iniciando instalação do Inviska MKV Extract..." $LogFile
    if (!(DS_CheckPathExist -Path "$env:ProgramFiles\Inviska MKV Extract\InviskaMKVExtract.exe")) {              
        DownloadAria2 -SourceUri $inviskaUrl -DestinationPath $AppsDir                
        DS_ExecuteProcess -FileName $inviskaPath
        DS_WriteLog S "- Inviska MKV Extract instalado com sucesso." $LogFile                
    }
    else {
        DS_WriteLog W "- Inviska MKV Extract já está instalado." $LogFile
    }         
}
function Get-Python {
    DS_WriteLog I "- Iniciando instalação do ptyhon." $LogFile   
    
    if (!(DS_CheckPathExist -Path "$env:LOCALAPPDATA\Programs\Python\Python313\python.exe")) {                
        $pythonDownloadUrl = "https://www.python.org/downloads/"
        $response = Invoke-WebRequest -Uri $pythonDownloadUrl
        $html = $response.Content
        $regex = [regex]"\bPython (\d+\.\d+\.\d+)\b"
        $python = $regex.Matches($html)
        $latestVersion = $python | Sort-Object { [Version]$_.Groups[1].Value } -Descending | Select-Object -First 1

        if ($latestVersion) {
            $version = $latestVersion.Groups[1].Value
            DS_WriteLog I "- A versão mais recente do Python é: $version." $LogFile  
            $downloadUrl = "https://www.python.org/ftp/python/$version/python-$version-amd64.exe"
            $outputPath = "$AppsDir\python-$version-amd64.exe"
            DS_WriteLog I "- Baixando Python $version de $downloadUrl para $outputPath." $LogFile  
            DownloadAria2 -SourceUri $downloadUrl -DestinationPath $AppsDir              
            DS_WriteLog I "- Download concluído com sucesso! Instalador salvo em $outputPath." $LogFile  
        }
        else {
            DS_WriteLog I "- Não foi possível encontrar a versão mais recente do Python." $LogFile  
        }        
    }
    else {
        DS_WriteLog S "Python já está instalado no sistema." $LogFile
    }
}
function Install-ShanaEncoder {
    DS_WriteLog I "- Iniciando instalação do Shana Encoder..." $LogFile
    if (!(DS_CheckPathExist -Path "C:\ShanaEncoder")) {        
        DownloadAria2 -SourceUri $codec32Url -DestinationPath $AppsDir
        DownloadAria2 -SourceUri $codec64Url -DestinationPath $AppsDir
        DownloadAria2 -SourceUri $shanaUrl -DestinationPath $AppsDir    
        DS_ExecuteProcess -FileName $shanaPath 
        DS_WriteLog S "- ShanaEncoder instalado com sucesso." $LogFile    
    }

    DS_WriteLog I "- Iniciando configuração do Shana Encoder." $LogFile
      
    if (DS_CheckPathExist -Path "$env:HOMEDRIVE\ShanaEncoder") { 
        DS_WriteLog I "- Iniciando configuração de ShanaEncoder." $LogFile  
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
            DownloadFileWebRequest -SourceUri $url -DestinationPath $filePath
            DS_WriteLog I "- Arquivos salvos em: $filePath." $LogFile     
        }           
        if (DS_CheckPathExist -Path $presets) {                    
            DS_DeleteDirectory -Directory $presets            
        }        
  
        if (DS_CheckPathExist -Path $settings) {            
            DS_DeleteDirectory -Directory $settings
        }           
  
        DS_CreateDirectory -Directory "$presets\(Copy)"
        DS_CreateDirectory -Directory "$presets\MP4"     
        DS_CreateDirectory -Directory $settings                  
        DS_CopyFile -SourceFiles "$AppsDir\MP4 HD Dub.xml" -Destination "$presets\MP4"
        DS_CopyFile -SourceFiles "$AppsDir\MP4 HD Leg.xml" -Destination "$presets\MP4"
        DS_CopyFile -SourceFiles "$AppsDir\MP4 SD Dub.xml" -Destination "$presets\MP4"
        DS_CopyFile -SourceFiles "$AppsDir\MP4 SD Leg.xml" -Destination "$presets\MP4"
        DS_CopyFile -SourceFiles "$AppsDir\Stream Copy to MP4.xml" -Destination "$presets\(Copy)"           
        DS_CopyFile -SourceFiles "$AppsDir\shanaapp.xml" -Destination "$settings\shanaapp.xml" 
        DS_WriteLog S "- ShanaEncoder configurado com sucesso." $LogFile
    }
}
function Install-W11SDK {
    DS_WriteLog I "- Instalando Windows 11 SDK." $LogFile  
    DownloadAria2 -SourceUri $w11sdkUrl -DestinationPath $AppsDir
    DS_ExecuteProcess -FileName $w11sdkPath -Arguments "/features OptionId.DesktopCPPx64 /quiet /norestart"
    DS_WriteLog S "- Windows 11 SDK instalado com sucesso." $LogFile 
}
function Install-Delphi12 {         
    DS_WriteLog I "- Baixando Key Patch." $LogFile
    DownloadAria2 -SourceUri $keypatchUrl -DestinationPath $AppsDir
    DS_WriteLog I "- Instalando Delphi 12.2." $LogFile  
    DownloadAria2 -SourceUri $delphiURL -DestinationPath $AppsDir      
    DS_ExecuteProcessNoWait -FileName $keypatchPath               
    if (DS_CheckPathExist -Path $delphiISOPath) {        
        Invoke-ISOExe -ISO $delphiISOPath -ExeName "radstudio_12_esd_120329a.exe"       
    }

    if (DS_CheckPathExist -Path "${env:ProgramFiles(x86)}\Embarcadero\Studio\23.0\bin") {
        DS_WriteLog I "Delphi já está instalado." $LogFile
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
    
    DS_ExpandArchive -SourceFile $postgresPath -DestinationPath $Postgres -Overwrite $true

    if (DS_CheckPathExist -Path "$Postgres\Server\bin\initdb.exe") {   
        DS_WriteLog I "- Postgresql já está instalando na pasta: [$Postgres]." $LogFile        
    }
    else {
        DS_CreateDirectory -Directory $Postgres
    }

    DS_WriteLog I "- Iniciando novo cluster Postgres usando initdb." $LogFile   

    DS_AddContentToFile -FilePath temp_pgsql.pw -Content $PG_PASSWORD

    try {
        & "$PG_SERVERHOME\bin\initdb.exe" -A "$PG_AUTHMETHOD" -D "$PG_DATAHOME" -E UTF8 -U "$PG_SUPERUSER" --locale-provider="$PG_LOCALE_PROVIDER" --icu-locale="$PG_ICU_LOCALE" --locale="$PG_LOCALE" --lc-collate="$PG_LOCALE" --lc-ctype="$PG_LOCALE" --lc-messages="$PG_LOCALE" --lc-monetary="$PG_LOCALE" --lc-numeric="$PG_LOCALE" --lc-time="$PG_LOCALE" --pwfile=temp_pgsql.pw --no-instructions    
    }
    finally {
        DS_DeleteFile -File temp_pgsql.pw 
    }

    DS_WriteLog I " - Adicionando novo serviço: '$ServiceName'." $LogFile

    & "$PG_SERVERHOME\bin\pg_ctl.exe" register -N "$ServiceName" -U LocalSystem -D "$PG_DATAHOME"

    DS_ChangeServiceStartupType -ServiceName $ServiceName -StartupType "Automatic"
    DS_StartService -ServiceName $ServiceName
    $serviceState = (Get-Service -Name $ServiceName).Status
    
    if ($serviceState -ne "Running") {
        Throw "- Falha em iniciar serviço $ServiceName."
    }
    DS_WriteLog S "- PostgreSQL instalado com sucesso!" $LogFile
}

function Install-ODBC {   
    DS_WriteLog I "- Instalando Driver ODBC 32 bits." $LogFile
    if (!(DS_CheckPathExist -Path "${env:ProgramFiles(x86)}\psqlODBC\1700\bin\libpq.dll")) {
        DownloadAria2 -SourceUri $odbcUrl -DestinationPath $odbcPath                    
    }
    else {
        DS_WriteLog E "- ODBC já instalado." $LogFile
    }
    
    if (DS_CheckPathExist -Path $odbcPath) {        
        DS_ExecuteProcess -FileName "msiexec" -Arguments "/i $odbcPath /qn quiet" 
    }
}

#==========================================================================

# Extras
#==========================================================================
function Set-BitTorrentFolders {
    $bitTorrent = "D:\BitTorrent"
    $folders = @(, 'Compressed', 'Documents', 'ISO', 'Logs', 'Music', 'Programs', 'Temp', 'Torrents', 'Video')  

    if (!(DS_CheckPathExist -Path $bitTorrent)) {
        DS_CreateDirectory -Directory $bitTorrent
        foreach ($folder in $folders) {
            DS_CreateDirectory -Directory $bitTorrent\$folder
        }
    }
    else {
        DS_WriteLog W "Pastas já foram criadas." $LogFile
    }
}
function Set-IDMFolders {
    $idmDir = "D:\IDM"
    $folders = @(, 'Compressed', 'Documents', 'Music', 'Programs', 'Temp', 'Video', 'APK', 'ISO', 'General')  

    if (!(DS_CheckPathExist -Path $idmDir)) {
        DS_CreateDirectory -Directory $idmDir
        foreach ($folder in $folders) {            
            DS_CreateDirectory -Directory $idmDir\$folder
        }
    }
    else {
        DS_WriteLog W "Pastas já foram criadas." $LogFile
    }
}
function Set-WinRARFolders {
    $rarDir = "D:\RAR"
    $folders = @(, 'Extracted', 'Output', 'Temp')  

    if (!(DS_CheckPathExist -Path $rarDir)) {
        DS_CreateDirectory -Directory $rarDir 
        foreach ($folder in $folders) {
            DS_CreateDirectory -Directory $rarDir\$folder 
        }
    }
    else {
        DS_WriteLog W "Pastas já foram criadas." $LogFile
    }
}
function Set-KotatogramFolders {
    $kotatogramDir = "D:\Kotatogram Desktop"

    if (!(DS_CheckPathExist -Path $kotatogramDir)) {
        DS_CreateDirectory -Directory $kotatogramDir   
    }
    else {
        DS_WriteLog W "- Pastas já foram criadas." $LogFile
    }
}   

function Set-TelegramFolders {
    $telegramDir = "D:\Telegram Desktop"
    
    if (!(DS_CheckPathExist -Path $telegramDir)) {
        DS_CreateDirectory -Directory $telegramDir 
    }
    else {
        DS_WriteLog W "- Pastas já foram criadas." $LogFile
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
        DS_WriteLog I "- Baixando Notepad++ versão $latestVersion." $LogFile   
        $webClient.DownloadFile($downloadUrl, $outputFile)
        DS_WriteLog I "- Download concluído: $outputFile" $LogFile
    }
    catch {
        DS_WriteLog E "- Ocorreu um erro ao tentar verificar ou baixar a última versão do Notepad++." $LogFile
        DS_WriteLog E $_.Exception.Message $LogFile
    }
}

function Get-PHP {
    $url = "https://windows.php.net/downloads/releases/"
    function Get-LatestPHPVersion {
        $pageContent = Invoke-WebRequest -Uri $url
        $versionLinks = $pageContent.Links | Where-Object { $_.href -match 'php-(\d+\.\d+\.\d+)-Win32-vs16-x64.zip' }
        $latestVersionLink = $versionLinks | Sort-Object {
            $_.href -match 'php-(\d+\.\d+\.\d+)' | Out-Null
            [version]$matches[1]
        } -Descending | Select-Object -First 1

        $latestVersionLink = $latestVersionLink.href -replace '^/downloads/releases/', ''
        return $latestVersionLink
    }

    $latestPHP = Get-LatestPHPVersion
    if ($latestPHP) {
        $downloadLink = "$url$latestPHP"
        $outputPath = "$AppsDir\$($latestPHP -split '/' | Select-Object -Last 1)"
        DS_WriteLog I "- Baixando PHP da URL: $downloadLink." $LogFile
        DownloadAria2 -SourceUri $downloadLink -DestinationPath $AppsDir
        DS_WriteLog S "- Download concluído. PHP salvo em $outputPath." $LogFile
    }
    else {
        Write-Host "- Não foi possível encontrar a última versão do PHP."
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
            DS_WriteLog I "- Baixando Nginx de: $nginxZipUrl" $LogFile
            DownloadAria2 -SourceUri $nginxZipUrl -DestinationPath $AppsDir
            DS_WriteLog S "- Download do Nginx concluído e salvo em: $nginxZipFile" $LogFile
        }
        else {
            DS_WriteLog E "- Erro: link para o arquivo zip não encontrado." $LogFile
        }
    }
    catch {
        DS_WriteLog E "- Ocorreu um erro ao tentar baixar o Nginx." $LogFile
        DS_WriteLog E $_.Exception.Message $LogFile
    }
}

function Install-Apache {
    if (!(DS_CheckPathExist -Path $apachePath)) {      
        DownloadAria2 -SourceUri $apacheUrl -DestinationPath $AppsDir
    }

    if (DS_CheckPathExist -Path $apachePath) {      
        DS_ExpandArchive -SourceFile $apachePath -DestinationPath "$Laragon\apache" -Overwrite $true
        DS_DeleteFile "$Laragon\apache\-- Win64 VS17  --"        
        DS_DeleteFile "$Laragon\apache\ReadMe.txt"
        DS_DeleteFile "$Laragon\apache\Apache24\README*"
        DS_DeleteFile "$Laragon\apache\Apache24\ABOUT*"
        DS_DeleteFile "$Laragon\apache\Apache24\CHANGES*"
        DS_DeleteFile "$Laragon\apache\Apache24\INSTALL*"
        DS_DeleteFile "$Laragon\apache\Apache24\NOTICE*"        
    }    
}

function Install-NotepadPlusPlus {
    $notepadPlusPlusZipFile = Get-ChildItem -Path $AppsDir -Filter "notepad*.zip" -Recurse -ErrorAction SilentlyContinue
    $ExtractDir = "$Laragon\notepad++"

    if ($notepadPlusPlusZipFile -and $notepadPlusPlusZipFile.FullName -is [string]) {
        DS_WriteLog I "- Arquivo encontrado: $($notepadPlusPlusZipFile.Name). Descompactando para $ExtractDir" $LogFile
        DS_WriteLog I $notepadPlusPlusZipFile.Name $LogFile
        DS_ExpandArchive -SourceFile $notepadPlusPlusZipFile.FullName -DestinationPath $ExtractDir -Overwrite $true        
    }
    else {
        DS_WriteLog I "- Arquivo não encontrado. Baixando nova versão." $LogFile
        Get-NotepadPlusPlus
    }
}

function Install-Nginx {
    $nginxZipFile = Get-ChildItem -Path $AppsDir -Filter "nginx*.zip" -Recurse -ErrorAction SilentlyContinue
    $ExtractDir = "$Laragon\nginx"

    if ($nginxZipFile -and $nginxZipFile.FullName -is [string]) {
        DS_WriteLog I "- Arquivo encontrado: $($nginxZipFile.Name). Descompactando para $ExtractDir" $LogFile
        DS_WriteLog I $nginxZipFile.Name $LogFile
        DS_ExpandArchive -SourceFile $nginxZipFile.FullName -DestinationPath $ExtractDir -Overwrite $true        
    }
    else {
        DS_WriteLog I "- Arquivo não encontrado. Baixando nova versão." $LogFile
        Get-Nginx
    }
}

function Install-PHP {
    $phpZipFile = Get-ChildItem -Path $AppsDir -Filter "php*.zip" -Recurse -ErrorAction SilentlyContinue
    $ExtractDir = "$Laragon\php\php8"

    if ($phpZipFile -and $phpZipFile.FullName -is [string]) {
        DS_WriteLog I "- Arquivo encontrado: $($phpZipFile.Name). Descompactando para $ExtractDir" $LogFile
        DS_WriteLog I $phpZipFile.Name $LogFile
        DS_ExpandArchive -SourceFile $phpZipFile.FullName -DestinationPath $ExtractDir -Overwrite $true        
    }
    else {
        DS_WriteLog I "- Arquivo não encontrado. Baixando nova versão." $LogFile
        Get-PHP    
    }
}

function Install-Python {
    $python = Get-ChildItem -Path $AppsDir -Filter "python*.exe" -Recurse -ErrorAction SilentlyContinue

    if ($python -and $python.FullName -is [string]) {
        DS_WriteLog I "- Arquivo encontrado: $($python.Name)." $LogFile
        DS_WriteLog I $python.Name $LogFile
        DS_ExecuteProcess -FileName $python.FullName -Arguments "/quiet InstallAllUsers=0 Include_pip=1 Include_exe=1 Include_dev=0 PrependPath=1 Include_lib=1 Include_tcltk=1 Include_launcher=1 Include_doc=0 Include_test=0 Include_symbols=0 Include_debug=0 AssociateFiles=1"
    }
    else {
        DS_WriteLog I "- Arquivo não encontrado. Baixando nova versão." $LogFile
        Get-Python    
    }
}
function Install-WinFindr {    
    DS_WriteLog I "- Instalando WinFindr." $LogFile
    if (DS_CheckPathExist -Path $winfindrPath) {        
        DS_ExecuteProcess -FileName $winfindrPath 
    }
    elseif (!(DS_CheckPathExist -Path "${env:ProgramFiles(x86)}\WinFindr\WinFindr.exe")) {
        DownloadAria2 -SourceUri $winfindrUrl -DestinationPath $winfindrPath
    }
    else {
        DS_WriteLog E "- WinFindr já está instalado." $LogFile
    }  
}

function Set-LaragonConfiguration {    
    DS_WriteLog I "- Iniciando configuração do Laragon." $LogFile
    DS_CleanupDirectory -Directory "$Laragon\php"
    DS_CleanupDirectory -Directory "$Laragon\apache"
    DS_CleanupDirectory -Directory "$Laragon\git"
    DS_CleanupDirectory -Directory "$Laragon\heidisql"
    DS_CleanupDirectory -Directory "$Laragon\mysql"
    DS_CleanupDirectory -Directory "$Laragon\nodejs"
    DS_CleanupDirectory -Directory "$Laragon\notepad++"
    DS_CleanupDirectory -Directory "$Laragon\nginx"
    DS_CleanupDirectory -Directory "$Laragon\python"
    DS_CreateDirectory -Directory "$Laragon\php\php8"
    DS_DeleteDirectory -Directory "$Laragon\git"
    DS_DeleteDirectory -Directory "$Laragon\heidisql"
    DS_DeleteDirectory -Directory "$Laragon\mysql"
    DS_DeleteDirectory -Directory "$Laragon\nodejs"
    DS_DeleteDirectory -Directory "$Laragon\python"        
    Install-Apache
    Install-PHP
    Install-NotepadPlusPlus   
    Install-Nginx
    DS_WriteLog I "- Laragon configured." $LogFile
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
Install-ODBC
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
