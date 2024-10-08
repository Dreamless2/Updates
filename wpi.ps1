$TempDir = $env:TEMP
$LogFile = "$TempDir\WPI\WPI.log"
$aria2c = "$TempDir\aria2c.exe"
$aria2conf = "$TempDir\aria2.conf"
$settings = "$TempDir\Settings.reg"
$idm = "$TempDir\IDM.reg"
$sysinternals = "$TempDir\Sysinternals.reg"
$radstudioPatch = "$TempDir\KeyPatch.exe"
$revoLic = "$TempDir\revouninstallerpro5.lic"

Start-BitsTransfer -Source "https://raw.githubusercontent.com/Dreamless2/Updates/main/DS_PowerShell_Function_Library.psm1" -Destination $TempDir

if (-not(Test-Path -Path $aria2c)) {
    Start-BitsTransfer -Source "https://github.com/Dreamless2/Updates/releases/download/youpdates/aria2c.exe" -Destination $TempDir
}

if (-not(Test-Path -Path $aria2conf)) {
    Start-BitsTransfer -Source "https://raw.githubusercontent.com/Dreamless2/Updates/main/aria2.conf" -Destination $TempDir
}

if (-not(Test-Path -Path $settings)) {
    Start-BitsTransfer -Source "https://github.com/Dreamless2/Updates/releases/download/youpdates/Settings.reg" -Destination $TempDir
}

if (-not(Test-Path -Path $idm)) {
    Start-BitsTransfer -Source "https://github.com/Dreamless2/Updates/releases/download/youpdates/IDM.reg" -Destination $TempDir
}

if (-not(Test-Path -Path $sysinternals)) {

    Start-BitsTransfer -Source "https://github.com/Dreamless2/Updates/releases/download/youpdates/Sysinternals.reg" -Destination $TempDir
}

if (-not(Test-Path -Path $radstudioPatch)) {
    Start-BitsTransfer -Source "https://github.com/Dreamless2/Updates/releases/download/youpdates/KeyPatch.exe" -Destination $TempDir
}

if (-not(Test-Path -Path $revoLic)) {
    Start-BitsTransfer -Source "https://github.com/Dreamless2/Updates/releases/download/youpdates/revouninstallerpro5.lic" -Destination $TempDir
}

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
    "Glarysoft.GlaryUtilities"     
)

$presets = "C:\ShanaEncoder\presets"
$settings = "C:\ShanaEncoder\settings" 
$downloadsFolderPath = "$env:USERPROFILE\Downloads"
$shanaUrl = "https://github.com/Dreamless2/Updates/releases/download/youpdates/ShanaEncoder6.0.1.7.exe"
$codecUrl = "https://github.com/Dreamless2/Updates/releases/download/youpdates/CodecLibrary.v1.2.x64.7z"
$regUrl = "https://github.com/Dreamless2/Updates/releases/download/youpdates/rarreg.key"    
$qBitTorrentUrl = "https://sinalbr.dl.sourceforge.net/project/qbittorrent/qbittorrent-win32/qbittorrent-5.0.0/qbittorrent_5.0.0_lt20_qt6_x64_setup.exe"
$inviskaUrl = "https://github.com/Dreamless2/Updates/releases/download/youpdates/Inviska_MKV_Extract_11.0_x86-64_Setup.exe"
$jdkUrl = "https://github.com/adoptium/temurin21-binaries/releases/download/jdk-21.0.4%2B7/OpenJDK21U-jdk_x64_windows_hotspot_21.0.4_7.msi"    
$vboxUrl = "https://github.com/Dreamless2/Updates/releases/download/youpdates/VirtualBox-7.1.2.msi"
$extpackUrl = "https://github.com/Dreamless2/Updates/releases/download/youpdates/Oracle_VirtualBox_Extension_Pack-7.1.2.vbox-extpack"    
$pythonUrl = "https://www.python.org/ftp/python/3.12.7/python-3.12.7-amd64.exe"

$shana = [System.IO.Path]::GetFileName($shanaUrl)        
$inviska = [System.IO.Path]::GetFileName($inviskaUrl)
$qBitTorrent = [System.IO.Path]::GetFileName($qBitTorrentUrl)
$jdkName = [System.IO.Path]::GetFileName($jdkUrl)
$vboxName = [System.IO.Path]::GetFileName($vboxUrl)
$extpackName = [System.IO.Path]::GetFileName($extpackUrl)
$pythonName = [System.IO.Path]::GetFileName($pythonUrl)  

$shanaPath = Join-Path -Path $TempDir $shana      
$inviskaPath = Join-Path -Path $TempDir $inviska
$qBitTorrentPath = Join-Path -Path $TempDir $qBitTorrent
$jdkPath = Join-Path $TempDir $jdkName
$vboxPath = Join-Path $TempDir $vboxName
$extpackPath = Join-Path $TempDir $extpackName
$pythonPath = Join-Path $TempDir $pythonName   

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

        DS_WriteLog "I" "Download $name successful." $LogFile
    }
    catch {
        DS_WriteLog "E" "An error occurred while downloading $name. Error details: $_.Exception.Message" $LogFile
    }
}

