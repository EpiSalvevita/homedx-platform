# homeDX Platform

A comprehensive mobile-first platform for rapid diagnostic testing with Cube device integration.

## 🏗️ **Architecture**

```
homedx-platform/
├── backend/          # NestJS API (GraphQL + REST)
├── mobile/           # React Native mobile app
├── Cube/             # Cube DLL integration files
└── docs/             # Documentation
```

## 🚀 **Quick Start**

### **Automated Deploy (Recommended)**
```bash
# Deploy everything (backend + mobile)
./deploy.sh

# Or deploy specific parts
./deploy.sh backend    # Start only backend
./deploy.sh mobile     # Start only mobile app

# Stop all services
./stop.sh
```

### **Manual Setup**
If you prefer to run each service manually:

### **Backend Setup**
```bash
cd backend
docker start hdx-postgres
npm install --legacy-peer-deps
npm run start:dev
```

### **Mobile App Setup**

#### **Prerequisites**
- Node.js 16+ with OpenSSL legacy provider support
- Android Studio (for Android development)
- Xcode (for iOS development, macOS only)

#### **Installation**
```bash
cd mobile
npm install

# Fix OpenSSL issue (if encountered)
export NODE_OPTIONS="--openssl-legacy-provider"

# Start Metro bundler
npx react-native start
```

#### **Android Development**
```bash
# Install Android Studio
sudo snap install android-studio --classic

# Set up environment variables
echo 'export ANDROID_HOME=$HOME/Android/Sdk' >> ~/.bashrc
echo 'export PATH=$PATH:$ANDROID_HOME/emulator' >> ~/.bashrc
echo 'export PATH=$PATH:$ANDROID_HOME/platform-tools' >> ~/.bashrc
source ~/.bashrc

# Create and start emulator in Android Studio
# Then run the app
npx react-native run-android
```

#### **iOS Development (macOS only)**
```bash
# Install Xcode from App Store
sudo xcode-select --install

# Run the app
npx react-native run-ios
```

## 📱 **Mobile App**

- **Framework**: React Native 0.66.5 with TypeScript
- **UI**: Native Base
- **Navigation**: React Navigation
- **Testing**: Jest + React Native Testing Library
- **Features**: 
  - Bluetooth connectivity (BLE)
  - Camera integration (Vision Camera)
  - File uploads and media management
  - Multi-language support (i18next)
  - Cube device integration
  - Video recording and conversion
  - Image picker and processing
  - Secure storage (Encrypted AsyncStorage)
  - Date/time pickers
  - SVG graphics support
  - Video playback
  - Splash screen
  - Safe area handling

## 🔧 **Backend API**

- **Framework**: NestJS with TypeScript
- **Database**: PostgreSQL with Prisma ORM
- **APIs**: 
  - GraphQL (for web admin)
  - REST (for mobile app)
- **Authentication**: JWT tokens
- **File Uploads**: Multer with organized storage

## 🔗 **API Endpoints**

### **Mobile REST API** (`/gg-homedx-json/gg-api/v1/`)
- `POST /login` - User authentication
- `POST /register-account` - User registration
- `POST /get-user-data` - Get user profile
- `POST /update-user-data` - Update user profile
- `POST /get-test-type-list` - Get available test types
- `POST /add-test` - Create new test
- `POST /get-last-test` - Get test results
- `POST /add-rapid-test-photo` - Upload test photo
- `POST /add-rapid-test-video` - Upload test video
- `POST /add-identification-photo` - Upload ID photo
- `POST /get-be-status-flags` - Get backend status
- `POST /get-live-token` - Get live session token

### **GraphQL API** (`/graphql`)
- Full CRUD operations for all entities
- Real-time subscriptions
- File uploads
- Admin functions

## 🧪 **Cube Integration**

The platform supports integration with Cube diagnostic devices:
- **DLL Library**: `CubeLibrary.dll` (Windows)
- **Documentation**: `CubeDLL Programmer's Guide.pdf`
- **Features**: Device communication, measurement management, data retrieval

## 🗄️ **Database**

PostgreSQL with the following main entities:
- **Users**: Authentication and profiles
- **RapidTests**: Test records and results
- **TestKits**: Available test types
- **Certificates**: Generated certificates
- **Licenses**: User licenses
- **AuditLogs**: System audit trail

## 🔐 **Security**

- JWT-based authentication
- Password hashing with bcrypt
- File upload validation
- CORS configuration
- Input validation with class-validator

## 🌍 **Internationalization**

- Multi-language support (i18next)
- Language detection
- Resource loading
- Mobile and backend support

## 📦 **Development**

### **Prerequisites**
- Node.js 16+
- PostgreSQL (Docker)
- React Native CLI
- Android Studio / Xcode

