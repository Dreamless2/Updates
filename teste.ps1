$TempDir = "$env:TEMP"

Start-BitsTransfer -Source "https://raw.githubusercontent.com/Dreamless2/Updates/main/DS_PowerShell_Function_Library.psm1" -Destination $TempDir

if (Test-Path -Path "$TempDir\DS_PowerShell_Function_Library.psm1") {
    Import-Module "$TempDir\DS_PowerShell_Function_Library.psm1"
}

DS_ClearPrefetchFolder

$url = "https://github.com/adoptium/temurin21-binaries/releases/download/jdk-21.0.4%2B7/OpenJDK21U-jdk_x64_windows_hotspot_21.0.4_7.msi"
$filename = [System.IO.Path]::GetFileName($url)
$filePath = Join-Path $TempDir $filename
Start-BitsTransfer -Source $url -Destination $TempDir
DS_InstallOrUninstallSoftware -File $filePath -Installationtype "Install" -Arguments "ADDLOCAL=FeatureMain,FeatureEnvironment,FeatureJarFileRunWith,FeatureJavaHome"