# Function to download a file using aria2
function DownloadAria2 {
    param (
        [Parameter(Mandatory = $true)]
        [string]$Url,
        [Parameter()]
        [string]$DestinationPath = "$env:TEMP"           
    )

    $Aria2ConfigPath = "$TempDir\aria2.conf"
    $Aria2ExePath = "$TempDir\aria2c.exe"    

    if (-not $Url -or $Url -notmatch '^(http|https|ftp)://') {
        DS_WriteLog "E" "Error: Invalid URL. Please provide a valid URL." $LogFile
        return
    } 

    if (-not (Test-Path -Path $Aria2ExePath)) {
        DS_WriteLog "E" "Error: aria2 executable not found at $Aria2ExePath." $LogFile
        return
    }  

    $fileName = [System.IO.Path]::GetFileName($Url)
    $aria2Command = "$Aria2ExePath --conf-path=$Aria2ConfigPath --dir=$DestinationPath --out=$fileName $Url"

    DS_WriteLog "I" "Executing command: $aria2Command" $LogFile

    try {
        $arguments = @(
            "--conf-path=`"$Aria2ConfigPath`"",
            "--dir=`"$DestinationPath`"",
            "--out=`"$fileName`"",
            "`"$Url`""
        ) -join " "

        $process = Start-Process -FilePath $Aria2ExePath -ArgumentList $arguments -NoNewWindow -PassThru -Wait
        if ($process.ExitCode -eq 0) {
            DS_WriteLog "I" "File $fileNamename downloaded." $LogFile
        }
        else {
            DS_WriteLog "E" "Error: Download failed with exit code $($process.ExitCode)." $LogFile
        }
    }
    catch {
        DS_WriteLog "E" "Error executing aria2 command: $_" $LogFile
    }
}
# Execute executable from iso
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
                DS_ExecuteProcess -FileName $exeFullPath                
            }
            else {
                DS_ExecuteProcess -FileName $exeFullPath -Arguments $ExeArgs                
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
    $wallpaperUrl = "https://images.pexels.com/photos/6559795/pexels-photo-6559795.jpeg"    
    $wallpaperFileName = [System.IO.Path]::GetFileName($wallpaperUrl)
    $wallpaperPath = Join-Path -Path $env:USERPROFILE $wallpaperFileName
    DS_WriteLog "I" "Applying new wallpaper..." $LogFile
    DS_SetRegistryValue -RegKeyPath "hkcu:\Control Panel\Desktop" -RegValueName "JPEGImportQuality" -RegValue "100" -Type "DWORD"       
    DownloadFileWebRequest -SourceUri $wallpaperUrl -DestinationPath $wallpaperPath
    DS_SetRegistryValue -RegKeyPath "hkcu:\Control Panel\Desktop" -RegValueName "Wallpaper" -RegValue "$wallpaperPath" -Type "String"
    Invoke-Expression -Command 'rundll32.exe user32.dll, UpdatePerUserSystemParameters 1, True'
    DS_WriteLog "I" "Customizations applied. Windows Explorer will restart." $LogFile       
    DS_StartStopProcess -ProcessName "explorer" -Action "Stop"
    DS_StartStopProcess -ProcessName "explorer" -Action "Start"
    DS_WriteLog "S" "New wallpaper applied." $LogFile     
}

function Set-ConfigSystem {
    DS_WriteLog "I" "Set settings for computer..." $LogFile
    DS_ClearPrefetchFolder
    Set-Ensure-Admin
    Set-Ensure-InternetConnection
    Set-Ensure-OSCompatibility   
    Set-ExecutionPolicy -ExecutionPolicy RemoteSigned
    DS_SetRegistryValue -RegKeyPath "hkcu:\Control Panel\Keyboard" -RegValueName "PrintScreenKeyForSnippingEnabled" -RegValue "0" -Type "DWORD"
    DS_SetRegistryValue -RegKeyPath "hklm:\SOFTWARE\Policies\Microsoft\OneDrive" -RegValueName "KFMBlockOptIn" -RegValue "1" -Type "DWORD"
    DS_SetRegistryValue -RegKeyPath "hkcu:\SOFTWARE\Policies\Microsoft\TabletPC" -RegValueName "DisableSnippingTool" -RegValue "1" -Type "DWORD"
    DS_SetRegistryValue -RegKeyPath "hklm:\SOFTWARE\Policies\Microsoft\TabletPC" -RegValueName "DisableSnippingTool" -RegValue "1" -Type "DWORD"
    DS_SetRegistryValue -RegKeyPath "hkcu:\Software\Microsoft\Windows\CurrentVersion\Policies\Attachments" -RegValueName "SaveZoneInformation" -RegValue "1" -Type "DWORD" 
    DS_SetRegistryValue -RegKeyPath "hkcu:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -RegValueName "SilentInstalledAppsEnabled" -RegValue "0" -Type "DWORD"
    DS_SetRegistryValue -RegKeyPath "hklm:\SYSTEM\CurrentControlSet\Control\BitLocker" -RegValueName "PreventDeviceEncryption" -RegValue "1" -Type "DWORD"
    DS_SetRegistryValue -RegKeyPath "hklm:\SYSTEM\CurrentControlSet\Control\FileSystem" -RegValueName "LongPathsEnabled" -RegValue "1" -Type "DWORD"   
    DS_WriteLog "S" "Settings done." $LogFile
}

