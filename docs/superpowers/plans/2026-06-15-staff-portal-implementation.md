# PetPal Staff Portal Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build six complete SQLite-backed staff functions: examination result detail, combined schedule/calendar, global pet search, professional profile, notification center, and personal statistics.

**Architecture:** Preserve the existing Provider -> Repository -> DAO structure. Keep booking and examination behavior in `staff_examination`, add five bounded staff feature modules, and connect them through database version 2, typed route parameters, and the existing role-aware layout.

**Tech Stack:** Flutter, Dart, Material 3, Provider, sqflite, shared_preferences, flutter_test, sqflite_common_ffi (test only)

---

## Working Rules

- The worktree already contains uncommitted staff-examination changes. Read and preserve them; never reset or overwrite unrelated user work.
- Follow `superpowers:test-driven-development`: add one failing behavior test, run it and observe the expected failure, implement minimally, then rerun.
- Run `dart format` only on files touched by the current task.
- Use parameterized SQLite queries. Do not interpolate user search text into SQL.
- Do not add a calendar/chart package. Build focused Material widgets from the queried data.
- Use the authenticated `AuthProvider.currentUser!.id` as `staffId`; show a controlled error when it is absent.
- Commit only files belonging to the completed task.

## File Map

### Shared foundation

- Modify `pubspec.yaml`: add `sqflite_common_ffi` under dev dependencies.
- Modify `lib/core/database/app_database.dart`: version 2 schema, migration hooks, indexes, testable database opening.
- Modify `lib/core/database/database_seed.dart`: `staff_id`, staff profile, shift, and notification/statistics seed data.
- Modify `lib/core/constants/app_routes.dart`: new staff route names and route classification.
- Modify `lib/app/app_route_path.dart`: parse `resultId` and `petId`.
- Modify `lib/app/app_router.dart`: construct new pages with validated IDs.
- Modify `lib/app/app.dart`: register five new providers.
- Modify `lib/shared/layouts/app_layout.dart`, `lib/shared/layouts/staff_layout.dart`, and `lib/shared/widgets/app_bottom_navigation_bar.dart`: six-destination staff navigation.

### Examination result

- Modify existing files under `lib/features/staff_examination/` for lookup by result ID and post-save navigation.
- Replace `pages/examination_result_detail_page.dart` placeholder with the responsive detail UI.

### New feature modules

- Create `lib/features/staff_pet_search/`: search result/profile models, DAO, repository, provider, search page, medical profile page, cards/timeline widgets.
- Create `lib/features/staff_schedule/`: schedule/shift models, DAO, repository, provider, calendar page, request form page, calendar/agenda widgets.
- Create `lib/features/staff_profile/`: professional profile/certificate models, DAO, repository, provider, profile/edit pages, profile widgets.
- Create `lib/features/staff_notifications/`: notification model, DAO, repository, provider, notification page/card.
- Create `lib/features/staff_statistics/`: summary/trend/feedback models, DAO, repository, provider, statistics page/widgets.

### Tests

- Add database helpers under `test/helpers/`.
- Mirror each feature under `test/features/<feature>/` with model, DAO, provider, page, and responsive tests where relevant.
- Extend `test/app/app_route_path_test.dart` and staff layout tests.

---

### Task 1: Database Version 2 and Typed Staff Routes

**Files:**
- Modify: `pubspec.yaml`
- Modify: `lib/core/database/app_database.dart`
- Modify: `lib/core/database/database_seed.dart`
- Modify: `lib/core/constants/app_routes.dart`
- Modify: `lib/app/app_route_path.dart`
- Test: `test/helpers/test_database.dart`
- Test: `test/core/database/app_database_migration_test.dart`
- Modify: `test/app/app_route_path_test.dart`

- [ ] **Step 1: Add the SQLite test dependency**

Add under `dev_dependencies`:

```yaml
sqflite_common_ffi: ^2.3.6
```

Run: `flutter pub get`

- [ ] **Step 2: Write failing route parameter tests**

Add tests proving:

```dart
expect(
  AppRoutePath.byLocation(
    '/staff/examination-results/detail?resultId=9',
  ).resultId,
  9,
);
expect(
  AppRoutePath.byLocation('/staff/pets/detail?petId=4').petId,
  4,
);
```

Run: `flutter test test/app/app_route_path_test.dart`

