# ==============================================================================
# TRUONG CON AOT - DRIVER INSTALLER & UPDATER ENGINE
# Hỗ trợ tự động quét SDI Offline và Windows Update API
# ==============================================================================
#Requires -RunAsAdministrator

$Host.UI.RawUI.WindowTitle = "TRUONG CON AOT - Driver Engine v2.0"
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
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

Show-TruongConAOT-Header -ToolName "[TOOL 2] DRIVER INSTALLER & UPDATER ENGINE" -Description "Tự Động Quét SDI Offline & Microsoft Windows Update API"

function Find-SDI {
    $drives = Get-PSDrive -PSProvider FileSystem
    $searchSubs = @("Drivers\SDIO", "Drivers\SDI", "Drivers", "SDIO", "SDI", "ventoy\Drivers", "Tools\Drivers", "")
    $exeNames = @("SDIO_x64.exe", "SDI_x64.exe", "SDIO.exe", "SDI.exe")

    foreach ($drive in $drives) {
        foreach ($sub in $searchSubs) {
            foreach ($exe in $exeNames) {
                $candidate = Join-Path $drive.Root (Join-Path $sub $exe)
                if (Test-Path $candidate) {
                    return $candidate
                }
            }
        }
    }
    return $null
}

function Test-Internet {
    try {
        $res = Invoke-WebRequest -Uri "http://www.msftconnecttest.com/connecttest.txt" -UseBasicParsing -TimeoutSec 8 -ErrorAction Stop
        return ($res.StatusCode -ge 200 -and $res.StatusCode -lt 400)
    } catch {
        return $false
    }
}

# 1. KIỂM TRA PHẦN CỨNG HỆ THỐNG
Write-Host " [1/3] THU THẬP THÔNG TIN PHẦN CỨNG HỆ THỐNG..." -ForegroundColor Yellow
$cs = Get-CimInstance Win32_ComputerSystem
$cpu = (Get-CimInstance Win32_Processor).Name
$gpu = (Get-CimInstance Win32_VideoController | Select-Object -ExpandProperty Name) -join ", "
$ramGB = [math]::Round((Get-CimInstance Win32_PhysicalMemory | Measure-Object -Property Capacity -Sum).Sum / 1GB)
$osInfo = (Get-CimInstance Win32_OperatingSystem).Caption

Write-Host "  ┌──────────────────────────────────────────────────────────────────┐" -ForegroundColor Cyan
Write-Host ("  │ Hãng SX    : {0,-51}│" -f "$($cs.Manufacturer)") -ForegroundColor White
Write-Host ("  │ Model máy  : {0,-51}│" -f "$($cs.Model)") -ForegroundColor White
Write-Host ("  │ Vi xử lý   : {0,-51}│" -f "$cpu") -ForegroundColor White
Write-Host ("  │ Card đồ họa: {0,-51}│" -f "$gpu") -ForegroundColor White
Write-Host ("  │ Dung lượng : {0,-51}│" -f "$ramGB GB RAM") -ForegroundColor White
Write-Host ("  │ Phiên bản  : {0,-51}│" -f "$osInfo") -ForegroundColor White
Write-Host "  └──────────────────────────────────────────────────────────────────┘" -ForegroundColor Cyan
Write-Host ""

# 2. TÌM KIẾM VÀ CHẠY SNAPPY DRIVER INSTALLER (SDI OFFLINE)
Write-Host " [2/3] KIỂM TRA GÓI DRIVER OFFLINE (SNAPPY DRIVER INSTALLER)..." -ForegroundColor Yellow
$sdiExe = Find-SDI

