# FaceAttend - Offline Face Recognition Attendance System

## Project Overview
FaceAttend is an offline-first face recognition attendance system designed for companies to track employee attendance. The system consists of a mobile app (Flutter) for employees to check-in/check-out using face recognition, an admin panel (Flutter web) for managing employees and viewing attendance reports, and a backend (Node.js/Express) for data synchronization and storage.

## Key Features

### Mobile App (Flutter)
- **Employee Features:**
  - Secure login/authentication (PIN, biometric fallback)
  - Real-time face capture using device camera
  - Offline face recognition with liveness detection
  - Attendance marking (check-in/check-out)
  - Local storage of attendance records when offline
  - Automatic sync when network available
  - Attendance history view
  - Profile management
  - Push notifications for reminders
  - Multi-language support

- **Admin Features (in mobile app):**
  - Admin login/dashboard
  - Employee management (add/edit/remove)
  - Department/team organization
  - Attendance reports (daily, weekly, monthly)
  - Export reports (CSV, PDF)
  - Real-time attendance monitoring
  - Manual override for attendance
  - Holiday and leave management
  - System settings

### Admin Panel (Web Responsive)
- Dashboard with key metrics
- Employee directory
- Attendance analytics and charts
- Report generation
- Settings management
- User role management

### Offline Capabilities
- Face recognition works completely offline
- Local database stores all transactions
- Sync queue for offline transactions
- Conflict resolution for sync
- Background sync service

### Security & Privacy
- Face templates stored locally (not raw images)
- Data encryption at rest
- Secure API communication
- Role-based access control
- Audit logs
- GDPR/compliance features

## Technology Stack

### Mobile App
- **Framework:** Flutter 3.0+
- **Language:** Dart
- **State Management:** Provider
- **Face Recognition:** 
  - tflite_flutter plugin
  - camera plugin
  - path_provider
  - sqflite (SQLite)
  - connectivity_plus
  - shared_preferences
- **UI Enhancements:**
  - flutter_lottie for animations
  - flutter_svg for icons
  - intl for localization

### Admin Panel
- **Framework:** Flutter Web (code sharing with mobile)
- **Language:** Dart
- **State Management:** Provider
- **UI Libraries:** 
  - flutter_svg
  - flutter_lottie
  - syncfusion_flutter_charts (for charts)
  - syncfusion_flutter_datagrid (for data tables)

### Backend
- **Framework:** Node.js with Express
- **Database:** MongoDB (with Mongoose ODM)
- **Authentication:** JWT (JSON Web Tokens)
- **Security:** bcrypt for password hashing, CORS, helmet
- **Validation:** express-validator (planned)

### Face Recognition Models
- **Primary:** TensorFlow Lite with MobileNet/FaceNet (converted to TFLite)
- **Alternative:** MediaPipe Face Detection + custom embedding model
- **Training:** Can be trained on LFW dataset or custom employee dataset
- **Conversion:** TensorFlow Lite Converter

## Setup Instructions

### Prerequisites
- Flutter SDK (>=3.0.0)
- Node.js (>=14.0.0)
- MongoDB (local or cloud instance)
- Git

### Mobile App Setup
1. Navigate to the `mobile_app` directory:
   ```bash
   cd faceattend/mobile_app
   ```
2. Install dependencies:
   ```bash
   flutter pub get
   ```
3. (Optional) Add face recognition model assets:
   - Place your `.tflite` model file in `assets/models/`
   - Place labels file in `assets/models/labels.txt`
   - Update `pubspec.yaml` to include these assets
4. Run the app:
   ```bash
   flutter run
   ```

### Admin Panel Setup
1. Navigate to the `admin_panel` directory:
   ```bash
   cd faceattend/admin_panel
   ```
2. Install dependencies:
   ```bash
   flutter pub get
   ```
3. Run for web:
   ```bash
   flutter run -d chrome
   ```
   Or build for web:
   ```bash
   flutter build web
   ```

### Backend Setup
1. Navigate to the `backend` directory:
   ```bash
   cd faceattend/backend
   ```
2. Install dependencies:
   ```bash
   npm install
   ```
3. Create a `.env` file based on `.env.example`:
   ```bash
   cp .env.example .env
   ```
   Edit `.env` to set your MongoDB URI and JWT secret.
4. Start the server:
   ```bash
   npm start
   ```
   For development with auto-reload:
   ```bash
   npm run dev
   ```

## Architecture Overview
```
Mobile App (Flutter) <--> Backend (Node.js/Express) <--> MongoDB
        ^                                                     ^
        |                                                     |
        v                                                     v
Admin Panel (Flutter Web)                                   Local SQLite (on device)
```

### Data Flow
1. Employee uses mobile app to capture face for attendance
2. Face recognition runs offline using TensorFlow Lite model
3. Attendance record stored locally in SQLite
4. When network is available, records are synced to backend via REST API
5. Admin panel views and manages data through backend API
6. Backend persists data to MongoDB

## API Endpoints

### Authentication
- `POST /api/auth/login` - Login and get JWT token

### Employees
- `GET /api/employees` - Get all active employees
- `POST /api/employees` - Create new employee
- `GET /api/employees/:id` - Get employee by ID
- `PUT /api/employees/:id` - Update employee
- `DELETE /api/employees/:id` - Deactivate employee

### Attendance
- `POST /api/attendance` - Record attendance (check-in/check-out)
- `GET /api/attendance` - Get attendance records (with filtering)
- `GET /api/attendance/reports` - Get attendance reports

## Screenshots
*(To be added after initial testing and UI refinement)*

### Mobile App Screens
- Login Screen
- Employee Home (Face Capture)
- Attendance History
- Admin Dashboard (in mobile app)

### Admin Panel Screens
- Login Screen
- Dashboard Overview
- Employee Management
- Attendance Reports
- Settings

## Future Enhancements
- [ ] Liveness detection (eye blink, head movement)
- [ ] Push notifications for attendance reminders
- [ ] Biometric fallback authentication (fingerprint)
- [ ] GPS/geofencing for location verification
- [ ] Integration with existing HR systems
- [ ] Advanced reporting and analytics
- [ ] Multi-language support (i18n)
- [ ] Dark mode theme
- [ ] Offline model updates
- [ ] Face mask detection (for pandemic scenarios)

## Contributing
1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing-feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## License
This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Acknowledgments
- TensorFlow Lite team for the face recognition models
- Flutter team for the beautiful UI framework
- Open-source community for various plugins and packages used

---

*FaceAttend: Ensuring accurate attendance tracking, even when offline.*