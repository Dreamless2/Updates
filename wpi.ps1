$OutputEncoding = [System.Text.Encoding]::UTF8

$TempDir = Join-Path -Path $PSScriptRoot -ChildPath "wpi_temp"
$ErrorLog = Join-Path -Path $PSScriptRoot -ChildPath "wpi_errors.log"

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
    "arch1t3cht.Aegisub",
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


function Write-Cyan {
    param(
        [string]$Message
    )
    Write-Host $Message -ForegroundColor Cyan
}

function Write-Green {
    param(
        [string]$Message
    )
    Write-Host $Message -ForegroundColor Green
}

function Write-Yellow {
    param(
        [string]$Message
    )
    Write-Host $Message -ForegroundColor Yellow
}

function Exit-Error {
    param ([string]$ErrorMessage)

    Write-Error -Message $ErrorMessage
    exit 1
}

function Exit-Script {
    Write-Cyan "Fazendo a limpeza do sistema... `nEventuais erros podem ser visualizados posteriormente em: '$ErrorLog'."
    CleanUp
    $error | Out-File -FilePath $ErrorLog
    
    Write-Yellow "Fim do script! `nReiniciar o sistema para aplicar alterações? (s = sim | n = não)" ; $i = Read-Host
    if ($i -ceq 's') {
        Write-Yellow "Reiniciando agora..."
        Restart-Computer -Force
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
        # Download the file
        Invoke-WebRequest -Uri $SourceUri -OutFile $DestinationPath
        Write-Host "Download successful using Invoke-WebRequest."
    }
    catch {
        # Handle errors
        Write-Host "An error occurred while downloading using Invoke-WebRequest. Error details: $_.Exception.Message"
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
        # Initialize WebClient and download the file
        $webClient = New-Object System.Net.WebClient
        $webClient.DownloadFile($SourceUri, $DestinationPath)
        Write-Host "Download successful using WebClient."
    }
    catch {
        # Handle errors
        Write-Host "An error occurred while downloading using WebClient. Error details: $_.Exception.Message"
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
        # Initialize BitsTransfer and download the file
        $bitsJob = Start-BitsTransfer -Source $SourceUri -Destination $DestinationPath -Asynchronous
         
        # Monitor the download
        while (($bitsJob.JobState -eq 'Transferring') -or ($bitsJob.JobState -eq 'Connecting')) {
            Start-Sleep -Seconds 10
        }
         
        # Handle errors and resume
        if ($bitsJob.JobState -eq 'Error') {
            Resume-BitsTransfer -BitsJob $bitsJob
        }
         
        # Complete the download
        if ($bitsJob.JobState -eq 'Transferred') {
            Complete-BitsTransfer -BitsJob $bitsJob
        }
         
        Write-Host "Download successful using BitsTransfer."
    }
    catch {
        # Handle errors
        Write-Host "An error occurred while downloading using BitsTransfer. Error details: $_.Exception.Message"
    }
}

function CleanUp {
    if (Test-Path $TempDir) {
        Remove-Item -Path $TempDir -Recurse -Force | Out-Null 
    }
}

function Set-Ensure-Admin {
    if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
        Exit-Error "Este script deve ser executado como Administrador!"
    }
}

function Set-Ensure-InternetConnection {
    Write-Cyan "Verificando conexão com a internet..."
    Test-Connection 8.8.8.8 -Count 1 -ErrorAction SilentlyContinue | Out-Null
    
    if (-not $?) {
        Exit-Error "O computador precisa estar conectado à internet para executar este script!"
    }
}

function Set-Ensure-OSCompatibility {
    Write-Cyan "Verificando compatibilidade do sistema..."
    $OS_name = Get-CimInstance Win32_OperatingSystem | Select-Object -ExpandProperty Caption
    
    if (-not $OS_name) {
        Exit-Error "Versão do Windows desconhecida ou não suportada!"
    } 
    else {
        Write-Green "Sistema operacional identificado: $OS_name"
        $OS_version = ($OS_name -split ' ')[2]
    
        if ($OS_version -lt 10) {
            Exit-Error "Versão do Windows desconhecida ou não suportada!"
        } 
        else {
            Write-Cyan "Versão do sistema operacional: $OS_version"
        }
    }
}

