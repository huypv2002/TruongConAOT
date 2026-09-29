# Truong Con AOT - Bộ 3 Công Cụ Cài Đặt Windows 11 Toàn Diện

Bộ giải pháp tự động hóa chuyên nghiệp mang thương hiệu **Truong Con AOT**, tách bạch rõ ràng thành **3 công cụ độc lập** giúp bạn kiểm soát 100% quá trình cài đặt, tương thích hoàn hảo cho cả **PC để bàn (Desktop)** và **Laptop** của tất cả các hãng (Dell, Asus, HP, Lenovo, MSI, Gigabyte...).

---

## 🌟 Cấu Trúc Bộ 3 Công Cụ (3-Tool Architecture)

```mermaid
flowchart LR
    USB[Chiếc USB Duy Nhất] --> T1[Tool 1: Cài Win Tự Động]
    USB --> T2[Tool 2: Driver Updater]
    USB --> T3[Tool 3: App Installer]
    
    T1 -->|Bước 1: Boot USB| OS[Cài đặt Windows 11 sạch sẽ siêu tốc]
    OS -->|Bước 2: Vào Win chạy| T2
    T2 -->|Bước 3: Màn hình nét, đủ Wifi| T3
    T3 --> Done[Hệ thống hoàn chỉnh sẵn sàng làm việc!]
```

| Công cụ | Vị trí trên USB | Chức năng chính |
| :--- | :--- | :--- |
| **Tool 1: Cài Win Tự Động** | Thư mục `ventoy/` | Boot USB, vượt rào cản phần cứng TPM/RAM/CPU, tự chia ổ đĩa, tạo tài khoản `Admin`, vào thẳng Desktop trong 5 - 8 phút. |
| **Tool 2: Driver Updater** | `Tools/2-Driver-Tool/` | Quét phần cứng, cập nhật card đồ họa (NVIDIA/AMD), âm thanh, Wifi qua SDI Offline hoặc máy chủ Microsoft Windows Update. |
| **Tool 3: App Installer** | `Tools/3-App-Tool/` | Cài đặt trọn bộ Visual C++ (2005-2022), Office 2024 LTSC (ODT), trình duyệt, công cụ lập trình (VS Code, Git, Python, NodeJS), tối ưu giao diện và đăng ký thương hiệu **Truong Con AOT**. |

---

## 📂 Cấu Trúc Thư Mục Dự Án

```plaintext
TruongConAOT/
├── .gitignore
├── README.md                           # Tài liệu hướng dẫn sử dụng
├── Setup-USB-Windows.bat               # Kịch bản 1-click trên Windows sao chép trọn bộ 3 tool vào USB
│
├── ventoy/                             # [TOOL 1] BỘ NẠP BOOT CÀI WIN TỰ ĐỘNG
│   ├── ventoy.json                     # Cấu hình nạp Theme Poly Dark & Bypass Win11
│   ├── ventoy_vhdboot.img              # Module boot VHD
│   ├── ventoy_wimboot.img              # Module boot WIM
│   ├── theme/poly-dark/                # Giao diện boot đồ họa màu tối cao cấp
│   └── unattend/                       # 3 Kịch bản cài Win sạch sẽ
│       ├── auto_wipe_disk_C.xml        # Máy trống: Tự xóa đĩa 0 và chia 1 ổ C
│       ├── auto_wipe_disk_C_D.xml      # Máy trống ổ lớn: Tự chia ổ C (150GB) + D (dữ liệu)
│       └── manual_disk_selection.xml   # Chọn ổ đĩa bằng tay: An toàn cho PC nhiều ổ SSD/HDD
│
└── Tools/                              # CÁC TOOL NẰM SẴN TRONG USB SAU KHI VÀO WIN
    ├── 2-Driver-Tool/                  # [TOOL 2] KIỂM TRA & CÀI ĐẶT DRIVER
    │   ├── Run-DriverUpdater.bat       # File chạy 1-click (Double-click là chạy)
    │   ├── driver-engine.ps1           # Engine quét SDI + Windows Update API
    │   └── README.md                   # Hướng dẫn chi tiết
    │
    └── 3-App-Tool/                     # [TOOL 3] CÀI PHẦN MỀM & MÔI TRƯỜNG DEV
        ├── Run-AppInstaller.bat        # File chạy 1-click (Double-click là chạy)
        ├── app-engine.ps1              # Master engine cài app, VC++ AIO, Tweaks
        ├── apps.ini                    # Bật/tắt danh sách phần mềm muốn cài
        ├── configure-windows.ps1       # Tinh chỉnh Windows, Dark mode, gỡ bloatware
        └── office/                     # Module Office 2024 LTSC qua ODT chính hãng
            ├── Install-Office.ps1      # Tự tải ODT và cài đặt ngầm
            ├── wep_en.xml              # Word, Excel, PowerPoint (EN)
            ├── wep_vi.xml              # Word, Excel, PowerPoint (VI)
            ├── full_en.xml             # Trọn bộ Office 2024 (EN)
            └── full_vi.xml             # Trọn bộ Office 2024 (VI)
```