if ($sdiExe) {
    Write-Host "  [✓] Đã tìm thấy SDI tại: $sdiExe" -ForegroundColor Green
    Write-Host "  [*] Đang khởi chạy SDI với chế độ tự động cài đặt (-autoinstall -autoclose)..." -ForegroundColor Cyan
    try {
        $p = Start-Process -FilePath $sdiExe -ArgumentList "-autoinstall -autoclose -showconsole" -Wait -PassThru
        Write-Host "  [✓] Quá trình cập nhật driver qua SDI hoàn tất (Mã thoát: $($p.ExitCode))." -ForegroundColor Green
    } catch {
        Write-Host "  [✗] Lỗi khi chạy SDI: $_" -ForegroundColor Red
    }
} else {
    Write-Host "  [-] Không phát hiện bộ driver offline trong USB (Có thể chép SDI vào USB:\Drivers\SDIO nếu muốn dùng offline)." -ForegroundColor DarkYellow
}

# 3. DỰ PHÒNG QUA WINDOWS UPDATE API (ONLINE)
Write-Host ""
Write-Host " [3/3] QUÉT & CẬP NHẬT DRIVER TỪ MICROSOFT WINDOWS UPDATE..." -ForegroundColor Yellow

if (Test-Internet) {
    Write-Host "  [*] Đang kết nối Windows Update API để tìm kiếm driver còn thiếu..." -ForegroundColor Cyan
    try {
        $UpdateSession = New-Object -ComObject Microsoft.Update.Session
        $UpdateSearcher = $UpdateSession.CreateUpdateSearcher()
        $SearchCriteria = "IsInstalled=0 and Type='Driver'"
        $SearchResult = $UpdateSearcher.Search($SearchCriteria)
        
        if ($SearchResult.Updates.Count -gt 0) {
            Write-Host "  [+] Phát hiện $($SearchResult.Updates.Count) driver cần cập nhật. Đang tải và cài đặt..." -ForegroundColor Green
            $UpdatesToDownload = New-Object -ComObject Microsoft.Update.UpdateColl
            foreach ($Update in $SearchResult.Updates) {
                $UpdatesToDownload.Add($Update) | Out-Null
            }
            $Downloader = $UpdateSession.CreateUpdateDownloader()
            $Downloader.Updates = $UpdatesToDownload
            $Downloader.Download() | Out-Null

            $UpdatesToInstall = New-Object -ComObject Microsoft.Update.UpdateColl
            foreach ($Update in $SearchResult.Updates) {
                if ($Update.IsDownloaded) {
                    $UpdatesToInstall.Add($Update) | Out-Null
                }
            }
            $Installer = $UpdateSession.CreateUpdateInstaller()
            $Installer.Updates = $UpdatesToInstall
            $InstallResult = $Installer.Install()
            Write-Host "  [✓] Đã hoàn tất cài đặt toàn bộ driver từ Windows Update!" -ForegroundColor Green
        } else {
            Write-Host "  [✓] Toàn bộ driver phần cứng của hệ thống đã đầy đủ và hoạt động tốt." -ForegroundColor Green
        }
    } catch {
        Write-Host "  [!] Không thể tự động chạy Windows Update: $_" -ForegroundColor DarkYellow
        Write-Host "  [i] Bạn có thể vào Windows Settings -> Windows Update để cập nhật thêm." -ForegroundColor DarkGray
    }
} else {
    Write-Host "  [i] Chưa có kết nối Internet. Vui lòng kết nối Wifi/LAN nếu cần tải thêm driver." -ForegroundColor DarkYellow
}

$Duration = New-TimeSpan -Start $StartTime -End (Get-Date)
Write-Host ""
Write-Host " ======================================================================" -ForegroundColor Cyan
Write-Host "  [✓] HOÀN TẤT CẬP NHẬT DRIVER - TRUONG CON AOT ECOSYSTEM" -ForegroundColor Green
Write-Host "      Thời gian thực thi: $($Duration.Minutes) phút $($Duration.Seconds) giây." -ForegroundColor White
Write-Host " ======================================================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Bấm phím bất kỳ để đóng cửa sổ..." -ForegroundColor DarkGray
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
exit 0
