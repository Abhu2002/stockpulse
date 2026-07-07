# StockPulse Flutter Interview Preparation

This document prepares you to explain the StockPulse assignment in an interview. Use it as revision notes before the discussion.

## 1. Project Overview

### Q1. Can you explain the assignment in your own words?

The task was to build a Flutter mobile application using the BLoC pattern. The app needed user authentication, profile management, logout, and a stock dashboard after login. The dashboard had to show stock indices and stock details, with live index updates using a WebSocket.

### Q2. What are the main features you implemented?

I implemented:

- Login screen with validation
- Loading and error feedback during login
- Session persistence using `shared_preferences`
- Stock dashboard after successful login
- Index cards and stock list
- WebSocket service for live index updates
- Fallback simulated updates when the WebSocket is unavailable
- Profile screen
- Edit profile screen
- Logout functionality
- Responsive UI for mobile and web
- BLoC-based state management

### Q3. Walk me through the app flow.

When the app starts, `AuthBloc` checks whether the user is already logged in. If the user is not logged in, `AppGate` shows the login screen. After successful login, `AuthBloc` emits an authenticated state, and `AppGate` shows the stock dashboard. The dashboard loads indices and stocks using `StockBloc`. The user can open profile, edit profile, or logout. Logout clears the session and returns the app to the login screen.

### Q4. What parts are mocked?

The login is mocked, meaning it does not call a real backend. The stock and index data are based on the assignment JSON and stored locally in `StockService`. The WebSocket connection is real, but if it is unavailable or outside market hours, the app falls back to simulated live updates.

## 2. Architecture

### Q5. What architecture did you follow?

I followed a simple clean architecture style with separation of concerns:

```text
Screens/Widgets -> BLoCs -> Services -> Models
```

The UI only displays data and dispatches events. BLoCs handle business logic and state. Services handle data operations like login persistence and stock/WebSocket data. Models represent structured data.

### Q6. Why did you create separate folders?

The folders keep the code organized:

- `bloc/`: state management and business logic
- `models/`: data structures
- `screens/`: full app screens
- `services/`: storage, mock API, and WebSocket logic
- `widgets/`: reusable UI components

This makes the project easier to maintain and scale.

### Q7. Why should UI not directly call services?

If UI directly calls services, screens become tightly coupled with business logic and data logic. By using BLoC, the UI only sends events and listens to states. This improves testability, readability, and maintainability.

### Q8. How is this architecture scalable?

New features can be added as separate BLoCs, services, models, and screens without changing unrelated code. For example, watchlist, search, or portfolio features can be added as separate modules.

## 3. BLoC

### Q9. What is BLoC?

BLoC stands for Business Logic Component. It separates business logic from UI. UI sends events to the BLoC, the BLoC processes them, and then emits states that the UI reacts to.

### Q10. What is the flow of BLoC?

```text
User action -> Event -> BLoC -> Service/business logic -> State -> UI rebuild
```

Example:

```text
User taps Sign in
-> LoginSubmitted event
-> AuthBloc calls SessionService.login()
-> AuthState.authenticated
-> Dashboard screen is shown
```

### Q11. What is an event?

An event represents something that happened in the UI or app. Examples:

- `LoginSubmitted`
- `LogoutRequested`
- `StocksRequested`
- `LiveIndexReceived`

### Q12. What is a state?

A state represents what the UI should display at a particular moment. Examples:

- loading
- authenticated
- unauthenticated
- success
- failure

### Q13. Why did you use BLoC instead of `setState`?

`setState` is fine for small local UI changes, but this app has authentication, profile persistence, stock loading, and WebSocket updates. BLoC keeps this logic outside the UI, making the app easier to test and maintain.

### Q14. Why did you use `Equatable`?

`Equatable` makes it easier to compare states and models by value instead of by object reference. This helps BLoC know when state has actually changed and avoids unnecessary rebuild issues.

### Q15. What is `BlocProvider`?

`BlocProvider` creates and provides a BLoC to the widget tree. Child widgets can access it using:

```dart
context.read<AuthBloc>()
```

or

```dart
context.watch<AuthBloc>()
```

### Q16. What is `BlocBuilder`?

`BlocBuilder` rebuilds UI when a BLoC emits a new state. I used it to show loading indicators, error messages, and loaded stock data.

