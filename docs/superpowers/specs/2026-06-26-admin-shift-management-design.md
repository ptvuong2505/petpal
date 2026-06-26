# Admin Shift Management Design

**Date:** 2026-06-26  
**Feature:** Admin Shift Management (Quản lý ca trực cho admin)  
**Status:** Design Approved

---

## Overview

Feature này cho phép admin quản lý ca trực của staff theo 2 cách:
1. **Duyệt/từ chối yêu cầu đăng ký ca** từ staff
2. **Tự xếp ca mới** cho staff khi không có ai đăng ký

Hiển thị dưới dạng **calendar view** (tuần/tháng) với màu sắc phân biệt các trạng thái ca trực.

---

## Requirements Summary

### Functional Requirements

1. **Calendar View:**
   - Hiển thị theo tuần (7 ngày) hoặc tháng (calendar grid)
   - Có nút toggle chuyển đổi giữa 2 mode
   - Phân biệt màu sắc theo status:
     - Pending (cam) - yêu cầu chờ duyệt
     - Approved (xanh lá) - đã duyệt
     - Rejected (đỏ) - đã từ chối
     - Admin-assigned (xanh dương) - admin tự xếp

2. **Filter theo Staff:**
   - Dropdown/chips để chọn xem lịch của 1 hoặc nhiều staff
   - Default: hiển thị tất cả staff

3. **Chi tiết ca trực (Bottom Sheet):**
   - Tap vào ca trong calendar → bottom sheet trượt lên
   - Hiển thị: Staff name, ngày, giờ, status, note
   - Actions tùy status:
     - Pending → nút "Approve", "Reject"
     - Approved/Rejected → chỉ hiển thị info
     - Admin-assigned → nút "Edit", "Delete"

4. **Duyệt/Từ chối:**
   - Không cần nhập lý do khi reject
   - Chỉ cần tap nút → update status

5. **Xếp ca mới (FAB):**
   - FAB "+" ở góc màn hình → mở form
   - Form gồm:
     - Dropdown chọn staff
     - DatePicker (ngày)
     - TimePicker (giờ bắt đầu, kết thúc)
     - TextField (ghi chú admin - optional)
   - Conflict detection: cảnh báo nếu staff đã có ca trong khung giờ đó, nhưng vẫn cho phép override
   - Staff nhận thông báo khi admin xếp ca mới

### Non-Functional Requirements

- Reuse existing patterns: calendar tương tự `StaffSchedulePage`
- Sử dụng database schema hiện có (`staff_shifts` table)
- Responsive: hoạt động tốt trên mobile và tablet

---

## Architecture

### Feature Structure

```
lib/features/admin_shift_management/
├── pages/
│   ├── admin_shift_calendar_page.dart      # Màn hình chính
│   └── admin_assign_shift_page.dart        # Form xếp ca mới
├── data/
│   └── admin_shift_dao.dart                # DB operations
├── widgets/
│   ├── shift_calendar_view.dart            # Calendar component
│   ├── shift_bottom_sheet.dart             # Chi tiết ca trực
│   ├── staff_filter_chips.dart             # Filter theo staff
│   └── shift_status_indicator.dart         # Màu sắc phân biệt status
└── models/
    └── calendar_shift_item.dart            # Model cho calendar item
```

### Integration Points

1. **Routing:**
   - Thêm route mới trong `app_router.dart`: `/admin/shift-management`
   - Link từ admin dashboard (thêm menu item tương tự "View All" ở dòng 85)

2. **Database:**
   - Reuse bảng `staff_shifts` hiện có
   - Extend `StaffPortalDao` hoặc tạo `AdminShiftDao` riêng

3. **Notification:**
   - Khi admin approve/reject hoặc assign ca → staff nhận thông báo
   - Reuse notification system hiện có (`StaffPortalDao.notifications()`)

---

## Database Schema

### Existing Table: `staff_shifts`

Không cần alter schema. Bảng hiện có đã đủ fields:

```sql
staff_shifts (
  id INTEGER PRIMARY KEY,
  staff_id INTEGER,
  shift_date TEXT,           -- YYYY-MM-DD
  start_time TEXT,           -- HH:mm
  end_time TEXT,             -- HH:mm
  status TEXT,               -- 'pending' | 'approved' | 'rejected'
  request_type TEXT,         -- 'register' | 'admin_assign'
  request_note TEXT,         -- Ghi chú từ staff khi đăng ký
  admin_note TEXT,           -- Ghi chú từ admin khi xếp ca
  created_at TEXT,
  updated_at TEXT
)
```

