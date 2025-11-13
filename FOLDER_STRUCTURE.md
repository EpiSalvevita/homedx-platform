# homeDX Platform - Folder Structure

## 📁 **Project Folders Explained**

### **Backend (`backend/`)**
- **Technology**: NestJS API with TypeScript
- **Purpose**: Server-side API with GraphQL + REST endpoints
- **Database**: PostgreSQL with Prisma ORM
- **Status**: ✅ Active and working

### **Mobile App (`mobile/`)**
- **Technology**: React Native 0.66.5 with TypeScript
- **Purpose**: Current production mobile app
- **Status**: ✅ Active - this is the app that's currently deployed
- **Features**: BLE, camera, video, file uploads, Cube integration

### **Mobile Flutter (`mobile_flutter/`)**
- **Technology**: Flutter/Dart
- **Purpose**: New Flutter app (in progress)
- **Status**: 🚧 Being set up - just created basic structure
- **Why**: Switching from React Native to Flutter due to compatibility issues
- **Current State**: Basic app with home screen, theme, navigation

### **Legacy Mobile (`mobile_reactnative_lagacy/`)**
- **Technology**: React Native
- **Purpose**: Old/previous React Native version
- **Status**: 📦 Archived - kept for reference

### **Flutter SDK (`flutter/`)**
- **Purpose**: Flutter SDK installation (not a project)
- **Status**: Used for Flutter development
- **Note**: This is the Flutter framework itself, not an app

### **Cube (`Cube/`)**
- **Purpose**: Cube device integration files (DLL, documentation)
- **Status**: Integration files for diagnostic devices

## 🎯 **Which One to Use?**

### **For Running the Current App:**
Use `mobile/` (React Native app)
```bash
cd mobile
./deploy.sh mobile
```

### **For Developing the New Flutter App:**
Use `mobile_flutter/` (Flutter app)
```bash
cd mobile_flutter
flutter run
```

## 📊 **Migration Status**

- ✅ **React Native App**: Working and deployed
- 🚧 **Flutter App**: Just created, needs backend integration
- 🔄 **Planned**: Migrate all features from React Native to Flutter

## 🚀 **Quick Start**

**Run React Native app:**
```bash
./deploy.sh
```

**Run Flutter app (once setup is complete):**
```bash
cd mobile_flutter
flutter pub get
flutter run
```

