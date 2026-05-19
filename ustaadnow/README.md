# UstaadNow AI 🔧📱
> **AI-Powered Service Marketplace for Pakistan’s Informal Economy**

An advanced, native Flutter application designed to bridge the gap between service providers and customers in Pakistan. Supports multilingual workflows in **Urdu (اردو)**, **Roman Urdu**, and **English**, leveraging backend **Python AI Agents** to understand intent and automate provider matches.

---

## 🚀 Key Architectural Features
1. **Feature-First Organization**: Fully modular clean directory layout (`core`, `features`, `shared`).
2. **State Management**: Robust, compile-safe state using **Riverpod**.
3. **Reactive Local Storage**: Type-safe local DB using **Drift (SQLite)** for offline storage (history, local session caching, and message backups).
4. **Secure Networking**: High-performance HTTP client powered by **Dio** with global logging, auto-retry, and custom error interceptors.
5. **Dynamic Routing**: Seamless, type-safe navigation powered by **GoRouter** with Shell navigation for bottom tabs.
6. **Premium Visuals & UX**: Full Material 3 support, custom dark mode, micro-animations via `flutter_animate`, and custom HSL gradients.
7. **Production Voice Recording**: Seamless voice note recording using **FlutterSound** (transfers high-fidelity `.aac` chunks directly to the backend for speech-to-text processing).

---

## 📦 What Data Does the App Use?

The application operates on high-fidelity domain models located in [lib/shared/models/](file:///d:/Documents/Android%20Studio%20Projects/ustaadnow/lib/shared/models/):

| Model | Primary Purpose | Fields & Structure |
|---|---|---|
| **`UserModel`** | Handles role-based identity & preferences | `id`, `name`, `phone`, `address`, `role` (Customer/Provider), `isOnline`, `createdAt` |
| **`BookingModel`** | Tracks service schedules and transaction details | `id`, `serviceType`, `description`, `customerName`, `customerPhone`, `location`, `status` (enum: pending, confirmed, inProgress, completed, cancelled), `estimatedCost`, `scheduledAt`, `createdAt`, and `assignedProvider` |
| **`ProviderModel`** | Profiles available skilled workers ("Ustaads") | `id`, `name`, `phone`, `serviceType`, `rating`, `totalJobs`, `isAvailable`, `earnings` |
| **`ChatMessageModel`**| Powers the AI booking conversational bot | `id`, `content`, `role` (user/ai), `timestamp`, `isLoading`, and optional custom `provider` suggestion metadata |
| **`TraceLogModel`** | Observability for complex backend AI agent steps | `agentName` (e.g. Intent-Agent, Ranker-Agent), `duration` (in ms), `success` state, and `result` details |

---

## 📡 API Integration Details

The API layer is built on a clean separation of concerns, routing through `BookingRepository` to orchestrate calls. 

### Base Configurations
* **API Base URL**: `http://localhost:8000` (Defined in [api_constants.dart](file:///d:/Documents/Android%20Studio%20Projects/ustaadnow/lib/core/network/api_constants.dart))
* **Network Client**: Custom `DioClient` singleton with auto-logging and unified `ApiResult<T>` error wrapper.

### Endpoints Integrated

| Endpoint | HTTP Method | Data Handled | Repository Wiring | Status |
|---|---|---|---|---|
| **`/api/health`** | `GET` | Health check for backend service check | `checkHealth()` | ✅ Wired |
| **`/api/request`** | `POST` | Text prompts (English / Urdu / Roman Urdu) | `submitRequest(input)` | ✅ Wired |
| **`/api/request/audio`**| `POST` | Multipart `.aac` voice records from mic | `submitAudioRequest(filePath)` | ✅ Wired |
| **`/api/bookings`** | `GET` | List of all registered bookings | `getBookings()` | ✅ Wired |
| **`/api/trace/{id}`**| `GET` | AI Agent workflow trace logs | `getTrace(id)` | ✅ Wired |

> [!NOTE]
> During development, if the Python server is offline, the API layer automatically runs fallbacks to native mock data arrays. This enables 100% fluent offline UI debugging.

---

## 🗄️ Database Schema & Offline Storage

UstaadNow AI integrates a reactive SQLite database using **Drift**.
* Schema is defined in [app_database.dart](file:///d:/Documents/Android%20Studio%20Projects/ustaadnow/lib/core/database/app_database.dart).
* **Tables Created**:
  1. `ChatMessagesTable`: Caches full chatbot threads locally for offline reading.
  2. `BookingsTable`: Caches service request statuses and provider schedules.
  3. `SettingsTable`: General key-value store for app settings (e.g. language preferences, custom caching states).

To run code generation for the database:
```bash
dart run build_runner build --delete-conflicting-outputs
```

---

## 🛠️ Step-by-Step Local Setup

### 1. Prerequisites
* Flutter SDK (v3.19.0 or higher recommended)
* Android Studio / VS Code
* Android SDK & Gradle installed

### 2. Fetch Packages & Clean Dependencies
```bash
flutter clean
flutter pub get
```

### 3. Build Code Generation Files
Compile the database models & Riverpod code-generator bindings:
```bash
dart run build_runner build --delete-conflicting-outputs
```

### 4. Run the Application
Start the app on an emulator, connected smartphone, or web preview:
```bash
flutter run
```

---

## 🎨 Theme & Typography Design System
We adhere strictly to custom Pakistani local marketplace guidelines:
* **Primary Branding**: Elegant HSL Emerald Greens (Light Mode: `#0A6F49`, Dark Mode: `#0FB877`)
* **Secondary Accents**: Warm Saffron Gold (`#FFB13B`) for ratings, stars, and highlight items.
* **Typography**: Modern, readable **Inter** font family integrated through Google Fonts.
* **Redirection**: Real-time app state redirection. Once logged in, users bypass onboarding; once logged out, all local storage gets wiped automatically.
