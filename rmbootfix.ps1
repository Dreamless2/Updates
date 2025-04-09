Write-Host "-------------------------------------------------------------"
Write-Host "Note: Please enter the path without any spaces, for example:" -ForegroundColor Yellow
Write-Host "=> "C:\Windows Image\win11.iso" (Not working)" -ForegroundColor Red
Write-Host "=> "C:\WindowsImage\win11.iso" (Working)" -ForegroundColor Cyan
Write-Host "-------------------------------------------------------------"

$SourceISOPath = $(Write-Host -NoNewLine) + $(Write-Host "`nEnter the path to the source ISO file:" -ForegroundColor Green -NoNewLine; Read-Host)
$UnattendedISOPath = $(Write-Host -NoNewLine) + $(Write-Host "Enter the path to the destination ISO file:" -ForegroundColor Green -NoNewLine; Read-Host)

# Then we start processing the source ISO file
$SourceISOFullPath = ($SourceISOPath).trim('"')
$ADKPath = "${env:ProgramFiles(x86)}\Windows Kits\10"

try {
    Mount-DiskImage -ImagePath $SourceISOFullPath
} catch {
    Write-Host -ForegroundColor Yellow 'An error occured while mounting the source ISO file. It may be corrupt. Aborting...'
    exit
}

$iSOImage = Get-DiskImage -ImagePath $SourceISOFullPath | Get-Volume
$iSODrive = "$([string]$iSOImage.DriveLetter):"

# Test if we have enough memory on the current Windows drive to perform the operation (twice the size of the IS0)
    $ISOItem = Get-Item -Path $SourceISOFullPath
    $SystemDrive = Get-WmiObject Win32_LogicalDisk -filter "deviceid=""$env:SystemDrive"""

if (($ISOItem.Length * 2) -le $SystemDrive.FreeSpace) {
    Write-Host -ForegroundColor Green "The current system drive appears to have enough free space for the ISO conversion process."
} else {
    Write-Host -ForegroundColor Yellow "The current system drive does not appear to have enough free space for the ISO conversion process. Aborting..."
    exit
}

# Process the ISO content using a temporary folder on the local system drive
if (!(Test-Path -Path "$PSScriptRoot\sourceisotemp" -PathType Container)) {
    New-Item -Path "$PSScriptRoot\sourceisotemp" -ItemType Directory -Force | Out-Null
} else {
    Remove-Item -Path "$PSScriptRoot\sourceisotemp" -Force -Confirm:$false
    New-Item -Path "$PSScriptRoot\sourceisotemp" -ItemType Directory -Force | Out-Null
}

Write-Host -ForegroundColor Green "Extracting the content of the ISO file."
Get-ChildItem -Path $iSODrive | Copy-Item -Destination "$PSScriptRoot\sourceisotemp" -Recurse -Container -Force
Write-Host -ForegroundColor Green "The content of the ISO file has been extracted."

# Processing the extracted content
if (Test-Path -Path "$PSScriptRoot\sourceisotemp\boot\bootfix.bin" -PathType Leaf) {
    Remove-Item -Path "$PSScriptRoot\sourceisotemp\boot\bootfix.bin" -Force -Confirm:$false
}

$oscdimg = $ADKPath + "Assessment and Deployment Kit\Deployment Tools\amd64\Oscdimg\oscdimg.exe"
$etfsboot = $ADKPath + "Assessment and Deployment Kit\Deployment Tools\amd64\Oscdimg\etfsboot.com"
$efisys_noprompt = $ADKPath + "Assessment and Deployment Kit\Deployment Tools\amd64\Oscdimg\efisys_noprompt.bin"
$parameters = "-bootdata:2#p0,e,b""$etfsboot""#pEF,e,b""$efisys_noprompt"" -u1 -udfver102 ""$PSScriptRoot\sourceisotemp"" ""$UnattendedISOPath"""

$ProcessingResult = Start-Process -FilePath $oscdimg -ArgumentList $parameters -Wait -NoNewWindow -PassThru

if ($ProcessingResult.ExitCode -ne 0) {
    Write-Host -ForegroundColor Yellow "There was an error while creating the iso file."
} else {
    Write-Host -ForegroundColor Green "The content of the ISO has been repackaged in the new ISO file."
}

# Cleaning up
Remove-Item -Path "$PSScriptRoot\sourceisotemp" -Force -Recurse -Confirm:$false
Write-Host -ForegroundColor Green "The temp folder has been removed."

# Dismount the ISO file as we no longer require it
Dismount-DiskImage -ImagePath $SourceISOFullPath
Write-Host -ForegroundColor Green "The source ISO file has been unmounted."