function Set-PowerOptions {
    DS_WriteLog "I" "Power configuration..." $LogFile
    Invoke-Expression -Command "powercfg /h off"
    Invoke-Expression -Command "powercfg /s e9a42b02-d5df-448d-aa00-03f14749eb61"
    Invoke-Expression -Command "powercfg /x standby-timeout-ac 0"
    Invoke-Expression -Command "powercfg /x disk-timeout-ac 0"
    Invoke-Expression -Command "powercfg /x monitor-timeout-ac 40"
    Invoke-Expression -Command "powercfg /SETACVALUEINDEX SCHEME_CURRENT 2a737441-1930-4402-8d77-b2bebba308a3 48e6b7a6-50f5-4782-a5d4-53bb8f07e226 0"
    Invoke-Expression -Command "fsutil.exe behavior set disableLastAccess 1"
    Invoke-Expression -Command "fsutil behavior set disable8dot3 1"
    DS_WriteLog "S" "Settings done." $LogFile
}

function Set-NetworkPrivate {
    if (1, 3, 4, 5 -contains (Get-WmiObject win32_computersystem).DomainRole) { 
        return 
    }

    $networkListManager = [Activator]::CreateInstance([Type]::GetTypeFromCLSID([Guid]"{DCB00C01-570F-4A9B-8D69-199FDBA5723B}"))
    $connections = $networkListManager.GetNetworkConnections()

    $connections | ForEach-Object {
        Write-Host $_.GetNetwork().GetName()"category was previously set to"$_.GetNetwork().GetCategory()
        $_.GetNetwork().SetCategory(1)
        Write-Host $_.GetNetwork().GetName()"changed to category"$_.GetNetwork().GetCategory()
    }
}

function Set-DarkMode {
    DS_WriteLog "I" "Setting Dark Mode..." $LogFile
    DS_SetRegistryValue -RegKeyPath "hkcu:\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize" -RegValueName "AppsUseLightTheme" -RegValue "0" -Type "DWORD"
    DS_SetRegistryValue -RegKeyPath "hkcu:\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize" -RegValueName "SystemUsesLightTheme" -RegValue "0" -Type "DWORD"
    DS_WriteLog "S" "Dark Mode Activated with success." $LogFile
}

# ------------ INSTALAÇÃO DO WINGET ------------ #

