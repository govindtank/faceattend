# 📋 FaceAttend Architecture Specification
# ========================================
# Version: 1.0
# Last Updated: 2026-04-30

## System Overview

FaceAttend is an offline-first face recognition attendance system designed to work 
reliably even when internet connectivity is unreliable or unavailable.

---

## 🏗️ Architecture Diagram

```
┌─────────────────────────────────────────────────────────────┐
│                    FACEATTEND SYSTEM                         │
├─────────────────────────────────────────────────────────────┤
│                                                               │
│  ┌──────────────────┐         ┌─────────────────────────┐   │
│  │ Mobile App       │◄───────►│ Admin Panel (Web)       │   │
│  │ (Flutter)        │  Sync   │ (Flutter Web / React)    │   │
│  │                  │◄──HTTP──►│                         │   │
│  │ ┌────────────┐   │         │ ┌──────────────┐        │   │
│  │ │ Face       │   │         │ │ Dashboard     │        │   │
│  │ │ Recognition │   │         │ ├──────────────┤        │   │
│  │ │ (Offline)  │   │         │ │ Reports       │        │   │
│  │ └────────────┘   │         │ ├──────────────┤        │   │
│  │ ┌────────────┐   │         │ │ Settings      │        │   │
│  │ │ Attendance │   │         │ └──────────────┘        │   │
│  │ │ Logging    │   │         └─────────────────────────┘   │
│  │ └────────────┘   │                                        │
│  └──────────────────┘                                        │
│                      │                                        │
│           ┌──────────┴──────────┐                             │
│           │  LOCAL DATABASE     │                             │
│           │  (SQLite on Device) │                             │
│           └─────────────────────┘                             │
│                                                               │
│              Offline-first with queued sync                    │
│                      Auto-sync when online                     │
│                                                               │
└─────────────────────────────────────────────────────────────┘

LEGEND:
  ◄───────► : In-app sync (HTTP/HTTPS)
  ───────── : Background service sync
```

---

## 📱 Mobile App Structure (Flutter)

### Project Layout
```
mobile_app/
├── lib/
│   ├── main.dart                      # App entry point
│   ├── config/                        # Configuration files
│   │   ├── constants.dart             # App-wide constants
│   │   ├── theme.dart                 # Theme configuration
│   │   └── api_config.dart            # API endpoints
│   ├── models/                        # Data models
│   │   ├── employee.dart              # Employee entity
│   │   ├── attendance_record.dart     # Attendance data model
│   │   └── face_template.dart         # Face template model
│   ├── screens/                       # UI Screens
│   │   ├── auth/                      # Authentication screens
│   │   │   ├── login_screen.dart      # Login screen
│   │   │   └── register_screen.dart   # Registration (admin only)
│   │   ├── home/                      # Main app screens
│   │   │   ├── home_screen.dart       # Home/dashboard
│   │   │   ├── attendance_screen.dart # Mark attendance
│   │   │   └── history_screen.dart    # Attendance history
│   │   ├── profile/                   # Profile management
│   │   │   ├── profile_screen.dart    # View/edit profile
│   │   │   └── settings_screen.dart   # App settings
│   │   └── components/                # Reusable widgets
│   │       ├── face_capture_widget.dart # Camera + capture
│   │       └── sync_status_widget.dart # Sync indicator
│   ├── services/                      # Business logic
│   │   ├── face_recognition_service.dart  # Face detection/recog
│   │   ├── attendance_service.dart        # Attendance logic
│   │   ├── local_database_service.dart    # SQLite operations
│   │   ├── sync_service.dart              # Offline→Online sync
│   │   └── auth_service.dart              # Authentication
│   └── utils/                         # Utilities
│       ├── cache_manager.dart         # Image caching
│       └── notification_helper.dart   # Push notifications
├── test/                              # Unit/widget tests
│   └── widget_test.dart
├── pubspec.yaml                       # Dependencies
└── README.md                          # This file + docs

```

---

## 🗄️ Local Database Schema (SQLite)

### Employees Table
```sql
CREATE TABLE employees (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    employee_id TEXT UNIQUE NOT NULL,
    name TEXT NOT NULL,
    department TEXT,
    phone TEXT,
    email TEXT,
    face_template BLOB NOT NULL,  -- Encoded image or embeddings
    is_active INTEGER DEFAULT 1,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    last_seen DATETIME
);

CREATE INDEX idx_employee_active ON employees(is_active);
CREATE INDEX idx_employee_dept ON employees(department);
```

### Attendance Records Table
```sql
CREATE TABLE attendance_records (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    employee_id TEXT NOT NULL,
    check_in_time DATETIME NOT NULL,
    check_out_time DATETIME,
    location_lat REAL,
    location_lng REAL,
    synced INTEGER DEFAULT 0,      -- 0=offline, 1=synced
    FOREIGN KEY (employee_id) REFERENCES employees(id)
);

CREATE INDEX idx_attendance_sync ON attendance_records(synced);
CREATE INDEX idx_attendance_time ON attendance_records(check_in_time);
```

