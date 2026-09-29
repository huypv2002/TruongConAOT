@echo off
chcp 65001 >nul
title TRUONG CON AOT - USB SETUP TOOLKIT
color 0B

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
echo                   TRUONG CON AOT - USB SETUP TOOLKIT
echo         Hệ Thống Tự Động Hóa Cài Win 11, Driver & Môi Trường Dev
echo  ======================================================================
echo.
echo  Bộ công cụ gồm 3 module độc lập được đồng bộ vào USB:
echo    [+] [Tool 1] Hệ thống Cài Win 11 Tự Động (Ventoy + Unattend XMLs)
echo    [+] [Tool 2] Cập Nhật & Cài Đặt Driver Tự Động (SDI Offline + WinUpdate)
echo    [+] [Tool 3] Cài Đặt Ứng Dụng, Office 2024 LTSC & Môi Trường Lập Trình
echo.

set /p USB_DRIVE=">> Nhập ký tự ổ đĩa USB của bạn (Ví dụ: E hoặc F): "

if "%USB_DRIVE%"=="" (
    echo [ERROR] Bạn chưa nhập ký tự ổ đĩa!
    pause
    exit /b 1
)

set TARGET=%USB_DRIVE:~0,1%:

if not exist "%TARGET%\" (
    echo [ERROR] Ổ đĩa %TARGET% không tồn tại! Vui lòng cắm USB và kiểm tra lại.
    pause
    exit /b 1
)

echo.
echo [*] [1/3] Đang sao chép Tool 1 (Ventoy Boot & Unattend) vào %TARGET%\ventoy ...
if not exist "%TARGET%\ventoy" mkdir "%TARGET%\ventoy"
xcopy /E /I /Y "%~dp0ventoy" "%TARGET%\ventoy"

echo.
echo [*] [2/3] Đang sao chép Tool 2 (Driver Updater) vào %TARGET%\Tools\2-Driver-Tool ...
if not exist "%TARGET%\Tools\2-Driver-Tool" mkdir "%TARGET%\Tools\2-Driver-Tool"
xcopy /E /I /Y "%~dp0Tools\2-Driver-Tool" "%TARGET%\Tools\2-Driver-Tool"

echo.
echo [*] [3/3] Đang sao chép Tool 3 (App Installer) vào %TARGET%\Tools\3-App-Tool ...
if not exist "%TARGET%\Tools\3-App-Tool" mkdir "%TARGET%\Tools\3-App-Tool"
xcopy /E /I /Y "%~dp0Tools\3-App-Tool" "%TARGET%\Tools\3-App-Tool"

echo.
echo  ======================================================================
echo   [THÀNH CÔNG] ĐÃ ĐỒNG BỘ TRỌN BỘ CÔNG CỤ TRUONG CON AOT VÀO USB (%TARGET%)!
echo  ======================================================================
echo.
echo  QUY TRÌNH SỬ DỤNG:
echo   1. Tải file Win11.iso chép vào thư mục gốc %TARGET%\
echo   2. [TOOL 1]: Cắm USB boot vào máy cần cài để chạy cài Win tự động.
echo   3. [TOOL 2]: Vào Win, mở USB -^> Tools\2-Driver-Tool -^> Run-DriverUpdater.bat
echo   4. [TOOL 3]: Mở USB -^> Tools\3-App-Tool -^> Run-AppInstaller.bat
echo  ======================================================================
echo.
pause
