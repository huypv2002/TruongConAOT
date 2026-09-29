# ==============================================================================
# Script cài đặt Microsoft Office 2024 LTSC chính hãng qua ODT (Silent Install)
# ==============================================================================
param(
    [string]$Template = "wep_en.xml"
)

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$ConfigFile = Join-Path $ScriptDir $Template
$SetupExe = Join-Path $ScriptDir "setup.exe"

if (-not (Test-Path $ConfigFile)) {
    Write-Host "[ERROR] Không tìm thấy file cấu hình XML: $ConfigFile" -ForegroundColor Red
    exit 1
}

# Nếu chưa có setup.exe (ODT), tự động tải từ Microsoft chính thức
if (-not (Test-Path $SetupExe)) {
    Write-Host "[INFO] Đang tải Office Deployment Tool chính hãng từ Microsoft..." -ForegroundColor Cyan
    $odtUrl = "https://download.microsoft.com/download/2/7/A/27AF1BE6-DD20-4CB4-B154-EBAB8A7D4A7E/officedeploymenttool_17328-20162.exe"
    $tempOdt = Join-Path $env:TEMP "odt_setup.exe"
    try {
        [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
        Invoke-WebRequest -Uri $odtUrl -OutFile $tempOdt -UseBasicParsing
        # Giải nén setup.exe từ ODT installer
        Start-Process -FilePath $tempOdt -ArgumentList "/quiet /extract:`"$ScriptDir`"" -Wait
        Remove-Item $tempOdt -Force -ErrorAction SilentlyContinue
    } catch {
        Write-Host "[WARN] Không thể tải ODT tự động. Đang chuyển sang cài đặt qua Winget..." -ForegroundColor Yellow
        winget install --id Microsoft.Office -e --silent --accept-package-agreements --accept-source-agreements
        exit $LASTEXITCODE
    }
}

if (Test-Path $SetupExe) {
    Write-Host "[INFO] Đang cài đặt Microsoft Office bằng template: $Template (Chế độ ngầm)..." -ForegroundColor Cyan
    $process = Start-Process -FilePath $SetupExe -ArgumentList "/configure `"$ConfigFile`"" -Wait -PassThru -NoNewWindow
    if ($process.ExitCode -eq 0) {
        Write-Host "[OK] Cài đặt Microsoft Office thành công!" -ForegroundColor Green
        exit 0
    } else {
        Write-Host "[FAIL] Office cài đặt thất bại với mã lỗi: $($process.ExitCode)" -ForegroundColor Red
        exit $process.ExitCode
    }
}
