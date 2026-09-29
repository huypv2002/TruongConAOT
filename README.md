# Auto-Win 11: Bộ Công Cụ Cài Đặt & Cấu Hình Windows 11 Tự Động Toàn Diện

Bộ công cụ tự động hóa toàn diện quá trình cài đặt Windows 11 dựa trên nền tảng **Ventoy Bootloader + Microsoft Unattended Engine + PowerShell AutoInstaller Engine**. Dự án tổng hợp đầy đủ các tính năng thực tế từ bộ giải pháp của tác giả `1172005thinh` (`AutoInstaller` & `QuickWinstall`), được tối ưu hóa 100% cho môi trường **Windows**, hoạt động hoàn toàn offline hoặc online không cần can thiệp thủ công.

---

## 🌟 Tổng Hợp Toàn Bộ Tính Năng (Đầy Đủ 100%)

### 1. Nền Tảng Khởi Động & Giao Diện Boot (Ventoy Bootloader)
- **Theme GRUB2 Poly Dark**: Giao diện khởi động đồ họa cao cấp, hiển thị icon nhận diện Windows 11, Windows 10, Ubuntu, Arch, Kali...
- **Bypass Phần Cứng Ngay Từ Ventoy**: Tích hợp sẵn `VTOY_WIN11_BYPASS_CHECK` và `VTOY_WIN11_BYPASS_NRO` trong `ventoy.json`.
- **Menu Chọn Kịch Bản Tự Động (Auto-Install Plugin)**: Khi nhấn vào file ISO Windows 11, menu sẽ hiện 5 kịch bản linh hoạt:
  1. `full_C.xml`: Tự động xóa sạch đĩa 0, tạo 1 ổ C, cài full apps, Office và drivers.
  2. `full_C_D.xml`: Tự động xóa đĩa 0, chia sẵn ổ C (150GB hệ thống) và ổ D (toàn bộ phần còn lại lưu dữ liệu).
  3. `full_mandisk.xml`: Cài full apps, Office và drivers nhưng dừng ở bước chọn ổ đĩa để người dùng chia tay an toàn.
  4. `noapps_C.xml`: Chỉ cài Windows 11 nguyên bản sạch sẽ (không cài thêm phần mềm), chia 1 ổ C.
  5. `noapps_mandisk.xml`: Chỉ cài Windows 11 nguyên bản sạch sẽ, tự chọn ổ đĩa bằng tay.

### 2. Kịch Bản Windows Unattended (`autounattend.xml`)
- Tự động vượt kiểm tra TPM 2.0, Secure Boot, RAM tối thiểu, CPU thế hệ cũ, Storage check.
- Tự động tắt tính năng BitLocker Device Encryption (tránh rủi ro bị khóa mã hóa ổ đĩa).
- Bỏ qua toàn bộ khảo sát OOBE, bỏ qua ép buộc tài khoản Microsoft, tự tạo tài khoản Offline `Admin` (không đặt mật khẩu).
- Nhận diện và tự kích hoạt bản quyền số nếu máy có nhúng sẵn key trong BIOS (như máy Dell/HP); nếu không có thì ở trạng thái chờ kích hoạt sạch sẽ.
- Tự động kích hoạt `AutoInstaller.ps1` ngay khi máy đăng nhập vào Desktop lần đầu.

### 3. Bộ Cài Đặt Microsoft Office 2024 LTSC Chính Hãng (`office/`)
- Cài đặt thông qua **Microsoft Office Deployment Tool (ODT)** chính thức từ Microsoft.
- Hỗ trợ đa dạng các template XML:
  - `wep_en.xml`: Word, Excel, PowerPoint (Tiếng Anh).
  - `wep_vi.xml`: Word, Excel, PowerPoint (Tiếng Việt kèm Tiếng Anh).
  - `full_en.xml`: Trọn bộ Office 2024 LTSC (Word, Excel, PowerPoint, Outlook, Access) Tiếng Anh.
  - `full_vi.xml`: Trọn bộ Office 2024 LTSC Tiếng Việt.
- Tự động tải ODT chính hãng và cài đặt ở chế độ ngầm (Silent Install), không chứa script crack.

### 4. Quản Lý Driver Thông Minh (`scripts/install-drivers.ps1`)
- **Tự động quét SDI**: Tìm kiếm công cụ **Snappy Driver Installer (SDI / SDIO)** trong USB và chạy tự động với cờ `-autoinstall -autoclose`.
- **Dự phòng Windows Update**: Nếu USB không có sẵn driver offline, script tự động kích hoạt phiên cập nhật Driver từ máy chủ Microsoft để tải driver chuẩn xác cho phần cứng.

### 5. Cấu Hình & Tinh Chỉnh Hệ Thống Chuyên Sâu (`scripts/configure-windows.ps1`)
- **File Explorer**: Tự động hiển thị đuôi tập tin (`.exe`, `.txt`), mở File Explorer vào This PC thay vì Quick Access.
- **Taskbar & Start Menu**: Căn lề Taskbar sang trái, bật lệnh **End Task** trên menu chuột phải, tắt Widgets (tin tức rác), tắt tìm kiếm Bing trên Start Menu.
- **Debloat**: Tự động gỡ các ứng dụng rác cài sẵn (Candy Crush, TikTok, Spotify demo, Clipchamp, Xbox junk...).
- **Hiệu năng & Quyền riêng tư**: Tắt Telemetry theo dõi của Windows, bật giao diện tối (Dark Mode), kích hoạt High Performance Power Plan.

