# ==============================================================================
# AutoInstaller - Windows 11 Post-Installation Master Engine
# ==============================================================================
#Requires -RunAsAdministrator

$Host.UI.RawUI.WindowTitle = "AutoInstaller - Live Log"
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$ProjectRoot = Split-Path -Parent $ScriptDir
$IniFile = Join-Path $ScriptDir "config.ini"
$StartTime = Get-Date

# Banner phong cách Terminal trong clip
Write-Host ""
Write-Host "======================================================================" -ForegroundColor Cyan
Write-Host "                       AUTOINSTALLER - LIVE LOG                       " -ForegroundColor Green
Write-Host "             Comprehensive Windows 11 Automation Engine               " -ForegroundColor DarkGray
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
# 1. DRIVER INSTALLATION (Snappy Driver Installer & Windows Update)
# ------------------------------------------------------------------------------
Write-Host ""
Log-Message ">> [1/5] Quét và cài đặt Drivers..." "Yellow"
$DriverScript = Join-Path $ScriptDir "install-drivers.ps1"
if (Test-Path $DriverScript) {
    & $DriverScript
} else {
    Log-Message "[SKIP] Không tìm thấy script cài driver." "DarkGray"
}

# ------------------------------------------------------------------------------
# 2. CÀI ĐẶT MICROSOFT OFFICE (ODT chính hãng Microsoft)
# ------------------------------------------------------------------------------
Write-Host ""
Log-Message ">> [2/5] Kiểm tra cài đặt Microsoft Office 2024 LTSC..." "Yellow"
if ($Config.Office.EnableOffice -eq "true") {
    $officeScript = Join-Path $ProjectRoot "office\Install-Office.ps1"
    if (-not (Test-Path $officeScript)) {
        $officeScript = Join-Path $ScriptDir "..\office\Install-Office.ps1"
    }
    $template = if ($Config.Office.OfficeTemplate) { $Config.Office.OfficeTemplate } else { "wep_en.xml" }
    
    if (Test-Path $officeScript) {
        Log-Message "Đang gọi module cài đặt Office Deployment Tool (Template: $template)..." "Cyan"
        & $officeScript -Template $template
    } else {
        Log-Message "[SKIP] Không tìm thấy module cài đặt Office trong thư mục office/." "DarkYellow"
    }
} else {
    Log-Message "[SKIP] Tùy chọn cài Office đã tắt trong config.ini." "DarkGray"
}

# ------------------------------------------------------------------------------
# 3. CÀI ĐẶT ỨNG DỤNG (Applications via Winget & Offline)
# ------------------------------------------------------------------------------
Write-Host ""
Log-Message ">> [3/5] Đang cài đặt các ứng dụng đã cấu hình trong config.ini..." "Yellow"

$TotalTargets = 0
$InstalledTargets = 0

if ($Config.Applications) {
    foreach ($appKey in $Config.Applications.Keys) {
        $raw = $Config.Applications[$appKey]
        $parts = $raw -split "\|"
        $enabled = ($parts[0].Trim().ToLower() -eq "true")
        $targetId = if ($parts.Count -gt 1) { $parts[1].Trim() } else { $appKey }
        $displayName = if ($parts.Count -gt 2) { $parts[2].Trim() } else { $targetId }

        if (-not $enabled) { continue }

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
            # Cài đặt thông qua Microsoft Winget chính chủ
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
# 4. CÀI ĐẶT FONTS
# ------------------------------------------------------------------------------
Write-Host ""
Log-Message ">> [4/5] Đang kiểm tra và cài đặt fonts..." "Yellow"
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
# 5. CẤU HÌNH & TINH CHỈNH WINDOWS (configure-windows.ps1)
# ------------------------------------------------------------------------------
Write-Host ""
Log-Message ">> [5/5] Cấu hình và tinh chỉnh Windows 11..." "Yellow"
$ConfigWinScript = Join-Path $ScriptDir "configure-windows.ps1"
if (Test-Path $ConfigWinScript) {
    & $ConfigWinScript
} else {
    Log-Message "[SKIP] Không tìm thấy script configure-windows.ps1." "DarkGray"
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
    Log-Message "Hệ thống sẽ khởi động lại sau 10 giây để áp dụng toàn diện driver và thiết lập..." "Yellow"
    Start-Sleep -Seconds 10
    Restart-Computer -Force
} else {
    Write-Host "Bấm phím bất kỳ để đóng cửa sổ này..." -ForegroundColor DarkGray
    $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
}
exit 0
