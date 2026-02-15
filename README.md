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
| **Backend & Admin Web** | Flask, SQLAlchemy, SQLite | RESTful API, quản lý dữ liệu trung tâm, giao diện Admin trên trình duyệt. |
| **Student Mobile** | Flutter, Dart | Ứng dụng di động (Android/iOS) cho sinh viên, hỗ trợ **Dark Mode**. |
| **Student Desktop** | Python, CustomTkinter | Ứng dụng desktop cho sinh viên với giao diện hiện đại. |
| **AI Integration** | Google Gemini API | Phân tích dữ liệu học tập, Chatbot cố vấn học tập thông minh. |

---

## 🚀 Tính năng nổi bật

### 1. Dành cho Sinh viên (Mobile & Desktop App)
*   **Trực quan hóa dữ liệu (Visualization)**: Biểu đồ xu hướng GPA/CPA qua các kỳ, top môn điểm cao/thấp, phân bố điểm số.
*   **Chế độ tối (Dark Mode)**: Giao diện tối hiện đại, bảo vệ mắt (Mobile App).
*   **Mô phỏng GPA (Simulator)**: Giả định điểm các môn sắp học để xem CPA dự kiến thay đổi ra sao, hỗ trợ đặt mục tiêu điểm số.
*   **Cố vấn AI (AI Advisor)**: Chatbot tích hợp Gemini 2.5, tư vấn lộ trình học tập dựa trên bảng điểm thực tế của sinh viên.
*   **Tra cứu thông tin**: Xem chi tiết bảng điểm, tín chỉ tích lũy, tiến độ chương trình đào tạo.

### 2. Dành cho Quản trị viên (Admin Web)
*   **Dashboard**: Thống kê tổng quan sinh viên, học phần, cảnh báo học vụ.
*   **Quản lý Cảnh báo (Warning System)**: Tự động quét và phát hiện sinh viên có nguy cơ (GPA thấp, nợ nhiều tín chỉ) theo luật cấu hình động.
*   **Quản lý dữ liệu**: Import danh sách Sinh viên, Điểm, Chương trình đào tạo từ file Excel.
*   **Phân quyền**: Quản lý tài khoản và quyền truy cập Admin/User.

---

## 🛠️ Hướng dẫn Cài đặt & Chạy

### Yêu cầu hệ thống
git clone <repo-url>
cd "Score Management Project"

# Tạo file .env cho backend
cp backend/.env.example backend/.env
# Sửa GEMINI_API_KEY trong .env

# Khởi chạy
docker compose up -d

# Server chạy tại: http://127.0.0.1:5000
```

### Cách 2: Chạy thủ công

```bash
# Tạo môi trường ảo
python -m venv .venv
# Windows:
.venv\Scripts\activate
# Linux/Mac:
source .venv/bin/activate

# Cài đặt dependencies
pip install -r backend/requirements.txt

# Chạy Backend
python -m backend.app
# Server: http://127.0.0.1:5000

# Chạy Desktop App (terminal mới)
python -m student.app
```

### Cách 3: Chạy Mobile App

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

Tạo file `backend/.env`:
```env
GEMINI_API_KEY=YOUR_API_KEY_HERE
GEMINI_MODEL=gemini-2.5-flash-lite
```



---

## 📂 Cấu trúc thư mục

```
Score Management Project/
├── backend/                # Backend Flask
│   ├── admin_ui/           # Giao diện Web Admin (Templates/Static)
│   ├── app.py              # Flask App chính
│   ├── admin_crud.py       # API endpoints cho Admin
│   ├── warning_scan.py     # Logic quét cảnh báo học vụ
│   ├── models.py           # Database Models
│   ├── seed.py             # Dữ liệu mẫu
│   └── requirements.txt    # Python dependencies
│
├── student/                # Desktop App (CustomTkinter)
│   ├── views/              # Các màn hình
│   ├── widgets/            # UI components
│   └── app.py              # Entry point Desktop
│
├── mobile/                 # Mobile App (Flutter)
│   └── lib/
│       ├── models/         # Data models
│       ├── providers/      # State management (Provider)
│       ├── screens/        # UI screens
│       ├── services/       # API service
│       ├── utils/          # Theme, constants
│       └── widgets/        # Reusable widgets
│
├── Dockerfile              # Multi-stage Docker build
├── docker-compose.yml      # Docker Compose config
├── .gitignore              # Git ignore rules
└── README.md               # Tài liệu này
```

---

## 📝 Tài khoản mặc định

| Loại | Username | Password |
|------|----------|----------|
| Admin | `admin` | `admin123` |

Để tạo dữ liệu mẫu:
```bash
python -m backend.seed
```
