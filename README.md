# Hệ Thống Quản Lý Điểm Sinh Viên & Trợ Lý Học Tập

Dự án phần mềm quản lý điểm sinh viên tích hợp ứng dụng dành cho sinh viên với các tính năng thông minh như Mô phỏng GPA và Trợ lý ảo AI, giúp sinh viên theo dõi và cải thiện kết quả học tập.

[![GitHub license](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)
[![Python](https://img.shields.io/badge/python-3.10%2B-blue)](https://www.python.org/)
[![Flutter](https://img.shields.io/badge/flutter-3.x-02569B)](https://flutter.dev/)

---

## 🏗️ Kiến trúc Hệ thống

Hệ thống hoạt động theo mô hình Client-Server đa nền tảng:

| Thành phần | Công nghệ | Mô tả |
| :--- | :--- | :--- |
| **Student Mobile** | Flutter, Dart | Ứng dụng di động (Android/iOS) cho sinh viên, hỗ trợ **Dark Mode**. |
| **API Backend** | RESTful | Giao tiếp qua HTTP/HTTPS với backend chính (tại nhánh `main`). |

---

## 🚀 Tính năng nổi bật

### Dành cho Sinh viên (Mobile App)
*   **Trực quan hóa dữ liệu (Visualization)**: Biểu đồ xu hướng GPA/CPA qua các kỳ, phân bố điểm số.
*   **Chế độ tối (Dark Mode)**: Giao diện tối hiện đại, bảo vệ mắt.
*   **Chiến lược học tập**: Tư vấn lộ trình và đặt mục tiêu học tập qua Giao tiếp AI.
*   **Tra cứu thông tin**: Xem chi tiết bảng điểm, tín chỉ tích lũy.

---

## 🛠️ Hướng dẫn Cài đặt & Chạy Mobile App

```bash
git clone -b mobile-app https://github.com/thinht7113/Student-Academic-Results-Visualization-System.git
cd "Student-Academic-Results-Visualization-System/mobile"
```

### Chạy Mobile App

```bash
cd mobile

# Cài đặt dependencies
flutter pub get

# Chạy debug (Chrome)
flutter run -d chrome

# Chạy debug (Android Emulator)
flutter run -d emulator
```

### Cấu hình môi trường

Tùy theo thư viện Flutter bạn sử dụng mà cấu hình URL API Backend (hiện tại backend nằm ở nhánh `main`). Mặc định có thể là `http://10.0.2.2:5000` (đối với Android Emulator) hoặc IP LAN nếu chạy trên thiết bị thật.

---

## 📂 Cấu trúc thư mục

Do đây là nhánh dành riêng cho Mobile, mã nguồn chủ yếu bao gồm thư mục Flutter:

```
Score Management Project/
├── mobile/                 # Mobile App (Flutter)
│   ├── android/            # Native Android code
│   ├── ios/                # Native iOS code
│   └── lib/
│       ├── models/         # Data models
│       ├── providers/      # State management (Provider)
│       ├── screens/        # UI screens
│       ├── services/       # API service (HTTP/Dio requests)
│       ├── utils/          # Theme, constants
│       └── widgets/        # Reusable widgets
└── README.md               # Tài liệu này
```

---

