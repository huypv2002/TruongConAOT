# ==============================================================================
# TRUONG CON AOT - APPLICATION INSTALLER & DEV ENVIRONMENT ENGINE
# ==============================================================================
#Requires -RunAsAdministrator

$Host.UI.RawUI.WindowTitle = "TRUONG CON AOT - Master App Installer v2.0"
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$IniFile = Join-Path $ScriptDir "apps.ini"
$StartTime = Get-Date

function Show-TruongConAOT-Header {
    param(
        [string]$ToolName,
        [string]$Description
    )
    Clear-Host
    Write-Host ""
    Write-Host " ======================================================================" -ForegroundColor Cyan
    Write-Host "   ████████╗██████╗ ██╗   ██╗ ██████╗ ███╗   ██╗ ██████╗ " -ForegroundColor Green
    Write-Host "   ╚══██╔══╝██╔══██╗██║   ██║██╔═══██╗████╗  ██║██╔════╝ " -ForegroundColor Green
    Write-Host "      ██║   ██████╔╝██║   ██║██║   ██║██╔██╗ ██║██║  ███╗" -ForegroundColor Green
    Write-Host "      ██║   ██╔══██╗██║   ██║██║   ██║██║╚██╗██║██║   ██║" -ForegroundColor Green
    Write-Host "      ██║   ██║  ██║╚██████╔╝╚██████╔╝██║ ╚████║╚██████╔╝" -ForegroundColor Green
    Write-Host "      ╚═╝   ╚═╝  ╚═╝ ╚═════╝  ╚═════╝ ╚═╝  ╚═══╝ ╚═════╝ " -ForegroundColor Green
    Write-Host "         ██████╗  ██████╗ ███╗   ██╗     █████╗  ██████╗ ████████╗" -ForegroundColor Green
    Write-Host "        ██╔════╝ ██╔═══██╗████╗  ██║    ██╔══██╗██╔═══██╗╚══██╔══╝" -ForegroundColor Green
    Write-Host "        ██║      ██║   ██║██╔██╗ ██║    ███████║██║   ██║   ██║   " -ForegroundColor Green
    Write-Host "        ██║      ██║   ██║██║╚██╗██║    ██╔══██║██║   ██║   ██║   " -ForegroundColor Green
    Write-Host "        ╚██████╗ ╚██████╔╝██║ ╚████║    ██║  ██║╚██████╔╝   ██║   " -ForegroundColor Green
    Write-Host "         ╚═════╝  ╚═════╝ ╚═╝  ╚═══╝    ╚═╝  ╚═╝ ╚═════╝    ╚═╝   " -ForegroundColor Green
    Write-Host " ======================================================================" -ForegroundColor Cyan
    Write-Host "                  TRUONG CON AOT AUTOMATION ECOSYSTEM" -ForegroundColor White
    if ($ToolName) {
        Write-Host "          $ToolName" -ForegroundColor Yellow
    }
    if ($Description) {
        Write-Host "   $Description" -ForegroundColor DarkCyan
    }
    Write-Host " ======================================================================" -ForegroundColor Cyan
    Write-Host ""
}

Show-TruongConAOT-Header -ToolName "[TOOL 3] MASTER APPLICATION & DEV INSTALLER" -Description "Cài Đặt Phần Mềm, Office 2024 LTSC, Fonts & Tối Ưu Hệ Thống"

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
$ReportPath = if ($Config.General.ReportPath) { $Config.General.ReportPath } else { "C:\Windows\Temp\TruongConAOT_Report.log" }
$LogEntries = @()

function Log-Message ($msg, $color = "White") {
    $timestamp = (Get-Date).ToString("yyyy-MM-dd HH:mm:ss")
    $logLine = "[$timestamp] $msg"
    Write-Host $msg -ForegroundColor $color
    $script:LogEntries += $logLine
}

Log-Message "Khởi động kịch bản Truong Con AOT App Engine..." "Cyan"

# 1. CÀI ĐẶT MICROSOFT VISUAL C++ RUNTIMES AIO (2005 - 2022)
if ($Config.DevEnvironment.InstallVCRedistAIO -eq "true") {
    Write-Host ""
    Log-Message ">> [1/6] Cài đặt Microsoft Visual C++ Redistributable (x86 & x64)..." "Yellow"
    $vcPackages = @("Microsoft.VCRedist.2015+.x64", "Microsoft.VCRedist.2015+.x86")
    foreach ($pkg in $vcPackages) {
        Write-Host ("  {0,-35} : " -f $pkg) -NoNewline
        $p = Start-Process -FilePath "winget" -ArgumentList "install --id $pkg -e --silent --accept-package-agreements --accept-source-agreements" -Wait -PassThru -NoNewWindow
        if ($p.ExitCode -eq 0 -or $p.ExitCode -eq 3010) {
            Write-Host "[✓] Installed" -ForegroundColor Green
        } else {
            Write-Host "[-] Already/Skipped" -ForegroundColor DarkGray
        }
    }
}

