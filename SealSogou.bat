@echo off
setlocal enabledelayedexpansion
title Sogou Input Bloatware Permanent Seal Tool

:: 1. Request Admin Privileges
%1 %2 mshta vbscript:createobject("shell.application").shellexecute("%~s0","goto :admin","","runas",1)(window.close)&goto :eof
:admin

echo ========================================================
echo       Sogou Input Bloatware Seal Script
echo ========================================================
echo.
echo Please enter the Sogou installation directory (Version Folder)
echo Example: D:\Input_Method\15.6.0.2020
echo.
set /p targetDir="Path: "

:: Remove quotes if user included them
set "targetDir=%targetDir:"=%"

if not exist "%targetDir%" (
    echo [Error] Path not found. Please check and try again.
    pause
    exit
)

cd /d "%targetDir%"

echo.
echo [1/3] Killing background processes...
taskkill /f /im SGSmartAssistant.exe /t >nul 2>&1
taskkill /f /im SGBizLauncher.exe /t >nul 2>&1
taskkill /f /im SGWangzai.exe /t >nul 2>&1
taskkill /f /im userNetSchedule.exe /t >nul 2>&1
taskkill /f /im PinyinUp.exe /t >nul 2>&1
taskkill /f /im SGDownload.exe /t >nul 2>&1
taskkill /f /im SogouCloud.exe /t >nul 2>&1
taskkill /f /im SGIGuideHelper.exe /t >nul 2>&1

echo.
echo [2/3] Locking down bloatware components...
echo Locking these files will prevent them from running or auto-repairing.

:: Blacklist of known bloatware/context menu injectors
set "blacklist=SGSmartAssistant.exe SGBizLauncher.exe SGWangzai.exe userNetSchedule.exe PinyinUp.exe SGDownload.exe SogouToolkits.exe sogou_torrent.dll SGMiniBrowserHelperHost.dll RightPopmenu.cupf SGIGuideHelper.exe SGWebRender.exe"

for %%f in (%blacklist%) do (
    if exist "%%f" (
        echo Sealing: %%f
        :: 1. Take ownership
        takeown /f "%%f" /a >nul 2>&1
        :: 2. Reset and disable inheritance
        icacls "%%f" /reset >nul 2>&1
        icacls "%%f" /inheritance:r >nul 2>&1
        :: 3. Deny EVERYONE all access (Full Control)
        icacls "%%f" /deny Everyone:(F) >nul 2>&1
    ) else (
        echo Skipping (Not Found): %%f
    )
)

echo.
echo [3/3] Cleaning Registry residues (Context Menu)...
reg delete "HKEY_CURRENT_USER\Software\Classes\Directory\Background\shell\SogouWallpaper" /f >nul 2>&1
reg delete "HKEY_CLASSES_ROOT\Directory\Background\shellex\ContextMenuHandlers\SogouWallpaper" /f >nul 2>&1

echo.
echo ========================================================
echo Operation Successful!
echo These bloatware files are now "Zombies" (Exist but cannot run).
echo.
echo Please restart Windows Explorer or your PC to clear the menu.
echo ========================================================
pause
