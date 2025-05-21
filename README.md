## Mô tả các thành phần

### 1. **core/**
Chứa các thành phần cốt lõi và các tiện ích dùng chung trong ứng dụng:
- **component/**: Các thành phần giao diện tái sử dụng, ví dụ: `loading_animation.dart` để hiển thị hiệu ứng tải.
- **decorations/**: Các định nghĩa về giao diện như kiểu nút bấm, phông chữ, và trang trí đầu vào.
- **ultis/**: Các tiện ích bổ trợ (nếu có).

### 2. **model/**
Chứa các lớp mô hình dữ liệu:
- `classes.dart`: Mô hình dữ liệu cho lớp học.
- `lecture.dart`: Mô hình dữ liệu cho bài giảng.

### 3. **network/**
Chứa các URL API và các cấu hình liên quan đến mạng:
- `api_urls.dart`: Định nghĩa các URL API được sử dụng trong ứng dụng.

### 4. **providers/**
Chứa các lớp quản lý trạng thái sử dụng mô hình `Provider`:
- `auth_provider.dart`: Quản lý trạng thái xác thực người dùng.
- `classes_provider.dart`: Quản lý trạng thái liên quan đến lớp học.
- `custom_stt_provider.dart`: Quản lý trạng thái liên quan đến nhận diện giọng nói.
- `lectures_provider.dart`: Quản lý trạng thái liên quan đến bài giảng.

### 5. **repositories/**
Chứa các lớp xử lý logic giao tiếp với API:
- `lectures_repository.dart`: Xử lý các yêu cầu API liên quan đến bài giảng.

### 6. **services/**
Chứa các dịch vụ hỗ trợ:
- `auth_service.dart`: Dịch vụ xác thực người dùng.
- `notification_service.dart`: Dịch vụ thông báo.
- `web_socket_services.dart`: Dịch vụ WebSocket.

### 7. **ui/**
Chứa các thành phần giao diện người dùng:
- **authentication/**: Giao diện liên quan đến xác thực (đăng nhập, đặt lại mật khẩu, v.v.).
- **home/**: Giao diện chính của ứng dụng, bao gồm danh sách bài giảng, chi tiết bài giảng,
- **widget/**: Các widget tái sử dụng trong giao diện.

### 8. **main.dart**