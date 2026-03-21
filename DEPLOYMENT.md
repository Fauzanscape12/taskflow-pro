# TaskFlow Pro - Deployment Guide

Complete deployment guide for TaskFlow Pro with **OTA Update**, auto-build, error monitoring, and Telegram integration.

## 🚀 Deployment Options

### 1. Web Deployment (Recommended - Free & Auto-Update)

#### Vercel Deployment (Recommended)

**Setup:**
1. Push code to GitHub
2. Connect repo to [Vercel](https://vercel.com)
3. Vercel will auto-deploy on every push

**Features:**
- ✅ Zero cost
- ✅ Auto-deploy from GitHub
- ✅ Global CDN
- ✅ HTTPS included
- ✅ Preview deployments
- ✅ Custom domain support

**Commands:**
```bash
# Build web version locally (optional)
flutter build web --release

# Deploy to Vercel (after connecting repo)
vercel --prod
```

#### Netlify Alternative

```bash
# Install Netlify CLI
npm install -g netlify-cli

# Build
flutter build web --release

# Deploy
netlify deploy --prod --dir=build/web
```

---

### 🔄 OTA Update (Over-the-Air Update)

**TaskFlow Pro sekarang memiliki fitur OTA Update!**

**Cara kerja:**
1. Aplikasi cek update dari GitHub Releases API
2. Jika ada versi terbaru, user dapat download & install APK langsung dari dalam aplikasi
3. Update diinstall tanpa perlu buka Play Store

**Cara pakai:**
1. Buka **Pengaturan** → **Tentang** → **Cek Update**
2. Aplikasi akan cek versi terbaru dari GitHub Releases
3. Jika ada update baru, user akan diminta untuk download & install

**Untuk developer (Bos Jon):**
- Create new release di GitHub dengan tag versi (contoh: `v1.0.1`)
- Upload APK sebagai asset di release tersebut
- Aplikasi akan otomatis mendeteksi update baru

**Catatan:**
- APK harus diupload dengan nama yang mengandung `.apk`
- Tag release harus dalam format `vX.X.X` (contoh: `v1.0.1`, `v1.1.0`)

---

### 2. Android APK Auto-Build (GitHub Actions)

**Setup:**
1. Add secrets to GitHub repo:
   - `TELEGRAM_BOT_TOKEN`: Your Telegram bot token
   - `TELEGRAM_CHAT_ID`: Your Telegram chat ID

2. Push to GitHub → Auto-build APK

3. Download APK from:
   - GitHub Actions artifacts
   - GitHub Releases (on tags)

**Create Release:**
```bash
# Tag and push
git tag v1.0.0
git push origin v1.0.0

# GitHub Actions will:
# - Build APK
# - Create release
# - Send notification to Telegram
```

---

### 3. Error Monitoring Setup

#### Sentry Setup (Free tier available)

1. Create account at [sentry.io](https://sentry.io)
2. Create new project → Flutter
3. Get DSN from project settings
4. Add to environment variables:

```bash
# For local development
export SENTRY_DSN="your-dsn-here"
export APP_VERSION="1.0.0"
export ENVIRONMENT="development"

# For production (Vercel/GitHub)
# Add SENTRY_DSN to secrets
```

#### Telegram Integration

**Get Bot Token & Chat ID:**
1. Create bot via @BotFather
2. Get token from BotFather
3. Get chat ID from @userinfobot

**Add to Environment:**
```bash
export TELEGRAM_BOT_TOKEN="your-bot-token"
export TELEGRAM_CHAT_ID="your-chat-id"
```

---

## 📱 Setup Instructions

### Local Development

1. **Install dependencies:**
```bash
flutter pub get
```

2. **Run with error monitoring:**
```bash
# Set environment variables
export SENTRY_DSN="your-dsn"
export TELEGRAM_BOT_TOKEN="your-token"
export TELEGRAM_CHAT_ID="your-chat-id"
export APP_VERSION="1.0.0"
export ENVIRONMENT="development"

# Run app
flutter run
```

### Production Build

#### Web:
```bash
flutter build web --release --dart-define=SENTRY_DSN="your-dsn" --dart-define=TELEGRAM_BOT_TOKEN="your-token" --dart-define=TELEGRAM_CHAT_ID="your-chat-id" --dart-define=APP_VERSION="1.0.0" --dart-define=ENVIRONMENT="production"
```

#### Android:
```bash
flutter build apk --release --dart-define=SENTRY_DSN="your-dsn" --dart-define=TELEGRAM_BOT_TOKEN="your-token" --dart-define=TELEGRAM_CHAT_ID="your-chat-id" --dart-define=APP_VERSION="1.0.0" --dart-define=ENVIRONMENT="production"
```

---

## 🔧 Environment Variables

Create `.env` file or set in CI/CD:

```bash
# Sentry (Error Tracking)
SENTRY_DSN=https://xxxxx@o123.ingest.sentry.io/12345
APP_VERSION=1.0.0
ENVIRONMENT=production

# Telegram (Notifications)
TELEGRAM_BOT_TOKEN=8349276139:AAEzDkW8cmGWK-pF59OjYcEZgbugDnan7oE
TELEGRAM_CHAT_ID=1010378689
```

---

## 🤖 Telegram Commands (via OpenClaw)

After connecting your Telegram bot to OpenClaw, you can:

**Check deployment status:**
```
/status
```

**Fix errors remotely:**
```
/exec cd /path/to/taskflow-pro && git pull origin main && flutter build apk
```

**View logs:**
```
/exec journalctl -u taskflow -n 50
```

**Update dependencies:**
```
/exec cd /path/to/taskflow-pro && flutter pub upgrade && flutter pub get
```

---

## 📊 Monitoring Dashboard

### Sentry Dashboard:
- View errors: https://sentry.io
- Filter by: release, environment, user
- Set up alerts for critical errors

### Telegram Notifications:
- ✅ Build success/failure
- 🚨 App crashes
- 🐛 Critical errors
- 💬 User feedback

---

## 🔄 Auto-Update Workflow

```
┌─────────────────┐
│  Push to GitHub │
└────────┬────────┘
         │
         ▼
┌─────────────────────────────────┐
│  GitHub Actions Triggered       │
│  - Build APK                    │
│  - Run tests                    │
│  - Create release (if tagged)   │
└────────┬────────────────────────┘
         │
         ▼
┌─────────────────────────────────┐
│  Notifications Sent             │
│  - Telegram: Build status       │
│  - Sentry: Errors (if any)      │
└─────────────────────────────────┘
         │
         ▼
┌─────────────────────────────────┐
│  Download Available             │
│  - GitHub Actions Artifacts     │
│  - GitHub Releases              │
│  - Telegram link                │
└─────────────────────────────────┘
```

---

## 💡 Tips

1. **Use Web Version** for instant updates without reinstallation
2. **Enable Sentry** for production to catch errors early
3. **Set up Telegram alerts** for immediate notifications
4. **Use Git tags** for releases to auto-create GitHub releases
5. **Monitor disk usage** - GitHub Actions auto-cleanup old artifacts

---

## 🆘 Troubleshooting

### Build fails:
- Check GitHub Actions logs
- Telegram notification includes error details
- Fix via Telegram: `/exec cd /path && git pull && flutter pub get`

### App crashes:
- Check Sentry dashboard
- Telegram receives crash report automatically
- Fix and push update

### Telegram not working:
- Verify bot token and chat ID
- Check bot is not blocked by Telegram
- Test: `curl https://api.telegram.org/bot<TOKEN>/getMe`

---

## 📞 Support

For issues or questions:
1. Check Sentry dashboard
2. Send message via Telegram bot
3. Create GitHub issue

---

*Last Updated: March 21, 2026*
