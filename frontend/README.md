# 🧠 Mood Tracker App

A comprehensive Flutter-based mood tracking application with AI-powered sentiment analysis, built as part of an Artificial Intelligence subject project.

## 📱 Overview

Mood Tracker is a modern mobile application designed to help users monitor their emotional well-being. The app combines beautiful UI/UX with intelligent AI sentiment analysis to provide personalized suggestions and insights based on daily mood entries and journal notes.

**Platform:** Flutter 3.41.0 | **Language:** Dart 3.11.0+  
**Target Platforms:** Android, iOS, Web  
**State Management:** Riverpod 2.6.1  
**Storage:** SharedPreferences (Local)

---

## ✨ Features

### Core Features

1. **Splash Screen** ✅
   - Animated app logo and branding
   - Auto-navigation based on auth state
   - Smooth fade and scale animations

2. **Onboarding Screen** ✅
   - 4-step guided introduction
   - Smooth page transitions
   - Mark onboarding as complete

3. **Authentication** ✅
   - **Login Screen**: Email/password-based sign-in
   - **Register Screen**: New user account creation
   - Password validation and confirmation
   - Form validation with error messages
   - Local storage of auth tokens and user data

4. **Dashboard** ✅
   - Welcome greeting with user name
   - Quick stat cards (Total Moods, Average Mood, Weekly View)
   - Visual mood charts (Line and Pie charts)
   - Quick access to mood logging
   - Responsive design with scrollable content

5. **Add Daily Mood** (Partial) 🔄
   - 5-emoji mood selector (Terrible, Sad, Okay, Good, Amazing)
   - Optional note/journal entry
   - AI sentiment analysis on notes
   - Mood prediction suggestions
   - Save mood with timestamp

6. **Mood History** (Partial) 🔄
   - List all previous mood entries
   - Swipe to delete entries
   - View mood details and notes
   - AI suggestions display
   - Date/time formatting
   - Filter and search capabilities

7. **Journal** (Partial) 🔄
   - Write detailed journal entries
   - Link moods to journal entries
   - Privacy toggle (private/shared)
   - Tags and categories
   - Search and filter
   - Edit and delete entries

8. **AI Sentiment Analysis** ✅
   - Rule-based keyword analysis
   - Positive/Negative/Neutral sentiment detection
   - Context-aware mood suggestions
   - Personalized recommendations

9. **Analytics & Insights** (Partial) 🔄
   - Mood distribution pie chart
   - Mood trends over time (line chart)
   - Statistics cards
   - Weekly/monthly summaries
   - Mood pattern insights

10. **Profile & Settings** (Partial) 🔄
    - User profile display
    - Edit user information
    - Theme preferences
    - Notification settings
    - Privacy settings
    - Logout functionality

---

## 🎨 Design System

### Color Palette

```dart
// Primary Colors
- Primary Purple: #6B5B95
- Secondary Pink: #D946A6
- Accent Lavender: #E8B4F3

// Mood Colors
- Amazing: #8B5CF6 (Purple)
- Good: #10B981 (Green)
- Okay: #3B82F6 (Blue)
- Sad: #F97316 (Orange)
- Terrible: #EF4444 (Red)

// Neutral
- Background: #F8F6FF
- Text Primary: #1F1F1F
- Text Secondary: #6B7280
- White: #FFFFFF
```

### Typography

- **Font Family:** Poppins (via google_fonts)
- **Hierarchy:** Headline Large → Headline Medium → Title Medium → Body Large/Medium/Small
- **Weight:** Regular (400), Semi-bold (600), Bold (700)

### Components

- Gradient backgrounds (Purple-Pink, Lavender-Blue)
- Rounded cards with shadows (border-radius: 12px)
- Custom buttons with loading states
- Mood emoji selector with animations
- Dashboard stat cards
- Bottom navigation bar
- Custom TextFields with validation

---

## 🤖 AI Sentiment Analysis Logic

### Technique: Rule-Based Keyword Analysis

The app uses a sophisticated keyword-matching system to analyze user sentiment:

```
Positive Keywords: 
  happy, good, great, excited, relaxed, calm, amazing, love, enjoy,
  wonderful, excellent, fantastic, brilliant, beautiful, grateful,
  blessed, confident, energetic, hopeful, peaceful, proud, accomplished

Negative Keywords:
  sad, bad, angry, stress, tired, upset, depressed, worried, lonely,
  anxiety, frustrated, miserable, terrible, horrible, awful, sick,
  hurt, confused, scared, afraid, disappointed, overwhelmed, exhausted
```

