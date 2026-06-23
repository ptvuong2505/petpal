# Staff UI Improvement Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use `superpowers:executing-plans` to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Make every Staff flow role-safe, validated, resilient, and consistent without changing the persistence layer.

**Architecture:** Add Staff-only presentation primitives under `staff_portal/widgets` and consume them from Staff feature pages. Each routed Staff page renders behind the same guard; form and data-page state stays local or uses the existing `StaffExaminationProvider`, while all persistence calls remain unchanged.

**Tech Stack:** Flutter, Material 3, Provider, existing `AuthProvider`, existing Staff DAOs/repositories/providers.

---

## File map

| File | Responsibility |
| --- | --- |
| `lib/features/staff_portal/widgets/staff_access_guard.dart` | Staff-only route gate and Access Denied UI. |
| `lib/features/staff_portal/widgets/staff_state_view.dart` | Loading/skeleton, empty, and error/retry widgets. |
| `lib/features/staff_portal/pages/staff_more_page.dart` | Confirmed, non-repeatable Staff logout. |
| `lib/features/staff_examination/widgets/staff_booking_status.dart` | Single raw-status → Vietnamese label/color/icon mapping. |
| `lib/features/staff_examination/widgets/staff_status_badge.dart` | Badge visual backed by the shared mapping. |
| `lib/features/staff_examination/pages/*.dart` | Guarded booking/dashboard/result views and confirmed completion flow. |
| `lib/features/staff_schedule/pages/*.dart` | Shift form validation and UI-only grouped/filterable schedule. |
| `lib/features/staff_pet_search/pages/*.dart` | Guarded debounced search with local states. |
| `lib/features/staff_notifications/pages/staff_notifications_page.dart` | Readability, local async states, readable timestamps. |
| `lib/features/staff_statistics/pages/staff_statistics_page.dart` | Safe defaults, skeleton/error/empty handling, responsive cards. |
| `lib/features/staff_profile/pages/*.dart` | Profile state handling, validation, chips, and save feedback. |
| `test/features/staff_*/...` | Focused behavior tests that make no database changes. |

### Task 1: Add Staff-only guard and async state primitives

**Files:**
- Create: `lib/features/staff_portal/widgets/staff_access_guard.dart`
- Create: `lib/features/staff_portal/widgets/staff_state_view.dart`
- Test: `test/features/staff_portal/staff_access_guard_test.dart`

- [ ] **Step 1: Write the failing guard widget tests.** Cover loading while `isCheckingLogin`, Access Denied for `user`/`admin`, and child rendering for `staff` using a fake `AuthProvider` state.
- [ ] **Step 2: Run the focused test.**

  Run: `flutter test test/features/staff_portal/staff_access_guard_test.dart`

  Expected: FAIL because the Staff-only guard does not exist.

- [ ] **Step 3: Implement minimal Staff primitives.** `StaffAccessGuard` must read `AuthProvider`, return a loading state while session recovery is in progress, schedule `NavigationService.goTo(context, AppRoutes.login)` for an unauthenticated visitor, and render a Vietnamese Access Denied state for a non-staff role. `StaffLoadingState` exposes a skeleton variant; `StaffEmptyState` and `StaffErrorState` accept an icon, description, and retry callback.
- [ ] **Step 4: Run focused tests again.**

  Run: `flutter test test/features/staff_portal/staff_access_guard_test.dart`

  Expected: PASS.

### Task 2: Guard every routed Staff page and implement logout

**Files:**
- Modify: `lib/features/staff_portal/pages/staff_more_page.dart`
- Modify: `lib/features/staff_examination/pages/staff_dashboard_page.dart`
- Modify: `lib/features/staff_examination/pages/staff_booking_list_page.dart`
- Modify: `lib/features/staff_examination/pages/staff_booking_detail_page.dart`
- Modify: `lib/features/staff_examination/pages/create_examination_result_page.dart`
- Modify: `lib/features/staff_examination/pages/examination_result_detail_page.dart`
- Modify: `lib/features/staff_schedule/pages/staff_schedule_page.dart`
- Modify: `lib/features/staff_schedule/pages/staff_shift_request_page.dart`
- Modify: `lib/features/staff_pet_search/pages/staff_pet_search_page.dart`
- Modify: `lib/features/staff_pet_search/pages/staff_pet_medical_profile_page.dart`
- Modify: `lib/features/staff_notifications/pages/staff_notifications_page.dart`
- Modify: `lib/features/staff_statistics/pages/staff_statistics_page.dart`
- Modify: `lib/features/staff_profile/pages/staff_profile_page.dart`
- Modify: `lib/features/staff_profile/pages/edit_staff_profile_page.dart`

