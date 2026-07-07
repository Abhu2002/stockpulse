Task implemented (live WebSocket & offline handling)

Date: 2026-07-07

Summary of work completed for the live feed task:

- WebSocket endpoint: `wss://streamer.ysil.in/freefeed` (single endpoint used).
- Added `connectivity_plus` to detect network state and show an offline UI when no network is available.
- Replaced `dart:io` WebSocket with `web_socket_channel` for cross-platform compatibility (mobile + web).
- Subscription preferences: `NSEIDX_26000` and `NSEIDX_26060` (falls back to `NSEIDX_26060`).
- Robust message parsing for pipe-delimited feed messages and safe numeric parsing.
- Fallback simulated updates when live stream is unavailable.

How to run locally:

```bash
cd /Users/abhaykapadnis/Desktop/stockpulse
flutter pub get
flutter run -d <device-or-browser>
```

If you want me to expand this section with architecture diagrams, reconnection strategy, or sample debug logs to show during the interview, tell me which one and I'll add it.