Expected: FAIL because `resultId`, `petId`, and new route catalog entries do not exist.

- [ ] **Step 3: Implement route constants and typed getters**

Add route names for schedule, shift request, pet search/detail, notifications, statistics, staff profile/edit profile. Add:

```dart
int? get resultId => int.tryParse(queryParameters['resultId'] ?? '');
int? get petId => int.tryParse(queryParameters['petId'] ?? '');
```

Include all new routes in `isStaffRoute` and primary-navigation logic.

- [ ] **Step 4: Write a failing version-1-to-version-2 migration test**

Create a temporary version 1 database with a user, booking, and health record. Open it through the version 2 migration and assert:

```dart
expect(await columnNames(db, 'bookings'), contains('staff_id'));
expect(await tableExists(db, 'staff_profiles'), isTrue);
expect(await tableExists(db, 'staff_shifts'), isTrue);
expect(await tableExists(db, 'staff_notification_reads'), isTrue);
expect((await db.query('bookings')).single['service_name'], 'Health Check');
```

Run: `flutter test test/core/database/app_database_migration_test.dart`

Expected: FAIL because the database remains version 1 and has no migration.

- [ ] **Step 5: Implement reusable version 2 schema creation and migration**

Set database version to 2, add `onUpgrade`, and extract focused private methods:

```dart
Future<void> _upgrade(Database db, int oldVersion, int newVersion) async {
  if (oldVersion < 2) await _migrateToV2(db);
}
```

Version 2 must add nullable `bookings.staff_id`, the three new tables, foreign keys/unique constraints, and indexes. New database creation must produce the same final schema without relying on `ALTER TABLE`.

- [ ] **Step 6: Seed attributable staff data**

Assign seeded bookings to staff 3 where appropriate; insert one professional profile, approved/pending/rejected shifts, and enough dates/statuses to exercise calendar, notifications, and statistics.

- [ ] **Step 7: Verify foundation tests**

Run:

```powershell
flutter test test/core/database/app_database_migration_test.dart
flutter test test/app/app_route_path_test.dart
flutter analyze
```

Expected: PASS with no analyzer errors.

- [ ] **Step 8: Commit**

```powershell
git add pubspec.yaml pubspec.lock lib/core/database lib/core/constants/app_routes.dart lib/app/app_route_path.dart test/helpers test/core/database test/app/app_route_path_test.dart
git commit -m "feat: add staff portal database foundation"
```

---

### Task 2: Examination Result Detail End-to-End

**Files:**
- Modify: `lib/features/staff_examination/models/examination_result.dart`
- Modify: `lib/features/staff_examination/data/staff_examination_dao.dart`
- Modify: `lib/features/staff_examination/repositories/staff_examination_repository.dart`
- Modify: `lib/features/staff_examination/providers/staff_examination_provider.dart`
- Modify: `lib/features/staff_examination/pages/create_examination_result_page.dart`
- Replace: `lib/features/staff_examination/pages/examination_result_detail_page.dart`
- Modify: `lib/app/app_router.dart`
- Test: `test/features/staff_examination/data/staff_examination_dao_test.dart`
- Modify: `test/features/staff_examination/models/examination_result_test.dart`
- Modify: `test/features/staff_examination/providers/staff_examination_provider_test.dart`
- Test: `test/features/staff_examination/pages/examination_result_detail_page_test.dart`

- [ ] **Step 1: Write failing model and DAO tests for result detail**

Assert `ExaminationResult.fromMap` reads joined `pet_name`, `pet_species`, `pet_breed`, `owner_name`, `service_name`, `start_time`, and `end_time`. Insert related rows and assert `getResultById(1)` returns them.

Run: `flutter test test/features/staff_examination/models/examination_result_test.dart test/features/staff_examination/data/staff_examination_dao_test.dart`

Expected: FAIL because joined fields and `getResultById` are missing.

- [ ] **Step 2: Implement result lookup contract**

Add nullable display fields without adding them to `toMap()`. Add DAO/repository method:

```dart
Future<ExaminationResult?> getResultById(int resultId);
```

Use joins across `health_records`, `pets`, `users`, `bookings`, and `time_slots`.

- [ ] **Step 3: Write failing provider state tests**

Test successful result load, not-found state, repository error, and clearing prior result before a new request.

- [ ] **Step 4: Implement provider loading by result ID**