- [ ] **Step 1: Wrap the visual output of each page in `StaffAccessGuard`.** Keep its existing body as the guarded child. For pages that start an async load in `initState`/`didChangeDependencies`, verify `currentRole == 'staff'` before starting that load so an unauthorized visit does not request Staff data.
- [ ] **Step 2: Add the More-page logout test and implement it.** The test opens the confirmation dialog, taps confirm once, asserts the action is disabled while awaiting `logout`, and checks that navigation uses the Login route. Implement the destructive `ListTile`, `showDialog<bool>`, `_isLoggingOut`, `await context.read<AuthProvider>().logout()`, and `NavigationService.goTo(...login)`.
- [ ] **Step 3: Run the focused guard/logout tests.**

  Run: `flutter test test/features/staff_portal`

  Expected: PASS.

### Task 3: Correct shift-request validation

**Files:**
- Modify: `lib/features/staff_schedule/pages/staff_shift_request_page.dart`
- Test: `test/features/staff_schedule/staff_shift_request_validation_test.dart`

- [ ] **Step 1: Extract pure local validators and write failing tests.** Test an earlier-than-today date, invalid date/clock text, equal/reversed start/end, a 501-character note, and valid boundary input.
- [ ] **Step 2: Implement the smallest `Form` change.** Use `TextFormField` validators with `autovalidateMode: AutovalidateMode.onUserInteraction`; parse `HH:mm` into minutes; compare normalized calendar dates; set `maxLength: 500`; disable the submit button and fields while `_submitting`.
- [ ] **Step 3: Preserve the current DAO request exactly.** Call `requestShift` only after `formKey.currentState!.validate()` succeeds, passing trimmed strings as today. On success show a success SnackBar then navigate to Staff Schedule; on failure retain the form and show a friendly error.
- [ ] **Step 4: Run the focused test.**

  Run: `flutter test test/features/staff_schedule/staff_shift_request_validation_test.dart`

  Expected: PASS.

### Task 4: Validate and confirm examination completion

**Files:**
- Modify: `lib/features/staff_examination/pages/create_examination_result_page.dart`
- Test: `test/features/staff_examination/examination_result_validation_test.dart`

- [ ] **Step 1: Add failing validator tests.** Require whitespace-trimmed symptom, diagnosis, and treatment; accept today's next-visit date; reject an earlier date.
- [ ] **Step 2: Change the treatment validator.** Replace the current "treatment or note" rule with the required trimmed treatment rule. Keep title validation and optional secondary fields.
- [ ] **Step 3: Add a confirmation dialog before `createExaminationResult`.** Do not construct/write the result unless the dialog returns `true`; recheck `provider.isSubmitting` before awaiting the API. The existing `isSubmitting` disables the save button during the write.
- [ ] **Step 4: Trim all persisted text and validate next-visit against the local start of today.** Keep the existing model/repository/DAO invocation unchanged.
- [ ] **Step 5: Run focused tests.**

  Run: `flutter test test/features/staff_examination/examination_result_validation_test.dart`

  Expected: PASS.

### Task 5: Normalize booking status presentation

**Files:**
- Create: `lib/features/staff_examination/widgets/staff_booking_status.dart`
- Modify: `lib/features/staff_examination/widgets/staff_status_badge.dart`
- Modify: `lib/features/staff_examination/widgets/staff_booking_card.dart`
- Modify: `lib/features/staff_examination/pages/staff_booking_list_page.dart`
- Modify: `lib/features/staff_examination/pages/staff_booking_detail_page.dart`
- Test: `test/features/staff_examination/staff_booking_status_test.dart`

- [ ] **Step 1: Write a mapping test.** Assert `pending`, `confirmed`, `completed`, and `cancelled` use Vietnamese labels, a non-null Material icon, and stable colors; unknown data falls back to "Không xác định".
- [ ] **Step 2: Add `StaffBookingStatus` value data and have the badge render its label/icon/colors.** Keep raw values only for filtering/API calls, never as customer-facing labels.
- [ ] **Step 3: Restrict UI actions by status.** The result-creation action is visible only for pending/confirmed bookings with no result; completed/cancelled bookings show a disabled explanatory state. Completion confirmation occurs in Task 4. Do not add cancellation mutation because there is no permitted existing API.
- [ ] **Step 4: Run status tests.**

  Run: `flutter test test/features/staff_examination/staff_booking_status_test.dart`

  Expected: PASS.

### Task 6: Standardize dashboard, pet search, and schedule states

