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

### **Backend Setup**
```bash
cd backend
docker start hdx-postgres
npm install --legacy-peer-deps
npm run start:dev
```

### **Mobile App Setup**
```bash
cd mobile
npm install
npx react-native run-android  # or run-ios
```

## 📱 **Mobile App**

- **Framework**: React Native with TypeScript
- **UI**: Native Base
- **Navigation**: React Navigation
- **Features**: 
  - Bluetooth connectivity
  - Camera integration
  - File uploads
  - Multi-language support
  - Cube device integration

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

**Platform Status**: ✅ Backend API Complete | 🔄 Mobile Integration In Progress | ⏳ Cube Integration Pending