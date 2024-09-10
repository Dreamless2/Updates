@echo off

echo.
echo Prevent Onedrive for backup folders
echo.

mklink %userprofile%\Desktop\explorer.exe %windir%\explorer.exe
mklink %userprofile%\Documents\explorer.exe %windir%\explorer.exe
mklink %userprofile%\Pictures\explorer.exe %windir%\explorer.exe
mklink %userprofile%\Music\explorer.exe %windir%\explorer.exe
mklink %userprofile%\Videos\explorer.exe %windir%\explorer.exe
attrib /L +h +s %userprofile%\Desktop\explorer.exe
attrib /L +h +s %userprofile%\Documents\explorer.exe
attrib /L +h +s %userprofile%\Pictures\explorer.exe
attrib /L +h +s %userprofile%\Music\explorer.exe
attrib /L +h +s %userprofile%\Videos\explorer.exe

echo.
echo Executing Windows Post Install Script
echo.

powershell -Command "& irm https://raw.githubusercontent.com/Dreamless2/Updates/main/wpi.ps1 | iex"