# 2. BẬT DEVELOPER MODE & LONG PATHS CHO DÂN CODE
if ($Config.DevEnvironment.EnableDeveloperMode -eq "true") {
    Write-Host ""
    Log-Message ">> [2/6] Bật Developer Mode & Cho phép đường dẫn dài (> 260 ký tự)..." "Yellow"
    Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\FileSystem" -Name "LongPathsEnabled" -Value 1 -Type DWord -Force
    New-Item -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\AppModelUnlock" -Force -ErrorAction SilentlyContinue | Out-Null
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\AppModelUnlock" -Name "AllowDevelopmentWithoutDevLicense" -Value 1 -Type DWord -Force
    Log-Message "  [✓] Đã kích hoạt Developer Mode và Long Paths thành công." "Green"
}

# 3. CÀI ĐẶT MICROSOFT OFFICE 2024 LTSC (ODT)
if ($Config.Office.EnableOffice -eq "true") {
    Write-Host ""
    Log-Message ">> [3/6] Cài đặt Microsoft Office 2024 LTSC chính hãng qua ODT..." "Yellow"
    $officeScript = Join-Path $ScriptDir "office\Install-Office.ps1"
    $template = if ($Config.Office.OfficeTemplate) { $Config.Office.OfficeTemplate } else { "wep_en.xml" }
    if (Test-Path $officeScript) {
        & $officeScript -Template $template
    } else {
        Log-Message "  [-] Không tìm thấy module office trong thư mục tool." "DarkYellow"
    }
}

# 4. CÀI ĐẶT CÁC ỨNG DỤNG TỪ APPS.INI
Write-Host ""
Log-Message ">> [4/6] Cài đặt các ứng dụng phần mềm tự động..." "Yellow"
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
            Write-Host ("  {0,-35} : " -f $displayName) -NoNewline
            try {
                $process = Start-Process -FilePath $offlineExe -ArgumentList "/S /SILENT /VERYSILENT /qn /norestart" -Wait -PassThru
                if ($process.ExitCode -eq 0 -or $process.ExitCode -eq 3010) {
                    Write-Host "[✓] Installed (Offline)" -ForegroundColor Green
                    $InstalledTargets++
                } else {
                    Write-Host ("[✗] ExitCode {0}" -f $process.ExitCode) -ForegroundColor Red
                }
            } catch {
                Write-Host "[✗] $_" -ForegroundColor Red
            }
        } else {
            Write-Host ("  {0,-35} : " -f $displayName) -NoNewline
            $p = Start-Process -FilePath "winget" -ArgumentList "install --id $targetId -e --silent --accept-package-agreements --accept-source-agreements --force" -Wait -PassThru -NoNewWindow
            if ($p.ExitCode -eq 0 -or $p.ExitCode -eq 3010) {
                Write-Host "[✓] Installed" -ForegroundColor Green
                $InstalledTargets++
            } else {
                Write-Host ("[✗] ExitCode {0}" -f $p.ExitCode) -ForegroundColor Red
            }
        }
    }
}
Log-Message "  [✓] Hoàn tất cài đặt ứng dụng: $InstalledTargets / $TotalTargets mục." "Cyan"

# 5. CÀI ĐẶT FONTS
Write-Host ""
Log-Message ">> [5/6] Kiểm tra cài đặt Fonts Tiếng Việt & Lập trình..." "Yellow"
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
    Log-Message "  [✓] Đã cài đặt $($fontFiles.Count) fonts thành công." "Green"
} else {
    Log-Message "  [-] Thư mục fonts trống, tiếp tục bước sau." "DarkGray"
}

# 6. TINH CHỈNH WINDOWS & GHI NHẬN OEM TRUONG CON AOT
Write-Host ""
Log-Message ">> [6/6] Tinh chỉnh hệ thống & Áp dụng thương hiệu Truong Con AOT..." "Yellow"
$ConfigWinScript = Join-Path $ScriptDir "configure-windows.ps1"
if (Test-Path $ConfigWinScript) {
    & $ConfigWinScript
}

# XUẤT BÁO CÁO & KẾT THÚC
$Duration = New-TimeSpan -Start $StartTime -End (Get-Date)
Write-Host ""
Write-Host " ======================================================================" -ForegroundColor Cyan
Write-Host "  [✓] HOÀN TẤT CÀI ĐẶT ỨNG DỤNG - TRUONG CON AOT ECOSYSTEM" -ForegroundColor Green
Write-Host "      Thời gian thực thi: $($Duration.Minutes) phút $($Duration.Seconds) giây." -ForegroundColor White
Write-Host "      Báo cáo chi tiết  : $ReportPath" -ForegroundColor DarkGray
Write-Host " ======================================================================" -ForegroundColor Cyan
Write-Host ""

$LogEntries | Out-File -FilePath $ReportPath -Encoding UTF8 -Force

if ($Config.General.RebootAfterInstall -eq "true") {
    Log-Message "Hệ thống sẽ khởi động lại sau 10 giây để áp dụng mọi thay đổi..." "Yellow"
    Start-Sleep -Seconds 10
    Restart-Computer -Force
} else {
    Write-Host "Bấm phím bất kỳ để đóng cửa sổ..." -ForegroundColor DarkGray
    $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
}
exit 0
