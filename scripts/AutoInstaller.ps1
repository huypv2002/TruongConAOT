# ==============================================================================
# AutoInstaller - Windows 11 Post-Installation Automation Engine
# ==============================================================================
#Requires -RunAsAdministrator

$Host.UI.RawUI.WindowTitle = "AutoInstaller - Live Log"
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$IniFile = Join-Path $ScriptDir "config.ini"
$StartTime = Get-Date

# Banner phong cách Terminal trong clip
Write-Host ""
Write-Host "======================================================================" -ForegroundColor Cyan
Write-Host "                       AUTOINSTALLER - LIVE LOG                       " -ForegroundColor Green
Write-Host "                   Windows 11 Post-Install Engine                     " -ForegroundColor DarkGray
Write-Host "======================================================================" -ForegroundColor Cyan
Write-Host ""

# Hàm đọc file INI đơn giản và tin cậy
function Parse-IniFile ($filePath) {
    $ini = @{}
    $section = "NO_SECTION"
    if (-not (Test-Path $filePath)) { return $ini }
    Get-Content $filePath | ForEach-Object {
        $line = $_.Trim()
        if ($line.StartsWith(";") -or $line.StartsWith("#") -or [string]::IsNullOrWhiteSpace($line)) { return }
        if ($line.StartsWith("[") -and $line.EndsWith("]")) {
            $section = $line.Substring(1, $line.Length - 2)
            if (-not $ini.ContainsKey($section)) { $ini[$section] = @{} }
        } elseif ($line.Contains("=")) {
            $parts = $line -split "=", 2
            $key = $parts[0].Trim()
            $val = $parts[1].Trim()
            if (-not $ini.ContainsKey($section)) { $ini[$section] = @{} }
            $ini[$section][$key] = $val
        }
    }
    return $ini
}

$Config = Parse-IniFile $IniFile
$ReportPath = if ($Config.General.ReportPath) { $Config.General.ReportPath } else { "C:\Windows\Temp\AutoInstaller_Report.log" }
$LogEntries = @()

function Log-Message ($msg, $color = "White") {
    $timestamp = (Get-Date).ToString("yyyy-MM-dd HH:mm:ss")
    $logLine = "[$timestamp] $msg"
    Write-Host $msg -ForegroundColor $color
    $script:LogEntries += $logLine
}

Log-Message "Khởi động kịch bản cấu hình Windows tự động..." "Cyan"
Log-Message "Thư mục kịch bản: $ScriptDir" "DarkGray"

# ------------------------------------------------------------------------------
# 1. DRIVER INSTALLATION (Snappy Driver Installer)
# ------------------------------------------------------------------------------
Write-Host ""
Log-Message ">> [1/4] Kiểm tra và cài đặt Drivers..." "Yellow"
$SDIPath = Join-Path $ScriptDir $Config.Driver.SDIPath
if ($Config.Driver.EnableSDI -eq "true" -and (Test-Path $SDIPath)) {
    Log-Message "Phát hiện Snappy Driver Installer. Đang tiến hành cài đặt..." "Green"
    try {
        Start-Process -FilePath $SDIPath -ArgumentList $Config.Driver.SDIArgs -Wait -NoNewWindow
        Log-Message "[OK] Đã hoàn tất quét và cập nhật Driver qua SDI." "Green"
    } catch {
        Log-Message "[WARN] Lỗi khi chạy SDI: $_" "Red"
    }
} else {
    Log-Message "[SKIP] Không tìm thấy driver offline trong USB (sẽ dùng Windows Update sau)." "DarkYellow"
}

# ------------------------------------------------------------------------------
# 2. CÀI ĐẶT ỨNG DỤNG (Applications)
# ------------------------------------------------------------------------------
Write-Host ""
Log-Message ">> [2/4] Đang cài đặt các ứng dụng đã cấu hình trong config.ini..." "Yellow"

$TotalTargets = 0
$InstalledTargets = 0

if ($Config.Applications) {
    foreach ($appKey in $Config.Applications.Keys) {
        $raw = $Config.Applications[$appKey]
        $parts = $raw -split "\|"
        $enabled = ($parts[0].Trim().ToLower() -eq "true")
        $targetId = if ($parts.Count -gt 1) { $parts[1].Trim() } else { $appKey }
        $displayName = if ($parts.Count -gt 2) { $parts[2].Trim() } else { $targetId }

        if (-not $enabled) {
            continue
        }

        $TotalTargets++
        $offlineExe = Join-Path $ScriptDir "packages\$targetId"
        if (Test-Path $offlineExe) {
            # Cài đặt từ file Offline trên USB
            Write-Host ("  {0,-35} : " -f $displayName) -NoNewline
            try {
                $process = Start-Process -FilePath $offlineExe -ArgumentList "/S /SILENT /VERYSILENT /qn /norestart" -Wait -PassThru
                if ($process.ExitCode -eq 0 -or $process.ExitCode -eq 3010) {
                    Write-Host "[OK] Installed (Offline)" -ForegroundColor Green
                    $InstalledTargets++
                } else {
                    Write-Host ("[FAIL] ExitCode {0}" -f $process.ExitCode) -ForegroundColor Red
                }
            } catch {
                Write-Host "[ERROR] $_" -ForegroundColor Red
            }
        } else {
            # Cài đặt thông qua Microsoft Winget
            Write-Host ("  {0,-35} : " -f $displayName) -NoNewline
            $wingetCmd = Get-Command winget.exe -ErrorAction SilentlyContinue
            if ($wingetCmd) {
                $p = Start-Process -FilePath "winget" -ArgumentList "install --id $targetId -e --silent --accept-package-agreements --accept-source-agreements --force" -Wait -PassThru -NoNewWindow
                if ($p.ExitCode -eq 0 -or $p.ExitCode -eq 3010) {
                    Write-Host "[OK] Installed" -ForegroundColor Green
                    $InstalledTargets++
                } else {
                    Write-Host ("[FAIL] ExitCode {0}" -f $p.ExitCode) -ForegroundColor Red
                }
            } else {
                Write-Host "[SKIP] Winget chưa sẵn sàng" -ForegroundColor DarkYellow
            }
        }
    }
}
Log-Message "Hoàn tất cài đặt ứng dụng: $InstalledTargets / $TotalTargets targets thành công." "Cyan"

