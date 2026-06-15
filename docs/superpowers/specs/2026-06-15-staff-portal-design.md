# PetPal Staff Portal Design

Date: 2026-06-15
Status: Approved for implementation planning

## 1. Goal

Complete the staff experience with production-ready SQLite-backed screens for examination result details, schedule management, global pet search, staff profile, notifications, and personal statistics. The work must preserve the current Flutter architecture, remain responsive on small phones, and integrate with the existing staff booking and examination flow.

## 2. Scope

### In scope

- Replace the examination result detail placeholder with a functional read-only detail page.
- Add staff calendar views for shifts and appointments.
- Allow staff to request a new shift or a shift change, subject to approval.
- Add global pet search and complete medical history access.
- Add staff professional profiles with editable professional information.
- Add a dynamically generated notification center.
- Add staff-specific performance statistics and customer feedback.
- Assign bookings to staff so statistics and reviews can be attributed correctly.
- Add database migration, seed data, routes, navigation, providers, and tests.

### Out of scope

- An admin UI for approving shift requests. The data model and statuses will support a future admin workflow; seed data may include approved/rejected examples.
- Push notifications, remote synchronization, or a backend service.
- Editing saved examination results.
- Staff directly approving their own shift requests.
- Free-form shift deletion or modification after approval.

## 3. Architecture

Keep examination and booking work in `staff_examination`. Add five bounded feature modules:

- `staff_schedule`
- `staff_pet_search`
- `staff_profile`
- `staff_notifications`
- `staff_statistics`

Each module follows the existing project structure where needed: `models`, `data`, `repositories`, `providers`, `pages`, and `widgets`. Pages consume providers, providers own view state and call repositories, repositories expose domain-oriented methods, and DAOs contain SQLite queries.

Cross-feature reads may join existing tables, but modules must not directly mutate another module's provider state. Authentication supplies the current `staffId` from `AuthProvider.currentUser`.

## 4. Database Design

Upgrade the database from version 1 to version 2 using a non-destructive `onUpgrade` migration.

### Bookings

Add nullable column:

```sql
ALTER TABLE bookings ADD COLUMN staff_id INTEGER;
```

Existing rows remain valid. Migration assigns the seeded/default staff member to existing completed bookings and health-record-linked bookings where attribution can be inferred. Other historical bookings may remain unassigned.

New or seeded staff bookings should have `staff_id`. Staff-facing appointment queries default to the current staff member, while global pet history remains independent of booking assignment.

### Staff profiles

Create `staff_profiles`:

```text
id, user_id, specialty, experience_years, bio,
certificate_names, certificate_details,
created_at, updated_at
```

`user_id` is unique and references a user with role `staff`. Certificates are stored as JSON strings because the current application is local SQLite and does not need certificate-level querying. Parsing failures return an empty list rather than breaking the profile screen.

### Staff shifts

Create `staff_shifts`:

```text
id, staff_id, shift_date, start_time, end_time,
status, request_type, source_shift_id, request_note,
review_note, created_at, updated_at
```

Allowed statuses: `pending`, `approved`, `rejected`, `cancelled`.

Allowed request types: `assigned`, `register`, `change`.

- `assigned`: an existing approved roster entry.
- `register`: a staff request for a new shift.
- `change`: a proposed replacement referencing `source_shift_id`.

A pending change request does not alter the approved source shift. Only an approved replacement should be shown as the active shift in a future approval workflow.

### Notification read state

Create `staff_notification_reads`:

```text
id, staff_id, notification_key, read_at
```

`staff_id + notification_key` is unique. Notification content itself is not persisted. Stable keys are derived from event type and source row, for example `booking-created-12`, `booking-cancelled-12`, `shift-pending-8`, and `shift-upcoming-8-2026-06-15`.

### Indexes

Add indexes for:

- `bookings(staff_id, booking_date, status)`
- `health_records(pet_id, record_date)`
- `staff_shifts(staff_id, shift_date, status)`
- `staff_notification_reads(staff_id, notification_key)`
- searchable pet/owner fields where supported by the current SQLite schema

