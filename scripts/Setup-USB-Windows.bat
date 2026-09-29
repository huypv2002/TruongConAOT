@echo off
chcp 65001 >nul
title Setup Ventoy USB Tool (Windows)
color 0A

echo ======================================================================
echo                  SETUP VENTOY USB FOR WINDOWS 11 AUTO
echo ======================================================================
echo.
echo Kịch bản này sẽ tự động sao chép các file cấu hình, kịch bản tự động,
echo giao diện theme, và bộ cài Office vào USB Ventoy của bạn.
echo.

set /p USB_DRIVE="Nhập ký tự ổ đĩa USB của bạn (Ví dụ: E hoặc F): "

if "%USB_DRIVE%"=="" (
    echo [ERROR] Bạn chưa nhập ký tự ổ đĩa!
    pause
    exit /b 1
)

set TARGET=%USB_DRIVE:~0,1%:

if not exist "%TARGET%\" (
    echo [ERROR] Ổ đĩa %TARGET% không tồn tại! Vui lòng kiểm tra lại.
    pause
    exit /b 1
)

echo.
echo [*] Đang sao chép thư mục ventoy vào %TARGET%\ventoy ...
if not exist "%TARGET%\ventoy" mkdir "%TARGET%\ventoy"
xcopy /E /I /Y "%~dp0..\ventoy" "%TARGET%\ventoy"

echo.
echo [*] Đang sao chép thư mục scripts vào %TARGET%\ventoy\scripts ...
if not exist "%TARGET%\ventoy\scripts" mkdir "%TARGET%\ventoy\scripts"
xcopy /E /I /Y "%~dp0" "%TARGET%\ventoy\scripts"

echo.
echo [*] Đang sao chép thư mục office vào %TARGET%\ventoy\office ...
if not exist "%TARGET%\ventoy\office" mkdir "%TARGET%\ventoy\office"
xcopy /E /I /Y "%~dp0..\office" "%TARGET%\ventoy\office"

echo.
echo ======================================================================
echo [THÀNH CÔNG] Đã sao chép cấu hình tự động vào USB thành công!
echo.
echo BƯỚC TIẾP THEO:
echo 1. Hãy tải file ISO Windows 11 chính hãng từ Microsoft.
echo 2. Đổi tên file thành Win11.iso rồi chép vào thư mục gốc của %TARGET%\
echo 3. Cắm USB vào máy tính, khởi động lại và chọn boot USB (Phím F9 trên HP)!
echo ======================================================================
echo.
pause
