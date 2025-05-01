$AppDir = $PSScriptRoot
$LogFile = "$AppDir\spotdl\spotdl.log"
$spotdlUrl = "https://github.com/spotDL/spotify-downloader/releases/download/v4.2.10/spotdl-4.2.10-win32.exe" 
$spotdlName = [System.IO.Path]::GetFileName($spotdlUrl)
$spotdlPath = Join-Path -Path $AppDir $spotdlName

if (-not(Test-Path -Path $spotdlPath)) {
    Start-BitsTransfer -Source $spotdlUrl -Destination $AppDir
    Start-BitsTransfer -Source "https://github.com/Nexxis20/Updates/releases/download/crd/ffmpeg.exe"
}

$NektaModule = "$env:TEMP\Nekta.psm1"

function Nekta_Spotify {
    [CmdletBinding()]
    param (
        [Alias("U")]
        [Parameter(Mandatory = $true, Position = 0)]
        [string] $Url,        
        [Alias("O")]
        [Parameter(Mandatory = $false, Position = 1)]
        [AllowEmptyString()]
        [string]$OutputFormat = "m4a",
        [Alias("T")]
        [Parameter(Mandatory = $false, Position = 2)]
        [AllowEmptyString()]
        [string]$Templates = "n"
    )
    
    begin {
        [string]$FunctionName = $PSCmdlet.MyInvocation.MyCommand.Name  
        Nekta_Logging INFO "START FUNCTION - $FunctionName" $LogFile     
    }
    
    process {               
        if ([string]::IsNullOrEmpty($OutputFormat)) {
            $OutputFormat = "m4a"
        }            
     
        if ([string]::IsNullOrEmpty($Templates)) {
            $Templates = "n"
        }        
        
        if ($Templates -eq "y") {
            Nekta_Logging INFO "Baixando arquivos do spotify e organizando por albuns" $LogFile          
            Nekta_RunProcess -F $spotdlPath -A "download $Url --format $OutputFormat --output ""{artist}/{album}/{title} - {artist}.{output-ext}"" --audio youtube youtube-music soundcloud bandcamp --lyrics genius musixmatch azlyrics --bitrate 128k"                                     
        }
        else {
            Nekta_Logging INFO "Baixando arquivos do spotify sem organizar por albuns" $LogFile                   
            Nekta_RunProcess -F $spotdlPath -A "download $Url --format $OutputFormat --audio youtube youtube-music soundcloud bandcamp --lyrics genius musixmatch azlyrics --bitrate 128k"              
        }                     
    }         
    
    end {
        Nekta_Logging INFO "END FUNCTION - $FunctionName" $LogFile
    }
}

function Show-Menu {    
    Clear-Host
    Write-Host "**************************************************************************************************" -ForegroundColor DarkBlue   
    Write-Host "*                                      Spotify Downloader                                        *" -ForegroundColor DarkBlue   
    Write-Host "**************************************************************************************************" -ForegroundColor DarkBlue  
    Write-Host ""   
    Write-Host "1: '1' para baixar do spotify no formato m4a diretamente sem organizar por albuns" -ForegroundColor Green
    Write-Host "2: '2' para baixar do spotify no formato m4a diretamente organizando por albuns" -ForegroundColor Yellow
    Write-Host "Q: 'Q' para sair."  -ForegroundColor Red      
}

do {
    Show-Menu
    $selection = Read-Host "Escolha abaixo" 
    switch ($selection) {
        '1' {
            Clear-Host
            Nekta_Logging INFO "Baixando no formato m4a sem organizar por albuns..." $LogFile
            $url = Read-Host -Prompt "Informe os links do spotify"          
            Nekta_Spotify -U $url -T "n"
        }      
        '2' {
            Clear-Host
            Nekta_Logging INFO "Baixando no formato m4a e organizando por albuns..." $LogFile
            $url = Read-Host -Prompt "Informe os links do spotify"          
            Nekta_Spotify -U $url -T "y"
        }              
    }
    pause
}
until ($selection -eq 'q')

Show-Menu