Use distinct detail loading/error state so loading result detail does not erase booking-list state.

- [ ] **Step 5: Write failing widget tests**

Cover populated, missing optional medical values (`Không có thông tin`), retry error, and 320x568 overflow behavior.

- [ ] **Step 6: Build the detail page**

Make `ExaminationResultDetailPage(resultId: ...)` stateful, load after first frame, and render scrollable summary/medical cards with shared loading/empty widgets.

- [ ] **Step 7: Make examination creation return and route by inserted ID**

Change provider creation API from `Future<bool>` to `Future<int?>`. After success call:

```dart
navigation.goTo(
  AppRoutes.examinationResultDetail,
  queryParameters: {'resultId': resultId.toString()},
);
```

Update all affected fakes/tests.

- [ ] **Step 8: Verify and commit**

Run:

```powershell
flutter test test/features/staff_examination
flutter test test/app
flutter analyze
```

Commit: `feat: complete examination result detail flow`

---

### Task 3: Global Pet Search and Medical Profile

**Files:**
- Create: `lib/features/staff_pet_search/models/staff_pet_search_result.dart`
- Create: `lib/features/staff_pet_search/models/staff_pet_medical_profile.dart`
- Create: `lib/features/staff_pet_search/data/staff_pet_search_dao.dart`
- Create: `lib/features/staff_pet_search/repositories/staff_pet_search_repository.dart`
- Create: `lib/features/staff_pet_search/providers/staff_pet_search_provider.dart`
- Create: `lib/features/staff_pet_search/pages/staff_pet_search_page.dart`
- Create: `lib/features/staff_pet_search/pages/staff_pet_medical_profile_page.dart`
- Create: `lib/features/staff_pet_search/widgets/staff_pet_search_card.dart`
- Create: `lib/features/staff_pet_search/widgets/medical_record_timeline.dart`
- Modify: `lib/app/app.dart`
- Modify: `lib/app/app_router.dart`
- Create matching tests under: `test/features/staff_pet_search/`

- [ ] **Step 1: Write failing model mapping tests**

Define immutable search/profile models and prove nullable owner/pet fields map safely.

- [ ] **Step 2: Write failing DAO search tests**

Test case-insensitive matches by pet name, owner name, email, and phone; empty query returns all pets ordered by latest activity/name; a query containing `' OR 1=1 --` returns no unintended rows.

Run: `flutter test test/features/staff_pet_search/data/staff_pet_search_dao_test.dart`

- [ ] **Step 3: Implement parameterized search and profile queries**

Use `LOWER(column) LIKE ?` with `%${query.toLowerCase()}%`. Medical profile query must return owner details plus health records ordered by `record_date DESC, id DESC`.

- [ ] **Step 4: Write failing provider debounce/stale-response tests**

Inject a debounce duration and fake delayed repository. Prove the latest query wins and clearing restores all pets.

- [ ] **Step 5: Implement provider**

Use a cancellable `Timer` and monotonically increasing request token. Dispose the timer.

- [ ] **Step 6: Write failing page tests**

Test loading, results, empty search, retry, tap-to-detail navigation, long owner email wrapping, and 320x568 layout.

- [ ] **Step 7: Implement search and medical profile pages**

Keep the search page list-driven. Keep profile page sections independent: pet summary, owner contact, care notes, timeline.

- [ ] **Step 8: Register provider/routes and verify**

Run:

```powershell
flutter test test/features/staff_pet_search
flutter test test/app/app_route_path_test.dart
flutter analyze
```

Commit: `feat: add global staff pet search`

---

### Task 4: Combined Staff Calendar and Shift Requests

**Files:**
- Create: `lib/features/staff_schedule/models/staff_schedule_entry.dart`
- Create: `lib/features/staff_schedule/models/staff_shift_request.dart`
- Create: `lib/features/staff_schedule/data/staff_schedule_dao.dart`
- Create: `lib/features/staff_schedule/repositories/staff_schedule_repository.dart`
- Create: `lib/features/staff_schedule/providers/staff_schedule_provider.dart`
- Create: `lib/features/staff_schedule/pages/staff_schedule_page.dart`
- Create: `lib/features/staff_schedule/pages/staff_shift_request_page.dart`
- Create: `lib/features/staff_schedule/widgets/staff_week_calendar.dart`
- Create: `lib/features/staff_schedule/widgets/staff_month_calendar.dart`
- Create: `lib/features/staff_schedule/widgets/staff_schedule_agenda.dart`
- Modify: `lib/app/app.dart`
- Modify: `lib/app/app_router.dart`
- Create matching tests under: `test/features/staff_schedule/`

