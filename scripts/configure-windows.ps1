# ==============================================================================
# AutoInstaller - Module Tinh Chỉnh & Tối Ưu Hệ Thống Windows 11
# ==============================================================================
#Requires -RunAsAdministrator

[CmdletBinding()]
param()

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$IniPath = Join-Path $ScriptDir "configure-windows.ini"

function Parse-Ini ($path) {
    $ini = @{}
    $section = "general"
    if (-not (Test-Path $path)) { return $ini }
    Get-Content $path | ForEach-Object {
        $line = $_.Trim()
        if ($line.StartsWith(";") -or $line.StartsWith("#") -or [string]::IsNullOrWhiteSpace($line)) { return }
        if ($line.StartsWith("[") -and $line.EndsWith("]")) {
            $section = $line.Substring(1, $line.Length - 2).ToLower()
            if (-not $ini.ContainsKey($section)) { $ini[$section] = @{} }
        } elseif ($line.Contains("=")) {
            $parts = $line -split "=", 2
            $k = $parts[0].Trim().ToLower()
            $v = $parts[1].Trim()
            if (-not $ini.ContainsKey($section)) { $ini[$section] = @{} }
            $ini[$section][$k] = $v
        }
    }
    return $ini
}

$Cfg = Parse-Ini $IniPath
Write-Host ""
Write-Host "======================================================================" -ForegroundColor Cyan
Write-Host "                WINDOWS 11 SYSTEM CONFIGURATION ENGINE                " -ForegroundColor Green
Write-Host "======================================================================" -ForegroundColor Cyan
Write-Host ""

# 1. FILE EXPLORER
Write-Host "[1/5] Tinh chỉnh File Explorer..." -ForegroundColor Yellow
if ($Cfg.explorer.show_extensions -eq "true") {
    Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "HideFileExt" -Value 0 -Type DWord -Force
    Write-Host "  - Hiển thị đuôi phần mở rộng tệp tin" -ForegroundColor Green
}
if ($Cfg.explorer.launch_to -eq "thispc") {
    Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "LaunchTo" -Value 1 -Type DWord -Force
    Write-Host "  - Khởi động File Explorer trực tiếp vào This PC" -ForegroundColor Green
}

# 2. TASKBAR & START MENU
Write-Host "[2/5] Tinh chỉnh Taskbar & Start Menu..." -ForegroundColor Yellow
if ($Cfg.taskbar.alignment -eq "left") {
    Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "TaskbarAl" -Value 0 -Type DWord -Force
    Write-Host "  - Căn lề Taskbar sang trái" -ForegroundColor Green
}
if ($Cfg.taskbar.end_task -eq "true") {
    Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced\TaskbarDeveloperSettings" -Name "TaskbarEndTask" -Value 1 -Type DWord -Force -ErrorAction SilentlyContinue
    Write-Host "  - Kích hoạt lệnh 'End Task' trên chuột phải Taskbar" -ForegroundColor Green
}
if ($Cfg.taskbar.widgets -eq "false") {
    Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "TaskbarDa" -Value 0 -Type DWord -Force
    Write-Host "  - Tắt thanh thông tin thời tiết & tin tức rác (Widgets)" -ForegroundColor Green
}
if ($Cfg.taskbar.taskview -eq "false") {
    Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "ShowTaskViewButton" -Value 0 -Type DWord -Force
    Write-Host "  - Ẩn nút Task View" -ForegroundColor Green
}
if ($Cfg.start_menu.disable_bing_search -eq "true") {
    New-Item -Path "HKCU:\Software\Policies\Microsoft\Windows\Explorer" -Force -ErrorAction SilentlyContinue | Out-Null
    Set-ItemProperty -Path "HKCU:\Software\Policies\Microsoft\Windows\Explorer" -Name "DisableSearchBoxSuggestions" -Value 1 -Type DWord -Force
    Write-Host "  - Tắt quảng cáo Bing trong tìm kiếm Start Menu" -ForegroundColor Green
}

# 3. DEBLOAT (Gỡ bỏ app rác)
Write-Host "[3/5] Gỡ bỏ bloatware mặc định..." -ForegroundColor Yellow
if ($Cfg.debloat.remove_bloatware -eq "true") {
    $junkApps = @(
        "*CandyCrush*", "*TikTok*", "*Instagram*", "*Facebook*", "*Spotify*",
        "*Disney*", "*Clipchamp*", "*MicrosoftTeams*", "*SolitaireCollection*"
    )
    foreach ($app in $junkApps) {
        Get-AppxPackage -Name $app -AllUsers -ErrorAction SilentlyContinue | Remove-AppxPackage -AllUsers -ErrorAction SilentlyContinue
    }
    Write-Host "  - Đã dọn dẹp sạch sẽ các ứng dụng rác cài sẵn" -ForegroundColor Green
}

# 4. SYSTEM & PRIVACY
Write-Host "[4/5] Tối ưu hóa hệ thống & Quyền riêng tư..." -ForegroundColor Yellow
if ($Cfg.system.enable_dark_mode -eq "true") {
    Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize" -Name "AppsUseLightTheme" -Value 0 -Type DWord -Force
    Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize" -Name "SystemUsesLightTheme" -Value 0 -Type DWord -Force
    Write-Host "  - Kích hoạt giao diện tối (Dark Mode)" -ForegroundColor Green
}
if ($Cfg.system.disable_telemetry -eq "true") {
    New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection" -Force -ErrorAction SilentlyContinue | Out-Null
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection" -Name "AllowTelemetry" -Value 0 -Type DWord -Force
    Write-Host "  - Tắt dịch vụ thu thập dữ liệu theo dõi (Diagnostics & Telemetry)" -ForegroundColor Green
}
if ($Cfg.system.disable_bitlocker -eq "true") {
    New-Item -Path "HKLM:\SYSTEM\CurrentControlSet\Control\BitLocker" -Force -ErrorAction SilentlyContinue | Out-Null
    Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\BitLocker" -Name "PreventDeviceEncryption" -Value 1 -Type DWord -Force
    Write-Host "  - Ngăn chặn BitLocker tự động khóa ổ đĩa" -ForegroundColor Green
}
if ($Cfg.system.enable_performance_plan -eq "true") {
    # Kích hoạt High Performance Power Scheme
    powercfg -duplicatescheme 8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c 2>$null | Out-Null
    powercfg -setactive 8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c 2>$null | Out-Null
    Write-Host "  - Kích hoạt chế độ nguồn hiệu năng cao (High Performance)" -ForegroundColor Green
}

# 5. KHỞI ĐỘNG LẠI EXPLORER
Write-Host "[5/5] Áp dụng các thay đổi..." -ForegroundColor Yellow
Stop-Process -Name explorer -Force -ErrorAction SilentlyContinue
Start-Sleep -Seconds 1
Start-Process explorer.exe

Write-Host ""
Write-Host "[OK] Quá trình cấu hình và tối ưu Windows 11 hoàn tất thành công!" -ForegroundColor Green
exit 0