### 6. Cài Đặt Ứng Dụng Hàng Loạt (`scripts/AutoInstaller.ps1`)
- Đọc cấu hình từ `config.ini` để cài đặt ứng dụng:
  - Cài trực tiếp từ kho ứng dụng chính chủ **Microsoft Winget** (Chrome, VS Code, Git, Python, NodeJS, Unikey, Zalo, VLC, 7-Zip...).
  - Hỗ trợ cài từ bộ cài offline trong thư mục `packages/` nếu không có mạng.
- Tự động cài font chữ tiếng Việt/lập trình từ thư mục `fonts/`.
- Xuất log chi tiết và file báo cáo hoàn tất với `exit code = 0`.

---

## 📂 Cấu Trúc Dự Án Chi Tiết

```plaintext
auto-win/
├── .gitignore
├── README.md                       # Tài liệu hướng dẫn chi tiết
│
├── ventoy/                         # Toàn bộ cấu hình nạp vào USB Ventoy
│   ├── ventoy.json                 # Cấu hình plugin Ventoy (Theme, Menu 5 kịch bản, Bypass)
│   ├── ventoy_vhdboot.img          # Module boot VHD
│   ├── ventoy_wimboot.img          # Module boot WIM
│   ├── theme/poly-dark/            # Giao diện bootloader GRUB2 Poly Dark
│   └── unattend/                   # 5 Kịch bản cài đặt tự động
│       ├── full_C.xml              # Kịch bản 1: Full Apps + Drivers + Chia 1 ổ C
│       ├── full_C_D.xml            # Kịch bản 2: Full Apps + Drivers + Chia ổ C (150GB) & D
│       ├── full_mandisk.xml        # Kịch bản 3: Full Apps + Drivers + Tự chọn ổ đĩa
│       ├── noapps_C.xml            # Kịch bản 4: Win sạch + Chia 1 ổ C
│       └── noapps_mandisk.xml      # Kịch bản 5: Win sạch + Tự chọn ổ đĩa
│
├── office/                         # Module cài đặt Microsoft Office 2024 LTSC qua ODT
│   ├── Install-Office.ps1          # Script tự tải ODT và cài đặt ngầm
│   ├── wep_en.xml                  # Word, Excel, PowerPoint (EN)
│   ├── wep_vi.xml                  # Word, Excel, PowerPoint (VI)
│   ├── full_en.xml                 # Trọn bộ Office 2024 (EN)
│   └── full_vi.xml                 # Trọn bộ Office 2024 (VI)
│
└── scripts/                        # Bộ công cụ tự động hóa chạy trên Windows
    ├── AutoInstaller.ps1           # Master Engine điều phối cài app, driver, tweaks
    ├── config.ini                  # File cấu hình danh sách app & cài đặt tổng
    ├── install-drivers.ps1         # Module tự quét SDI hoặc gọi Windows Update
    ├── configure-windows.ps1       # Module tinh chỉnh Windows, gỡ bloatware, dark mode
    ├── configure-windows.ini       # File cấu hình chi tiết cho configure-windows
    └── Setup-USB-Windows.bat       # Kịch bản 1-click trên Windows đồng bộ toàn bộ vào USB
```

---

## 🚀 Hướng Dẫn Sử Dụng Trên Máy Windows (Step-by-Step)

### Bước 1: Tạo USB Ventoy
1. Tải [Ventoy for Windows](https://www.ventoy.net/en/download.html) (file `ventoy-x.x.xx-windows.zip`).
2. Mở `Ventoy2Disk.exe`, cắm USB vào máy.
3. Chọn **Option -> Partition Style -> GPT**, bấm **Install**.

### Bước 2: Đồng Bộ Dự Án Vào USB Với 1 Cú Click
1. Clone hoặc pull repository này về máy Windows:
   ```cmd
   git clone <URL_REPO_CUA_BAN>
   cd auto-win
   ```
2. Chuột phải vào file `scripts\Setup-USB-Windows.bat` -> chọn **Run as administrator**.
3. Nhập ký tự ổ đĩa USB của bạn (ví dụ: `E` hoặc `F`) -> Bấm Enter.
4. Kịch bản sẽ tự động sao chép toàn bộ thư mục `ventoy\`, `scripts\`, và `office\` vào USB.

### Bước 3: Thêm Bộ Cài Windows 11
1. Tải file ISO Windows 11 từ Microsoft: [Download Windows 11](https://www.microsoft.com/software-download/windows11).
2. Đổi tên file tải về thành: **`Win11.iso`**
3. Chép file `Win11.iso` vào thư mục gốc của USB.

### Bước 4: Khởi Động & Cài Đặt
1. Cắm USB vào máy HP, bật nguồn và **bấm liên tục phím `F9`** để mở Boot Menu.
2. Chọn boot vào USB Ventoy (UEFI).
3. Màn hình Poly Dark xuất hiện -> Chọn file **`Win11.iso`**.
4. Menu tự động hiện lên 5 tùy chọn:
   - Nếu máy trống muốn tự làm tất cả: Chọn **`Boot with /ventoy/unattend/full_C.xml`**.
   - Nếu máy có dữ liệu muốn tự chọn ổ đĩa: Chọn **`Boot with /ventoy/unattend/full_mandisk.xml`**.
5. Máy tính sẽ tự hoàn tất mọi khâu và đưa bạn vào thẳng Desktop với đầy đủ ứng dụng, Office và driver!
