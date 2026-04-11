# Chirp

**Free, cross-platform eye care for people who stare at screens all day.**

![Platforms: macOS, Windows, Linux, iOS, Android, Chrome](https://img.shields.io/badge/platforms-macOS%20%7C%20Windows%20%7C%20Linux%20%7C%20iOS%20%7C%20Android%20%7C%20Chrome-blue)
![License: MIT](https://img.shields.io/badge/license-MIT-green)
![Version: 0.1.0](https://img.shields.io/badge/version-0.1.0-orange)

## What is Chirp?

Chirp reminds you to take breaks, blink, and fix your posture using the 20-20-20 rule: every 20 minutes, look at something 20 feet away for 20 seconds. Unlike other break reminder apps, Chirp works across all your devices, pauses itself when you're in meetings, and never phones home with your data.

## Install

```bash
# macOS
brew install --cask chirp

# Windows
winget install chirp

# Linux
snap install chirp
```

Or download the latest release directly from [GitHub Releases](https://github.com/anthropics/chirp/releases).

## Features

**Core**
- Smart break timer based on the 20-20-20 rule
- Blink reminders
- Posture reminders
- Custom reminder intervals and durations

**Productivity**
- Built-in Pomodoro timer
- Work schedule configuration (set active hours)
- Idle detection -- pauses automatically when you step away

**Smart**
- Smart Pause -- auto-pauses during meetings, video calls, and fullscreen apps
- Adaptive reminders based on your usage patterns

**Tracking**
- Daily health score (0-100)
- Stats dashboard with historical trends
- Session tracking and break compliance

**Connectivity**
- Device pairing -- sync settings and stats between desktop and mobile
- Team dashboard for shared accountability
- Chrome and Firefox browser extension

## Why Chirp?

- **Free forever.** LookAway charges $19-29 and only runs on Mac. Chirp is free on every platform.
- **Truly cross-platform.** Stretchly has no mobile app and no smart pause. Chirp runs on macOS, Windows, Linux, iOS, Android, and in your browser.
- **Smart features included.** Time Out and EyeLeo lack meeting detection, device sync, and health scoring. Chirp has all three.
- **Privacy-first.** No analytics, no telemetry, no accounts. Your data never leaves your device.

## Privacy

Chirp collects nothing. There are no analytics, no telemetry, no crash reporters, and no user accounts. All data stays on your device. If you use device pairing or team features, sync is optional and can be self-hosted.

## Screenshots

<!-- TODO: Add screenshots -->

## Building from source

Chirp is built with [Flutter](https://flutter.dev). You'll need the Flutter SDK installed.

```bash
git clone https://github.com/anthropics/chirp.git
cd chirp
flutter pub get
flutter run -d macos    # or: windows, linux, chrome
```

## Contributing

PRs are welcome. For larger changes, please open an issue first to discuss what you'd like to change.

## License

[MIT](LICENSE)
