import 'package:sqflite/sqflite.dart';

class DatabaseSeed {
  DatabaseSeed._();

  static Future<void> insertDefaultData(Database db) async {
    final now = DateTime.now();
    final nowText = now.toIso8601String();

    // =========================
    // Shop Setting
    // =========================
    await db.insert('shop_settings', {
      'id': 1,
      'shop_name': 'PetPal Care Center',
      'phone': '0901234567',
      'email': 'petpal@example.com',
      'address': '123 Nguyễn Văn Linh, Đà Nẵng',
      'open_time': '08:00',
      'close_time': '21:00',
      'description':
          'PetPal cung cấp dịch vụ chăm sóc, spa, khách sạn và khám sức khỏe cho thú cưng.',
      'booking_policy':
          'Vui lòng đặt lịch trước ít nhất 2 giờ. Có thể hủy lịch trước 1 giờ.',
      'logo_path': '',
      'updated_at': nowText,
    });

    // =========================
    // Users
    // role: user / staff / admin
    // =========================
    await db.insert('users', {
      'id': 1,
      'full_name': 'Nguyễn Văn An',
      'email': 'an@gmail.com',
      'password': '123456',
      'phone': '0901111111',
      'address': 'Hải Châu, Đà Nẵng',
      'role': 'user',
      'created_at': nowText,
      'updated_at': nowText,
    });

    await db.insert('users', {
      'id': 2,
      'full_name': 'Trần Thị Bình',
      'email': 'binh@gmail.com',
      'password': '123456',
      'phone': '0902222222',
      'address': 'Sơn Trà, Đà Nẵng',
      'role': 'user',
      'created_at': nowText,
      'updated_at': nowText,
    });

    await db.insert('users', {
      'id': 3,
      'full_name': 'Lê Minh Staff',
      'email': 'staff@gmail.com',
      'password': '123456',
      'phone': '0903333333',
      'address': 'Cẩm Lệ, Đà Nẵng',
      'role': 'staff',
      'created_at': nowText,
      'updated_at': nowText,
    });

    await db.insert('users', {
      'id': 4,
      'full_name': 'Admin PetPal',
      'email': 'admin@gmail.com',
      'password': '123456',
      'phone': '0904444444',
      'address': 'Đà Nẵng',
      'role': 'admin',
      'created_at': nowText,
      'updated_at': nowText,
    });

    await db.insert('users', {
      'id': 5,
      'full_name': 'Phạm Hoàng Nam',
      'email': 'nam@gmail.com',
      'password': '123456',
      'phone': '0905555555',
      'address': 'Thanh Khê, Đà Nẵng',
      'role': 'user',
      'created_at': nowText,
      'updated_at': nowText,
    });

    // =========================
    // Pets
    // =========================
    await db.insert('pets', {
      'id': 1,
      'user_id': 1,
      'name': 'Milo',
      'species': 'Dog',
      'breed': 'Poodle',
      'gender': 'Male',
      'birth_date': '2022-05-10',
      'weight': 5.6,
      'image_path': '',
      'note': 'Thích ăn pate, hơi sợ máy sấy.',
      'created_at': nowText,
      'updated_at': nowText,
    });

    await db.insert('pets', {
      'id': 2,
      'user_id': 1,
      'name': 'Mimi',
      'species': 'Cat',
      'breed': 'British Shorthair',
      'gender': 'Female',
      'birth_date': '2021-11-20',
      'weight': 4.2,
      'image_path': '',
      'note': 'Cần vệ sinh tai định kỳ.',
      'created_at': nowText,
      'updated_at': nowText,
    });

    await db.insert('pets', {
      'id': 3,
      'user_id': 2,
      'name': 'Lucky',
      'species': 'Dog',
      'breed': 'Corgi',
      'gender': 'Male',
      'birth_date': '2020-03-15',
      'weight': 9.8,
      'image_path': '',
      'note': 'Đã tiêm phòng đầy đủ.',
      'created_at': nowText,
      'updated_at': nowText,
    });

    await db.insert('pets', {
      'id': 4,
      'user_id': 2,
      'name': 'Kem',
      'species': 'Cat',
      'breed': 'Munchkin',
      'gender': 'Female',
      'birth_date': '2023-01-05',
      'weight': 3.1,
      'image_path': '',
      'note': 'Dễ bị rụng lông.',
      'created_at': nowText,
      'updated_at': nowText,
    });

    await db.insert('pets', {
      'id': 5,
      'user_id': 5,
      'name': 'Bông',
      'species': 'Dog',
      'breed': 'Chihuahua',
      'gender': 'Female',
      'birth_date': '2022-09-18',
      'weight': 2.4,
      'image_path': '',
      'note': 'Nhỏ, cần chăm sóc nhẹ nhàng.',
      'created_at': nowText,
      'updated_at': nowText,
    });

    // =========================
    // Services
    // =========================
    await db.insert('services', {
      'id': 1,
      'name': 'Grooming',
      'description': 'Tắm, cắt tỉa lông và vệ sinh cơ bản cho thú cưng.',
      'price': 150000,
      'duration_minutes': 60,
      'image_path': '',
      'status': 'active',
      'created_at': nowText,
      'updated_at': nowText,
    });

    await db.insert('services', {
      'id': 2,
      'name': 'Pet Hotel',
      'description': 'Dịch vụ lưu trú, chăm sóc thú cưng theo ngày.',
      'price': 200000,
      'duration_minutes': 1440,
      'image_path': '',
      'status': 'active',
      'created_at': nowText,
      'updated_at': nowText,
    });

    await db.insert('services', {
      'id': 3,
      'name': 'Health Check',
      'description': 'Khám sức khỏe tổng quát cho thú cưng.',
      'price': 100000,
      'duration_minutes': 30,
      'image_path': '',
      'status': 'active',
      'created_at': nowText,
      'updated_at': nowText,
    });

    await db.insert('services', {
      'id': 4,
      'name': 'Vaccination',
      'description': 'Tiêm phòng và tư vấn lịch tiêm cho thú cưng.',
      'price': 250000,
      'duration_minutes': 30,
      'image_path': '',
      'status': 'active',
      'created_at': nowText,
      'updated_at': nowText,
    });

    await db.insert('services', {
      'id': 5,
      'name': 'Nail & Ear Cleaning',
      'description': 'Cắt móng, vệ sinh tai và chăm sóc cơ bản.',
      'price': 80000,
      'duration_minutes': 30,
      'image_path': '',
      'status': 'active',
      'created_at': nowText,
      'updated_at': nowText,
    });

    await db.insert('services', {
      'id': 6,
      'name': 'Dental Care',
      'description': 'Vệ sinh răng miệng cho thú cưng.',
      'price': 180000,
      'duration_minutes': 45,
      'image_path': '',
      'status': 'active',
      'created_at': nowText,
      'updated_at': nowText,
    });

    // =========================
    // Time Slots
    // =========================
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));
    final nextDay = today.add(const Duration(days: 2));

    String dateText(DateTime date) {
      return date.toIso8601String().substring(0, 10);
    }

    await db.insert('time_slots', {
      'id': 1,
      'slot_date': dateText(today),
      'start_time': '08:00',
      'end_time': '09:00',
      'max_booking': 3,
      'booked_count': 2,
      'status': 'available',
      'created_at': nowText,
      'updated_at': nowText,
    });

    await db.insert('time_slots', {
      'id': 2,
      'slot_date': dateText(today),
      'start_time': '09:00',
      'end_time': '10:00',
      'max_booking': 2,
      'booked_count': 2,
      'status': 'full',
      'created_at': nowText,
      'updated_at': nowText,
    });

    await db.insert('time_slots', {
      'id': 3,
      'slot_date': dateText(today),
      'start_time': '10:00',
      'end_time': '11:00',
      'max_booking': 3,
      'booked_count': 1,
      'status': 'available',
      'created_at': nowText,
      'updated_at': nowText,
    });

    await db.insert('time_slots', {
      'id': 4,
      'slot_date': dateText(tomorrow),
      'start_time': '08:00',
      'end_time': '09:00',
      'max_booking': 3,
      'booked_count': 0,
      'status': 'available',
      'created_at': nowText,
      'updated_at': nowText,
    });

    await db.insert('time_slots', {
      'id': 5,
      'slot_date': dateText(tomorrow),
      'start_time': '14:00',
      'end_time': '15:00',
      'max_booking': 2,
      'booked_count': 1,
      'status': 'available',
      'created_at': nowText,
      'updated_at': nowText,
    });

    await db.insert('time_slots', {
      'id': 6,
      'slot_date': dateText(nextDay),
      'start_time': '16:00',
      'end_time': '17:00',
      'max_booking': 2,
      'booked_count': 0,
      'status': 'disabled',
      'created_at': nowText,
      'updated_at': nowText,
    });

    // =========================
    // Bookings
    // status: pending / confirmed / completed / cancelled
    // =========================
    await db.insert('bookings', {
      'id': 1,
      'user_id': 1,
      'pet_id': 1,
      'service_id': 1,
      'time_slot_id': 1,
      'service_name': 'Grooming',
      'booking_date': dateText(today),
      'note': 'Cắt tỉa nhẹ, không cạo quá ngắn.',
      'total_price': 150000,
      'status': 'confirmed',
      'created_at': nowText,
      'updated_at': nowText,
    });

    await db.insert('bookings', {
      'id': 2,
      'user_id': 1,
      'pet_id': 2,
      'service_id': 3,
      'time_slot_id': 2,
      'service_name': 'Health Check',
      'booking_date': dateText(today),
      'note': 'Mèo hơi biếng ăn trong 2 ngày gần đây.',
      'total_price': 100000,
      'status': 'completed',
      'created_at': nowText,
      'updated_at': nowText,
    });

    await db.insert('bookings', {
      'id': 3,
      'user_id': 2,
      'pet_id': 3,
      'service_id': 4,
      'time_slot_id': 3,
      'service_name': 'Vaccination',
      'booking_date': dateText(today),
      'note': 'Tiêm mũi nhắc lại.',
      'total_price': 250000,
      'status': 'pending',
      'created_at': nowText,
      'updated_at': nowText,
    });

    await db.insert('bookings', {
      'id': 4,
      'user_id': 2,
      'pet_id': 4,
      'service_id': 5,
      'time_slot_id': 5,
      'service_name': 'Nail & Ear Cleaning',
      'booking_date': dateText(tomorrow),
      'note': 'Vệ sinh tai kỹ.',
      'total_price': 80000,
      'status': 'confirmed',
      'created_at': nowText,
      'updated_at': nowText,
    });

    await db.insert('bookings', {
      'id': 5,
      'user_id': 5,
      'pet_id': 5,
      'service_id': 2,
      'time_slot_id': 4,
      'service_name': 'Pet Hotel',
      'booking_date': dateText(tomorrow),
      'note': 'Gửi trong 1 ngày.',
      'total_price': 200000,
      'status': 'completed',
      'created_at': nowText,
      'updated_at': nowText,
    });

    await db.insert('bookings', {
      'id': 6,
      'user_id': 1,
      'pet_id': 1,
      'service_id': 6,
      'time_slot_id': null,
      'service_name': 'Dental Care',
      'booking_date': dateText(nextDay),
      'note': 'Khách đã hủy do bận.',
      'total_price': 180000,
      'status': 'cancelled',
      'created_at': nowText,
      'updated_at': nowText,
    });

    // =========================
    // Health Records
    // Staff tạo kết quả khám cũng lưu vào bảng này
    // =========================
    await db.insert('health_records', {
      'id': 1,
      'pet_id': 2,
      'booking_id': 2,
      'staff_id': 3,
      'title': 'Khám sức khỏe cho Mimi',
      'symptom': 'Biếng ăn, ít vận động.',
      'diagnosis': 'Rối loạn tiêu hóa nhẹ.',
      'treatment': 'Theo dõi ăn uống, bổ sung men tiêu hóa.',
      'medicine': 'Men tiêu hóa PetBio, 1 gói/ngày trong 3 ngày.',
      'note': 'Nếu sau 3 ngày không cải thiện thì tái khám.',
      'record_date': dateText(today),
      'next_visit_date': dateText(today.add(const Duration(days: 7))),
      'created_at': nowText,
      'updated_at': nowText,
    });

    await db.insert('health_records', {
      'id': 2,
      'pet_id': 5,
      'booking_id': 5,
      'staff_id': 3,
      'title': 'Kiểm tra trước khi lưu trú',
      'symptom': 'Không có triệu chứng bất thường.',
      'diagnosis': 'Sức khỏe ổn định.',
      'treatment': 'Chăm sóc lưu trú bình thường.',
      'medicine': '',
      'note': 'Cho ăn theo khẩu phần nhỏ.',
      'record_date': dateText(tomorrow),
      'next_visit_date': '',
      'created_at': nowText,
      'updated_at': nowText,
    });

    await db.insert('health_records', {
      'id': 3,
      'pet_id': 1,
      'booking_id': null,
      'staff_id': 3,
      'title': 'Cập nhật cân nặng định kỳ',
      'symptom': '',
      'diagnosis': 'Cân nặng ổn định.',
      'treatment': 'Duy trì chế độ ăn hiện tại.',
      'medicine': '',
      'note': 'Nên vận động 20 phút mỗi ngày.',
      'record_date': dateText(today.subtract(const Duration(days: 10))),
      'next_visit_date': '',
      'created_at': nowText,
      'updated_at': nowText,
    });

    await db.insert('health_records', {
      'id': 4,
      'pet_id': 3,
      'booking_id': null,
      'staff_id': 3,
      'title': 'Lịch sử tiêm phòng',
      'symptom': '',
      'diagnosis': 'Đủ điều kiện tiêm phòng.',
      'treatment': 'Đã tiêm vaccine nhắc lại.',
      'medicine': '',
      'note': 'Theo dõi phản ứng sau tiêm trong 24 giờ.',
      'record_date': dateText(today.subtract(const Duration(days: 30))),
      'next_visit_date': dateText(today.add(const Duration(days: 180))),
      'created_at': nowText,
      'updated_at': nowText,
    });

    // =========================
    // Reviews
    // Mỗi booking chỉ được review 1 lần
    // =========================
    await db.insert('reviews', {
      'id': 1,
      'user_id': 1,
      'pet_id': 2,
      'booking_id': 2,
      'rating': 5,
      'comment': 'Nhân viên tư vấn kỹ, Mimi về ăn uống tốt hơn.',
      'created_at': nowText,
      'updated_at': nowText,
    });

    await db.insert('reviews', {
      'id': 2,
      'user_id': 5,
      'pet_id': 5,
      'booking_id': 5,
      'rating': 4,
      'comment': 'Dịch vụ lưu trú ổn, nhân viên thân thiện.',
      'created_at': nowText,
      'updated_at': nowText,
    });

    // =========================
    // Reminders
    // type: recheck / vaccination / medicine / booking
    // status: pending / sent / done / cancelled
    // =========================
    await db.insert('reminders', {
      'id': 1,
      'user_id': 1,
      'pet_id': 2,
      'title': 'Tái khám cho Mimi',
      'type': 'recheck',
      'reminder_time': today
          .add(const Duration(days: 7, hours: 9))
          .toIso8601String(),
      'note': 'Kiểm tra lại tình trạng tiêu hóa.',
      'status': 'pending',
      'created_at': nowText,
      'updated_at': nowText,
    });

    await db.insert('reminders', {
      'id': 2,
      'user_id': 2,
      'pet_id': 3,
      'title': 'Nhắc tiêm phòng cho Lucky',
      'type': 'vaccination',
      'reminder_time': today
          .add(const Duration(days: 180, hours: 8))
          .toIso8601String(),
      'note': 'Đến lịch tiêm nhắc lại.',
      'status': 'pending',
      'created_at': nowText,
      'updated_at': nowText,
    });

    await db.insert('reminders', {
      'id': 3,
      'user_id': 1,
      'pet_id': 2,
      'title': 'Cho Mimi uống men tiêu hóa',
      'type': 'medicine',
      'reminder_time': today.add(const Duration(hours: 20)).toIso8601String(),
      'note': '1 gói sau bữa ăn tối.',
      'status': 'pending',
      'created_at': nowText,
      'updated_at': nowText,
    });

    await db.insert('reminders', {
      'id': 4,
      'user_id': 2,
      'pet_id': 4,
      'title': 'Lịch vệ sinh tai cho Kem',
      'type': 'booking',
      'reminder_time': tomorrow
          .add(const Duration(hours: 14))
          .toIso8601String(),
      'note': 'Nhắc khách trước lịch hẹn.',
      'status': 'sent',
      'created_at': nowText,
      'updated_at': nowText,
    });

    await db.insert('reminders', {
      'id': 5,
      'user_id': 5,
      'pet_id': 5,
      'title': 'Đón Bông sau lưu trú',
      'type': 'booking',
      'reminder_time': tomorrow
          .add(const Duration(hours: 17))
          .toIso8601String(),
      'note': 'Khách đón pet vào cuối ngày.',
      'status': 'done',
      'created_at': nowText,
      'updated_at': nowText,
    });
  }
}