### Q17. What is `BlocListener`?

`BlocListener` reacts to one-time side effects such as showing a `SnackBar` or navigating after a successful action. It should not be used to build UI.

### Q18. Difference between `BlocBuilder` and `BlocListener`?

`BlocBuilder` is for rebuilding widgets based on state. `BlocListener` is for side effects like snackbars, dialogs, and navigation.

### Q19. Why separate `AuthBloc`, `ProfileBloc`, and `StockBloc`?

Each BLoC has a separate responsibility:

- `AuthBloc`: login, logout, session state
- `ProfileBloc`: profile saving state
- `StockBloc`: stock loading and live index updates

This avoids one large BLoC with too many responsibilities.

## 4. Authentication

### Q20. How does login work?

The login screen validates email and password. If valid, it dispatches `LoginSubmitted` to `AuthBloc`. `AuthBloc` calls `SessionService.login()`. If login succeeds, it emits authenticated state. If login fails, it emits failure state and the UI shows a snackbar.

### Q21. What validations are added?

The login form validates:

- Email is not empty
- Email format is valid
- Password is not empty
- Password has at least 6 characters

### Q22. How is loading shown during login?

When login starts, `AuthBloc` emits `AuthStatus.loading`. The login button becomes disabled and shows a `CircularProgressIndicator`.

### Q23. How are login errors shown?

`BlocListener` listens for `AuthStatus.failure` and shows a `SnackBar` with the error message.

### Q24. How does the app know whether to show login or dashboard?

`AppGate` listens to `AuthBloc`. If state is authenticated, it shows `StockDashboardScreen`. If unauthenticated, it shows `LoginScreen`.

### Q25. Did you manually navigate after login?

No. I used auth state to control the screen. When `AuthBloc` emits authenticated state, `AppGate` automatically shows the dashboard.

## 5. Session and Storage

### Q26. Why did you use `shared_preferences`?

I used `shared_preferences` for simple local session persistence. It allows the app to remember whether the user is logged in and store demo profile data.

### Q27. What data is stored locally?

The app stores:

- login status
- user profile JSON

### Q28. Is `shared_preferences` secure?

No. `shared_preferences` is not secure for sensitive data like passwords or access tokens. It is fine for simple demo flags and non-sensitive data.

### Q29. What would you use for secure token storage?

For production, I would use `flutter_secure_storage` to store sensitive tokens securely using Keychain on iOS and Keystore on Android.

### Q30. How does logout work?

When the user logs out, `LogoutRequested` is sent to `AuthBloc`. `AuthBloc` calls `SessionService.logout()`, clears the login flag, and emits unauthenticated state. Then `AppGate` shows the login screen.

## 6. Profile Management

### Q31. How is the profile screen implemented?

The profile screen reads the current user profile from `AuthBloc` and displays the user's name, email, avatar, and bio. It also has edit profile and logout buttons.

### Q32. Why did you create `ProfileBloc`?

Profile editing has its own states like saving, success, and failure. Keeping it in `ProfileBloc` separates profile logic from authentication logic.

### Q33. How does edit profile work?

The edit profile screen loads current profile data into text controllers. When the user taps save, the form validates the fields and dispatches `ProfileSaved` to `ProfileBloc`.

### Q34. What validations are added to edit profile?

The edit profile form validates:

- Name is not empty
- Email is not empty
- Email format is valid
- Bio is not empty

### Q35. How is updated profile data reflected?

After profile save succeeds, the app dispatches `AuthProfileChanged` to `AuthBloc`, so the updated profile becomes available across the app.

## 7. Stock Dashboard

### Q36. What does the stock dashboard show?

The dashboard shows:

- Market dashboard header
- Horizontal live index cards
- Top stock list
- Stock price, change, percentage change, high, low, volume, and holdings

### Q37. What happens when the dashboard opens?

In `initState()`, the dashboard dispatches `StocksRequested` to `StockBloc`. `StockBloc` loads indices and stocks from `StockService`.

### Q38. Why did you create `Stock` and `StockIndex` models?

The assignment data comes as JSON. Models convert raw JSON into structured Dart objects, making the code safer and easier to read.

### Q39. How do stock updates reach the UI?

