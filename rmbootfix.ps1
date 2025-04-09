$rmbootPath = "$env:USERPROFILE\Downloads\rmbootfix"
$logs = "$rmbootPath\rmbootfix.log"
$SourceISOTemp = "$rmbootPath\SourceISOTemp"
$bootPath = "$SourceISOTemp\boot"
$oscdimgPath = "$rmbootPath\Oscdimg"

$NektaModule = "$env:TEMP\Nekta.psm1"

Invoke-WebRequest -Uri "https://raw.githubusercontent.com/Dreamless2/Updates/refs/heads/main/Nekta.psm1" -OutFile $NektaModule

Import-Module $NektaModule -Force

if (Test-Path -Path $rmbootPath) {    
    Nekta_WipeDirectory -D $rmbootPath
}
else {
    Nekta_NewDirectory -D $rmbootPath
}


$oscdUrl = "https://github.com/Dreamless2/Updates/releases/download/youpdates/oscdimg-amd64.zip"
$oscdPath = [System.IO.Path]::GetFileName($oscdUrl)
$oscdFullPath = Join-Path -Path $rmbootPath $oscdPath

Nekta_Logging "I" "Download the OSCDIMG zip file." -LogFile $logs
Nekta_NovaDownloader -U "https://github.com/Dreamless2/Updates/releases/download/youpdates/oscdimg-amd64.zip" -D $rmbootPath

Nekta_Logging "I" "Extracting the OSCDIMG." -LogFile $logs
Nekta_UnzipArchive -F $oscdFullPath -D $rmbootPath -P

$SourceISOPath = $(Write-Host -NoNewLine) + $(Write-Host "`nEnter the path to the source ISO file:" -ForegroundColor Green -NoNewLine; Read-Host)
$UnattendedISOPath = $(Write-Host -NoNewLine) + $(Write-Host "Enter the path to the destination ISO file:" -ForegroundColor Green -NoNewLine; Read-Host)
$SourceISOFullPath = ($SourceISOPath).trim('"')

if (!(Test-Path -Path $UnattendedISOPath)) {
    Nekta_NewDirectory -D $UnattendedISODirectory
}

try {
    Mount-DiskImage -ImagePath $SourceISOFullPath
}
catch {    
    Nekta_Logging "E" "An error occured while mounting the source ISO file. It may be corrupt. Aborting..." -LogFile $logs
    exit
}

$ISOImage = Get-DiskImage -ImagePath $SourceISOFullPath | Get-Volume
$ISODrive = "$([string]$ISOImage.DriveLetter):"

if (!(Test-Path -Path $SourceISOTemp)) {
    Nekta_NewDirectory -D $SourceISOTemp
}
else {
    Nekta_WipeDirectory -D $SourceISOTemp
    Nekta_NewDirectory -D $SourceISOTemp
}

Nekta_Logging "I" "Extracting the content of the ISO file." -LogFile $logs

Nekta_CopyWithProgress -S $ISODrive -D $SourceISOTemp

Nekta_Logging "I" "The content of the ISO file has been extracted." -LogFile $logs

if (Test-Path -Path "$bootPath\bootfix.bin") {
    Nekta_DeleteFile -F "$bootPath\bootfix.bin"
}

$oscdimg = "$rmbootPath\oscdimg.exe"
$etfsboot = "$rmbootPath\etfsboot.com"
$efisys_noprompt = "$rmbootPath\efisys_noprompt.bin"
$parameters = " -m -o -u2 -udfver102 -bootdata:2#p0,e,b""$etfsboot""#pEF,e,b""$efisys_noprompt"" -u1 -udfver102 ""$SourceISOTemp"" ""$UnattendedISOPath"""

$ProcessingResult = Nekta_RunProcess -P $oscdimg -A $parameters

if ($ProcessingResult.ExitCode -ne 0) {
    Nekta_Logging "E" "There was an error while creating the iso file." -LogFile $logs
}
else {
    Nekta_Logging "I" "The content of the ISO has been repackaged in the new ISO file." -LogFile $logs
}

Nekta_WipeDirectory -D $SourceISOTemp

Dismount-DiskImage -ImagePath $SourceISOFullPath
Nekta_Logging "I" "The source ISO file has been unmounted." -LogFile $logs