### **Environment Variables**
```bash
# Backend (.env)
DATABASE_URL="postgresql://devuser:devpassword@localhost:5432/devdb?schema=public"
JWT_SECRET="your-secret-key"

# Mobile (.env)
HOMEDX_API_URL="http://localhost:4000"
HOMEDX_BASIC_AUTH_USER="mobile"
HOMEDX_BASIC_AUTH_PW="password"
```

## 🧪 **Testing**

### **Test User Credentials**
- **Email**: `epirotalija@gmail.com`
- **Password**: `espex260`

### **Database State**
- 1 test user
- 0 tests/certificates/licenses
- Ready for development

### **Mobile App Testing**
1. **Start Backend**: Ensure backend is running on `http://localhost:4000`
2. **Start Metro**: Run `npx react-native start` in mobile directory
3. **Run on Device**: Use `npx react-native run-android` or `run-ios`
4. **Test Login**: Use the test credentials above

## 🔧 **Troubleshooting**

### **OpenSSL Error (Metro Bundler)**
```bash
export NODE_OPTIONS="--openssl-legacy-provider"
npx react-native start
```

### **Gradle Version Error**
If you see "minimal gradle version 7.3" error:
```bash
# Update gradle-wrapper.properties
distributionUrl=https\://services.gradle.org/distributions/gradle-7.5.1-all.zip

# Update build.gradle
classpath("com.android.tools.build:gradle:7.2.2")
```

### **Metro Port Conflict**
```bash
# Kill existing Metro process
pkill -f "react-native start"

# Restart Metro
export NODE_OPTIONS="--openssl-legacy-provider"
npx react-native start
```

### **Android Emulator Issues**
- Ensure Android Studio is installed
- Check `ANDROID_HOME` environment variable
- Verify emulator is running: `adb devices`
- If emulator shows "offline" from WSL, use Android Studio to run the app

### **iOS Simulator Issues (macOS)**
- Install Xcode from App Store
- Run `sudo xcode-select --install`
- Open Xcode and accept license agreements

### **Build Issues**
```bash
# Clean and rebuild
cd mobile/android
./gradlew clean
./gradlew assembleDebug
```

## 🚀 **Deployment**

### **Backend**
```bash
cd backend
npm run build
npm run start:prod
```

### **Mobile**
- Build APK/IPA for distribution
- Configure production API endpoints
- Set up app store accounts

## 📚 **Documentation**

- [Backend API Documentation](./backend/README.md)
- [Mobile App Documentation](./mobile/README.md)
- [Cube Integration Guide](./Cube/)

## 🤝 **Contributing**

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly
5. Submit a pull request

## 📄 **License**

[Add your license information here]

---

**Platform Status**: ✅ Backend API Complete | ✅ Mobile App Ready | ⏳ Cube Integration Pending

## 🎉 **Current Status**

### ✅ **Completed**
- **Backend API**: Fully functional with GraphQL and REST endpoints
- **Mobile App**: React Native app with comprehensive testing suite
- **Android Build**: Successfully builds and generates APK
- **Testing**: Complete Jest test suite with React Native Testing Library
- **Dependencies**: All native modules properly configured and working
- **Gradle Update**: Updated to Gradle 7.5.1 and Android Gradle Plugin 7.2.2
- **OpenSSL Fix**: Resolved Metro bundler OpenSSL compatibility issues

### 🚀 **Ready to Run**
The mobile app is now ready to run! You can:
1. **Use Android Studio**: Open the project and click Run
2. **Use Command Line**: `npx react-native run-android` (with emulator running)
3. **Install APK**: Directly install the generated APK file

### 📱 **APK Location**
The debug APK is available at:
```
/home/epi_linux/homedx-platform/mobile/android/app/build/outputs/apk/debug/app-debug.apk
```

### 🔧 **Recent Updates**
- **Automated Deploy Scripts**: Created `deploy.sh` and `stop.sh` for one-command deployment
- **Fixed Gradle Version**: Updated from 6.7.1 to 7.5.1 to resolve compatibility issues
- **Updated Android Gradle Plugin**: Upgraded from 4.2.2 to 7.2.2
- **Resolved OpenSSL Error**: Fixed Metro bundler compatibility with Node.js 17+
- **Successfully Built APK**: App compiles and generates APK without errors
- **Metro Bundler**: Development server runs with OpenSSL legacy provider

### ⚠️ **Known Issues**
- **Emulator Connection**: WSL may show emulator as "offline" but app still installs
- **Port Conflicts**: Metro bundler may need port 8081 to be freed before restart
- **Gradle Warnings**: Some deprecation warnings (non-blocking)

### 🎯 **Next Steps**
1. **Launch App**: Use Android Studio to run the app on emulator
2. **Test Features**: Verify all screens and functionality work
3. **Cube Integration**: Implement Cube device connectivity
4. **Production Build**: Create release APK for distribution