- [ ] **Step 1: Write failing interval/model tests**

Define half-open overlap behavior:

```dart
expect(overlaps('08:00', '09:00', '09:00', '10:00'), isFalse);
expect(overlaps('08:00', '10:00', '09:00', '11:00'), isTrue);
```

Reject equal start/end, end before start, malformed times, and overnight shifts.

- [ ] **Step 2: Implement focused schedule models and time helpers**

Keep parsing/overlap pure and unit tested. Do not put SQL or widget concerns in models.

- [ ] **Step 3: Write failing DAO tests**

Test date-range loading combines assigned bookings and shifts, current staff scoping, status mapping, conflict with approved shift, conflict with appointment, adjacent allowance, pending request insertion, and change request preserving the source shift.

- [ ] **Step 4: Implement DAO/repository transactions**

Validate again inside the transaction immediately before insert to avoid race-like duplicate requests.

- [ ] **Step 5: Write failing provider tests**

Test week/month range calculation, selected day, previous/next/today, mode switching, load error, duplicate-submit guard, and refresh after request.

- [ ] **Step 6: Implement provider state**

Expose derived `selectedDayEntries`, requestable approved shifts, and `canMoveNext` based on current period.

- [ ] **Step 7: Write failing calendar/request widget tests**

Verify legend labels, both entry types, selected-day agenda, form validation, conflict message, pending success, and responsive layout.

- [ ] **Step 8: Implement Material week/month views and request form**

Use `GridView`/`Wrap` and compact day cells. Include icon/text markers so color is not the only status signal.

- [ ] **Step 9: Register provider/routes and verify**

Run: `flutter test test/features/staff_schedule && flutter analyze`

Commit: `feat: add staff calendar and shift requests`

---

### Task 5: Professional Staff Profile

**Files:**
- Create: `lib/features/staff_profile/models/staff_certificate.dart`
- Create: `lib/features/staff_profile/models/staff_professional_profile.dart`
- Create: `lib/features/staff_profile/data/staff_profile_dao.dart`
- Create: `lib/features/staff_profile/repositories/staff_profile_repository.dart`
- Create: `lib/features/staff_profile/providers/staff_profile_provider.dart`
- Create: `lib/features/staff_profile/pages/staff_profile_page.dart`
- Create: `lib/features/staff_profile/pages/edit_staff_profile_page.dart`
- Create: `lib/features/staff_profile/widgets/staff_certificate_card.dart`
- Modify: `lib/app/app.dart`
- Modify: `lib/app/app_router.dart`
- Create matching tests under: `test/features/staff_profile/`

- [ ] **Step 1: Write failing certificate JSON tests**

Test valid encode/decode, empty JSON, malformed JSON fallback, and optional certificate detail.

- [ ] **Step 2: Implement models**

Expose one `toUpdateMap()` containing only editable professional columns.

- [ ] **Step 3: Write failing DAO tests**

Test joined user/profile load, missing profile default, upsert, and upcoming approved shifts only.

- [ ] **Step 4: Implement DAO/repository/provider**

Profile save must upsert by unique `user_id`, update timestamps, and reload the displayed profile.

- [ ] **Step 5: Write failing page/form tests**

Cover populated/empty certificates, read-only identity, add/remove certificate rows, invalid negative experience, save failure, and 320x568 keyboard layout.

- [ ] **Step 6: Implement pages and register routes/provider**

Use the existing user identity values for name/email/phone; do not duplicate their editing controls.

- [ ] **Step 7: Verify and commit**

Run: `flutter test test/features/staff_profile && flutter analyze`

Commit: `feat: add professional staff profile`

---

### Task 6: Dynamic Staff Notifications

**Files:**
- Create: `lib/features/staff_notifications/models/staff_notification_item.dart`
- Create: `lib/features/staff_notifications/data/staff_notifications_dao.dart`
- Create: `lib/features/staff_notifications/repositories/staff_notifications_repository.dart`
- Create: `lib/features/staff_notifications/providers/staff_notifications_provider.dart`
- Create: `lib/features/staff_notifications/pages/staff_notifications_page.dart`
- Create: `lib/features/staff_notifications/widgets/staff_notification_card.dart`
- Modify: `lib/app/app.dart`
- Modify: `lib/app/app_router.dart`
- Create matching tests under: `test/features/staff_notifications/`

