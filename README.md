# StockPulse

StockPulse is a Flutter assignment project for a stock-market dashboard app. It demonstrates authentication, profile management, session persistence, BLoC state management, responsive UI, mock stock data, and WebSocket-based live index updates.

## Features

- Login screen with email and password validation
- Loading and error feedback during login
- Local session persistence using `shared_preferences`
- Stock dashboard after successful login
- Live index cards with WebSocket subscription support
- Mock stock and index data based on the assignment JSON
- Graceful fallback to simulated live updates when the WebSocket is unavailable
- Profile screen with user details
- Edit profile screen with form validation
- Logout flow that clears the active session state
- Responsive layout for mobile, tablet, and web
- Clean separation between UI, BLoC, services, models, and reusable widgets

## Tech Stack

- Flutter
- Dart
- `flutter_bloc`
- `equatable`
- `shared_preferences`
- `http`

## Project Structure

```text
lib/
  bloc/
    auth_bloc.dart        # Authentication events, states, and logic
    profile_bloc.dart     # Profile loading/saving state
    stock_bloc.dart       # Stock dashboard and live index state
  models/
    stock.dart            # Stock item model
    stock_index.dart      # Index model
    user_profile.dart     # User profile model
  screens/
    login_screen.dart
    stock_dashboard_screen.dart
    profile_screen.dart
    edit_profile_screen.dart
  services/
    session_service.dart  # Login/session/profile persistence
    stock_service.dart    # Mock data and WebSocket stream handling
  widgets/
    app_logo.dart
    metric_chip.dart
    stock_cards.dart
  main.dart               # App setup, providers, routes, and auth gate
test/
  widget_test.dart
```

## Architecture Overview

The app follows a simple clean-architecture style:

```text
Screens/Widgets
      | events
BLoCs
      | calls
Services
      | parse/store
Models
```

The UI does not directly perform login, storage, or WebSocket work. Screens dispatch BLoC events, BLoCs call services, and services return model objects. The UI rebuilds from BLoC states.

Example login flow:

```text
User taps Sign in
-> LoginSubmitted event
-> AuthBloc calls SessionService.login()
-> AuthState.authenticated
-> AppGate shows StockDashboardScreen
```

Example stock flow:

```text
Dashboard opens
-> StocksRequested event
-> StockBloc calls StockService.fetchIndices() and fetchStocks()
-> StockState.success
-> UI shows index cards and stock list
-> WebSocket updates dispatch LiveIndexReceived
```

## WebSocket Behavior

The assignment WebSocket endpoint is used in `StockService`:

```text
wss://streamer.ysil.in/
```

Subscription payload:

```json
{
  "action": "subscribe",
  "type": "freefeed",
  "symbols": ["NSEIDX_26000"]
}
```

If the WebSocket is unavailable, outside market hours, or blocked by the environment, the app falls back to simulated index updates so the dashboard remains demo-friendly.

## Demo Login

The login form is prefilled for quick testing:

```text
Email: abhay@stockpulse.app
Password: password123
```

To test the failed-login state, use:

```text
Password: fail123
```

## Getting Started

Install dependencies:

```bash
flutter pub get
```

Run on web:

```bash
flutter run -d web-server --web-hostname 127.0.0.1 --web-port 8080
```

If port `8080` is busy, use another port:

```bash
flutter run -d web-server --web-hostname 127.0.0.1 --web-port 8081
```

Run on a connected device or simulator:

```bash
flutter run
```


## Assignment Coverage

- Uses `flutter_bloc` for state management
- Separates UI, business logic, data services, and models
- Includes login, profile, edit profile, logout, and stock dashboard screens
- Includes form validation and visual feedback
- Includes local session handling
- Includes WebSocket subscription logic for live index updates
- Includes responsive Material UI
- Includes widget test coverage for the login screen
