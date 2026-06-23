# Staff UI Improvement Design

Date: 2026-06-22

## Scope and constraints

- Change only Flutter files below `lib/features/staff_*` and
  `lib/features/staff_portal`.
- Do not change database schema, seeds, DAOs, repositories, SQL queries,
  `AuthProvider`, the application router, or shared UI components.
- Use existing Staff data-loading and write APIs. New behavior is limited to
  presentation, validation, navigation, and widget-local/provider state.

## Access control and logout

`StaffAccessGuard` lives in `staff_portal` and wraps every Staff page. It reads
the existing authentication state.

- Unauthenticated visitors are sent to Login.
- A non-Staff authenticated role sees an Access Denied screen and a route to
  its appropriate destination.
- A Staff role renders the guarded content.
- Staff More adds a destructive logout action with confirmation and busy state.
  It calls `AuthProvider.logout()` and navigates to Login, replacing the Staff
  route so Back cannot reveal Staff content.

## Forms and booking outcomes

- Shift request is a `Form`: date is today or later, times are parseable and
  ordered, note is at most 500 characters, and validation errors render under
  the input. Submitting disables the form action.
- Examination result requires trimmed symptom, diagnosis, and treatment. A
  next visit date is optional but must not be before today. Saving requires
  confirmation and uses existing provider submission state to prevent duplicate
  writes.
- One Staff booking-status presentation maps raw values to a Vietnamese label,
  color, and icon. UI actions are limited to valid states. Completion is
  confirmed before creating the examination result. Cancellation remains
  display-only because the existing Staff API exposes no cancellation command;
  adding one would require changing a DAO/query, which is out of scope.

## Common Staff UI states

Dedicated Staff-only state widgets provide:

- clear loading/skeleton feedback;
- empty state with icon, description, and reload action; and
- readable error state with Retry.

Dashboard, schedule, pet search, notifications, statistics, and profile use
these widgets. Content is inside `SafeArea`/scrollable layouts as appropriate,
with responsive card layouts and disabled actions while work is underway.

## Page-specific improvements

- Pet search retains its 350ms debounce, ignores whitespace-only terms, adds a
  clear control, and presents error/empty states.
- Schedule groups the already-loaded data in Upcoming, Pending approval, and
  Past views with UI-only filters. Shift cards surface date, time, type, and a
  localized status.
- Profile validates specialty and bio, constrains experience to 0–80, trims
  and removes blank certificates, caps bio at 500 characters with a counter,
  and gives save feedback. Profile displays certificate chips and safe defaults.
- Statistics supplies safe zero/no-rating defaults and readable stat cards.
- Notifications better differentiate unread cards, show human-readable times,
  and expose their existing per-notification read behavior. A "mark all read"
  control is intentionally omitted because the existing API only supports one
  notification at a time.

## Verification

- Add focused widget/unit tests in `test/features/staff_*` for guard decisions,
  shift/examination validation, and status mapping where dependencies allow.
- Run `flutter analyze` and the Staff-focused tests.
- Inspect the changed-file list to confirm no database, DAO, SQL, or non-Staff
  production files changed.
