````md
# PetPal - Hướng dẫn làm việc nhóm

## 1. Phiên bản yêu cầu

Project yêu cầu sử dụng:

```txt
Flutter: 3.41.8
Dart: đi kèm theo Flutter 3.41.8
````

Kiểm tra phiên bản hiện tại:

```bash
flutter --version
```

Nếu phiên bản Flutter không đúng, xem phần **11. Cách xử lý khi chưa đúng phiên bản Flutter**.

---

## 2. Clone project về máy

Clone source code:

```bash
git clone https://github.com/ptvuong2505/petpal.git
```

Di chuyển vào thư mục project:

```bash
cd petpal
```

Lấy dependencies:

```bash
flutter pub get
```

Chạy project:

```bash
flutter run
```

Nếu chạy Android Emulator, cần mở emulator trước hoặc kết nối thiết bị Android thật.

---

## 3. Cấu trúc branch

Project sử dụng 2 branch chính:

```txt
main: nhánh ổn định
dev : nhánh phát triển chính của team
```

Member không code trực tiếp trên `main` hoặc `dev`.

Flow làm việc:

```txt
feature/... → dev → main
```

Ví dụ:

```txt
feature/login-screen → dev
dev → main
```

---

## 4. Cách tạo branch để làm task

Trước khi làm task mới, luôn kéo code mới nhất từ `dev`:

```bash
git checkout dev
git pull origin dev
```

Tạo branch mới từ `dev`:

```bash
git checkout -b feature/tên-chức-năng
```

Ví dụ:

```bash
git checkout -b feature/login-screen
```

Một số quy tắc đặt tên branch:

```txt
feature/login-screen
feature/pet-profile
fix/login-validation
refactor/api-service
docs/update-readme
```

---

## 5. Format code trước khi commit

Trước khi commit, luôn format code:

```bash
dart format .
```

Sau đó kiểm tra lỗi:

```bash
flutter analyze
```

Chạy test:

```bash
flutter test
```

Nếu code chưa format, Pull Request sẽ fail CI.

---

## 6. Commit code

Kiểm tra file thay đổi:

```bash
git status
```

Add file:

```bash
git add .
```

Commit:

```bash
git commit -m "feat: create login screen"
```

Một số prefix nên dùng:

```txt
feat: thêm chức năng mới
fix: sửa lỗi
refactor: sửa code nhưng không đổi logic
docs: sửa tài liệu
style: format code
test: thêm/sửa test
chore: cấu hình, dependency
```

Ví dụ:

```bash
git commit -m "feat: create pet profile screen"
git commit -m "fix: validate empty pet name"
git commit -m "docs: update setup guide"
```

---

## 7. Push branch lên GitHub

Push branch hiện tại:

```bash
git push -u origin feature/tên-chức-năng
```

Ví dụ:

```bash
git push -u origin feature/login-screen
```

---

## 8. Tạo Pull Request

Sau khi push branch lên GitHub:

1. Vào repo GitHub.
2. Chọn **Compare & pull request**.
3. Chọn base branch là `dev`.
4. Chọn compare branch là branch feature của bạn.
5. Ghi mô tả thay đổi.
6. Tạo Pull Request.

Ví dụ:

```txt
base: dev
compare: feature/login-screen
```

Không tạo PR trực tiếp vào `main`.

---

## 9. Quy định merge

PR vào `dev` cần:

```txt
CI pass
Ít nhất 1 người review approve
Branch đã cập nhật code mới nhất từ dev
```

Nếu GitHub báo branch chưa update, cần update branch trước khi merge.

Cách 1: Bấm nút **Update branch** trên GitHub nếu có.

Cách 2: Update bằng command line:

```bash
git checkout feature/tên-chức-năng
git fetch origin
git merge origin/dev
git push
```

Ví dụ:

```bash
git checkout feature/login-screen
git fetch origin
git merge origin/dev
git push
```

Sau đó đợi CI chạy lại.

PR vào `main` chỉ thực hiện theo flow:

```txt
dev → main
```

Việc merge vào `main` do leader phụ trách.

---

## 10. Khi sửa `pubspec.yaml`

Nếu thêm/sửa package trong `pubspec.yaml`, bắt buộc chạy:

```bash
flutter pub get
```

Sau đó commit cả 2 file:

```txt
pubspec.yaml
pubspec.lock
```

CI đang dùng:

```bash
flutter pub get --enforce-lockfile
```

Nên nếu `pubspec.yaml` và `pubspec.lock` không khớp, CI sẽ fail.

---

## 11. Cách xử lý khi chưa đúng phiên bản Flutter

Project yêu cầu Flutter:

```txt
3.41.8
```

Kiểm tra version:

```bash
flutter --version
```

Nếu chưa đúng version, có các cách xử lý sau.

### Cách 1: Dùng FVM

Khuyến khích dùng FVM nếu máy có nhiều project Flutter dùng nhiều version khác nhau.

Cài FVM:

```bash
dart pub global activate fvm
```

Cài Flutter version yêu cầu:

```bash
fvm install 3.41.8
```

Set version cho project:

```bash
fvm use 3.41.8
```

Chạy lệnh Flutter qua FVM:

```bash
fvm flutter pub get
fvm flutter run
fvm flutter analyze
fvm flutter test
```

Nếu dùng VS Code, mở Command Palette và chọn Flutter SDK từ FVM nếu cần.

### Cách 2: Đổi version Flutter thủ công

Kiểm tra thư mục Flutter SDK hiện tại:

```bash
where flutter
```

Cập nhật Flutter stable:

```bash
flutter channel stable
flutter upgrade
```

Nếu `flutter upgrade` không ra đúng version yêu cầu, nên dùng FVM để cài đúng version.

### Cách 3: Nếu chưa thể đổi version ngay

Báo lại với leader trước khi làm task.

Không nên push code khi local đang dùng version Flutter khác quá xa version CI, vì có thể xảy ra lỗi:

```txt
CI pass/fail khác máy local
pubspec.lock bị thay đổi không mong muốn
format/analyze khác kết quả
```

---

## 12. Checklist trước khi tạo Pull Request

Trước khi tạo PR, cần chạy:

```bash
dart format .
flutter analyze
flutter test
```

Nếu có sửa package:

```bash
flutter pub get
```

Kiểm tra lại:

```bash
git status
```

Checklist:

```txt
Code đã format
Không còn lỗi analyze
Test pass
Không push file build/cache
Không commit secret/API key
Branch tạo từ dev mới nhất
PR tạo vào dev, không tạo vào main
```

---

## 13. Các file không được commit

Không commit các file/thư mục sau:

```txt
.dart_tool/
build/
.idea/
*.iml
.env
.env.*
```

Nếu có file chứa API key, token hoặc thông tin nhạy cảm, báo leader trước khi push.

---

## 14. Lỗi thường gặp

### Lỗi code chưa format

Nếu CI báo lỗi format, chạy:

```bash
dart format .
```

Sau đó commit lại:

```bash
git add .
git commit -m "style: format code"
git push
```

### Lỗi `pubspec.lock` không khớp

Chạy:

```bash
flutter pub get
```

Sau đó commit lại:

```bash
git add pubspec.yaml pubspec.lock
git commit -m "chore: update dependencies"
git push
```

### Lỗi branch chưa cập nhật `dev` mới nhất

Chạy:

```bash
git checkout feature/tên-chức-năng
git fetch origin
git merge origin/dev
git push
```

Nếu có conflict, resolve conflict rồi chạy:

```bash
dart format .
flutter analyze
flutter test
git add .
git commit
git push
```

### Lỗi build Android

Thử chạy local:

```bash
flutter clean
flutter pub get
flutter build apk --debug
```

Nếu vẫn lỗi, gửi log lỗi lên Pull Request để team cùng xử lý.

---

## 15. Quy tắc chung

```txt
Không push trực tiếp vào main
Không push trực tiếp vào dev
Luôn tạo branch riêng cho từng task
Luôn tạo Pull Request
Luôn chờ CI pass và được review trước khi merge
Luôn format code trước khi commit
```

```
```
