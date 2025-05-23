# FE-Mobile-IoT-Screening

Đây là một ứng dụng Flutter hỗ trợ quản lý lớp học, bài giảng, thông báo và tích hợp các dịch vụ IoT.

## Mục lục

- [Cấu trúc thư mục](#cấu-trúc-thư-mục)
- [Cài đặt](#cài-đặt)
- [Chạy ứng dụng](#chạy-ứng-dụng)
- [Môi trường](#môi-trường)
- [Công nghệ sử dụng](#công-nghệ-sử-dụng)
- [Đóng góp](#đóng-góp)

---

## Cấu trúc thư mục
```sh
  ├── lib/ # Thư mục chính của ứng dụng Flutter
  │   ├── core/ # Thành phần cốt lõi và tiện ích dùng chung
  │   │   ├── component/ # Các thành phần giao diện tái sử dụng
  │   │   ├── decorations/ # Định nghĩa giao diện (phông chữ, nút bấm, v.v.)
  │   │   ├── ultis/ # Các tiện ích bổ trợ
  │   ├── model/ # Định nghĩa các lớp mô hình dữ liệu
  │   │   ├── classes.dart
  │   │   ├── lecture.dart
  │   ├── network/ # Cấu hình API và giao tiếp mạng
  │   │   ├── api_urls.dart
  │   ├── providers/ # Quản lý trạng thái ứng dụng
  │   │   ├── auth_provider.dart
  │   │   ├── classes_provider.dart
  │   │   ├── custom_stt_provider.dart
  │   │   ├── lectures_provider.dart
  │   ├── repositories/ # Xử lý logic giao tiếp với API
  │   │   ├── lectures_repository.dart
  │   ├── services/ # Các dịch vụ hỗ trợ
  │   │   ├── auth_service.dart
  │   │   ├── notification_service.dart
  │   │   ├── web_socket_services.dart
  │   ├── ui/ # Thành phần giao diện người dùng
  │   │   ├── authentication/ # Giao diện xác thực
  │   │   ├── home/ # Giao diện chính của ứng dụng
  │   │   ├── widget/ # Các widget tái sử dụng
  │   ├── main.dart # Điểm khởi đầu của ứng dụng
  ├── [pubspec.yaml](http://_vscodecontentref_/1) # Thông tin và dependencies của dự án
  ├── .gitignore # File ignore cho Git
```
## Cài đặt
Yêu cầu hệ thống
- Flutter SDK phiên bản mới nhất.
- Dart SDK.
- Android Studio hoặc Xcode (nếu chạy trên thiết bị thật hoặc giả lập).

Các bước cài đặt
1. Clone dự án:
    ```sh
    git clone <repository-url>
    cd FE-Mobile-IoT-Screening
    ```
2. Cài đặt các gói phụ thuộc:
    ```sh
    flutter pub get
    ```
## Chạy ứng dụng
1. Chạy ứng dụng trên thiết bị thật hoặc giả lập:
    ```sh
    flutter run
    ```
2. Để build ứng dụng cho Android:
    ```sh
    flutter build apk
    ```
3. Để build ứng dụng cho iOS:
    ```sh
    flutter build iosP
    ```
## Môi trường
- Dart SDK: Được sử dụng để phát triển ứng dụng Flutter.
- Flutter SDK: Framework chính để xây dựng giao diện người dùng.
- Firebase: Tích hợp cho thông báo và các dịch vụ backend.
## Công nghệ sử dụng
- Flutter: Framework phát triển giao diện người dùng đa nền tảng.
- Provider: Quản lý trạng thái ứng dụng.
- WebSocket: Giao tiếp thời gian thực.
- Firebase: Tích hợp thông báo đẩy và các dịch vụ backend.
- REST API: Giao tiếp với backend thông qua các API.
## Đóng góp
Nếu bạn muốn đóng góp cho dự án, vui lòng tạo một Pull Request hoặc mở một Issue để thảo luận.