# ------------------------------------------------------------------------------
# 3. CÀI ĐẶT FONTS
# ------------------------------------------------------------------------------
Write-Host ""
Log-Message ">> [3/4] Đang kiểm tra và cài đặt fonts..." "Yellow"
$FontsDir = Join-Path $ScriptDir "fonts"
if (Test-Path $FontsDir) {
    $fontFiles = Get-ChildItem -Path $FontsDir -Include "*.ttf", "*.otf" -Recurse
    foreach ($font in $fontFiles) {
        $dest = Join-Path "C:\Windows\Fonts" $font.Name
        if (-not (Test-Path $dest)) {
            Copy-Item $font.FullName -Destination $dest -Force
            New-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Fonts" -Name $font.BaseName -Value $font.Name -PropertyType String -Force | Out-Null
        }
    }
    Log-Message "[OK] Đã cài đặt $($fontFiles.Count) fonts thành công." "Green"
} else {
    Log-Message "[SKIP] Không có thư mục fonts, bỏ qua." "DarkGray"
}

# ------------------------------------------------------------------------------
# 4. CẤU HÌNH & TINH CHỈNH WINDOWS (Tweaks)
# ------------------------------------------------------------------------------
Write-Host ""
Log-Message ">> [4/4] Đang cấu hình và tối ưu Windows 11..." "Yellow"

try {
    # Bật Dark Mode cho Apps và System
    if ($Config.Tweaks.EnableDarkMode -eq "true") {
        Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize" -Name "AppsUseLightTheme" -Value 0 -Type DWord -Force -ErrorAction SilentlyContinue
        Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize" -Name "SystemUsesLightTheme" -Value 0 -Type DWord -Force -ErrorAction SilentlyContinue
        Log-Message "  - Kích hoạt Dark Mode (Giao diện tối)" "Green"
    }

    # Hiện đuôi file mở rộng (File Extensions)
    if ($Config.Tweaks.ShowFileExtensions -eq "true") {
        Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "HideFileExt" -Value 0 -Type DWord -Force -ErrorAction SilentlyContinue
        Log-Message "  - Hiển thị phần mở rộng tập tin (file extensions)" "Green"
    }

    # Căn thanh Taskbar sang bên trái (Kiểu cổ điển tiện làm việc)
    if ($Config.Tweaks.AlignTaskbarLeft -eq "true") {
        Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "TaskbarAl" -Value 0 -Type DWord -Force -ErrorAction SilentlyContinue
        Log-Message "  - Căn thanh Taskbar sang lề trái" "Green"
    }

    # Tắt quảng cáo và tìm kiếm Bing trong Start Menu
    if ($Config.Tweaks.DisableBingSearchInStart -eq "true") {
        Set-ItemProperty -Path "HKCU:\Software\Policies\Microsoft\Windows\Explorer" -Name "DisableSearchBoxSuggestions" -Value 1 -Type DWord -Force -ErrorAction SilentlyContinue
        Log-Message "  - Tắt tìm kiếm Bing trong Start Menu" "Green"
    }

    # Tắt BitLocker Device Encryption
    if ($Config.Tweaks.DisableBitLocker -eq "true") {
        Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\BitLocker" -Name "PreventDeviceEncryption" -Value 1 -Type DWord -Force -ErrorAction SilentlyContinue
        Log-Message "  - Đã ngăn chặn BitLocker tự động khóa ổ đĩa" "Green"
    }
} catch {
    Log-Message "[WARN] Lỗi khi tinh chỉnh Windows: $_" "Red"
}

# ------------------------------------------------------------------------------
# XUẤT BÁO CÁO & EXIT CODE = 0
# ------------------------------------------------------------------------------
$Duration = New-TimeSpan -Start $StartTime -End (Get-Date)
Write-Host ""
Write-Host "======================================================================" -ForegroundColor Cyan
Log-Message "Script đã hoàn thành! Thời gian thực thi: $($Duration.Minutes) phút $($Duration.Seconds) giây." "Green"
Log-Message "Generating installation report: $ReportPath" "DarkGray"
$LogEntries | Out-File -FilePath $ReportPath -Encoding UTF8 -Force

Write-Host ""
Write-Host "script exit code = 0" -ForegroundColor Green
Write-Host "======================================================================" -ForegroundColor Cyan
Write-Host ""

if ($Config.General.RebootAfterInstall -eq "true") {
    Log-Message "Hệ thống sẽ khởi động lại sau 10 giây để áp dụng thay đổi..." "Yellow"
    Start-Sleep -Seconds 10
    Restart-Computer -Force
} else {
    Write-Host "Bấm phím bất kỳ để đóng cửa sổ này..." -ForegroundColor DarkGray
    $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
}
exit 0
