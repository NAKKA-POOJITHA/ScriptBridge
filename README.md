# ScriptBridge 🌉

Real-Time Offline Indic Script Transliteration Tool for Street Signs.

ScriptBridge is designed to help travelers, commuters, and language learners bridge the language barrier by scanning and transliterating street signboards in real-time. By leveraging offline-first technologies, it detects written Indic scripts, transliterates them into a target script (including English/Latin or other Indian languages), and provides text-to-speech feedback.

---

## ✨ Features

- **📷 Real-Time OCR scanning**: Powered by Google ML Kit Text Recognition to process and extract text from live camera frames.
- **🌍 Multiple Indian Languages**: Supports transliteration mapping across major Indic scripts:
  * Hindi (Devanagari)
  * Telugu
  * Tamil
  * Kannada
  * Malayalam
  * Bengali
  * Gujarati
  * Punjabi (Gurmukhi)
  * English (Latin)
- **⚡ Offline Transliteration Engine**: Translates text characters based on native Unicode range calculations and character mapping matrices, functioning 100% offline.
- **🗣️ Integrated Text-to-Speech (TTS)**: Translates the transliterated script to audio speech, with customizable speed rates and pitches.
- **🗂️ Persistent Offline History**:
  * **Flutter App**: Powered by Hive DB to cache the history of scanned signboards, keeping a strict memory bound of 1,000 entries.
  * **Web Simulator**: Powered by LocalStorage caching to save your mock runs.

---

## 🏗️ Tech Stack

### Flutter App (Mobile)
- **Core**: Flutter & Dart (Material 3 Dark Theme)
- **OCR Engine**: `google_mlkit_text_recognition`
- **Database (Cache)**: `hive` & `hive_flutter`
- **Speech Synthesis**: `flutter_tts`
- **State Management**: `provider`
- **Permissions**: `permission_handler`

### Web Simulator (Interactive Sandbox)
- **Structure & Logic**: Vanilla HTML5, CSS3, & Modern JavaScript
- **Backend / Development Server**: Node.js HTTP server module (zero-dependency)
- **Data Persistence**: HTML5 LocalStorage

---

## 🚀 Running the Project

### 1. Web Simulator

The project includes a lightweight, fully functional web-based simulator simulating the OCR, detection, and transliteration flow.

1. Navigate to the root directory of the project.
2. Start the Node.js server:
   ```bash
   node web_simulator/server.js
   ```
3. Open your browser and navigate to:
   [http://localhost:8080/](http://localhost:8080/)

> [!NOTE]
> The Web Simulator allows you to test the transliteration mapping either using **mock preloaded signboards** (working offline) or utilizing your **actual device camera (webcam)**.

---

### 2. Flutter Mobile Application

To run the full Android mobile application:

1. Ensure you have the Flutter SDK installed on your system.
2. Install the pub dependencies:
   ```bash
   flutter pub get
   ```
3. Connect a physical Android device or launch an emulator.
4. Run the application:
   ```bash
   flutter run
   ```

---

## 📂 Project Directory Structure

```
├── android/            # Android native configurations & permissions
├── lib/
│   ├── core/           # App-wide themes, constants, and utilities
│   ├── models/         # Data structures (ScanHistory, DetectedText)
│   ├── providers/      # ChangeNotifier provider state management
│   ├── screens/        # Main UI screen structures (HomeScreen)
│   ├── services/       # OCR, Transliteration, TTS, Cache, and Camera services
│   └── widgets/        # Modular UI components (overlays, settings panel)
├── web_simulator/      # Complete interactive HTML/CSS/JS web sandbox
├── pubspec.yaml        # Flutter project dependency definitions
└── README.md           # Project documentation
```