### Data Flow

1. **Staff đăng ký ca:**
   - `request_type = 'register'`
   - `status = 'pending'`

2. **Admin duyệt/từ chối:**
   - `status = 'approved'` hoặc `'rejected'`

3. **Admin tự xếp ca:**
   - `request_type = 'admin_assign'`
   - `status = 'approved'`

### DAO Methods

File: `lib/features/admin_shift_management/data/admin_shift_dao.dart`

```dart
class AdminShiftDao {
  // Lấy tất cả ca trong khoảng thời gian, filter theo staff nếu có
  Future<List<CalendarShiftItem>> getShiftsInRange(
    String startDate,
    String endDate,
    List<int>? staffIds,
  );

  // Duyệt ca trực
  Future<void> approveShift(int shiftId);

  // Từ chối ca trực
  Future<void> rejectShift(int shiftId);

  // Xếp ca mới cho staff
  Future<int> assignShift({
    required int staffId,
    required String date,
    required String startTime,
    required String endTime,
    String? adminNote,
  });

  // Kiểm tra xung đột lịch
  Future<ConflictCheckResult> checkConflict({
    required int staffId,
    required String date,
    required String startTime,
    required String endTime,
    int? excludeShiftId, // Loại trừ shift đang edit
  });

  // Lấy danh sách staff (cho dropdown)
  Future<List<StaffInfo>> getAllStaff();
}
```

---

## Components Breakdown

### 1. AdminShiftCalendarPage

**Màn hình chính** hiển thị calendar và quản lý ca trực.

**State:**
- `CalendarView selectedView` — week hoặc month
- `DateTime selectedDate` — ngày đang focus
- `List<int>? staffFilter` — danh sách staff đã chọn (null = all)
- `List<CalendarShiftItem> shifts` — data ca trực

**UI Structure:**
```
AppBar
  - Title: "Quản lý ca trực"
  - Actions: View toggle button (Week/Month)

Body
  - StaffFilterChips (nếu có nhiều staff)
  - ShiftCalendarView
    - Week view: 7 cột, mỗi cột hiển thị list ca
    - Month view: Calendar grid, mỗi ô có dots/badges

FAB
  - "+" button → navigate to AdminAssignShiftPage
```

**Lifecycle:**
1. `initState`: Load shifts for current view range
2. User thay đổi view/date/filter → reload data
3. User tap ca trong calendar → show `ShiftBottomSheet`

---

### 2. ShiftCalendarView

**Calendar component** hiển thị ca trực theo tuần hoặc tháng.

**Props:**
- `CalendarView view` — week hoặc month
- `DateTime date` — ngày focus
- `List<CalendarShiftItem> shifts` — data
- `Function(CalendarShiftItem) onShiftTap` — callback khi tap ca

**Rendering:**

**Week view:**
- 7 cột (T2 → CN)
- Mỗi cột hiển thị list các ca trong ngày đó
- Mỗi ca: Card với màu sắc, staff name, giờ

**Month view:**
- Calendar grid (7 cột x 4-6 rows)
- Mỗi ô ngày hiển thị:
  - Số ngày
  - Dots/badges theo số ca (tối đa 3 dots, nếu >3 hiển thị "+2")
  - Màu dot theo status

**Color mapping:**
- Pending: `Colors.orange`
- Approved: `Colors.green`
- Rejected: `Colors.red`
- Admin-assigned: `Colors.blue`

---

### 3. ShiftBottomSheet

**Bottom sheet** hiển thị chi tiết ca trực và actions.

**Props:**
- `CalendarShiftItem shift` — data ca trực
- `Function(ShiftAction) onAction` — callback khi user tap action

**UI:**
```
DraggableScrollableSheet
  Header: Status badge (màu sắc theo status)
  
  Content:
    - Staff name + avatar
    - Ngày: DD/MM/YYYY
    - Giờ: HH:mm - HH:mm
    - Loại: "Đăng ký" hoặc "Admin xếp"
    - Ghi chú (nếu có)
  
  Actions (tùy status):
    - Pending:
        → FilledButton "Duyệt" (xanh lá)
        → OutlinedButton "Từ chối" (đỏ)
    - Approved/Rejected:
        → TextButton "Đóng"
    - Admin-assigned:
        → OutlinedButton "Sửa"
        → TextButton "Xóa" (màu đỏ)
```

