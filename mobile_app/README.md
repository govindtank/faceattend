# 🎯 FaceAttend - Face Recognition Attendance System

<div align="center">

[![Flutter](https://img.shields.io/badge/Flutter-3.24.0-02569B?style=flat-square&logo=flutter)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.5.0-0175C2?style=flat-square&logo=dart)](https://dart.dev)
[![License](https://img.shields.io/badge/License-MIT-green?style=flat-square)](LICENSE)
[![GitHub deployments](https://img.shields.io/github/deployments/govindtank/faceattend-mobile/github-pages?style=flat-square)](https://github.com/govindtank/faceattend-mobile/deployments)

**A modern, enterprise-grade face recognition-based employee attendance system**

[Features](#-features) • [Tech Stack](#-tech-stack) • [Getting Started](#-getting-started) • [Contributing](#-contributing)

</div>

---

## 🎯 Features

### Core Functionality
- **🤖 Face Recognition Login** - Secure authentication using facial recognition technology
- **📋 Check-In/Check-Out** - One-tap attendance marking with face verification
- **📊 Real-time Dashboard** - Live view of attendance status and recent activity
- **📅 Attendance History** - Complete log of all check-in/check-out records
- **👥 Employee Management** - Admin panel for managing employee records
- **📱 Cross-Platform** - Works on iOS, Android, and Web

### UI/UX Features
- **🎨 Professional Design** - Clean, enterprise-grade interface
- **📐 Responsive Layout** - Adapts to all screen sizes
- **✨ Smooth Animations** - Polished transitions and micro-interactions
- **🌙 Modern Color Scheme** - Blue/teal corporate palette
- **⏳ Loading States** - Proper feedback during operations

## 🛠 Tech Stack

| Category | Technology |
|----------|------------|
| **Framework** | Flutter 3.24.0 |
| **Language** | Dart 3.5.0 |
| **State Management** | Provider |
| **Local Database** | SQLite (sqflite) |
| **Face Recognition** | TensorFlow Lite |
| **HTTP Client** | Dio |
| **Camera** | camera |
| **CI/CD** | GitHub Actions |
| **Hosting** | GitHub Pages |

## 📁 Project Structure

```
faceattend-mobile/
├── lib/
│   ├── main.dart                 # App entry point & UI
│   ├── models/
│   │   └── employee_model.dart   # Data models
│   ├── services/
│   │   ├── database_helper.dart  # SQLite operations
│   │   └── face_recognition_service.dart  # ML model
│   └── widgets/
│       └── camera_preview.dart   # Camera component
├── web/
│   └── index.html                # Web entry point
├── .github/
│   └── workflows/
│       └── deploy.yml            # CI/CD pipeline
└── pubspec.yaml
```

## 🚀 Getting Started

### Prerequisites
- Flutter SDK 3.24.0 or higher
- Dart SDK 3.5.0 or higher
- Git

### Installation

```bash
# Clone the repository
git clone https://github.com/govindtank/faceattend-mobile.git
cd faceattend-mobile

# Install dependencies
flutter pub get

# Run on web
flutter run -d chrome

# Build for web
flutter build web --release --base-href /faceattend-mobile/
```

### Web Deployment

The app is automatically deployed to GitHub Pages via GitHub Actions on every push to `main`.

**Live URL**: https://govindtank.github.io/faceattend-mobile/

## 📱 Screenshots

| Login | Dashboard | Attendance |
|:-----:|:---------:|:----------:|
| ![Login](https://via.placeholder.com/300x600/0D47A1/FFFFFF?text=Login+Screen) | ![Dashboard](https://via.placeholder.com/300x600/00897B/FFFFFF?text=Dashboard) | ![Attendance](https://via.placeholder.com/300x600/00BCD4/FFFFFF?text=Attendance) |

## 🔧 Configuration

### Environment Variables
Create a `.env` file in the root directory:

```env
API_BASE_URL=https://api.faceattend.com
FACE_MODEL_PATH=assets/models/mobilefacenet.tflite
```

### Database
The app uses SQLite for local storage. Database schema is automatically created on first run.

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 👨‍💻 Author

**Govind Tank**
- GitHub: [@govindtank](https://github.com/govindtank)
- Email: govindtank600@gmail.com

## 🙏 Acknowledgments

- Flutter team for the amazing framework
- TensorFlow Lite for face recognition capabilities
- All contributors who help improve this project

---

<div align="center">

**Made with ❤️ using Flutter**

</div>
