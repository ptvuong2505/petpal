# PetPal

PetPal là ứng dụng Flutter quản lý dịch vụ chăm sóc thú cưng. Dự án này đang dùng dữ liệu local để team newbie có thể chia task, hiểu luồng code, và mở rộng từng module trước khi cần API thật.

## Công Nghệ Sử Dụng

- Flutter
- Provider để quản lý state
- Navigator 2.0 để điều hướng
- SQLite với sqflite để lưu dữ liệu local

Package cần dùng:

```bash
flutter pub add provider sqflite path
```

## Cấu Trúc Thư Mục

```txt
lib/
  main.dart
  app/
    app.dart
    app_router.dart
    app_route_path.dart
    app_route_parser.dart
  core/
    constants/
    database/
    utils/
    services/
  shared/
    widgets/
    layouts/
  features/
    auth/
    user_profile/
    pet_profile/
    health_record/
    booking/
    time_slot/
    review/
    staff_examination/
    reminder/
    admin_dashboard/
    shop_setting/
  config/
    app_config.dart
```

Ý nghĩa chính:

- `app/`: cấu hình app, `MaterialApp.router`, `RouterDelegate`, route path và parser.
- `core/`: hằng số, database SQLite, service dùng chung, helper và validator.
- `shared/`: widget và layout dùng lại ở nhiều feature.
- `features/`: mỗi chức năng nằm trong thư mục riêng, dễ chia task.
- `config/`: cấu hình môi trường đơn giản cho app.

Mỗi feature có cấu trúc:

```txt
models/
pages/
providers/
repositories/
data/
```

## Phân Công Team

Vương:

- `features/admin_dashboard/`
- `features/shop_setting/`
- `shared/layouts/admin_layout.dart`

Nguyên:

- `features/auth/`
- `features/user_profile/`
- `features/pet_profile/`
- `features/health_record/`

Cường:

- `features/review/`

Huy:

- `features/staff_examination/`
- `features/reminder/`
- `shared/layouts/staff_layout.dart`

Linh:

- `features/booking/`
- `features/time_slot/`
- `shared/layouts/user_layout.dart`

## Luồng Dữ Liệu

```txt
Page -> Provider -> Repository -> DAO -> SQLite
```

- `Page`: hiển thị UI và gọi provider.
- `Provider`: giữ state, loading, danh sách dữ liệu.
- `Repository`: gom logic lấy/lưu dữ liệu cho feature.
- `DAO`: làm việc trực tiếp với bảng SQLite.
- `SQLite`: database local `petpal.db`.

## Cách Thêm Một Page Mới

1. Tạo file trong `features/<ten_feature>/pages/`.
2. Tạo class `StatelessWidget` hoặc `StatefulWidget`.
3. Dùng `Scaffold`, `AppBar`, body text và button cơ bản.
4. Nếu page cần điều hướng, dùng `PageAction` trong `AppPage` hoặc gọi `NavigationService.goTo(context, AppRoutes.tenRoute)`.

Ví dụ:

```dart
class ExamplePage extends StatelessWidget {
  const ExamplePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const AppPage(
      title: 'Example',
      message: 'Example Page',
    );
  }
}
```

## Cách Thêm Một Route Mới

1. Thêm tên route trong `lib/core/constants/app_routes.dart`.
2. Thêm route vào `AppRouteCatalog.routes` trong `lib/app/app_route_path.dart`.
3. Import page mới trong `lib/app/app_router.dart`.
4. Thêm case mới trong hàm `_buildPage`.

## Cách Chạy Project

```bash
flutter pub get
flutter run
```

## Kiểm Tra Code Trước Khi Commit

```bash
dart format .
flutter analyze
flutter test
```

## Quy Tắc Commit Gợi Ý

- `feat`: thêm chức năng mới
- `fix`: sửa lỗi
- `refactor`: chỉnh code không đổi chức năng
- `docs`: sửa tài liệu
- `style`: format code
- `test`: thêm hoặc sửa test

Ví dụ:

```bash
git add .
git commit -m "feat: add pet profile pages"
```

## Quy Trình Git Cho Team

- Không code trực tiếp trên `main`.
- Mỗi người tạo branch riêng theo task.

Ví dụ:

```bash
git checkout -b feature/auth
git checkout -b feature/booking
git checkout -b feature/review
git checkout -b feature/admin-dashboard
```

Sau khi code xong:

```bash
dart format .
flutter analyze
flutter test
git add .
git commit -m "feat: add booking pages"
git push origin feature/booking
```

Sau đó lên GitHub tạo Pull Request vào branch `dev` hoặc `main` tùy quy định team. Người khác nên review code trước khi merge. Nếu có conflict thì pull code mới nhất về rồi xử lý.

## Quy Tắc Đặt Tên

- Tên file dùng `snake_case`.
- Tên class dùng `PascalCase`.
- Tên biến và hàm dùng `camelCase`.

Ví dụ:

- `pet_profile_page.dart`
- `class PetProfilePage`
- `bookingProvider`
- `loadBookings()`

## Lưu Ý

- Không tạo logic quá phức tạp.
- Không cần hoàn thiện toàn bộ business logic.
- Không dùng `go_router`.
- Mục tiêu chính là có bộ khung rõ ràng, compile được.
- Không làm phá cấu trúc, conflict phần người khác
