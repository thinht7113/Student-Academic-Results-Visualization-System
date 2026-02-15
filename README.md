<<<<<<< HEAD
# Student Performance Visualization & AI Advisor
**(Phần mềm Desktop Trực quan hóa Kết quả Học tập & Cố vấn AI)**

> Ứng dụng Desktop giúp sinh viên theo dõi và trực quan hóa dữ liệu học tập cá nhân, tích hợp AI (Google Gemini) để phân tích xu hướng và đưa ra lời khuyên cải thiện điểm số.

---

## 🛠 Công nghệ sử dụng

| Thành phần | Công nghệ | Chi tiết |
| :--- | :--- | :--- |
| **Core Language** | Python 3.10+ | |
| **Backend API** | Flask | RESTful API, xử lý nghiệp vụ, xác thực JWT. |
| **Database** | SQLite + SQLAlchemy | ORM, thiết kế CSDL quan hệ chuẩn hóa. |
| **Desktop Client** | CustomTkinter | GUI hiện đại (Dark/Light mode), Matplotlib (Biểu đồ). |
| **Admin Web** | HTML/CSS/Bootstrap | Giao diện quản trị viên trên trình duyệt. |
| **AI Integration** | Google Gemini API | Phân tích dữ liệu học tập, Chatbot cố vấn. |

---

## 🏗 Kiến trúc Hệ thống

Hệ thống hoạt động theo mô hình **Client-Server**:

1.  **Backend (Server):** Chạy API trung tâm, quản lý Database, xử lý Logic cảnh báo học vụ và phân quyền.
2.  **Student App (Client):** Ứng dụng Desktop kết nối tới Backend qua API để lấy dữ liệu và vẽ biểu đồ trực quan cho sinh viên.

---

## 🚀 Chức năng chính

### 1. Student App (Dành cho Sinh viên)
* **Trực quan hóa dữ liệu (Visualization):** Biểu đồ xu hướng GPA qua các kỳ, phân tích môn điểm cao/thấp.
* **Mô phỏng GPA (Simulator):** Tính toán kịch bản điểm số (VD: *"Nếu kỳ này môn A được 8.0 thì CPA sẽ tăng bao nhiêu?"*).
* **Cố vấn AI (AI Advisor):** Chatbot tích hợp Gemini, đưa ra lời khuyên dựa trên bảng điểm thực tế của sinh viên.
* **Tra cứu:** Xem chi tiết bảng điểm, tín chỉ và tiến độ học tập.

### 2. Admin Web (Dành cho Quản lý)
* **Dashboard:** Thống kê tổng quan sinh viên, học phần.
* **Hệ thống cảnh báo (Warning System):** Tự động quét sinh viên có nguy cơ (GPA thấp, nợ tín chỉ vượt mức) theo luật cấu hình động.
* **Quản lý dữ liệu:** Import danh sách Sinh viên, Điểm, Chương trình đào tạo từ file Excel.

---

## ⚙️ Cài đặt & Hướng dẫn sử dụng

### Yêu cầu
* Python 3.10 trở lên.
* Hệ điều hành: Windows, macOS hoặc Linux.

### Bước 1: Cài đặt môi trường
```bash
# Tạo môi trường ảo
python -m venv .venv

# Kích hoạt môi trường (Windows)
.venv\Scripts\activate

# Cài đặt thư viện
pip install -r requirements.txt
=======
# Hệ Thống Quản Lý Điểm Sinh Viên & Trợ Lý Học Tập

Dự án phần mềm quản lý điểm sinh viên tích hợp ứng dụng dành cho sinh viên với các tính năng thông minh như Mô phỏng GPA và Trợ lý ảo AI.

## 🏗️ Kiến trúc Hệ thống

| Thành phần | Công nghệ | Mô tả |
|-----------|-----------|-------|
| **Backend & Admin Web** | Flask, SQLAlchemy, SQLite | Quản lý dữ liệu, API, giao diện Admin |
| **Student Desktop** | Python, CustomTkinter | Ứng dụng desktop cho sinh viên |
| **Student Mobile** | Flutter, Dart | Ứng dụng di động cho sinh viên |
| **Deployment** | Docker, Gunicorn | Container hóa backend |

---

## 🚀 Tính năng nổi bật

### 1. Dành cho Quản trị viên (Admin Web)
*   **Bảng điều khiển (Dashboard)**: Thống kê tổng quan sinh viên, học phần.
*   **Nhập dữ liệu (Import)**: Hỗ trợ nhập danh sách sinh viên, điểm, chương trình học từ Excel.
*   **Quản lý Cảnh báo (Warning System)**:
    *   Tự động quét và phát hiện sinh viên có nguy cơ (GPA thấp, nợ nhiều tín chỉ).
    *   Cấu hình các luật cảnh báo linh hoạt.
*   **Quản lý người dùng**: Phân quyền Admin/User.

### 2. Dành cho Sinh viên (Mobile & Desktop)
*   **Tổng quan cá nhân**: Biểu đồ xu hướng GPA theo kỳ, Top môn điểm cao/thấp.
*   **Tra cứu bảng điểm & Chương trình học**: Xem chi tiết điểm số, tiến độ hoàn thành chương trình.
*   **Phân tích học tập**: Biểu đồ phân bố điểm, scatter plot tín chỉ vs điểm, bảng môn kéo tụt CPA.
*   **Mô phỏng GPA (Simulator)**: Giả định điểm các môn sắp học, gợi ý điểm cần đạt.
*   **Cố vấn AI (Advisor)**: Chatbot tích hợp Google Gemini AI, tư vấn dựa trên dữ liệu thực tế.

---

## 🛠️ Hướng dẫn Cài đặt & Chạy

### Yêu cầu hệ thống
*   Python 3.10+ (cho Backend & Desktop App)
*   Flutter 3.x (cho Mobile App)
*   Docker & Docker Compose (tùy chọn, cho deployment)

### Cách 1: Chạy bằng Docker (Khuyến khích cho Backend)

```bash
# Clone repo
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
SECRET_KEY=your-secret-key
JWT_SECRET_KEY=your-jwt-secret
```

> ⚠️ **Lưu ý**: File `.env` và thư mục `secrets/` KHÔNG được commit vào git.

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
>>>>>>> e2da918 (feat: implement dark mode across all screens and widgets)
