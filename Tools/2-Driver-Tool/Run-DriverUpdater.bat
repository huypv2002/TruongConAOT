@echo off
chcp 65001 >nul
title TRUONG CON AOT - DRIVER ENGINE LAUNCHER
color 0B

:: Yêu cầu quyền Administrator
net session >nul 2>&1
if %errorLevel% neq 0 (
    echo [INFO] Đang yêu cầu quyền Administrator để cập nhật Driver...
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
echo              TRUONG CON AOT - TOOL 2: DRIVER ENGINE
echo              Quét, Cập Nhật & Cài Đặt Driver Tự Động
echo  ======================================================================
echo.
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0driver-engine.ps1"