- [ ] **Step 1: Write failing notification-key/model tests**

Prove keys are stable, type/priority mappings are deterministic, and routes carry required booking/shift IDs.

- [ ] **Step 2: Write failing DAO aggregation tests**

Inject/fix `now` in tests. Cover assigned new/cancelled booking events, shift request statuses, upcoming approved shifts, other-staff exclusion, priority/time sorting, read merge, mark one, and mark all.

- [ ] **Step 3: Implement aggregation and read-state persistence**

Generate items from source rows, then query read keys and merge in memory. Use insert conflict replace/ignore for idempotent reads.

- [ ] **Step 4: Write failing provider tests**

Test all/unread filters, unread count, optimistic or post-write mark read, mark all, refresh, and errors.

- [ ] **Step 5: Implement provider and page tests**

Page tests cover filters, badges, empty unread state, event navigation, pull-to-refresh, and responsive cards.

- [ ] **Step 6: Implement UI and register provider/route**

Use priority icon, readable timestamp, unread visual indicator, and semantic text label.

- [ ] **Step 7: Verify and commit**

Run: `flutter test test/features/staff_notifications && flutter analyze`

Commit: `feat: add staff notification center`

---

### Task 7: Personal Staff Statistics and Feedback

**Files:**
- Create: `lib/features/staff_statistics/models/staff_statistics_summary.dart`
- Create: `lib/features/staff_statistics/models/staff_statistics_point.dart`
- Create: `lib/features/staff_statistics/models/staff_feedback_item.dart`
- Create: `lib/features/staff_statistics/data/staff_statistics_dao.dart`
- Create: `lib/features/staff_statistics/repositories/staff_statistics_repository.dart`
- Create: `lib/features/staff_statistics/providers/staff_statistics_provider.dart`
- Create: `lib/features/staff_statistics/pages/staff_statistics_page.dart`
- Create: `lib/features/staff_statistics/widgets/statistic_summary_card.dart`
- Create: `lib/features/staff_statistics/widgets/completion_progress_card.dart`
- Create: `lib/features/staff_statistics/widgets/appointment_trend_chart.dart`
- Create: `lib/features/staff_statistics/widgets/staff_feedback_card.dart`
- Modify: `lib/app/app.dart`
- Modify: `lib/app/app_router.dart`
- Create matching tests under: `test/features/staff_statistics/`

- [ ] **Step 1: Write failing summary calculation tests**

Prove `0/0 -> 0%`, normal completion percentage, average rating rounding, and immutable trend/feedback mapping.

- [ ] **Step 2: Write failing DAO scoping tests**

Insert two staff members, assigned/unassigned bookings, examinations, and reviews. Assert only current-staff rows in the inclusive-start/exclusive-end range contribute.

- [ ] **Step 3: Implement aggregate queries**

Use SQL aggregates for summary and grouped completed-booking counts for trends. Attribute reviews through booking `staff_id`. Return recent feedback newest first.

- [ ] **Step 4: Write failing provider period tests**

Cover week/month ranges, previous/next, disabled future period, loading/error, and reload on mode change.

- [ ] **Step 5: Implement provider and widget tests**

Test zero-data screen, populated cards, long feedback, and 320x568 layout.

- [ ] **Step 6: Build lightweight chart widgets**

Use `LayoutBuilder`, proportional bars, labels, and `LinearProgressIndicator`; avoid custom painting unless necessary for clarity.

- [ ] **Step 7: Register provider/route, verify, and commit**

Run: `flutter test test/features/staff_statistics && flutter analyze`

Commit: `feat: add personal staff statistics`

---

### Task 8: Six-Destination Staff Navigation

**Files:**
- Modify: `lib/shared/widgets/app_bottom_navigation_bar.dart`
- Modify: `lib/shared/layouts/app_layout.dart`
- Modify: `lib/shared/layouts/staff_layout.dart`
- Modify: `lib/core/constants/app_routes.dart`
- Modify: `test/features/staff_examination/pages/staff_layout_responsive_test.dart`
- Test: `test/shared/widgets/staff_navigation_test.dart`

