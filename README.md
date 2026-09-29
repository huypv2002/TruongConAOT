# Auto-Win 11: Bộ Công Cụ Cài Đặt & Cấu Hình Windows 11 Tự Động 100%

Dự án tự động hóa toàn diện quá trình cài đặt Windows 11 trên nền tảng **Ventoy + Microsoft Unattended Setup + PowerShell AutoInstaller Engine**. Toàn bộ cấu trúc được tối ưu hóa 100% cho môi trường **Windows**, không phụ thuộc vào bất kỳ công cụ của macOS nào.

---

## 🌟 Điểm Nổi Bật

- **Menu Boot Đồ Họa Cực Đẹp**: Tích hợp Theme GRUB2 Poly Dark hiện đại với icon nhận diện hệ điều hành.
- **Bypass 100% Yêu Cầu Phần Cứng**: Vượt qua TPM 2.0, Secure Boot, RAM, CPU check trên mọi dòng máy (kể cả máy đời cũ/máy ảo).
- **Tự Động Phân Vùng Đĩa (GPT/UEFI)**: Kịch bản `autounattend_auto.xml` tự động xóa sạch ổ đĩa 0 và chia phân vùng EFI (300MB), MSR (16MB), ổ C NTFS sạch sẽ.
- **Tắt BitLocker Device Encryption**: Ngăn chặn Windows tự động mã hóa ổ đĩa gây rủi ro mất dữ liệu.
- **Bypass Màn Hình Khảo Sát (OOBE)**: Bỏ qua ép buộc kết nối mạng, bỏ qua ép đăng nhập tài khoản Microsoft, tự tạo tài khoản Offline `Admin` (không đặt pass), vào thẳng Desktop.
- **AutoInstaller Engine (PowerShell)**: Sau khi vào Desktop, kịch bản tự động quét USB, đọc file `config.ini` để cài đặt ứng dụng (qua Winget hoặc offline), cập nhật driver (SDI), cài font và tinh chỉnh hệ thống.
- **Sạch Sẽ & Hợp Pháp**: Không chứa bất kỳ mã độc, backdoor hay script bẻ khóa (crack) lậu.

---

## 📂 Cấu Trúc Thư Mục

```plaintext
auto-win/
├── .gitignore                      # Bỏ qua file nhị phân lớn (.iso, .mp4, .dmg)
├── README.md                       # Tài liệu hướng dẫn sử dụng chi tiết
│
├── ventoy/                         # Toàn bộ cấu hình nạp vào USB Ventoy
│   ├── ventoy.json                 # Cấu hình plugin Ventoy (Theme, Auto_Install, Win11 bypass)
│   ├── autounattend_auto.xml       # Kịch bản 1: Tự động 100% (Xóa và chia ổ đĩa 0)
│   ├── autounattend_manual_disk.xml# Kịch bản 2: Bán tự động (Dừng lại để tự chọn ổ đĩa)
│   ├── ventoy_vhdboot.img          # Module hỗ trợ boot VHD của Ventoy
│   ├── ventoy_wimboot.img          # Module hỗ trợ boot WIM của Ventoy
│   └── theme/
│       └── poly-dark/              # Giao diện bootloader GRUB2 màu tối cao cấp
│
└── scripts/                        # Bộ công cụ tự động hóa chạy trên Windows
    ├── AutoInstaller.ps1           # Engine cài app, driver, tweaks chạy lúc First Logon
    ├── config.ini                  # File INI cấu hình danh sách app cần cài
    └── Setup-USB-Windows.bat       # Kịch bản 1-click trên Windows đồng bộ file vào USB
```

---

## 🚀 Hướng Dẫn Sử Dụng Trên Máy Windows (Step-by-Step)

