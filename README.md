# Tareeq - Lebanese Bus Tracking & Routing System

<div align="center">
  <img src="flutter_frontend/assets/logo.png" alt="Tareeq Logo" width="200"/>
  <br />
  <p><em>Navigate Lebanon's public transportation with ease</em></p>
</div>

## 📋 Overview

Tareeq (meaning "path" or "road" in Arabic) is a comprehensive bus tracking and routing application designed specifically for Lebanon's public transportation system. The app aims to improve the commuting experience by providing real-time information about bus locations, routes, and schedules.

## ✨ Features

### 🚍 For Passengers

- **Real-time Bus Tracking**: See exactly where your bus is on the map
- **Route Planning**: Find optimal routes between any two locations
- **Stop Information**: View details and schedules for all bus stops
- **Saved Places**: Save your frequent destinations for quick access
- **Timetables**: Access visual timetables for all routes
- **Issue Reporting**: Report problems with buses or stops
- **Two-Factor Authentication**: Secure your account with 2FA

### 🚌 For Bus Drivers

- **Status Updates**: Update bus status (active/inactive)
- **Location Sharing**: Share location for real-time passenger tracking

### 👨‍💼 For Administrators

- **Dashboard**: View system statistics and usage data
- **Fleet Management**: Add, edit, or remove buses from the system
- **Route Configuration**: Create and modify bus routes
- **Stop Management**: Add or update bus stop information
- **User Management**: Manage passenger and driver accounts

## 🔧 Technology Stack

### Frontend (Mobile App)

- **Framework**: Flutter (Dart)
- **Maps**: Google Maps API
- **State Management**: Provider
- **Storage**: SharedPreferences, Firebase
- **Authentication**: Firebase Auth with custom extensions

### Backend (Administrative Panel)

- **Framework**: Laravel (PHP)
- **Database**: MySQL
- **Authentication**: Laravel Sanctum
- **CSS Framework**: Tailwind CSS
- **Real-time Updates**: Firebase Firestore

## 📱 Screenshots

<!-- Replace with actual screenshots when available -->
<div align="center">
  <p><em>Screenshots coming soon</em></p>
</div>

## 🛠️ Installation

### Prerequisites

- Flutter SDK (2.10.0 or higher)
- Dart (2.16.0 or higher)
- Android Studio / Xcode
- PHP 8.1 or higher (for backend)
- Composer
- MySQL

### Frontend Setup

```bash
# Clone the repository
git clone https://github.com/yourusername/Tareeq.git

# Navigate to the frontend directory
cd Tareeq/flutter_frontend

# Install dependencies
flutter pub get

# Run the app
flutter run
```

### Backend Setup

```bash
# Navigate to the backend directory
cd Tareeq/laravel_backend

# Install PHP dependencies
composer install

# Copy environment file
cp .env.example .env

# Generate application key
php artisan key:generate

# Run migrations
php artisan migrate

# Start the server
php artisan serve
```

## 🚀 Deployment

### Android

```bash
cd flutter_frontend
flutter build apk --release
```

### iOS

```bash
cd flutter_frontend
flutter build ios --release
```

## 📊 Project Structure

```
Tareeq/
├── flutter_frontend/    # Flutter mobile application
│   ├── lib/
│   │   ├── components/  # Reusable UI components
│   │   ├── models/      # Data models
│   │   ├── pages/       # App screens
│   │   ├── providers/   # State management
│   │   └── services/    # API services
│   └── ...
└── laravel_backend/     # Laravel admin panel and API
    ├── app/
    │   ├── Http/        # Controllers and middleware
    │   ├── Models/      # Database models
    │   └── Services/    # Business logic
    └── ...
```

## 👥 Contributing

We welcome contributions to Tareeq! If you'd like to contribute, please:

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 📞 Contact

For questions or support, please contact:

<!-- - Email: contact@tareeq.app
- Website: https://tareeq.app -->

---

<div align="center">
  <p>© 2025 Tareeq. All rights reserved.</p>
  <p>Built with ❤️ in Lebanon</p>
</div>