`StockService` emits live `StockIndex` updates through a stream. `StockBloc` listens to that stream and dispatches `LiveIndexReceived`. Then it updates the matching index and emits a new `StockState`, causing the UI to rebuild.

### Q40. How does refresh work?

The dashboard uses `RefreshIndicator`. Pulling down dispatches `StocksRequested` again and reloads stock/index data.

## 8. WebSocket

### Q41. What is a WebSocket?

A WebSocket is a persistent two-way connection between client and server. It allows the server to push updates to the app in real time.

### Q42. Difference between HTTP and WebSocket?

HTTP is request-response based. The client asks for data and the server responds. WebSocket stays open, so the server can push updates whenever data changes.

### Q43. Why use WebSocket for stock prices?

Stock prices need near real-time updates. WebSocket is better than repeatedly polling an API because updates can be pushed instantly and efficiently.

### Q44. Where is WebSocket implemented?

The WebSocket logic is implemented in `StockService`, inside the `liveIndexUpdates()` method.

### Q45. What WebSocket endpoint is used?

```text
wss://streamer.ysil.in/
```

### Q46. What subscription payload is used?

```json
{
  "action": "subscribe",
  "type": "freefeed",
  "symbols": ["NSEIDX_26000"]
}
```

### Q47. What happens if WebSocket fails?

The app catches the error and switches to simulated index updates. This keeps the dashboard working during demos, outside market hours, or if the socket is unavailable.

### Q48. How would you improve WebSocket handling in production?

I would add:

- reconnect with exponential backoff
- heartbeat/ping handling
- unsubscribe support
- better error reporting
- stream lifecycle management
- multiple symbol subscriptions

## 9. Models

### Q49. What is `fromJson()`?

`fromJson()` converts raw JSON data into a Dart model object.

### Q50. What is `toJson()`?

`toJson()` converts a Dart object into JSON/map format. It is used when saving profile data to local storage.

### Q51. What is `copyWith()`?

`copyWith()` creates a new object by copying the old object and replacing selected fields. It is useful because BLoC states and models should be treated as immutable.

### Q52. Why avoid mutating existing objects?

Immutable state is safer and predictable. Instead of changing an existing object, we create a new updated object and emit it as a new state.

### Q53. How do you parse price strings?

The model removes commas and uses `double.tryParse()`. If parsing fails, it returns `0`.

## 10. UI and Responsiveness

### Q54. How did you make the UI responsive?

The dashboard checks the available width using `SliverLayoutBuilder`. On mobile, it uses a `SliverList`. On wider screens, it uses a two-column `SliverGrid`.

### Q55. Why use `SliverList` on mobile?

Mobile screens have limited width and dynamic content height. `SliverList` allows each stock card to take natural height, preventing overflow.

### Q56. Why use `SliverGrid` on wide screens?

Wide screens have more horizontal space. A two-column grid makes better use of space and improves scanability.

### Q57. What caused the RenderFlex overflow?

The stock cards and index cards had content that needed more vertical space than the fixed card height allowed. On mobile, chips wrapped into extra lines, causing overflow.

### Q58. How did you fix RenderFlex overflow?

I changed mobile stock layout from fixed-height grid to natural-height list. I also made index cards more compact and increased the carousel height slightly.

### Q59. Why use `SafeArea`?

`SafeArea` prevents UI from going under system areas like notches, status bars, and navigation bars.

### Q60. Why use `SingleChildScrollView` on login?

It prevents overflow when the keyboard opens or on smaller screens.

## 11. Flutter Widgets

### Q61. Difference between `StatelessWidget` and `StatefulWidget`?

`StatelessWidget` has no internal mutable state. `StatefulWidget` has state that can change during runtime.

### Q62. Why is login screen stateful?

The login screen owns text controllers and password visibility state, so it needs to be stateful.

### Q63. Why dispose controllers?

Text controllers use resources. Disposing them prevents memory leaks.

### Q64. What is `Form`?

`Form` groups multiple input fields and allows validation of all fields together.

### Q65. What is `GlobalKey<FormState>`?

It gives access to the form state so we can call:

```dart
_formKey.currentState!.validate()
```

### Q66. What is `ScaffoldMessenger`?

`ScaffoldMessenger` shows snackbars and other scaffold-level messages.

