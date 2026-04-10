# LookAway Competitive Analysis
**Date**: April 10, 2026
**Product**: LookAway v2.0.0 (https://lookaway.com/)
**Developer**: Mystical Bits, LLC (Kushagra Agarwal)
**Platform**: macOS 13+ only

---

## Product Overview
Mac-native digital wellness app that enforces healthy screen habits through smart break reminders, blink/posture nudges, and iPhone sync. Built around the 20-20-20 rule.

## Complete Feature List

### Core Break System
- Customizable break intervals (short + long breaks)
- Pre-break notifications with snooze (+1m, +5m, +15m)
- Floating countdown that follows cursor
- Menu bar live status + Quick Look panel (v2.0)
- Break screen with custom text, sounds, wallpapers/gradients/images
- Animated break backgrounds (v2.0)
- Postpone limits (v2.0)
- Skip break replaced with +15m snooze (v2.0)

### Smart Pause (Activity Detection)
- Meeting/call detection (camera/microphone activity)
- Video playback detection (YouTube, Netflix, VLC, QuickTime)
- Screen recording/sharing detection (OBS, QuickTime, Zoom)
- Fullscreen gaming detection
- Deep Focus Apps (user-configurable list)
- Post-activity delay (1/2/5 min)

### Wellness Reminders
- Blink reminders (configurable interval, position, size)
- Posture reminders (configurable interval, position, size)

### Stats & Gamification (v2.0)
- Screen Score (0-100 metric)
- Stats dashboard: screen time, breaks taken, longest session, median session, app usage
- Quick Look menu bar panel

### iPhone Sync
- LookAway Mirror companion iOS app
- Blocks websites/apps on iPhone during Mac breaks
- Push notifications for break events
- Pairing via code (max 3 iPhones per Mac, 5 Macs per iPhone)

### Scheduling & Focus
- Office Hours (active days + hours)
- macOS Focus Filters integration
- Idle time detection (pause when away)

### Automations
- Run AppleScript or Shortcuts on break start/end
- AppleScript commands: start break, pause, resume, postpone, open settings
- Works with Alfred, Raycast, cron

### Design & Platform
- Native Swift app (25 MB, <1% CPU, ~100 MB RAM)
- Liquid Glass design for macOS Tahoe (v2.0)
- Global keyboard shortcuts
- Multi-display support
- Session resumption on restart (v2.0)
- Dark interface, sufficient contrast (accessibility)

---

## Pricing

### Website (One-Time Purchase)
| License | Price | Seats |
|---------|-------|-------|
| Single | $19 | 1 device |
| Personal | $29 (save 25%) | 2 devices |
| Team | $29/seat (min 5) | 5+ devices |
| Renewal (optional) | 50% off ($9.50-$14.50/seat) | Extends updates 1 year |
| Educational | 30% discount | Requires .edu email |

### App Store
- Free + In-App Purchases (subscription model)
- Different pricing from website

### Other Channels
- Setapp (subscription service, full features including iPhone Sync)
- Homebrew: `brew install --cask lookaway`

### Payment
- Stripe Checkout (hosted)
- Supports multiple currencies
- Merchant: Mystical Bits

---

## Technical Architecture (Website)

- **Stack**: Static HTML + CSS + vanilla JS (no framework)
- **CSS**: Single custom stylesheet
- **JS**: cash.js (jQuery alt), custom faq-accordion.js, plasma-ghost-canvas.js
- **Fonts**: Google Fonts (Geist Mono), SeriouslyNostalgic (custom)
- **Hosting**: Cloudflare
- **Analytics**: Plausible (privacy-focused) + Cloudflare Web Analytics
- **Performance**: DOMContentLoaded 118ms, full load 134ms
- **Blog**: 5 pages, ~40-45 articles, RSS feed, 8 categories

---

## Public Roadmap (lookaway.userjot.com)

| Feature | Status | Comments |
|---------|--------|----------|
| Custom reminders | Planned | 24 |
| Wind down (end-of-day) | In Progress | 23 |
| Scheduled breaks (lunch, walks) | Planned | 13 |
| Windows app | Planned | 12 |
| Apple Watch support | Reviewing | 10 |
| Pomodoro timer | Reviewing | 10 |
| iPad Mirror app | Planned | 9 |
| Settings sync | Planned | 9 |
| Long break on demand | Planned | 8 |
| Android app | Planned | 8 |

---

## App Store Reviews (Mac)

All visible reviews are 5 stars. Not enough total ratings for aggregate score.

Key themes:
- Users love the firmness/enforcement (they need it)
- Posture + break combo valued
- Minimalists appreciate daily-use value
- Developer responds to reviews

---

## Competitive Positioning (from comparison pages)

### LookAway vs Time Out
- LookAway wins on: blink/posture reminders, iPhone sync, Smart Pause, Focus Filters, Shortcuts
- Both have: customization, app ignore list, native macOS
- Time Out has: HTML/CSS themes

### Named Competitors
- Time Out (Mac)
- BreakTimer (cross-platform)
- Stretchly (cross-platform, open source)

---

## Marketing & Content Strategy

- Blog: SEO guides for developers, students, Mac users
- Eye Strain Risk Calculator (7-question quiz, lead gen)
- Comparison pages for SEO (/compare/lookaway-vs-*)
- RSS feed
- Affiliate program: 35% commission, 14-day cookie
- Social proof: The Verge, YouTubers (Brandon Butch), product designers
- Social: X (@lookawaymac), Discord, GitHub
- Public roadmap at userjot.com
- Press kit available

---

## Other Products by Mystical Bits
- **Unwind**: Breathing exercises app
- **Cone**: Color Picker & Identifier
- **CBVision**: Colorblind Assist
