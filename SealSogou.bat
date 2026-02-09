@echo off
setlocal enabledelayedexpansion
title Sogou Bloatware Permanent Seal Tool v2.0

:: 1. 健壮的提权逻辑：解决带空格路径崩溃问题
:check_admin
net session >nul 2>&1
if %errorLevel% neq 0 (
    echo [Info] Requesting Administrator Privileges...
    powershell -Command "Start-Process -FilePath '%~0' -Verb RunAs"
    exit /b
)

echo ========================================================
echo       Sogou Input Bloatware Seal Script (Optimized)
echo ========================================================
echo.
set /p targetDir="Please paste Sogou version directory: "
set "targetDir=%targetDir:"=%"

if not exist "%targetDir%" (
    echo [Error] Path not found: "%targetDir%"
    pause & exit
)

cd /d "%targetDir%"

echo.
echo [1/3] Terminating persistent processes...
:: 使用循环强制多次尝试，确保进程完全释放
set "procs=SGSmartAssistant.exe SGBizLauncher.exe SGWangzai.exe userNetSchedule.exe PinyinUp.exe SGDownload.exe SogouCloud.exe SGIGuideHelper.exe"
for %%p in (%procs%) do (
    taskkill /f /im %%p /t >nul 2>&1
)

echo.
echo [2/3] Sealing components (Zombification)...
:: 关键修改：仅禁用执行权限(X)，避免锁定读取导致脚本后续报错
set "blacklist=SGSmartAssistant.exe SGBizLauncher.exe SGWangzai.exe userNetSchedule.exe PinyinUp.exe SGDownload.exe SogouToolkits.exe sogou_torrent.dll SGMiniBrowserHelperHost.dll RightPopmenu.cupf SGIGuideHelper.exe SGWebRender.exe"

for %%f in (%blacklist%) do (
    if exist "%%f" (
        echo Sealing: %%f
        :: 夺取所有权
        takeown /f "%%f" /a >nul 2>&1
        :: 重置权限并禁用继承
        icacls "%%f" /reset >nul 2>&1
        icacls "%%f" /inheritance:r >nul 2>&1
        :: 拒绝所有人执行权限 (RX)
        icacls "%%f" /deny *S-1-1-0:(X) >nul 2>&1
        if %errorLevel% equ 0 (echo [Success] %%f is now a zombie.) else (echo [Failed] %%f could not be locked.)
    )
)

echo.
echo [3/3] Cleaning Context Menu Registry...
reg delete "HKEY_CURRENT_USER\Software\Classes\Directory\Background\shell\SogouWallpaper" /f >nul 2>&1
reg delete "HKEY_CLASSES_ROOT\Directory\Background\shellex\ContextMenuHandlers\SogouWallpaper" /f >nul 2>&1

echo.
echo ========================================================
echo Done! All selected bloatware is now permanently disabled.
echo If you update Sogou, you may need to run this again.
echo ========================================================
pause