## 5. Models and Data Contracts

### Examination result detail

Extend the existing examination result query model only with joined display fields required by the page: pet name/species/breed, owner name, staff name, service name, and booking time. Persisted medical fields remain sourced from `health_records`.

Add repository methods:

```dart
Future<ExaminationResult?> getResultById(int resultId);
```

Existing `getResultByBooking` remains for booking detail.

### Schedule

`StaffScheduleEntry` represents either an approved/pending shift or assigned appointment using an entry type discriminator. `StaffShiftRequest` represents registration/change form input.

Repository responsibilities:

- Load entries for a date range and current staff.
- Load shift request history.
- Validate overlap with approved shifts and assigned appointments.
- Insert pending registration/change requests transactionally.

Time overlap uses half-open intervals: `[start, end)`. Adjacent shifts are allowed. Invalid or overnight intervals are rejected in version 1 of this feature.

### Pet search

`StaffPetSearchResult` contains pet summary plus owner contact details and a medical-record count. Search is case-insensitive and matches pet name, owner name, email, or phone using parameterized SQL.

`StaffPetMedicalProfile` groups pet details, owner details, and ordered health records. Records are ordered newest first.

### Staff profile

`StaffProfessionalProfile` combines the base `users` identity with `staff_profiles`. Editing is limited to specialty, years of experience, bio, and certificates. Name/email/phone remain under the existing user-profile ownership. Shift data is read-only from this page.

### Notifications

`StaffNotificationItem` has a stable key, type, title, message, event timestamp, route target, read state, and priority.

Notifications are generated from:

- newly created bookings assigned to the current staff member;
- cancelled assigned bookings;
- pending, approved, or rejected shift requests;
- approved shifts starting within the configured upcoming window.

The first implementation uses persisted timestamps and current local time. Items are sorted by priority, then newest first. Marking read only inserts/upserts `staff_notification_reads`.

### Statistics

`StaffStatisticsSummary` contains assigned count, completed count, completion rate, examination count, average rating, and rating count. Time-series points group completed appointments by day for week mode and by week/day as appropriate for month mode.

Reviews are attributed through `reviews.booking_id -> bookings.staff_id`. Unassigned bookings do not contribute to personal statistics.

## 6. Screens

### Examination Result Detail

Route query: `resultId`.

Sections:

- pet, owner, service, appointment, and examiner summary;
- symptoms and diagnosis;
- treatment plan;
- prescription/medicine;
- post-visit instructions;
- examination and next-visit dates.

Empty medical fields display a neutral `Không có thông tin` value. Missing IDs and missing records show recoverable error states. After successful examination creation, navigation replaces the form with this route using the inserted result ID.

### Staff Schedule

Default to week view with an optional month view. The page includes date navigation, today action, legend, selected-day agenda, and request action.

Visual categories:

- approved shift;
- pending shift request;
- confirmed/pending appointment;
- completed appointment;
- cancelled appointment.

The request form supports new-shift registration or change of an existing approved shift. It validates required values, date/time ordering, overlap, and explanatory note for changes. Successful submission refreshes the calendar and appears as pending.

### Global Pet Search

The page has a debounced search field, recent/all-pets initial state, result count, and cards with pet and owner summaries. Selecting a result opens a staff medical profile page containing identity, owner contact, care notes, and complete health-record timeline.

Search debounce target is 300-400 ms. Clearing the query restores the initial list. Empty and database-error states offer retry actions.

### Staff Profile

Display avatar/initials, identity, specialty, experience, bio, certificates, and upcoming approved shifts. An edit page updates only professional fields. Certificate entries support name and optional detail. Empty certificate lists have an explicit add action.

### Staff Notifications

Provide unread/all filters, unread count, mark-one-read, mark-all-read, pull-to-refresh, and event-specific navigation. Because notifications are generated dynamically, records that no longer meet the event window disappear while their read-state rows may remain harmlessly stored.

### Staff Statistics

