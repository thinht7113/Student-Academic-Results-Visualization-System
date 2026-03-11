# 🎓 Student Performance Visualization & AI Advisor
**(Hệ thống Trực quan hóa Kết quả Học tập & Cố vấn Học tập AI)**

Ứng dụng toàn diện theo mô hình Client-Server giúp sinh viên theo dõi, trực quan hóa dữ liệu học tập cá nhân, đồng thời cung cấp hệ thống quản trị mạnh mẽ cho Cán bộ đào tạo. Đặc biệt, hệ thống tích hợp **Google Gemini AI** để phân tích xu hướng và đóng vai trò như một cố vấn học tập ảo (AI Advisor) đưa ra lộ trình cải thiện điểm số.

---

## ✨ Tính năng nổi bật

### 🎓 Dành cho Sinh viên (Desktop App)
* **Trực quan hóa Dữ liệu (Visualization):** Vẽ biểu đồ (Matplotlib) phân tích xu hướng GPA/CPA qua các học kỳ, đánh giá tỷ lệ môn đạt/trượt và điểm số trung bình.
* **Mô phỏng Điểm số (GPA Simulator):** Cho phép sinh viên nhập điểm dự kiến của các học phần đang học để tính toán thử sự thay đổi của CPA.
* **AI Advisor (Cố vấn học tập AI):** Chatbot thông minh tích hợp **Gemini 2.5 Pro**, đọc hiểu bối cảnh bảng điểm hiện tại của sinh viên để đưa ra lời khuyên cá nhân hóa về việc chọn môn, cải thiện GPA và quy chế tín chỉ.
* **Theo dõi Tiến trình:** Xem chi tiết bảng điểm, tín chỉ tích lũy và so sánh với khung chương trình đào tạo chuẩn.

### 👨‍💼 Dành cho Quản trị viên (Web Admin & API)
* **Dashboard Thống kê:** Bảng điều khiển tổng quan về tỷ lệ sinh viên qua môn, rớt môn, tổng số tín chỉ và KPI chất lượng đào tạo.
* **Hệ thống Cảnh báo Học vụ (Warning System):** Tự động quét và phát hiện sinh viên có nguy cơ (GPA dưới ngưỡng, nợ quá số tín chỉ cho phép). Các ngưỡng này có thể cấu hình động (Dynamic Rules).
* **Quản lý Dữ liệu Hàng loạt:** Hỗ trợ import/export dữ liệu Sinh viên, Điểm số, Chương trình đào tạo và Lớp học qua file Excel/CSV.
* **Cấu hình Hệ thống:** Quản lý các tham số cốt lõi như `GPA_GIOI_THRESHOLD`, `TINCHI_NO_CANHCAO_THRESHOLD` trực tiếp trên giao diện.

---

## 💻 Công nghệ sử dụng

Dự án được xây dựng với các công nghệ hiện đại, phân tách rõ ràng giữa Backend và UI:

| Thành phần | Công nghệ / Thư viện | Vai trò cốt lõi |
| :--- | :--- | :--- |
| **Backend API** | Python, Flask, Flask-RESTful | Xử lý logic nghiệp vụ, cung cấp RESTful API. |
| **Bảo mật** | Flask-JWT-Extended, Passlib | Mã hóa mật khẩu (Bcrypt), xác thực người dùng qua JWT. |
| **Database** | SQLite + SQLAlchemy (ORM) | Lưu trữ dữ liệu quan hệ (chế độ WAL tối ưu hiệu suất đọc/ghi). |
| **Desktop Client**| CustomTkinter, Matplotlib | Giao diện người dùng đồ họa (GUI) hiện đại có Dark/Light mode. |
| **AI Integration**| Google Generative AI (Gemini) | Cung cấp dịch vụ Cố vấn học tập NLP. |
| **Deployment** | Docker, Docker Compose | Đóng gói và triển khai Backend dễ dàng, đồng nhất. |

---

## 🗂 Kiến trúc Hệ thống

```text
├── backend/                  # REST API Server (Flask)
│   ├── app.py                # Điểm vào của Backend, định nghĩa các API routes
│   ├── models.py             # Định nghĩa cấu trúc Database (SQLAlchemy)
│   ├── services/             # Logic nghiệp vụ (Analytics, Importer...)
│   └── app.db                # Cơ sở dữ liệu SQLite
├── Desktop/                  # Ứng dụng Client cho sinh viên
│   ├── app.py                # Điểm vào của ứng dụng Desktop (CustomTkinter)
│   ├── api/client.py         # Module giao tiếp với Backend API
│   ├── views/                # Các màn hình (Login, Dashboard, Analytics, Simulator)
│   └── state/                # Quản lý trạng thái (Token, User info)
└── docker-compose.yml        # File triển khai Docker cho Backend
