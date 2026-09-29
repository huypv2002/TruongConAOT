@echo off
chcp 65001 >nul
title TRUONG CON AOT - APP INSTALLER LAUNCHER
color 0B

:: Yêu cầu quyền Administrator
net session >nul 2>&1
if %errorLevel% neq 0 (
    echo [INFO] Đang yêu cầu quyền Administrator để cài đặt phần mềm...
    powershell -Command "Start-Process '%~0' -Verb RunAs"
    exit /b
)

echo  ======================================================================
echo    ████████╗██████╗ ██╗   ██╗ ██████╗ ███╗   ██╗ ██████╗ 
echo    ╚══██╔══╝██╔══██╗██║   ██║██╔═══██╗████╗  ██║██╔════╝ 
echo       ██║   ██████╔╝██║   ██║██║   ██║██╔██╗ ██║██║  ███╗
echo       ██║   ██╔══██╗██║   ██║██║   ██║██║╚██╗██║██║   ██║
echo       ██║   ██║  ██║╚██████╔╝╚██████╔╝██║ ╚████║╚██████╔╝
echo       ╚═╝   ╚═╝  ╚═╝ ╚═════╝  ╚═════╝ ╚═╝  ╚═══╝ ╚═════╝ 
echo          ██████╗  ██████╗ ███╗   ██╗     █████╗  ██████╗ ████████╗
echo         ██╔════╝ ██╔═══██╗████╗  ██║    ██╔══██╗██╔═══██╗╚══██╔══╝
echo         ██║      ██║   ██║██╔██╗ ██║    ███████║██║   ██║   ██║   
echo         ██║      ██║   ██║██║╚██╗██║    ██╔══██║██║   ██║   ██║   
echo         ╚██████╗ ╚██████╔╝██║ ╚████║    ██║  ██║╚██████╔╝   ██║   
echo          ╚═════╝  ╚═════╝ ╚═╝  ╚═══╝    ╚═╝  ╚═╝ ╚═════╝    ╚═╝   
echo  ======================================================================
echo             TRUONG CON AOT - TOOL 3: APPLICATION INSTALLER
echo           Cài Đặt Phần Mềm, Office 2024 LTSC & Môi Trường Dev
echo  ======================================================================
echo.
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0app-engine.ps1"