---

### 4. AdminAssignShiftPage

**Form xếp ca mới** cho staff.

**State:**
- `int? selectedStaffId`
- `DateTime selectedDate`
- `TimeOfDay startTime`
- `TimeOfDay endTime`
- `String adminNote`
- `ConflictCheckResult? conflictResult`

**UI:**
```
AppBar: "Xếp ca mới"

Body (ListView):
  1. DropdownButtonFormField: Chọn staff
  2. TextFormField (readOnly): Ngày → tap mở DatePicker
  3. TextFormField (readOnly): Giờ bắt đầu → tap mở TimePicker
  4. TextFormField (readOnly): Giờ kết thúc → tap mở TimePicker
  5. TextFormField: Ghi chú admin (optional)

  [Conflict Warning Card - nếu có xung đột]:
    Icon warning + text "Staff đã có ca 08:00-12:00 trong ngày này"

Bottom:
  FilledButton "Xếp ca" → submit
```

**Validation:**
- Staff phải được chọn
- Ngày không được quá khứ
- Giờ kết thúc > giờ bắt đầu

**Flow:**
1. User điền form → tap "Xếp ca"
2. Gọi `AdminShiftDao.checkConflict()`
3. Nếu có conflict → hiển thị warning card
4. User confirm → gọi `AdminShiftDao.assignShift()`
5. Success → navigate back, reload calendar

---

### 5. StaffFilterChips

**Filter widget** để chọn staff hiển thị trong calendar.

**Props:**
- `List<StaffInfo> allStaff` — danh sách tất cả staff
- `List<int>? selectedStaffIds` — staff đã chọn
- `Function(List<int>?) onChanged` — callback khi thay đổi

**UI:**
```
Wrap(
  - Chip "Tất cả" (selected nếu selectedStaffIds == null)
  - FilterChip "Staff A" (selected nếu trong list)
  - FilterChip "Staff B"
  ...
)
```

**Behavior:**
- Tap "Tất cả" → clear filter
- Tap staff chip → toggle selection
- Multi-select: có thể chọn nhiều staff cùng lúc

---

## Data Flow

### Flow 1: Load Calendar

```
User → AdminShiftCalendarPage
  ↓
Load shifts: AdminShiftDao.getShiftsInRange(start, end, staffIds?)
  ↓
Query database:
  SELECT ss.*, u.full_name AS staff_name
  FROM staff_shifts ss
  INNER JOIN users u ON u.id = ss.staff_id
  WHERE ss.shift_date BETWEEN ? AND ?
    AND (? IS NULL OR ss.staff_id IN (?))
  ORDER BY ss.shift_date, ss.start_time
  ↓
Map to List<CalendarShiftItem>
  ↓
ShiftCalendarView render với màu sắc
```

---

### Flow 2: Approve/Reject Shift

```
User tap ca pending → ShiftBottomSheet
  ↓
User tap "Duyệt"
  ↓
AdminShiftDao.approveShift(shiftId)
  ↓
UPDATE staff_shifts
  SET status = 'approved', updated_at = ?
  WHERE id = ?
  ↓
Notification: Staff thấy status changed trong StaffPortalDao.notifications()
  ↓
Bottom sheet đóng, calendar reload
```

Tương tự cho "Từ chối" với `status = 'rejected'`.

---

### Flow 3: Admin Assign Shift

```
User tap FAB "+"
  ↓
Navigate to AdminAssignShiftPage
  ↓
User chọn staff, date, time, nhập note
  ↓
User tap "Xếp ca"
  ↓
AdminShiftDao.checkConflict(staffId, date, startTime, endTime)
  ↓
Nếu có conflict:
  → Show warning card "Staff đã có ca..."
  → User confirm override
  ↓
AdminShiftDao.assignShift(...)
  ↓
INSERT INTO staff_shifts (
  staff_id, shift_date, start_time, end_time,
  status = 'approved',
  request_type = 'admin_assign',
  admin_note, created_at, updated_at
)
  ↓
Navigate back to calendar, reload data
  ↓
Staff nhận notification về ca mới
```

---