function Add-Winget {
    Write-Cyan "Iniciando o download e instalação do Winget e suas dependências..."

    # Fazer o download dos 3 arquivos manualmente economiza MUITO tempo! 
    # De qualquer forma, o script faz o download automático dos arquivos caso não sejam encontrados na pasta Downloads.
    $VCLibsURL = "https://download.microsoft.com/download/4/7/c/47c6134b-d61f-4024-83bd-b9c9ea951c25/Microsoft.VCLibs.x64.14.00.Desktop.appx"
    $UIXamlURL = "https://github.com/microsoft/microsoft-ui-xaml/releases/download/v2.8.6/Microsoft.UI.Xaml.2.8.x64.appx"
    $WingetURL = "https://github.com/microsoft/winget-cli/releases/latest/download/Microsoft.DesktopAppInstaller_8wekyb3d8bbwe.msixbundle"
    $SourcesUrl = " https://winget.azureedge.net/cache/source.msix"

    $VCLibsPKG = $VCLibsURL.Split('/')[-1]
    $UIXamlPKG = $UIXamlURL.Split('/')[-1]
    $WingetPKG = $WingetURL.Split('/')[-1]
    $SourcesPKG = $SourcesUrl.Split('/')[-1]
    
    $VCLibsPath = Join-Path -Path $downloadsFolderPath -ChildPath $VCLibsPKG
    $UIXamlPath = Join-Path -Path $downloadsFolderPath -ChildPath $UIXamlPKG
    $WingetPath = Join-Path -Path $downloadsFolderPath -ChildPath $WingetPKG
    $SourcesPath = Join-Path -Path $downloadsFolderPath -ChildPath $SourcesPKG
    
    try {
        if (-not (Test-Path $VCLibsPath)) {
            Write-Cyan "Downloading $($VCLibsPKG). Wait a moment..."
            Invoke-WebRequest $VCLibsURL -OutFile (Join-Path -Path $TempDir -ChildPath $VCLibsPKG) -ErrorAction Stop | Out-Null
            Add-AppxPackage -Path (Join-Path -Path $TempDir -ChildPath $VCLibsPKG) -ErrorAction Stop | Out-Null
        }
        else {
            Add-AppxPackage -Path $VCLibsPath -ErrorAction Stop | Out-Null
        }
        
        if (-not (Test-Path $UIXamlPath)) {
            Write-Cyan "Downloading $($UIXamlPKG). Wait a moment..."
            Invoke-WebRequest $UIXamlURL -OutFile (Join-Path -Path $TempDir -ChildPath $UIXamlPKG) -ErrorAction Stop | Out-Null
            Add-AppxPackage -Path (Join-Path -Path $TempDir -ChildPath $UIXamlPKG) -ErrorAction Stop | Out-Null
        }
        else {
            Add-AppxPackage -Path $UIXamlPath -ErrorAction Stop | Out-Null
        }
        
        if (-not (Test-Path $WingetPath)) {
            Write-Cyan "Downloading $($WingetPKG). Wait a moment..."
            Invoke-WebRequest $WingetURL -OutFile (Join-Path -Path $TempDir -ChildPath $WingetPKG) -ErrorAction Stop | Out-Null
            Add-AppxPackage -Path (Join-Path -Path $TempDir -ChildPath $WingetPKG) -ForceApplicationShutdown -ErrorAction Stop | Out-Null
        }
        else {
            Add-AppxPackage -Path $WingetPath -ForceApplicationShutdown -ErrorAction Stop | Out-Null
        }

        if (-not (Test-Path $SourcesPath)) {
            Write-Cyan "Downloading $($SourcesPKG). Wait a moment..."
            Invoke-WebRequest $SourcesUrl -OutFile (Join-Path -Path $TempDir -ChildPath $SourcesPKG) -ErrorAction Stop | Out-Null
            Add-AppxPackage -Path (Join-Path -Path $TempDir -ChildPath $SourcesPKG) -ForceApplicationShutdown -ErrorAction Stop | Out-Null
        }
        else {
            Add-AppxPackage -Path $SourcesPath -ForceApplicationShutdown -ErrorAction Stop | Out-Null
        }
        
        Invoke-Expression -Command "echo y | winget list --accept-source-agreements" -ErrorAction Stop | Out-Null
        
        Write-Green "Winget has been properly updated and is ready to use."
    }
    catch {
        return 1
    }
    
    return 0
}

# ------------ INSTALAÇÃO DOS PACOTES ------------ #