### Bước 1: Chuẩn Bị USB Bằng Ventoy Chính Chủ
1. Tải công cụ **Ventoy for Windows** chính thức: [Trang chủ Ventoy](https://www.ventoy.net/en/download.html) (tải file `ventoy-x.x.xx-windows.zip`).
2. Giải nén và chạy file **`Ventoy2Disk.exe`**.
3. Cắm chiếc USB của bạn vào máy tính.
4. Trên thanh menu của Ventoy, vào **Option** -> **Partition Style** -> chọn **GPT**.
5. Bấm nút **Install** để tiến hành cài Ventoy vào USB (Lưu ý: Thao tác này sẽ format trắng USB).

### Bước 2: Đồng Bộ Dự Án Này Vào USB (1-Click)
1. Clone hoặc pull repository này về máy Windows:
   ```cmd
   git clone <URL_REPO_CUA_BAN>
   cd auto-win
   ```
2. Chuột phải vào file `scripts\Setup-USB-Windows.bat` -> chọn **Run as administrator**.
3. Nhập ký tự ổ đĩa USB của bạn (ví dụ: `E` hoặc `F`) -> Bấm Enter.
4. Kịch bản sẽ tự động sao chép toàn bộ thư mục `ventoy\` và `scripts\` vào đúng vị trí trên USB của bạn.

### Bước 3: Tải Bộ Cài Windows 11 Nguyên Gốc (ISO)
1. Tải file ISO Windows 11 từ Microsoft: [Microsoft Windows 11 Download](https://www.microsoft.com/software-download/windows11).
2. Đổi tên file tải về thành: **`Win11.iso`**
3. Chép file `Win11.iso` thả thẳng vào thư mục gốc của USB.

### Bước 4: Cắm Vào Máy HP Và Cài Đặt Tự Động
1. Cắm USB vào máy HP (máy đang tắt).
2. Bật nguồn máy HP và **bấm liên tục phím `F9`** để mở Boot Menu.
3. Chọn boot vào thiết bị **UEFI: USB Ventoy**.
4. Màn hình giao diện Poly Dark hiện ra -> Chọn file **`Win11.iso`**.
5. Chọn kịch bản cài đặt:
   - 👉 **`Boot with /ventoy/autounattend_auto.xml`**: Dành cho máy trống, máy sẽ tự xóa sạch đĩa và cài tự động từ đầu đến cuối!
   - 👉 **`Boot with /ventoy/autounattend_manual_disk.xml`**: Dành cho máy đang có dữ liệu ở ổ D/E, kịch bản sẽ dừng lại ở màn hình phân vùng để bạn tự bấm chọn ổ C.
6. Ngồi đợi 15 - 20 phút, máy sẽ tự khởi động lại và vào thẳng Desktop Windows 11!

---

## ⚙️ Tùy Chỉnh Ứng Dụng Trong `scripts/config.ini`

Bạn có thể mở file `scripts/config.ini` bằng Notepad để bật/tắt các ứng dụng và tính năng theo nhu cầu:

```ini
[Tweaks]
EnableDarkMode=true              ; Bật giao diện tối
ShowFileExtensions=true          ; Hiện đuôi tập tin (.txt, .exe, .ps1...)
AlignTaskbarLeft=true            ; Căn thanh taskbar sang bên trái
DisableBitLocker=true            ; Ngăn chặn khóa ổ đĩa tự động

[Applications]
; Cú pháp: AppKey = Kích_hoạt(true/false) | Mã_Winget_hoặc_Tên_File | Tên_hiển_thị
GoogleChrome=true|Google.Chrome|Google Chrome
VSCode=true|Microsoft.VisualStudioCode|Visual Studio Code
Git=true|Git.Git|Git SCM
Python=true|Python.Python.3.12|Python 3.12
NodeJS=true|OpenJS.NodeJS.LTS|Node.js LTS
Unikey=true|Unikey.Unikey|UniKey Tiếng Việt
Zalo=true|VNG.Zalo|Zalo PC
7Zip=true|7zip.7zip|7-Zip
```

- Nếu muốn cài thêm ứng dụng nào, bạn chỉ cần chuyển giá trị thành `true`.
- Có thể tìm thêm mã gói ứng dụng bằng lệnh: `winget search <tên_app>`.

---

## 🛠️ Đẩy Lên Git & Kéo Về Trên Máy Windows

Từ máy tính hiện tại, bạn có thể commit và push lên Git:
```bash
git add .
git commit -m "feat: complete windows 11 unattended auto setup toolkit"
git branch -M main
git remote add origin <URL_GITHUB_CUA_BAN>
git push -u origin main
```

Khi sang máy HP (Windows), bạn chỉ cần mở Command Prompt hoặc PowerShell:
```cmd
git clone <URL_GITHUB_CUA_BAN>
```
Toàn bộ mã nguồn, script batch, powershell và cấu hình USB sẽ sẵn sàng để bạn sử dụng ngay lập tức!