### Algorithm

1. **Text Processing**: Convert user input to lowercase
2. **Keyword Scoring**: 
   - Positive words: +1 to +5 points
   - Negative words: -1 to -5 points
3. **Sentiment Determination**:
   - Positive Score > Negative Score → **Positive Sentiment**
   - Negative Score > Positive Score → **Negative Sentiment**
   - Equal or no keywords → **Neutral Sentiment**
4. **Suggestion Generation**: Based on mood and sentiment, provide personalized recommendations

### Suggestion Engine

The app provides context-aware suggestions:

```
Mood: Amazing → "Keep this momentum going! 🚀"
Mood: Good → "You're on the right track! 👍"
Mood: Okay → "Take a deep breath, you're doing fine. 🧘"
Mood: Sad → "It's okay to feel sad. Let it out. 💙"
Mood: Terrible → "You're not alone. Please reach out. 💚"
```

---

## 📁 Project Structure

```
frontend/
├── lib/
│   ├── main.dart                          # App entry point with routing
│   ├── core/
│   │   ├── constants/
│   │   │   ├── app_colors.dart           # Color definitions
│   │   │   ├── app_strings.dart          # UI text strings
│   │   │   └── app_styles.dart           # Text styles & constants
│   │   └── routes/
│   │       └── app_routes.dart           # Route definitions
│   ├── models/
│   │   ├── user_model.dart              # User data model
│   │   ├── mood.dart                     # Mood data model
│   │   ├── journal_model.dart           # Journal entry model
│   │   └── chat_message.dart            # Chat message model
│   ├── services/
│   │   ├── auth_service.dart            # Authentication service
│   │   ├── mood_service.dart            # Mood CRUD operations
│   │   ├── journal_service.dart         # Journal management
│   │   ├── ai_service.dart              # AI analysis service
│   │   ├── api_service.dart             # Backend API client
│   │   ├── local_cache_service.dart     # Local caching
│   │   └── biometric_service.dart       # Biometric auth
│   ├── providers/
│   │   ├── auth_provider.dart           # Auth state management
│   │   ├── mood_provider.dart           # Mood state management
│   │   ├── journal_provider.dart        # Journal state management
│   │   └── ai_provider.dart             # AI analysis state
│   ├── screens/
│   │   ├── splash_screen.dart           # Splash/Loading screen
│   │   ├── onboarding_screen.dart       # Onboarding guide
│   │   ├── login_screen.dart            # User login
│   │   ├── register_screen.dart         # User registration
│   │   ├── dashboard_screen.dart        # Main dashboard
│   │   ├── log_mood_screen.dart         # Add mood form
│   │   ├── history_screen.dart          # Mood history list
│   │   ├── ai_chat_screen.dart          # AI chatbot interface
│   │   ├── analytics_screen.dart        # Statistics & charts
│   │   └── profile_screen.dart          # User profile
│   ├── widgets/
│   │   ├── custom_button.dart           # Reusable button
│   │   ├── custom_textfield.dart        # Reusable text input
│   │   ├── mood_card.dart               # Mood entry card
│   │   ├── mood_emoji_button.dart       # Mood emoji selector
│   │   ├── suggestion_card.dart         # Suggestion display
│   │   ├── dashboard_card.dart          # Dashboard stat card
│   │   ├── mood_chart.dart              # Chart visualization
│   │   └── bottom_nav_bar.dart          # Navigation bar
│   └── data/
│       ├── mood_data.dart               # Sentiment keywords & analysis
│       └── suggestions_data.dart        # Suggestion database
├── pubspec.yaml                          # Dependencies
└── README.md                             # This file
```

---

## 📦 Dependencies

### Core Dependencies

```yaml
flutter: ^3.41.0
flutter_riverpod: ^2.6.1        # State management
shared_preferences: ^2.3.3      # Local storage
http: ^1.6.0                     # HTTP requests
```

### UI Dependencies

```yaml
fl_chart: ^0.68.0               # Charts & graphs
google_fonts: ^6.0.0            # Typography
cupertino_icons: ^1.0.8         # iOS icons
```

### Device Features

```yaml
local_auth: ^2.3.0              # Biometric authentication
flutter_local_notifications: ^17.0.0  # Push notifications
```

---

## 🚀 Getting Started

### Prerequisites

- Flutter SDK ^3.41.0
- Dart SDK ^3.11.0
- Android Studio or Xcode (for native development)
- VS Code with Flutter extension (recommended)