### Face Templates Table (Alternative to embedded)
```sql
CREATE TABLE face_templates (
    id INTEGER PRIMARY KEY,
    employee_id TEXT UNIQUE NOT NULL,
    template_data BLOB NOT NULL,
    model_version TEXT DEFAULT 'mobilefacenet',
    confidence_threshold REAL DEFAULT 0.85,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (employee_id) REFERENCES employees(id)
);
```

---

## 🔐 Face Recognition Flow (Offline)

### Step-by-Step Process

```
┌─────────────┐
│ Employee    │
│ Approaches  │
└──────┬──────┘
       │
       ▼
┌─────────────────────┐
│ 1. Face Detection   │ ← TensorFlow Lite / MediaPipe
└──────┬──────────────┘
       │
       ▼
┌─────────────────────┐
│ 2. Extract Features │ ← Convert to face embeddings
└──────┬──────────────┘
       │
       ▼
┌─────────────────────┐
│ 3. Template Match   │ ← Compare against local database
│    (Cosine Similarity) │
└──────┬──────────────┘
       │
       ├───── YES (>85%) ───┐
       │                    │
       ▼                    ▼
┌─────────────────────┐  ┌─────────────┐
│ Match Found!        │  │ No Match    │
└──────┬──────────────┘  └──────┬──────┘
       │                        │
       ▼                        ▼
┌─────────────────────┐  ┌─────────────────────┐
│ 4. Verify Liveness  │  │ Log to database     │
│    (blink/pose)     │  │ as UNKNOWN_ID       │
└──────┬──────────────┘  └─────────────────────┘
       │
       ▼
┌─────────────────────┐
│ 5. Record           │
│    Attendance       │
└─────────────────────┘
```

---

## 🔄 Offline Sync Strategy

### Queued Sync Model

```python
# Pseudocode for sync behavior
class AttendanceRecord:
    def __init__(self, employee_id, check_in_time, location=None):
        self.employee_id = employee_id
        self.check_in_time = check_in_time
        self.location = location
        self.synced = False
        self.retry_count = 0
    
    def sync_to_server(self, http_client):
        """Attempt to sync with server, retry up to 3 times"""
        if self.synced:
            return True
            
        for attempt in range(3):
            try:
                # POST to /api/attendance/sync
                response = http_client.post(
                    f"{API_BASE}/sync",
                    json={
                        "employee_id": self.employee_id,
                        "check_in_time": self.check_in_time.isoformat(),
                        "location": self.location
                    }
                )
                
                if response.status_code == 200:
                    self.synced = True
                    return True
                    
            except Exception as e:
                self.retry_count += 1
                if self.retry_count >= 3:
                    print(f"Sync failed after {self.retry_count} attempts")
                    return False
        
        return False
```

---

## 🎨 Recommended UI Components

### Home Screen
- **Sync Status Indicator** (Top bar)
- **Quick Action Buttons**: Check-in, Check-out
- **Today's Summary**: Time in office, breaks
- **Pending Actions**: Offline queue count

### Attendance Marking Screen
- **Camera Preview** with face detection overlay
- **"Capture" Button** (large, thumb-friendly)
- **Confidence Meter**: Show recognition confidence
- **Location Toggle**: GPS enabled/disabled

---

## 🧪 Testing Strategy

```bash
# Run Flutter tests
flutter test test/

# Lint check
flutter analyze

# Build release APK
flutter build apk --release

# Hot reload (development)
flutter run --hot-reload
```

---

## 📚 Dependencies Reference

### Core
- `tflite_flutter`: TensorFlow Lite inference on mobile
- `camera`: Camera access and preview
- `path_provider`: File system paths
- `sqflite`: SQLite database

### Network & Sync
- `connectivity_plus`: Internet connectivity detection
- `http`: HTTP client for sync operations
- `shared_preferences`: Store offline queue config

### UI Enhancements
- `flutter_lottie`: Animated onboarding/loading
- `cached_network_image`: Image caching (when fetching models)
- `intl`: Date/time formatting

---

## 🛠️ Development Commands

```bash
# Install dependencies
flutter pub get

# Run in debug mode
flutter run -d <device_id> --debug

# Hot reload for faster iteration
flutter run --hot-reload

# Analyze code quality
flutter analyze --no-fatal-inf-warnings

# Generate coverage
flutter test --coverage
```

---

## 📊 Metrics to Track

1. **Offline Queue Size**: Number of pending sync records
2. **Sync Success Rate**: % of queued items successfully synced
3. **Face Recognition Accuracy**: Match rate vs manual review
4. **App Crash Rate**: Stability monitoring
5. **Average Sync Time**: Network latency impact

---

*Last Updated: 2026-04-30 21:00 UTC*