function Install-WingetPackages {
    DS_WriteLog "I" "Starting winget package installation..." $LogFile

    $count = 0

    foreach ($pkg in $PKGS) {
        $installed = Invoke-Expression -Command "winget list $pkg --accept-source-agreements"
        if ($installed -match ([regex]::Escape($pkg))) {
            DS_WriteLog "W" "$pkg are installed." $LogFile
        }
        else {
            DS_WriteLog "I" "Starting installation of $pkg..." $LogFile		
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

    DS_WriteLog "I" "All packages installed." $LogFile
    DS_WriteLog "I" "$count of $($PKGS.Count) packages were installed." $LogFile
}

# ------------ DESABILITAR SERVIÇOS DESNECESSÁRIOS ------------ #
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

# ------------ REMOVER WINDOWS DEFENDER ------------ #
function Remove-WindowsDefender {
    DS_WriteLog "I" "Downloading Windows Defender Removal..." $LogFile
    $defenderUrl = "https://github.com/ionuttbara/windows-defender-remover/releases/download/release_def_12_8/DefenderRemover.exe"
    $defenderName = [System.IO.Path]::GetFileName($defenderUrl)
    $defenderPath = Join-Path -Path $TempDir $defenderName
    DownloadAria2 -Url $defenderUrl -DestinationPath $TempDir
    DS_ExecuteProcess -FileName $defenderPath
}

# ------------ PACOTES EXTRAS ------------ #
function Add-ExtrasPackages {  
    if (Test-Path -Path "$env:ProgramFiles\VS Revo Group\Revo Uninstaller Pro\RevoUninPro.exe") {
        DS_WriteLog "I" "Registering Revo Uninstaller Pro..." $LogFile
        DownloadAria2 -Url $regUrl -DestinationPath $TempDir
        DS_CopyFile -SourceFiles "$TempDir\revouninstallerpro5.lic" -Destination "$env:ProgramData\VS Revo Group\Revo Uninstaller Pro"        
        DS_WriteLog "S" "Revo Uninstaller Pro registered." $LogFile  
    }

    if (Test-Path -Path "${env:ProgramFiles(x86)}\Internet Download Manager\IDMan.exe") {
        DS_WriteLog "I" "Registering IDM..." $LogFile
        DS_StartStopProcess -ProcessName "idm*" -Action "Stop"
        DS_ImportRegistryFile -FileName "$TempDir\IDM.reg"
        DS_WriteLog "S" "IDM registered." $LogFile 
    }

    if (-not(Test-Path -Path "$env:ProgramFiles\WinRAR\rarreg.key")) {
        DS_WriteLog "I" "Registering WinRAR..." $LogFile
        DownloadAria2 -Url $regUrl -DestinationPath $TempDir
        DS_CopyFile -SourceFiles "$TempDir\rarreg.key" -Destination "$env:ProgramFiles\WinRAR"        
        DS_WriteLog "S" "WinRAR registered." $LogFile  
    }
    else {
        DS_WriteLog "I" "Winrar already registered. Starting configuration..." $LogFile 
        DS_ImportRegistryFile -FileName "$TempDir\Settings.reg"       
        DS_WriteLog "W" "Winrar configuration done." $LogFile 
    }    

    if (Test-Path -Path "$env:LOCALAPPDATA\Microsoft\WindowsApps\streams.exe") {
        DS_WriteLog "I" "Configuring Sysinternals..." $LogFile
        DS_ImportRegistryFile -FileName "$TempDir\Sysinternals.reg"
        DS_WriteLog "I" "Sysinternals are configured." $LogFile
    }

    DS_WriteLog "S" "Packages configured with successful." $LogFile
}

# ------------ PROGRAMAS ------------ #
function Install-QuickPlugins {
    DS_WriteLog "I" "Downloading QuickLook Plugins..." $LogFile
    DownloadAria2 -Url "https://github.com/canheo136/QuickLook.Plugin.ApkViewer/releases/download/1.3.5/QuickLook.Plugin.ApkViewer.qlplugin" -DestinationPath $downloadsFolderPath
    DownloadAria2 -Url "https://github.com/adyanth/QuickLook.Plugin.FolderViewer/releases/download/1.3/QuickLook.Plugin.FolderViewer.qlplugin" -DestinationPath $downloadsFolderPath
    DownloadAria2 -Url "https://github.com/emako/QuickLook.Plugin.TorrentViewer/releases/download/v1.0.3/QuickLook.Plugin.TorrentViewer.qlplugin" -DestinationPath $downloadsFolderPath    
    DS_WriteLog "S" "Plugins QuickLook downloaded successful." $LogFile
}
function Install-Office365 {
    $officeToolUrl = "https://github.com/YerongAI/Office-Tool/releases/download/v10.14.28.0/Office_Tool_with_runtime_v10.14.28.0_x64.zip"   
    $configurationUrl = "https://github.com/Dreamless2/Updates/releases/download/youpdates/Configuration.xml"
    $officeToolName = [System.IO.Path]::GetFileName($officeToolUrl)
    $officeToolPath = Join-Path $TempDir $officeToolName    
    DS_WriteLog "I" "Starting installation of Office 365..." $LogFile
    DownloadAria2 -Url $configurationUrl -DestinationPath $downloadsFolderPath
    DownloadAria2 -Url $officeToolUrl -DestinationPath $TempDir
    DS_ExpandArchive -SourceFile $officeToolPath -DestinationPath $TempDir -Overwrite $true
    Invoke-RestMethod https://get.activated.win | Invoke-Expression
    DS_ExecuteProcess -FileName "$TempDir\Office Tool\Office Tool Plus.exe"
    DS_WriteLog "S" "Office 365 are installed." $LogFile
}
function Install-BitTorrent {
    DS_WriteLog "I" "Starting installation of qBitTorrent..." $LogFile
    if (-not(Test-Path -Path "$env:ProgramFiles\qBittorrent\qbittorrent.exe")) {      
        DownloadAria2 -Url $qBitTorrentUrl -DestinationPath $TempDir        
        DS_InstallOrUninstallSoftware -File $qBitTorrentPath -Installationtype "Install" -Arguments "/S"
        DS_WriteLog "S" "qBitTorrent installed." $LogFile                   
    }
    
    if (Test-Path -Path "$env:ProgramFiles\qBittorrent\qbittorrent.exe") {    
        DS_WriteLog "I" "Starting configuration of qBitTorrent..." $LogFile
        DownloadAria2 -Url "https://github.com/Dreamless2/Updates/releases/download/youpdates/qt.conf" -DestinationPath $TempDir
        DS_CopyFile -SourceFiles "$TempDir\qt.conf" -Destination "$env:ProgramFiles\qBittorrent"          
        DS_WriteLog "W" "qBitTorrent already installed." $LogFile
    }
}
function Install-MKVExtractor {
    DS_WriteLog "I" "Starting installation of Inviska MKV Extract..." $LogFile
    if (-not(Test-Path -Path "$env:ProgramFiles\Inviska MKV Extract\InviskaMKVExtract.exe")) {              
        DownloadAria2 -Url $inviskaUrl -DestinationPath $TempDir                
        DS_InstallOrUninstallSoftware -File $inviskaPath -Installationtype "Install" -Arguments ""
        DS_WriteLog "S" "Inviska MKV Extract installed sucessful" $LogFile                
    }
    else {
        DS_WriteLog "W" "Inviska MKV Extract already installed." $LogFile
    }         
}
function Install-JDK {
    DS_WriteLog "I" "Starting installation of JDK Temurin 21..." $LogFile
    if (-not(Test-Path -Path "$env:ProgramFiles\Eclipse Adoptium\jdk-21.0.4.7-hotspot\bin\javac.exe")) {       
        DownloadAria2 -Url $jdkUrl -DestinationPath $TempDir
        DS_InstallOrUninstallSoftware -File $jdkPath -Installationtype "Install" -Arguments "ADDLOCAL=FeatureMain,FeatureEnvironment,FeatureJarFileRunWith,FeatureJavaHome /quiet" 
        DS_WriteLog "S" "JDK Temurin 21 installed sucessful." $LogFile 
    }
    else {
        DS_WriteLog "W" "JDK Temurin 21 already installed." $LogFile
    }  
}
function Install-VirtualBox {
    DS_WriteLog "I" "Starting installation of VirtualBox..." $LogFile
    if (-not(Test-Path -Path "$env:ProgramFiles\Oracle\VirtualBox\VBoxManage.exe")) {        
        DownloadAria2 -Url $vboxUrl -DestinationPath $TempDir
        DownloadAria2 -Url $extpackUrl -DestinationPath $TempDir    
        DS_InstallOrUninstallSoftware -File $vboxPath -Installationtype "Install" -Arguments "ADDLOCAL=VBoxApplication,VBoxUSB,VBoxNetworkFlt NETWORKTYPE=NDIS6 VBOX_INSTALLDESKTOPSHORTCUT=1 VBOX_INSTALLQUICKLAUNCHSHORTCUT=0 VBOX_REGISTERFILEEXTENSIONS=1 VBOX_START=0"
        DS_WriteLog "S" "VirtualBox are installed." $LogFile    
    }
    else {	        
        DS_WriteLog "I" "VirtualBox are installed. Starting installation of Extension Pack..." $LogFile
        & "$env:ProgramFiles\Oracle\VirtualBox\VBoxManage.exe" extpack install --replace $extpackPath --accept-license=eb31505e56e9b4d0fbca139104da41ac6f6b98f8e78968bdf01b1f3da3c4f9ae
        DS_WriteLog "S" "VirtualBox Extension Pack are installed." $LogFile
    }
}
function Install-Python {
    DS_WriteLog "I" "Starting installation of python..." $LogFile   
    if (-not(Test-Path -Path "$env:LOCALAPPDATA\Programs\Python\Python312\python.exe")) {                
        DownloadAria2 -Url $pythonUrl -DestinationPath $TempDir
        DS_InstallOrUninstallSoftware -File $pythonPath -Installationtype "Install" -Arguments "/quiet InstallAllUsers=0 Include_pip=1 Include_exe=1 Include_dev=0 PrependPath=1 Include_lib=1 Include_tcltk=1 Include_launcher=1 Include_doc=0 Include_test=0 Include_symbols=0 Include_debug=0 AssociateFiles=1"
    }
    else {
        DS_WriteLog "S" "Python are installed." $LogFile
    }
}
function Install-ShanaEncoder {
    DS_WriteLog "I" "Starting installation of Shana Encoder..." $LogFile
    if (-not(Test-Path -Path "C:\ShanaEncoder")) {        
        DownloadAria2 -Url $codecUrl -DestinationPath $TempDir
        DownloadAria2 -Url $shanaUrl -DestinationPath $TempDir    
        DS_InstallOrUninstallSoftware -File $shanaPath -Installationtype "Install" -Arguments ""  
        DS_WriteLog "S" "ShanaEncoder installed." $LogFile    
    }

    DS_WriteLog "I" "Starting Shana Encoder configuration..." $LogFile
      
    if (Test-Path -Path "C:\ShanaEncoder") { 
        DS_WriteLog "I" "ShanaEncoder are installed. Starting configuration..." $LogFile  
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
            $filePath = Join-Path -Path $TempDir $fileName
            DownloadFileWebRequest -SourceUri $url -DestinationPath $filePath
            DS_WriteLog "I" "Files Saved on: $filePath" $LogFile     
        }           
        if (Test-Path -Path $presets) {                    
            DS_DeleteDirectory -Directory $presets            
        }        
  
        if (Test-Path -Path $settings) {            
            DS_DeleteDirectory -Directory $settings
        }           
  
        DS_CreateDirectory -Directory "$presets\(Copy)"
        DS_CreateDirectory -Directory "$presets\MP4"     
        DS_CreateDirectory -Directory $settings                  
        DS_CopyFile -SourceFiles "$TempDir\MP4 HD Dub.xml" -Destination "$presets\MP4"
        DS_CopyFile -SourceFiles "$TempDir\MP4 HD Leg.xml" -Destination "$presets\MP4"
        DS_CopyFile -SourceFiles "$TempDir\MP4 SD Dub.xml" -Destination "$presets\MP4"
        DS_CopyFile -SourceFiles "$TempDir\MP4 SD Leg.xml" -Destination "$presets\MP4"
        DS_CopyFile -SourceFiles "$TempDir\Stream Copy to MP4.xml" -Destination "$presets\(Copy)"           
        DS_CopyFile -SourceFiles "$TempDir\shanaapp.xml" -Destination "$settings\shanaapp.xml" 
        DS_WriteLog "S" "ShanaEncoder configured." $LogFile
    }
}
function Install-Delphi12 {
    $delphiURL = "https://altd.embarcadero.com/download/radstudio/12.0/RADStudio_12_2_9782_9961F.iso"    
    $w11sdkUrl = "https://download.microsoft.com/download/2/6/f/26f7aa55-ef6f-4882-b19b-a1be0e7328fe/KIT_BUNDLE_WINDOWSSDK_MEDIACREATION/winsdksetup.exe"
    $cnPackUrl = "https://github.com/cnpack/cnwizards/releases/download/CNWIZARDS_1.5.0.1209_20240917/CnWizards_1.5.0.1209.exe"
    $componentsUrl = "https://github.com/Dreamless2/Updates/releases/download/youpdates/DelphiComponents.zip"
    $delphiName = [System.IO.Path]::GetFileName($delphiURL)
    $w11sdkName = [System.IO.Path]::GetFileName($w11sdkUrl)
    $cnPackName = [System.IO.Path]::GetFileName($cnPackUrl)
    $componentsName = [System.IO.Path]::GetFileName($componentsUrl)
    $delphiISOPath = Join-Path $downloadsFolderPath $delphiName   
    $w11sdkPath = Join-Path $TempDir $w11sdkName    
    $cnPackPath = Join-Path -Path $TempDir $cnPackName   
    $componentsPath = Join-Path -Path $TempDir $componentsName
    DownloadAria2 -Url $componentsUrl -DestinationPath $TempDir
    DS_ExpandArchive -SourceFile $componentsPath -DestinationPath $downloadsFolderPath -Overwrite $true
    DS_WriteLog "I" "Starting installation of Windows 11 SDK Desktop 64 bits Features..." $LogFile  
    DownloadAria2 -Url $w11sdkUrl -DestinationPath $TempDir
    DS_InstallOrUninstallSoftware -File $w11sdkPath -Installationtype "Install" -Arguments "/features OptionId.DesktopCPPx64 /quiet /norestart"
    DS_WriteLog "I" "Windows 11 SDK Desktop 64 bits Features are installed." $LogFile  
    DS_WriteLog "I" "Starting installation of Delphi 12.2..." $LogFile  
    DownloadAria2 -Url $delphiURL -DestinationPath $downloadsFolderPath      
    if (Test-Path $delphiISOPath) {        
        Start-Process -FilePath "$TempDir\KeyPatch.exe"        
        Invoke-ISOExe -ISO $delphiISOPath -ExeName "radstudio_12_esd_119782a.exe"
        if (Test-Path -Path "${env:ProgramFiles(x86)}\Embarcadero\Studio\23.0\bin") {
            DS_WriteLog "I" "Starting installation of CnPack Wizard..." $LogFile
            DownloadAria2 -Url $cnPackUrl -DestinationPath $TempDir
            DS_InstallOrUninstallSoftware -File $cnPackPath -Installationtype "Install" -Arguments ""
            DS_WriteLog "I" "CnPack Wizard are instaled." $LogFile          
        }
        else {
            DS_WriteLog "W" "CnPack already installed." $LogFile
        }  
    }
    else {
        DS_WriteLog "I" "Delphi 12.2 are installed." $LogFile
    }
}

function Install-Postgres {
    $odbcUrl = "https://www.postgresql.org/ftp/odbc/releases/REL-17_00_0002-mimalloc/psqlodbc_x86.msi"  
    $postgresUrl = "https://get.enterprisedb.com/postgresql/postgresql-17.0-1-windows-x64.exe" 
    $odbcName = [System.IO.Path]::GetFileName($odbcUrl)
    $postgresName = [System.IO.Path]::GetFileName($postgresUrl)
    $odbcPath = Join-Path $TempDir $odbcName
    $postgresPath = Join-Path $TempDir $postgresName
    $locale = "Portuguese, Brazil"
    $password = "oTRuM5eBdm8VK*kv"
    $servicename = "postgresql-x64-17"
    DS_WriteLog "I" "Starting installation PostgreSQL..." $LogFile 
    DownloadAria2 -Url $odbcUrl -DestinationPath $TempDir
    DownloadAria2 -Url $postgresUrl -DestinationPath $TempDir
    DS_InstallOrUninstallSoftware -File $odbcPath -Installationtype "Install" -Arguments ""
    $arguments = @(
        "--unattendedmodeui none",
        "--mode unattended",
        "--debuglevel 0",
        "--disable-components stackbuilder",
        "--install_runtimes 0",
        "--serverport 5432",
        "--locale `"$locale`"",
        "--superpassword `"$password`"",      
        "--servicename `"$serviceName`""
    ) -join " "
    DS_InstallOrUninstallSoftware -File $postgresPath -Installationtype "Install" -Arguments $arguments     
    DS_WriteLog "S" "PostgreSQL are installed." $LogFile 
}

# ------------ CONFIGURAÇÕES EXTRAS ------------ #
function Set-BitTorrentFolders {
    $bitTorrent = "D:\BitTorrent"
    $folders = @(, 'Compressed', 'Documents', 'ISO', 'Logs', 'Music', 'Programs', 'Temp', 'Torrents', 'Video')  

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
    else {
        DS_WriteLog "W" "Folders already exists." $LogFile
    }
    
    if (-not(Test-Path $telegramDir)) {
        DS_CreateDirectory -Directory $telegramDir 
    }
    else {
        DS_WriteLog "W" "Folders already exists." $LogFile
    }
}
function Set-LaragonConfiguration {    
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
    $php = "https://github.com/Dreamless2/Updates/releases/download/youpdates/php-8.3.12-nts-Win32-vs16-x64.zip"
    $apache = "https://github.com/Dreamless2/Updates/releases/download/youpdates/httpd-2.4.62-240904-win64-VS17.zip"
    $notepadplusplus = "https://github.com/notepad-plus-plus/notepad-plus-plus/releases/download/v8.7/npp.8.7.portable.x64.zip"
    $nginx = "https://nginx.org/download/nginx-1.27.2.zip"
    $apacheName = [System.IO.Path]::GetFileName($apache)
    $phpName = [System.IO.Path]::GetFileName($php)
    $notepadplusplusName = [System.IO.Path]::GetFileName($notepadplusplus)
    $nginxName = [System.IO.Path]::GetFileName($nginx)   
  
    if (-not $php) { throw "php cannot be null or empty." }
    if (-not $apache) { throw "apache cannot be null or empty." }
    if (-not $notepadplusplus) { throw "notepadplusplus cannot be null or empty." }
    if (-not $nginx) { throw "nginx cannot be null or empty." }

    $downloads = @{
        "php"             = @{ "Url" = $php; "Path" = Join-Path $TempDir $phpName; "Destination" = "C:\laragon\bin\php\php8" }
        "apache"          = @{ "Url" = $apache; "Path" = Join-Path $TempDir $apacheName; "Destination" = "C:\laragon\bin\apache" }
        "notepadplusplus" = @{ "Url" = $notepadplusplus; "Path" = Join-Path $TempDir $notepadplusplusName; "Destination" = "C:\laragon\bin\notepad++" }
        "nginx"           = @{ "Url" = $nginx; "Path" = Join-Path $TempDir $nginxName; "Destination" = "C:\laragon\bin\nginx" }
    }

    foreach ($key in $downloads.Keys) {
        $file = $downloads[$key]
 
        if (-not $file.Path) { throw "The route for $key cannot be null or empty." }
        if (-not $file.Url) { throw "The URL for $key cannot be null or empty." }
        if (-not $file.Destination) { throw "The destiny for $key cannot be null or empty." }
    
        if (!(Test-Path -Path $file.Path)) {      
            DownloadAria2 -Url $file.Url -DestinationPath $TempDir        
        }
        else {
            DS_ExpandArchive -SourceFile $file.Path -DestinationPath $file.Destination -Overwrite $true
        }
    }
    
    DS_DeleteFile "C:\laragon\bin\apache\-- Win64 VS17  --"
    DS_DeleteFile "C:\laragon\bin\apache\ReadMe.txt"
    DS_WriteLog "I" "Laragon configured." $LogFile
}

# ------------ EXECUÇÃO ------------ #

Set-DarkMode
Disable-Services
Set-ConfigSystem
Set-PowerOptions
Set-NetworkPrivate
Set-Wallpaper
Add-Winget
Install-WingetPackages
Install-Office365
Install-Delphi12
Install-ShanaEncoder
Install-BitTorrent
Install-MKVExtractor
Install-JDK
Install-VirtualBox
Install-Python
Install-QuickPlugins
Install-Postgres
Set-BitTorrentFolders
Set-IDMFolders
Set-WinRARFolders
Set-TelegramFolders
Add-ExtrasPackages
Set-ShanaEncoderConfig
Set-LaragonConfiguration
Clear-TempFiles
Remove-WindowsDefender