**Files:**
- Modify: `lib/features/staff_examination/pages/staff_dashboard_page.dart`
- Modify: `lib/features/staff_pet_search/pages/staff_pet_search_page.dart`
- Modify: `lib/features/staff_schedule/pages/staff_schedule_page.dart`

- [ ] **Step 1: Replace ad-hoc loading/empty/error displays with Staff state widgets.** Each retry calls its original load method; cards preserve responsive width constraints and `SafeArea`/scroll behavior.
- [ ] **Step 2: Finish the pet-search UX.** Keep debounce at 350ms, cancel the timer on new input/dispose, skip DAO calls when `value.trim().isEmpty`, add a suffix clear button, capture errors, and ignore stale async responses with a request counter.
- [ ] **Step 3: Build schedule UI-only filters.** After the unchanged weekly DAO load, derive `pending`, `upcoming`, and `past` lists from `_items` and the local date. Add a `SegmentedButton`/chips and a card displaying event type, date, time, and `StaffStatusBadge`; never filter through a new query.
- [ ] **Step 4: Run analyzer for the modified areas.**

  Run: `flutter analyze lib/features/staff_examination lib/features/staff_pet_search lib/features/staff_schedule lib/features/staff_portal`

  Expected: no errors.

### Task 7: Improve Profile and Statistics resilience

**Files:**
- Modify: `lib/features/staff_profile/pages/staff_profile_page.dart`
- Modify: `lib/features/staff_profile/pages/edit_staff_profile_page.dart`
- Modify: `lib/features/staff_statistics/pages/staff_statistics_page.dart`
- Test: `test/features/staff_profile/edit_staff_profile_validation_test.dart`

- [ ] **Step 1: Write failing profile-validator tests.** Require trimmed specialty/bio, allow experience 0 and 80, reject non-numeric/negative/>80 values, and verify blank certificate lines are removed.
- [ ] **Step 2: Convert the edit page to a `Form`.** Add validators, `maxLength: 500`/counter for bio, numeric text input formatting, disabled save action while `_saving`, and local error/success SnackBars. Keep `saveProfile` arguments and certificate JSON behavior unchanged.
- [ ] **Step 3: Make profile loading explicit.** Track loading/error separately from the nullable record, show Staff state widgets with retry, use `Chưa cập nhật` and `0` defaults, and render cleaned certificates as wrapping `Chip`s.
- [ ] **Step 4: Make statistics robust.** Track loading/error separately, show a Staff skeleton while loading, defensively read numbers/list feedback, use `Chưa có đánh giá` when no rating exists, and use responsive cards with no overflow.
- [ ] **Step 5: Run profile test and analyzer.**

  Run: `flutter test test/features/staff_profile/edit_staff_profile_validation_test.dart && flutter analyze lib/features/staff_profile lib/features/staff_statistics`

  Expected: PASS with no analyzer errors.

### Task 8: Improve notifications and inspect all Staff UI states

**Files:**
- Modify: `lib/features/staff_notifications/pages/staff_notifications_page.dart`
- Modify: `lib/features/staff_portal/docs/2026-06-22-staff-improvement-design.md`

- [ ] **Step 1: Add guarded local loading/error/empty states.** Retain pull-to-refresh and per-item `markRead`; disable a tapped item while it is being marked to prevent duplicate presses.
- [ ] **Step 2: Improve visual meaning.** Give unread notifications a leading unread indicator and stronger container treatment; use a local `formatRelativeTime` helper for valid event timestamps, falling back safely to the existing string.
- [ ] **Step 3: Deliberately omit "mark all read".** The existing DAO only exposes `markRead(staffId, key)`; do not loop over the list because that creates a new bulk behavior and risks partial failure. Keep this limitation recorded in the design doc.
- [ ] **Step 4: Perform a manual state pass.** Exercise loading, empty, error/retry, and narrow-screen layout on Dashboard, Schedule, Pet Search, Notifications, Statistics, and Profile.

### Task 9: Final verification and scope audit

**Files:**
- Verify: all files listed above

- [ ] **Step 1: Format only modified Staff files.**

  Run: `dart format <each modified Staff Dart file>`

- [ ] **Step 2: Run all tests and static analysis.**

  Run: `flutter test && flutter analyze`

  Expected: all tests pass and analysis emits no errors.

- [ ] **Step 3: Audit changed files.**

  Run: `git diff --name-only` and `git diff -- lib/core/database lib/**/data lib/**/repositories`

  Expected: no changed database, DAO, repository, query, SQL, or non-Staff production file.

- [ ] **Step 4: Review the complete diff and report any pre-existing user changes separately.** Do not stage or commit unrelated files (`pubspec.lock`, `.cursor/`).