### Q67. What is `Navigator`?

`Navigator` manages screen navigation, such as pushing profile screen or returning back.

## 12. Routing

### Q68. How is navigation handled?

The app uses named routes in `MaterialApp`. Auth-based switching is handled by `AppGate`, while profile/edit screens are opened using `Navigator.pushNamed()`.

### Q69. How does logout navigate to login?

Logout emits unauthenticated state from `AuthBloc`. `AppGate` reacts to that state and shows the login screen.

### Q70. How would you improve routing?

For a larger app, I would use `go_router` because it handles nested routes, route guards, deep links, and redirect logic more cleanly.

## 13. Testing

### Q71. What tests did you write?

I wrote a widget test that verifies the login screen loads and contains the email and password fields.

### Q72. How would you test BLoC logic?

I would use `bloc_test` to test event-to-state transitions. For example, `LoginSubmitted` should emit loading and then authenticated state.

### Q73. How would you test failed login?

I would mock `SessionService.login()` to throw an exception and verify that `AuthBloc` emits failure state.

### Q74. How would you test WebSocket updates?

I would mock `StockService.liveIndexUpdates()` with a stream that emits fake `StockIndex` updates, then verify that `StockBloc` updates its state correctly.

### Q75. What commands did you run for quality checks?

```bash
flutter analyze
flutter test
flutter build web
```

## 14. Error Handling

### Q76. How do you handle login failure?

`SessionService.login()` throws an `AuthException`. `AuthBloc` catches it and emits failure state. The login screen shows a snackbar.

### Q77. How do you handle stock loading failure?

`StockBloc` catches errors while loading data and emits failure state with an error message.

### Q78. How do you handle WebSocket failure?

`StockService` catches WebSocket errors and falls back to simulated updates.

### Q79. How would you handle no internet in production?

I would detect connectivity, show a clear offline UI, cache previous data locally, and retry requests when the connection returns.

### Q80. How would you handle invalid JSON?

I would use safer parsing, validation, error logging, and fallback values. For production, I would also report parsing errors to monitoring tools.

## 15. Performance

### Q81. How do you avoid unnecessary rebuilds?

Using BLoC separates state updates. Widgets rebuild only when the BLoC state changes. `Equatable` helps compare states by value.

### Q82. How would you optimize a long stock list?

I would use lazy builders like `ListView.builder` or `SliverList`, pagination, caching, and possibly search/filtering.

### Q83. Why cancel stream subscription in `close()`?

The WebSocket/live stream subscription must be cancelled when `StockBloc` is destroyed to avoid memory leaks and unnecessary background work.

### Q84. How would you optimize frequent WebSocket updates?

I would batch updates, throttle UI rebuilds, update only changed items, and avoid rebuilding the entire dashboard when only one index changes.

## 16. Code Quality

### Q85. Why split reusable widgets?

Reusable widgets like `IndexCard`, `StockTile`, and `MetricChip` keep screen files clean and reduce duplication.

### Q86. Why not put everything in `main.dart`?

Putting everything in `main.dart` makes the app hard to read, test, and maintain. Splitting files by responsibility is cleaner.

### Q87. How is your code maintainable?

Each class has a clear responsibility. Services handle data, BLoCs handle state, screens handle UI, and models handle structured data.

### Q88. What would you refactor with more time?

I would add a repository layer between BLoC and services, improve WebSocket reconnection, add secure authentication, add more tests, and connect to real backend APIs.

## 17. Production Improvements

### Q89. How would you connect real backend login?

I would create an `AuthRepository` that calls a backend API using `dio` or `http`, receives access/refresh tokens, stores them securely, and exposes login/logout methods to `AuthBloc`.

### Q90. How would you secure authentication?

I would store tokens in `flutter_secure_storage`, never store passwords, use HTTPS, refresh tokens safely, and handle token expiry.

### Q91. How would you improve API handling?

I would use:

- repository layer
- DTOs
- API error mapping
- retry logic
- interceptors
- logging

### Q92. How would you add offline cache?

I would use Hive, SQLite, or Isar to cache stock and profile data locally, then sync with the backend when internet is available.

### Q93. How would you add CI/CD?

I would configure GitHub Actions to run:

```bash
flutter pub get
flutter analyze
flutter test
flutter build apk
```

### Q94. How would you add crash reporting?

I would integrate Firebase Crashlytics or Sentry to capture runtime errors and crashes.

### Q95. How would you add dark mode?

I would define light and dark `ThemeData` in `MaterialApp`, then use color scheme tokens throughout the app.

## 18. Important Code-Specific Questions

### Q96. What does `AppGate` do?

`AppGate` listens to `AuthBloc` and decides whether to show login, dashboard, or loading screen based on auth state.

### Q97. What does `SessionService.login()` do?

It simulates login, throws an error for the test password `fail123`, saves the logged-in flag, saves the profile, and returns a `UserProfile`.

### Q98. What does `StockService.liveIndexUpdates()` do?

It tries to connect to the WebSocket, sends the subscription payload, parses incoming messages, and emits `StockIndex` updates. If it fails, it emits simulated updates.

### Q99. What does `LiveIndexReceived` do?

It carries one updated index from the live stream into `StockBloc`, which replaces the matching index in the current list and emits a new state.

### Q100. Why use `copyWith()` in models?

`copyWith()` helps create updated copies without mutating the original object. This is useful for immutable state management.

## 19. Weaknesses and Honest Answers

### Q101. What are the limitations of this project?

Current limitations:

- Login is mocked, not connected to real API
- Stock data is local mock data
- WebSocket fallback is simulated
- No secure token storage
- Limited test coverage
- No repository layer yet
- No offline database cache

### Q102. Why is mock login acceptable here?

The assignment allowed mock APIs. The purpose was to demonstrate UI, state management, architecture, validation, and data flow.

### Q103. Why did you add fallback updates?

The provided WebSocket may work only during market hours or may be unavailable in some environments. Fallback updates ensure the dashboard can still demonstrate live-state behavior.

### Q104. What would you improve first?

I would add a repository layer, connect real APIs, improve WebSocket reconnection, add secure token storage, and add BLoC tests.

## 20. Best Short Answers

### Explain your approach.

I first broke the assignment into authentication, profile management, and stock dashboard modules. Then I created models for user profile, stock, and index data. I added services for session storage and stock/WebSocket data. After that, I used BLoC to separate business logic from UI. The screens only dispatch events and rebuild based on states. I used `shared_preferences` for local session persistence, mock JSON for stock data, and WebSocket logic for live index updates with fallback simulated updates when the socket is unavailable. I also made the dashboard responsive for mobile and web.

### Explain BLoC in this project.

In this app, the UI sends events to BLoCs. For example, login sends `LoginSubmitted` to `AuthBloc`. The BLoC calls the required service, then emits a state like loading, success, or failure. The UI listens to those states and updates itself. This keeps UI and business logic separate.

### Explain login flow.

The login screen validates email and password. If valid, it dispatches `LoginSubmitted`. `AuthBloc` emits loading, calls `SessionService.login()`, saves the session if successful, and emits authenticated state. `AppGate` then shows the dashboard.

### Explain stock flow.

When the dashboard opens, it dispatches `StocksRequested`. `StockBloc` loads indices and stocks from `StockService`, emits success state, and starts listening to live index updates. When a live update arrives, `StockBloc` updates the matching index and the UI rebuilds.

### Explain WebSocket fallback.

The app tries to connect to the provided WebSocket endpoint and subscribe to `NSEIDX_26000`. If the connection fails or is unavailable outside market hours, the service emits simulated updates. This keeps the demo working and still demonstrates real-time state handling.

### Explain responsive UI.

The dashboard uses a list layout on mobile so cards can take natural height and avoid overflow. On wider screens, it uses a two-column grid to use available space better.

## 21. Final Interview Pitch

Use this if the interviewer asks you to summarize the project:

> StockPulse is a Flutter stock dashboard assignment built using BLoC. I separated the project into screens, BLoCs, services, models, and reusable widgets. Authentication and session persistence are handled through `AuthBloc` and `SessionService`. Stock data and live updates are handled through `StockBloc` and `StockService`. The app uses mock assignment data, attempts a real WebSocket subscription for live index updates, and falls back to simulated updates if the stream is unavailable. I also implemented profile editing, logout, validation, loading/error states, responsive UI, and basic widget testing.

