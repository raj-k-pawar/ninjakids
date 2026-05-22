# 🥷 NinjaKids — AI-Powered Educational App

> **Learn • Play • Level Up** — A gamified educational mobile app for children aged 4–15

---

## 📱 Features

- **AI Quiz Engine** — Dynamic MCQ quizzes with timer, hints, and confetti animations
- **AI Tutor Chat** — Child-safe conversational AI tutor (Ninja Sensei)
- **Speaking Practice** — Voice waveform with pronunciation scoring for English & Marathi
- **Gamification** — XP, coins, streaks, badges, leaderboard
- **Parent Controls** — Screen time, subject access, progress analytics
- **Dark/Light Mode** — Full theme support with auto-switch
- **Multi-Child** — Manage multiple child profiles with PIN login
- **Premium Plans** — Free, Monthly, Yearly, Family subscription tiers

---

## 🚀 Quick Start

### Prerequisites
- Flutter SDK **3.0+** — https://docs.flutter.dev/get-started/install
- Android Studio / VS Code
- Java 17+
- Git

### 1. Clone the Repository
```bash
git clone https://github.com/YOUR_USERNAME/ninjakids.git
cd ninjakids
```

### 2. Install Dependencies
```bash
flutter pub get
```

### 3. Add Font Assets (Required)
Download and place fonts in `assets/fonts/`:
```
assets/fonts/
├── Poppins-Regular.ttf
├── Poppins-Medium.ttf
├── Poppins-SemiBold.ttf
├── Poppins-Bold.ttf
├── Poppins-ExtraBold.ttf
├── Nunito-Regular.ttf
├── Nunito-Bold.ttf
└── Nunito-ExtraBold.ttf
```
Download from: https://fonts.google.com/specimen/Poppins and https://fonts.google.com/specimen/Nunito

> **Tip**: If you don't want to download fonts manually, remove the `fonts:` section from `pubspec.yaml` — `google_fonts` package will download them at runtime automatically.

### 4. Run the App
```bash
# Debug mode
flutter run

# Release APK
flutter build apk --release
```

---

## 🏗️ Project Structure

```
lib/
├── core/
│   ├── constants/        # App-wide constants & subject data
│   └── theme/            # Colors, gradients, light/dark themes
├── features/
│   ├── auth/             # Splash, Login, Register, Child PIN
│   ├── parent/           # Dashboard, Child profile, Screen time, Analytics
│   ├── child/            # Dashboard, Subjects, Games, Rewards, Profile
│   ├── quiz/             # Quiz screen, Result screen
│   ├── speaking/         # Speaking practice with waveform
│   ├── ai_tutor/         # AI chat screen
│   └── settings/         # Settings, Subscription
├── routes/               # go_router configuration
├── services/             # Riverpod providers (auth, quiz, AI chat, etc.)
└── shared/
    ├── models/            # Data models (User, Child, Quiz, Badge, etc.)
    └── widgets/           # Reusable widgets (GradientButton, AnimatedCard, etc.)
```

---

## 🔧 Configuration

### Firebase Setup (Optional — for production)
1. Create a Firebase project at https://console.firebase.google.com
2. Add Android app with package ID: `com.ninjakids.app`
3. Download `google-services.json` → place in `android/app/`
4. Enable: Authentication, Firestore, Storage
5. Uncomment Firebase initialization in `main.dart`

### AI Integration
Replace the demo responses in `app_providers.dart` → `AIChatNotifier._generateResponse()` with:
```dart
// OpenAI
final response = await http.post(
  Uri.parse('https://api.openai.com/v1/chat/completions'),
  headers: {'Authorization': 'Bearer YOUR_KEY', 'Content-Type': 'application/json'},
  body: jsonEncode({
    'model': 'gpt-4o-mini',
    'messages': [
      {'role': 'system', 'content': 'You are a friendly educational AI tutor for children aged 4-15. Be simple, encouraging, and educational.'},
      {'role': 'user', 'content': query}
    ],
    'max_tokens': 300
  }),
);
```

### Dynamic Quiz Generation
Replace `_generateQuestions()` in `app_providers.dart` with an API call to generate subject-specific questions using AI.

---

## 📦 Building APK

### Debug APK (for testing)
```bash
flutter build apk --debug
# Output: build/app/outputs/flutter-apk/app-debug.apk
```

### Release APK (unsigned)
```bash
flutter build apk --release --no-shrink
# Output: build/app/outputs/flutter-apk/app-release.apk
```

### Signed Release APK
1. Generate keystore:
```bash
keytool -genkey -v -keystore ninjakids.jks -keyalg RSA -keysize 2048 -validity 10000 -alias ninjakids
```

2. Create `android/key.properties`:
```
storePassword=YOUR_STORE_PASSWORD
keyPassword=YOUR_KEY_PASSWORD
keyAlias=ninjakids
storeFile=../ninjakids.jks
```

3. Build signed APK:
```bash
flutter build apk --release
```

---

## ☁️ Codemagic CI/CD

### Setup
1. Push code to GitHub/GitLab/Bitbucket
2. Go to https://codemagic.io and sign in
3. Connect your repository
4. The `codemagic.yaml` is already configured for:
   - **Debug APK** build on every push to `main`
   - **Release APK** build with signing
   - Email notifications on build success/failure

### Codemagic Environment Variables
Set these in Codemagic dashboard → App Settings → Environment Variables:
```
CM_KEYSTORE_PASSWORD   → Your keystore password
CM_KEY_PASSWORD        → Your key password
CM_KEY_ALIAS           → ninjakids
```

Upload your `.jks` file under "Code signing" → Android → Keystores

---

## 🎨 Demo Credentials

The app runs in **demo mode** by default (no Firebase needed):

| Role | Email | Password | PIN |
|------|-------|----------|-----|
| Parent | any email | 6+ chars | — |
| Child (Aarav) | — | — | 1234 |
| Child (Siya) | — | — | 5678 |

---

## 📐 Design System

| Token | Value |
|-------|-------|
| Primary | `#6C63FF` |
| Secondary | `#FFB84C` |
| Green | `#4CD964` |
| Red | `#FF6B6B` |
| Blue | `#00C2FF` |
| Border Radius | 20–28px |
| Font | Poppins + Nunito |

---

## 🛣️ Roadmap

- [ ] Firebase Authentication & Firestore
- [ ] Real OpenAI / Gemini API integration
- [ ] Flutter TTS voice reading of questions
- [ ] Speech-to-text for voice answers
- [ ] Lottie animations for mascot
- [ ] Offline quiz caching
- [ ] Push notifications (FCM)
- [ ] iPad / tablet layout
- [ ] iOS build support
- [ ] Admin web panel

---

## 📄 License

MIT License — free to use, modify, and distribute.

---

## 🙏 Credits

Built with ❤️ using Flutter, Riverpod, go_router, and fl_chart.

Logo: NinjaKids — *Learn • Play • Level Up*