function Set-Wallpaper {
    $wallpaperUrl = "https://images.pexels.com/photos/20775596/pexels-photo-20775596/free-photo-of-mar-panorama-vista-paisagem.jpeg"
    $wallpaperFileName = [System.IO.Path]::GetFileName($wallpaperUrl)
    $wallpaperPath = Join-Path -Path $env:USERPROFILE -ChildPath $wallpaperFileName
    Write-Cyan "Aplicando novo wallpaper..."
    Set-ItemProperty -Path "HKCU:\Control Panel\Desktop" -Name "JPEGImportQuality" -Value 100 -Type DWORD -Force
    DownloadFileBitsTransfer -SourceUri $wallpaperUrl -DestinationPath $wallpaperPath
    Set-ItemProperty -Path "HKCU:\Control Panel\Desktop" -Name "Wallpaper" -Value $wallpaperPath -Type String -Force
    Invoke-Expression -Command 'rundll32.exe user32.dll, UpdatePerUserSystemParameters 1, True'
    Write-Green "Personalizações aplicadas. O Windows Explorer será reiniciado."
    Pause
    Stop-Process -Name explorer -Force ; Start-Process explorer
}
function Set-ConfigSystem {
    Set-Ensure-Admin
    Set-Ensure-InternetConnection
    Set-Ensure-OSCompatibility

    <#if (-not (Test-Path $TempDir)) {
        New-Item -ItemType Directory -Path $TempDir | Out-Null 
    }#>
}

# ------------ INSTALAÇÃO DO WINGET ------------ #

function Install-WingetDependency {
    param (
        [string]$URL
    )
    $PackageName = [System.IO.Path]::GetFileName($URL)
    $PackagePath = Join-Path -Path $PSScriptRoot -ChildPath $PackageName
    
    try {
        if (-not (Test-Path $PackagePath)) {
            Write-Cyan "Fazendo o download de $PackageName..."
            DownloadFileBitsTransfer -SourceUri $URL -DestinationPath $PackagePath
        }
        Add-AppxPackage -Path $PackagePath -ErrorAction Stop | Out-Null
    }
    catch {
        Exit-Error "Erro ao baixar ou instalar $PackageName"
    }
}

function Install-Winget {
    Write-Cyan "Iniciando o download e instalação do Winget e suas dependências..."
    Install-WingetDependency "https://download.microsoft.com/download/4/7/c/47c6134b-d61f-4024-83bd-b9c9ea951c25/Microsoft.VCLibs.x64.14.00.Desktop.appx"
    Install-WingetDependency "https://github.com/microsoft/microsoft-ui-xaml/releases/download/v2.8.6/Microsoft.UI.Xaml.2.8.x64.appx"
    Install-WingetDependency "https://github.com/microsoft/winget-cli/releases/latest/download/Microsoft.DesktopAppInstaller_8wekyb3d8bbwe.msixbundle"    
    Invoke-Expression -Command "echo y | winget list --accept-source-agreements" -ErrorAction Stop | Out-Null
    Write-Green "Winget foi devidamente atualizado e está pronto para o uso."
}

# ------------ INSTALAÇÃO DOS PACOTES ------------ #

function Install-WingetPackages {
    Write-Cyan "Iniciando a instalação de pacotes do Winget..."

    $count = 0

    foreach ($pkg in $PKGS) {
        $installed = Invoke-Expression -Command "winget list $pkg --accept-source-agreements"
        if ($installed -match ([regex]::Escape($pkg))) {
            Write-Yellow "$pkg já está instalado."
        }
        else {
            Write-Cyan "Instalando $pkg ..."
            Invoke-Expression -Command "winget install $pkg --accept-package-agreements --accept-source-agreements --no-upgrade -h" -ErrorAction SilentlyContinue
            
            if ($?) {
                Write-Green "O pacote $pkg foi instalado com sucesso!"
                $count++
            }
            else {
                Write-Warning -Message "Falha ao tentar instalar o pacote $pkg."               
            }
        }
    }

    Write-Green "Fim da instalação de pacotes."
    Write-Green "$count de $($PKGS.Count) pacotes foram instalados com sucesso."
}

function Disable-Superfetch {
    Set-Service -Name "SysMain" -StartupType Disabled
    Stop-Service -Force -Name "SysMain"
}