## Error Handling

### 1. Network/Database Errors

- Khi DAO operations fail → catch exception
- Calendar page:
  - Load fail → hiển thị empty state với icon error + message + nút "Retry"
- Form submit fail:
  - Giữ nguyên form data
  - Hiển thị error message dưới submit button
  - SnackBar: "Không thể xếp ca. Vui lòng thử lại."

### 2. Conflict Detection

- `checkConflict()` trả về `ConflictCheckResult`:
  ```dart
  class ConflictCheckResult {
    final bool hasConflict;
    final List<ConflictingShift> conflicts;
  }
  ```
- Nếu có conflict → show warning card trong form:
  ```
  ⚠️ Staff [Tên] đã có ca 08:00-12:00 trong ngày này.
  Vẫn muốn xếp ca?
  ```
- User confirm → proceed với flag `allowConflict: true`

### 3. Validation Errors

- Form validation realtime (onChange)
- Errors hiển thị dưới field:
  - "Vui lòng chọn staff"
  - "Giờ kết thúc phải sau giờ bắt đầu"
  - "Ngày không được ở quá khứ"

### 4. Permission/Auth

- Hiện tại: Admin role check đơn giản (`user.role == 'admin'`)
- Future: Wrap page trong `AdminAccessGuard` (tương tự `StaffAccessGuard`)

---

## Testing Approach

### Unit Tests

Location: `test/features/admin_shift_management/`

**1. DAO Tests** (`admin_shift_dao_test.dart`):
- `getShiftsInRange()` với filter khác nhau (all staff, specific staff)
- `approveShift()`, `rejectShift()` update đúng status
- `assignShift()` insert đúng data với `request_type = 'admin_assign'`
- `checkConflict()` phát hiện xung đột chính xác (same date, overlapping time)

**2. Widget Tests:**
- `shift_calendar_view_test.dart`: Calendar render đúng theo week/month mode
- `shift_bottom_sheet_test.dart`: Actions hiển thị đúng theo status
- `staff_filter_chips_test.dart`: Multi-select filter

**3. Page Tests:**
- `admin_shift_calendar_page_test.dart`:
  - Load data thành công
  - Filter interaction
  - Navigate to assign page khi tap FAB
- `admin_assign_shift_page_test.dart`:
  - Form validation
  - Conflict warning hiển thị
  - Submit thành công

### Integration Test Scenarios

1. **Approve flow:**
   - Admin approve ca pending → status update → staff nhận notification

2. **Conflict override:**
   - Admin assign ca có xung đột → warning hiển thị → override thành công

3. **Filter:**
   - Admin chọn filter staff → calendar chỉ hiển thị ca của staff đó

4. **View toggle:**
   - Switch week ↔ month → data load đúng range

### Manual Testing Checklist

- [ ] Calendar hiển thị đúng màu 4 loại ca
- [ ] Week/month view toggle hoạt động
- [ ] Filter staff hoạt động đúng (single + multi-select)
- [ ] Bottom sheet actions work cho từng status
- [ ] Form validation chính xác
- [ ] Conflict detection chính xác (same time overlap)
- [ ] Notification đến staff sau khi admin assign ca
- [ ] Responsive trên mobile/tablet

---

## Implementation Notes

1. **Reuse existing components:**
   - Calendar UI: tham khảo `StaffSchedulePage` (đã có week view)
   - Status badges: tham khảo `StaffBookingStatus` widgets
   - Bottom sheet: pattern giống `booking_detail_page`

2. **Color scheme:**
   - Dùng `AppColors` constants hiện có
   - Đảm bảo contrast đủ cho accessibility

3. **Performance:**
   - Limit query range: 1 tháng tại một thời điểm
   - Pagination nếu có >100 shifts trong range

4. **Future enhancements:**
   - Bulk approve/reject
   - Export lịch ra PDF
   - Push notification thay vì in-app notification

---

## Success Criteria

✅ Admin có thể xem lịch ca trực theo tuần/tháng  
✅ Admin có thể duyệt/từ chối yêu cầu đăng ký ca  
✅ Admin có thể tự xếp ca cho staff  
✅ Staff nhận thông báo khi admin xếp ca  
✅ Conflict detection hoạt động chính xác  
✅ UI responsive và dễ sử dụng  
✅ Tests coverage ≥80%

---

**End of Design Document**
