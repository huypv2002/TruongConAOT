# ==============================================================================
# AutoInstaller - Module Tự Động Cài Đặt Drivers (SDI & Windows Update)
# ==============================================================================
[CmdletBinding()]
param(
    [switch]$ForceWindowsUpdate
)

$Host.UI.RawUI.WindowTitle = "AutoInstaller - Driver Installation"
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

function Find-SDI {
    $drives = Get-PSDrive -PSProvider FileSystem
    $searchSubs = @("Drivers\SDIO", "Drivers\SDI", "Drivers", "SDIO", "SDI", "ventoy\Drivers", "")
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
        $res = Invoke-WebRequest -Uri "http://www.msftconnecttest.com/connecttest.txt" -UseBasicParsing -TimeoutSec 10 -ErrorAction Stop
        return ($res.StatusCode -ge 200 -and $res.StatusCode -lt 400)
    } catch {
        return $false
    }
}

Write-Host ""
Write-Host "======================================================================" -ForegroundColor Cyan
Write-Host "                    DRIVER INSTALLATION ENGINE                        " -ForegroundColor Yellow
Write-Host "======================================================================" -ForegroundColor Cyan
Write-Host ""

$sdiExe = Find-SDI

if ($sdiExe) {
    Write-Host "[INFO] Tìm thấy Snappy Driver Installer tại: $sdiExe" -ForegroundColor Green
    Write-Host "[INFO] Đang khởi chạy SDI với chế độ tự động cài đặt (-autoinstall -autoclose)..." -ForegroundColor Cyan
    try {
        $p = Start-Process -FilePath $sdiExe -ArgumentList "-autoinstall -autoclose -showconsole" -Wait -PassThru
        Write-Host "[OK] Quá trình cập nhật driver qua SDI hoàn tất (ExitCode: $($p.ExitCode))." -ForegroundColor Green
        exit 0
    } catch {
        Write-Host "[ERROR] Lỗi khi chạy SDI: $_" -ForegroundColor Red
    }
} else {
    Write-Host "[SKIP] Không tìm thấy bộ driver offline SDI trong USB." -ForegroundColor DarkYellow
}

# Nếu không có SDI offline hoặc được yêu cầu Windows Update
if (Test-Internet) {
    Write-Host "[INFO] Máy tính có kết nối Internet. Đang kiểm tra Driver qua Windows Update..." -ForegroundColor Cyan
    try {
        # Kích hoạt quét cập nhật driver nền của Windows
        $UpdateSession = New-Object -ComObject Microsoft.Update.Session
        $UpdateSearcher = $UpdateSession.CreateUpdateSearcher()
        $SearchCriteria = "IsInstalled=0 and Type='Driver'"
        Write-Host "[INFO] Đang tìm kiếm driver tương thích từ máy chủ Microsoft..." -ForegroundColor DarkGray
        $SearchResult = $UpdateSearcher.Search($SearchCriteria)
        
        if ($SearchResult.Updates.Count -gt 0) {
            Write-Host "[INFO] Tìm thấy $($SearchResult.Updates.Count) driver cần cập nhật. Đang tải và cài đặt..." -ForegroundColor Green
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
            Write-Host "[OK] Đã cập nhật xong các driver chính thức từ Windows Update." -ForegroundColor Green
        } else {
            Write-Host "[OK] Toàn bộ driver cơ bản của hệ thống đã đầy đủ." -ForegroundColor Green
        }
    } catch {
        Write-Host "[WARN] Không thể tự động chạy Windows Update: $_" -ForegroundColor DarkYellow
        Write-Host "[INFO] Bạn có thể vào Settings -> Windows Update để cập nhật thủ công sau." -ForegroundColor Cyan
    }
} else {
    Write-Host "[INFO] Máy chưa có mạng Internet. Bạn có thể cắm mạng/kết nối Wifi sau để Windows Update tự tải driver." -ForegroundColor DarkYellow
}

exit 0