### Installation & Setup

```bash
# 1. Navigate to project directory
cd "path/to/mood tracker/frontend"

# 2. Get dependencies
flutter pub get

# 3. Get Google Fonts specifically
flutter pub get google_fonts

# 4. Run the app on connected device/emulator
flutter run

# 5. For web:
flutter run -d chrome

# 6. For Android:
flutter run -d android

# 7. For iOS:
flutter run -d ios
```

### Run with Specific Configuration

```bash
# Release build (optimized for performance)
flutter run --release

# Debug build (with hot reload)
flutter run --debug

# Profile build (for performance testing)
flutter run --profile
```

---

## 💾 Data Persistence

The app uses **SharedPreferences** for local storage:

- **User Authentication**: `auth_token`, `user_email`, `user_name`
- **Moods**: Stored in JSON format with timestamps
- **Journals**: Full journal entries with timestamps
- **Settings**: User preferences and theme choice
- **Cache**: API responses and offline data

**Storage Location:**
- **Android**: `/data/data/com.example.moodtracker/shared_prefs/`
- **iOS**: `Library/Preferences/`
- **Web**: Browser localStorage

---

## 🎓 Viva Explanation

### Project Overview for Academics

This project demonstrates the application of Artificial Intelligence in mobile app development. The core intelligence is implemented through:

1. **Sentiment Analysis Engine**: A rule-based NLP technique using keyword matching to analyze emotional content in user inputs

2. **Recommendation System**: Uses the sentiment analysis output to generate context-aware suggestions and mental health support recommendations

3. **Pattern Recognition**: Analyzes mood patterns over time to provide insights and trends

### Technical Highlights

- **State Management**: Riverpod for reactive, efficient state handling
- **Architecture**: Clean separation of concerns (models, services, providers, screens, widgets)
- **UI/UX**: Material Design 3 with custom gradient designs
- **Performance**: Optimized chart rendering with lazy loading
- **Persistence**: Local-first approach with encrypted storage

### AI Techniques Used

1. **Rule-Based Expert System**: Keywords mapped to sentiment scores
2. **Pattern Mining**: Mood trend analysis
3. **Recommendation Engine**: Personalized suggestions based on context
4. **Time-Series Analysis**: Weekly/monthly aggregations

### Use Cases

- **Mental Health Support**: Helps users track emotional patterns
- **Therapy Companion**: Provides daily insights between therapy sessions
- **Stress Management**: Early warning system for mood changes
- **Self-Discovery**: Journal and mood correlation insights

---

## 🧪 Testing

### Flutter Analyzer

```bash
# Check code quality
flutter analyze

# Fix common issues automatically
dart fix --apply

# Run specific test
flutter test test/widget_test.dart
```

### Building APK/AAB

```bash
# Build APK for Android
flutter build apk --release

# Build App Bundle for Play Store
flutter build appbundle --release

# Build iOS
flutter build ios --release
```

---

## 🐛 Troubleshooting

### Common Issues

**Issue**: "Gradle build failed"
- **Solution**: `flutter clean && flutter pub get && flutter run`

**Issue**: "Google Fonts not loading"
- **Solution**: `flutter pub get google_fonts && flutter run`

**Issue**: "SharedPreferences throwing error"
- **Solution**: Ensure `android:usesCleartextTraffic` is set in AndroidManifest.xml

**Issue**: "Hot reload not working"
- **Solution**: Run `flutter run -v` for verbose logs

---

## 📄 License

This project is created for educational purposes as part of an Artificial Intelligence subject.

---

## 👨‍💻 Development Notes

### Future Enhancements

- [ ] Backend API integration (REST/GraphQL)
- [ ] Multi-language support (i18n)
- [ ] Advanced ML-based sentiment analysis
- [ ] Therapist integration
- [ ] Social sharing features
- [ ] Wearable device integration
- [ ] Voice emotion recognition
- [ ] Push notifications for check-ins
- [ ] Dark theme full support
- [ ] Unit and widget tests

### Known Limitations

- Local storage only (no cloud sync)
- Rule-based AI (not ML)
- Single-user per device
- No offline-first conflict resolution
- Limited export options

---

## 📞 Support

For issues or questions:
1. Check the troubleshooting section
2. Review Flutter documentation: https://flutter.dev/docs
3. Check Riverpod docs: https://riverpod.dev
4. Open an issue in your repository

---

**Made with ❤️ for emotional wellness**

*Last Updated: 2026*  
*Version: 1.0.0*