function Add-ExtrasPackages {
    $shanaUrl = "https://www.videohelp.com/download/ShanaEncoder6.0.1.7.exe"
    $codecUrl = "https://file.shana.pe.kr/lib/CodecLibrary.v1.2.x64.7z"
    $regUrl = "https://gist.githubusercontent.com/MuhammadSaim/de84d1ca59952cf1efaa8c061aab81a1/raw/ca31cbda01412e85949810d52d03573af281f826/rarreg.key"
    $cnPackUrl = "https://github.com/cnpack/cnwizards/releases/download/CNWIZARDS_1.3.1.1181_20240404/CnWizards_1.3.1.1181.exe"
    $shana = [System.IO.Path]::GetFileName($shanaUrl)
    $codecs = [System.IO.Path]::GetFileName($codecUrl)
    $cnPack = [System.IO.Path]::GetFileName($cnPackUrl)
    $shanaPath = Join-Path -Path $PSScriptRoot -ChildPath $shana
    $codecsPath = Join-Path -Path $PSScriptRoot -ChildPath $codecs  
    $cnPackPath = Join-Path -Path $PSScriptRoot -ChildPath $cnPack

    Write-Cyan "Iniciando a instalação de extras..."
    
    if (-not(Test-Path "C:\ShanaEncoder")) {        
        DownloadFileBitsTransfer -SourceUri $codec -DestinationPath $codecsPath
        DownloadFileBitsTransfer -SourceUri $url -DestinationPath $shanaPath
        Start-Process -FilePath $shana -Wait -NoNewWindow -ErrorAction SilentlyContinue | Out-Null
        Remove-Item -Path "C:\ShanaEncoder\presets\(Copy)\Stream Copy to AVI.xml" -Force
        Remove-Item -Path "C:\ShanaEncoder\presets\(Copy)\Stream Copy to MKV.xml" -Force
        Remove-Item -Path "C:\ShanaEncoder\presets\(Copy)\Stream Copy(TS, TP).xml" -Force
        Remove-Item -Path "C:\ShanaEncoder\presets\(Copy)\Stream Copy.xml" -Force
        
    }
    else {
        Write-Warning -Message "Shana Encoder já está instalado."
    }

    if (-not(Test-Path "C:\Program Files\WinRAR\rarreg.key")) {
        DownloadFileBitsTransfer -SourceUri $regUrl -DestinationPath $TempDir
        Copy-Item $TempDir\rarreg.key -Destination C:\Program Files\WinRAR -Force
    }
    else {
        Write-Warning -Message "Arquivo já existe."        
    }

    Write-Cyan "Instalando CNPACK Wizard"
    DownloadFileBitsTransfer -SourceUri $cnPackUrl -DestinationPath $TempDir
    Start-Process -FilePath $cnPackPath -Wait -NoNewWindow -ErrorAction SilentlyContinue | Out-Null    

    Write-Cyan "Dowload QuickLook Plugins"
    DownloadFileBitsTransfer -SourceUri "https://github.com/canheo136/QuickLook.Plugin.ApkViewer/releases/download/1.3.5/QuickLook.Plugin.ApkViewer.qlplugin" -DestinationPath "$env:USERPROFILE\Downloads"
    DownloadFileBitsTransfer -SourceUri "https://github.com/adyanth/QuickLook.Plugin.FolderViewer/releases/download/1.3/QuickLook.Plugin.FolderViewer.qlplugin" -DestinationPath "$env:USERPROFILE\Downloads"
    DownloadFileBitsTransfer -SourceUri "https://github.com/Cologler/QuickLook.Plugin.TorrentViewer/releases/download/0.2.1/QuickLook.Plugin.TorrentViewer.qlplugin" -DestinationPath "$env:USERPROFILE\Downloads"

    Write-Green "Fim da instalação de pacotes."
}

function Set-BitTorrentFolders {
    $bitTorrent = "D:\BitTorrent"
    $folders = @(, 'Compressed', 'Documents', 'Logs', 'Music', 'Programs', 'Temp', 'Torrents', 'Video')  

    if (-not(Test-Path $bitTorrent)) {
        New-Item -ItemType Directory $bitTorrent -Force
        foreach ($folder in $folders) {
            New-Item -ItemType Directory $bitTorrent\$folder -Force
        }
    }
}
function Set-IDMFolders {
    $idmDir = "D:\IDM"
    $folders = @(, 'Compressed', 'Documents', 'Music', 'Programs', 'Temp', 'Video', 'APK', 'ISO', 'General')  

    if (-not(Test-Path $idmDir)) {
        New-Item -ItemType Directory $idmDir -Force
        foreach ($folder in $folders) {
            New-Item -ItemType Directory $idmDir\$folder -Force
        }
    }
    else {
        Write-Warning -Message "Pastas já existem." 
    }
}

function Set-WinRARFolders {
    $rarDir = "D:\RAR"
    $folders = @(, 'Extracted', 'Output', 'Temp')  

    if (-not(Test-Path $rarDir)) {
        New-Item -ItemType Directory $rarDir -Force
        foreach ($folder in $folders) {
            New-Item -ItemType Directory $rarDir\$folder -Force
        }
    }
    else {
        Write-Warning -Message "Pastas já existem." 
    }
}

function Set-TelegramFolders {
    $kotatogramDir = "D:\Kotatogram Desktop"
    $telegramDir = "D:\Telegram Desktop"
    
    if (-not(Test-Path $kotatogramDir)) {
        New-Item -ItemType Directory $kotatogramDir -Force    
    }
    elseif (-not(Test-Path $telegramDir)) {
        New-Item -ItemType Directory $telegramDir -Force
    }
    else {
        Write-Warning -Message "Pastas já existem." 
    }
}

# ------------ EXECUÇÃO ------------ #

Set-ConfigSystem
Disable-Superfetch
Set-Wallpaper
Set-BitTorrentFolders
Set-IDMFolders
Set-WinRARFolders
Set-TelegramFolders
Install-Winget
Install-WingetPackages
Add-ExtrasPackages
Exit-Script