Provide week/month range selection, previous/next period controls, summary cards, completion visualization, appointment trend, rating summary, and recent feedback list. Zero denominators produce `0%`, not NaN or an exception. Future periods are disabled unless explicitly needed later.

## 7. Navigation

Add staff routes for:

- schedule;
- pet search;
- pet medical profile with `petId`;
- staff notifications;
- staff statistics;
- staff profile and edit profile;
- examination result detail with `resultId`.

The staff navigation presents six primary destinations: Dashboard, Schedule, Pet Search, Notifications, Statistics, and Profile. Booking list remains reachable from Dashboard and relevant contextual actions rather than consuming another primary destination.

On narrow screens, use the existing bottom-navigation pattern with an overflow/menu solution if six labels do not fit safely. On wider layouts, use the existing navigation rail/drawer behavior. Detail/edit pages do not become primary navigation items.

## 8. State and Error Handling

Each provider exposes clear loading, success, empty, and error states. Providers ignore stale asynchronous search responses by tracking the latest query/request token. Mutations return success/failure and retain a user-facing error message.

Database writes for examination creation, booking completion, and shift requests use transactions. UI actions are disabled while their mutation is in progress to prevent duplicate inserts.

All date calculations use local dates consistently with the existing booking schema. Parsing malformed legacy date/time values must fail gracefully and omit invalid entries from calendar calculations while exposing a controlled error where appropriate.

## 9. Responsive and Accessibility Requirements

- Support at least 320x568 and 360x640 without overflow.
- Use scrollable content for forms and long detail pages.
- Keep tap targets at least 44 logical pixels where practical.
- Do not rely on color alone for calendar state; include labels/icons/legends.
- Long names, email addresses, notes, prescriptions, and certificates must wrap.
- Preserve readable contrast using the existing application color system.
- Loading, empty, and error states use shared widgets where possible.

## 10. Testing Strategy

Follow test-first implementation for each behavior.

### Database and DAO tests

- Version 1 to version 2 migration preserves existing rows.
- Existing bookings can have null `staff_id`.
- Result lookup by ID returns joined detail fields.
- Pet search matches each supported field and rejects SQL injection attempts through parameterization.
- Shift overlap validation covers adjacency, exact overlap, partial overlap, and appointments.
- Shift registration/change inserts pending rows without mutating approved rows.
- Notification generation and read-state merging are deterministic.
- Statistics exclude unassigned and other-staff bookings and handle zero values.

### Provider tests

- Loading, success, error, retry, filter, and refresh transitions.
- Debounced pet search ignores stale results.
- Shift mutation prevents duplicate submission.
- Statistics period selection reloads the correct range.

### Widget and routing tests

- Every new page fits 320x568 and 360x640.
- Empty, loading, error, and populated states render correctly.
- Routes parse and preserve `resultId` and `petId`.
- Navigation actions open the correct detail pages.
- Long medical and profile text wraps without overflow.

### End-to-end feature flow

Create examination result, capture inserted result ID, navigate to result detail, search for the pet globally, and verify the new medical record appears in the timeline.

## 11. Delivery Order

1. Database migration, shared identifiers, and route parsing.
2. Examination result detail and post-save navigation.
3. Global pet search and medical profile.
4. Staff schedule and shift requests.
5. Staff professional profile.
6. Dynamic notifications and read state.
7. Staff statistics and feedback.
8. Staff navigation integration, complete responsive pass, and full regression suite.

This order completes the existing examination workflow first, then builds reusable pet and staff attribution data before dependent notification/statistics screens.

## 12. Acceptance Criteria

- No staff screen remains a placeholder.
- All six requested functional areas use SQLite-backed data.
- Saved examination results can be reopened by result ID.
- Staff can view appointments and shifts together and submit non-conflicting pending shift requests.
- Staff can find any pet and review its full medical history without a current booking.
- Staff can edit professional profile data but cannot edit approved shifts from the profile.
- Notifications are derived from current data and support persistent local read state.
- Statistics are correctly scoped to the authenticated staff member.
- New routes work with deep-link query parameters.
- Automated tests pass and target phone sizes render without overflow.