---

## 🚀 Hướng Dẫn Sử Dụng (Quy Trình 3 Bước Chuẩn Chỉ)

### Bước 1: Chuẩn Bị Chiếc USB Trên Máy Windows
1. Tải công cụ [Ventoy for Windows](https://www.ventoy.net/en/download.html) (file `ventoy-x.x.xx-windows.zip` rồi giải nén).
2. Chạy file `Ventoy2Disk.exe`, cắm USB vào, chọn **Option -> Partition Style -> GPT**, bấm **Install**.
3. Clone dự án này về máy Windows:
   ```cmd
   git clone https://github.com/huypv2002/TruongConAOT.git
   cd TruongConAOT
   ```
4. Chuột phải vào file **`Setup-USB-Windows.bat`** -> chọn **Run as administrator** -> nhập ký tự ổ USB (ví dụ: `E`). Toàn bộ kịch bản và 3 công cụ sẽ được tự động copy vào USB.
5. Tải file ISO Windows 11 từ Microsoft, đổi tên thành **`Win11.iso`** và copy thả vào thư mục gốc của USB.

---

### Bước 2: Dùng Tool 1 Để Cài Đặt Windows 11 Tự Động
1. Cắm USB vào máy tính cần cài, bật nguồn và bấm phím tắt Boot Menu:
   - **HP**: Bấm phím **`F9`**
   - **Dell**: Bấm phím **`F12`**
   - **ASUS PC**: Bấm **`F8`** (Laptop ASUS bấm **`Esc`**)
   - **Mainboard PC tự ráp (Gigabyte/MSI/ASRock)**: Bấm **`F11`** hoặc **`F12`**
2. Chọn boot vào USB Ventoy (UEFI).
3. Màn hình Poly Dark xuất hiện -> Chọn file **`Win11.iso`**.
4. Menu tự động hiện lên:
   - Nếu máy trống: Chọn **`auto_wipe_disk_C.xml`**.
   - Nếu PC cắm nhiều ổ cứng có dữ liệu: Chọn **`manual_disk_selection.xml`** để tự click chọn ổ SSD mong muốn.
5. Máy sẽ tự cài đặt và vào thẳng màn hình Desktop trong 5 - 8 phút!

---

### Bước 3: Dùng Tool 2 & Tool 3 Trong Màn Hình Windows
Khi đã vào màn hình Desktop Windows 11, bạn mở ổ USB ra sẽ thấy ngay thư mục **`Tools`**:

#### 1. Cập nhật Driver (Tool 2):
- Vào thư mục `Tools\2-Driver-Tool\` -> Nhấp đúp chuột vào file **`Run-DriverUpdater.bat`**.
- Tool sẽ tự động quét linh kiện phần cứng và kéo đầy đủ driver chuẩn xác về máy.

#### 2. Cài đặt Phần mềm & Tối ưu hóa (Tool 3):
- Vào thư mục `Tools\3-App-Tool\` -> Nhấp đúp chuột vào file **`Run-AppInstaller.bat`**.
- Tool sẽ tự động:
  - Cài đặt trọn bộ Microsoft Visual C++ Redistributable (2005 - 2022).
  - Bật Developer Mode & cho phép đường dẫn dài (> 260 ký tự) cho lập trình viên.
  - Cài đặt Microsoft Office 2024 LTSC chính hãng theo template đã chọn.
  - Cài đặt sạch các phần mềm đã chọn trong `apps.ini` (Chrome, VS Code, Git, Python, NodeJS, Unikey, Zalo...).
  - Dọn dẹp bloatware rác của Windows 11, kích hoạt Dark Mode, tối ưu Taskbar.
  - Ghi nhận thông tin bản dựng mang thương hiệu **Truong Con AOT**.
