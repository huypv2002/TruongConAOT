# ==============================================================================
# TRUONG CON AOT - WINDOWS 11 SYSTEM OPTIMIZATION ENGINE
# ==============================================================================
#Requires -RunAsAdministrator

[CmdletBinding()]
param()

$Host.UI.RawUI.WindowTitle = "TRUONG CON AOT - Windows 11 Optimization"
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

Write-Host ""
Write-Host " ======================================================================" -ForegroundColor Cyan
Write-Host "             TRUONG CON AOT - WINDOWS 11 SYSTEM TUNING" -ForegroundColor Green
Write-Host "         Tối Ưu Giao Diện, Hiệu Năng & Đăng Ký Thương Hiệu OEM         " -ForegroundColor Yellow
Write-Host " ======================================================================" -ForegroundColor Cyan
Write-Host ""

# 1. FILE EXPLORER
Write-Host "[1/6] Tinh chỉnh File Explorer..." -ForegroundColor Yellow
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "HideFileExt" -Value 0 -Type DWord -Force
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "LaunchTo" -Value 1 -Type DWord -Force
Write-Host "  - Hiển thị đuôi phần mở rộng tệp tin" -ForegroundColor Green
Write-Host "  - Khởi động File Explorer trực tiếp vào This PC" -ForegroundColor Green

# 2. TASKBAR & START MENU
Write-Host "[2/6] Tinh chỉnh Taskbar & Start Menu..." -ForegroundColor Yellow
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "TaskbarAl" -Value 0 -Type DWord -Force
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced\TaskbarDeveloperSettings" -Name "TaskbarEndTask" -Value 1 -Type DWord -Force -ErrorAction SilentlyContinue
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "TaskbarDa" -Value 0 -Type DWord -Force
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "ShowTaskViewButton" -Value 0 -Type DWord -Force
New-Item -Path "HKCU:\Software\Policies\Microsoft\Windows\Explorer" -Force -ErrorAction SilentlyContinue | Out-Null
Set-ItemProperty -Path "HKCU:\Software\Policies\Microsoft\Windows\Explorer" -Name "DisableSearchBoxSuggestions" -Value 1 -Type DWord -Force
Write-Host "  - Căn lề Taskbar sang trái" -ForegroundColor Green
Write-Host "  - Bật lệnh 'End Task' khi chuột phải vào ứng dụng ở Taskbar" -ForegroundColor Green
Write-Host "  - Tắt Widget thời tiết & tin tức rác" -ForegroundColor Green
Write-Host "  - Tắt quảng cáo Bing trên Start Menu" -ForegroundColor Green

# 3. GỠ BỎ BLOATWARE (Ứng dụng rác cài sẵn)
Write-Host "[3/6] Dọn dẹp bloatware mặc định của Windows 11..." -ForegroundColor Yellow
$junkApps = @(
    "*CandyCrush*", "*TikTok*", "*Instagram*", "*Facebook*", "*Spotify*",
    "*Disney*", "*Clipchamp*", "*MicrosoftTeams*", "*SolitaireCollection*"
)
foreach ($app in $junkApps) {
    Get-AppxPackage -Name $app -AllUsers -ErrorAction SilentlyContinue | Remove-AppxPackage -AllUsers -ErrorAction SilentlyContinue
}
Write-Host "  - Đã gỡ bỏ sạch sẽ các ứng dụng rác tài trợ" -ForegroundColor Green

# 4. GIAO DIỆN TỐI & HIỆU NĂNG CAO
Write-Host "[4/6] Kích hoạt Dark Mode & High Performance Plan..." -ForegroundColor Yellow
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize" -Name "AppsUseLightTheme" -Value 0 -Type DWord -Force
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize" -Name "SystemUsesLightTheme" -Value 0 -Type DWord -Force
powercfg -duplicatescheme 8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c 2>$null | Out-Null
powercfg -setactive 8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c 2>$null | Out-Null
Write-Host "  - Đã bật giao diện tối (Dark Mode)" -ForegroundColor Green
Write-Host "  - Đã kích hoạt chế độ nguồn hiệu năng cao (High Performance)" -ForegroundColor Green

# 5. BẢO MẬT & QUYỀN RIÊNG TƯ
Write-Host "[5/6] Tối ưu hóa quyền riêng tư..." -ForegroundColor Yellow
New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection" -Force -ErrorAction SilentlyContinue | Out-Null
Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection" -Name "AllowTelemetry" -Value 0 -Type DWord -Force
New-Item -Path "HKLM:\SYSTEM\CurrentControlSet\Control\BitLocker" -Force -ErrorAction SilentlyContinue | Out-Null
Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\BitLocker" -Name "PreventDeviceEncryption" -Value 1 -Type DWord -Force
Write-Host "  - Đã tắt dịch vụ thu thập dữ liệu (Telemetry)" -ForegroundColor Green
Write-Host "  - Đã vô hiệu hóa tính năng tự động khóa BitLocker" -ForegroundColor Green

# 6. ĐĂNG KÝ THƯƠNG HIỆU TRUONG CON AOT VÀO HỆ THỐNG
Write-Host "[6/6] Ghi nhận thương hiệu Truong Con AOT vào Windows Settings / System About..." -ForegroundColor Yellow
try {
    New-Item -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\OEMInformation" -Force -ErrorAction SilentlyContinue | Out-Null
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\OEMInformation" -Name "Manufacturer" -Value "Truong Con AOT" -Type String -Force
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\OEMInformation" -Name "Model" -Value "Truong Con AOT Ultimate Edition" -Type String -Force
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\OEMInformation" -Name "SupportURL" -Value "https://github.com/huypv2002/TruongConAOT" -Type String -Force
    Write-Host "  [✓] Đã đăng ký thông tin hệ thống OEM: Truong Con AOT" -ForegroundColor Green
} catch {
    Write-Host "  [-] Bỏ qua đăng ký OEM." -ForegroundColor DarkGray
}

# Khởi động lại Explorer để áp dụng
Stop-Process -Name explorer -Force -ErrorAction SilentlyContinue
Start-Sleep -Seconds 1
Start-Process explorer.exe

Write-Host ""
Write-Host "  [✓] Tinh chỉnh hệ thống Truong Con AOT hoàn tất!" -ForegroundColor Green