- [ ] **Step 1: Write failing role-specific navigation tests**

Verify staff primary destinations are Dashboard, Schedule, Pet Search, Notifications, Statistics, and Profile; nested staff routes select their parent destination; user/admin navigation remains unchanged.

- [ ] **Step 2: Write failing 320/360 responsive tests**

Prove navigation has no overflow and every destination remains reachable.

- [ ] **Step 3: Implement responsive staff navigation**

For narrow screens, show four high-frequency items plus `Thêm`; the overflow opens a bottom sheet/menu containing Statistics and Profile (and any displaced destination). Wider navigation displays all six directly. Map detail/edit routes to parent selection.

- [ ] **Step 4: Verify all layout tests**

Run:

```powershell
flutter test test/shared/widgets/staff_navigation_test.dart
flutter test test/features/staff_examination/pages/staff_layout_responsive_test.dart
flutter test test/features/staff_examination/pages/staff_pages_responsive_test.dart
```

- [ ] **Step 5: Commit**

Commit: `feat: integrate staff portal navigation`

---

### Task 9: Cross-Feature Flow and Regression Tests

**Files:**
- Create: `test/features/staff_portal/staff_portal_flow_test.dart`
- Create: `test/features/staff_portal/staff_portal_responsive_test.dart`
- Modify test fakes/helpers only where necessary.

- [ ] **Step 1: Write the end-to-end feature test**

Using a temporary SQLite database:

1. Create a confirmed assigned booking.
2. Save an examination result and capture its ID.
3. Query result detail by ID.
4. Search the pet globally.
5. Load its medical profile.
6. Assert the new record is first in the timeline.

- [ ] **Step 2: Run and fix only integration defects**

Run: `flutter test test/features/staff_portal/staff_portal_flow_test.dart`

Expected before fixes: FAIL only where module contracts disagree. Fix production contracts, not assertions that reflect the approved spec.

- [ ] **Step 3: Add a route/page smoke matrix**

Pump every new primary/detail/edit page at 320x568 and 360x640 with populated long-text fakes. Assert no exceptions or overflow messages.

- [ ] **Step 4: Run the complete test suite**

Run:

```powershell
dart format --output=none --set-exit-if-changed lib test
flutter analyze
flutter test
```

Expected: all commands exit 0.

- [ ] **Step 5: Commit**

Commit: `test: cover staff portal workflows`

---

### Task 10: Final Manual Verification and Delivery

**Files:**
- Modify only files required by defects found during verification.

- [ ] **Step 1: Reset/reinstall the local app database for seed verification**

Uninstall the debug app or delete its local database, then launch:

```powershell
flutter run
```

Log in with the seeded staff account and verify new-database creation, not only migration tests.

- [ ] **Step 2: Manually exercise the acceptance flow**

Verify:

- create result -> result detail;
- search pet -> full medical timeline;
- week/month calendar -> selected-day agenda;
- valid shift request and conflict rejection;
- profile edit persists after reopening;
- notification read state persists after refresh;
- statistics change between week/month;
- all six staff destinations work on a narrow emulator.

- [ ] **Step 3: Run final automated verification again**

```powershell
flutter analyze
flutter test
git diff --check
```

- [ ] **Step 4: Review scope and working tree**

Run `git status --short` and confirm no unrelated pre-existing files were staged or reverted. Review each task commit with `git log --oneline --max-count=12`.

- [ ] **Step 5: Commit final defect fixes if any**

```powershell
git add <only-final-fix-files>
git commit -m "fix: finalize staff portal"
```

Do not create an empty commit when no defect was found.

---

## Completion Checklist

- [ ] Database migration preserves version 1 data and new installs receive version 2 schema/seed data.
- [ ] Examination result detail uses `resultId` and post-save navigation reaches it.
- [ ] Pet search covers pet and owner fields with complete medical history.
- [ ] Calendar combines appointments and shifts and validates pending requests.
- [ ] Professional profile is editable without allowing shift edits.
- [ ] Notifications are dynamically generated with persistent local read state.
- [ ] Statistics are scoped to the authenticated staff member.
- [ ] Six staff destinations remain reachable at 320 px width.
- [ ] `flutter analyze`, `flutter test`, formatting check, and `git diff --check` pass.
