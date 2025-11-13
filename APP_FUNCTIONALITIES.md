# HomeDX Mobile App - Complete Functionality List

Based on the backend API analysis, here are all the functionalities the app has or should have:

## 🔐 1. Authentication & User Management

### ✅ Implemented
- **User Registration** (`/register-account`)
  - Create account with first name, last name, email, password
  - Email validation
  - Password requirements

- **User Login** (`/login`)
  - Email/password authentication
  - JWT token generation
  - Token-based session management

- **User Profile Management**
  - View user data (`/get-user-data`)
  - Update user profile (`/update-user-data`)
    - Personal information (name, email, phone)
    - Address (city, country, postal code, address)
    - Date of birth
    - Profile image

### 📋 Should Implement
- **Password Management**
  - Change password
  - Reset password / Forgot password
  - Password strength indicator

- **Account Settings**
  - Language selection
  - Notification preferences
  - Privacy settings
  - Account deletion

- **Profile Image Upload**
  - Upload profile picture
  - Crop/edit profile image
  - Remove profile image

---

## 🧪 2. Rapid Test Management

### ✅ Implemented
- **Test Selection** (`/get-test-type-list`)
  - Browse available test types
  - Select from multiple test types:
    - **RheumaCheck** - Rheumatoid arthritis screening test
    - **Vitamin D** - Vitamin D deficiency screening test
    - **COVID-19 Rapid Test** - Rapid antigen test for COVID-19
    - **Antigen Test** - General antigen test
    - **PCR Test** - Polymerase Chain Reaction test
  - Test type information display (name, description, icon, color)
  - Add test (`/add-test`)

- **Test Submission** (`submitTest` mutation) - Backend Ready
  - Submit test with video, photo, test device image
  - Upload identity card photos (front/back)
  - Set test date
  - Agreement acceptance
  - License code activation
  - Payment association

- **Test History**
  - View last test (`/get-last-test`)
  - View all user tests
  - Test status tracking (PENDING, COMPLETED, FAILED)

### 📋 Should Implement
- **Test Creation Flow**
  - Start new test after selection
  - Upload test media:
    - Test photo (`/add-rapid-test-photo`)
    - Test video (`/add-rapid-test-video`)
    - Identification photos (`/add-identification-photo`)
  - Review and submit test

- **Test Status Tracking**
  - Real-time test status updates
  - Test validation status
  - Test result display (POSITIVE, NEGATIVE, INVALID)

- **Live Test Session**
  - Get live token (`/get-live-token`)
  - Real-time test monitoring
  - Live video streaming support

- **Test Details View**
  - View test information
  - Test date and time
  - Associated certificate
  - Test kit information

---

## 📜 3. Certificate Management

### ✅ Implemented (Backend Ready)
- **Certificate Generation**
  - Automatic certificate creation after test validation
  - Certificate types: TEST_RESULT, RECOVERY, VACCINATION, MEDICAL_CLEARANCE
  - Certificate status: DRAFT, ISSUED, REVOKED, EXPIRED

- **Certificate Viewing**
  - View certificate by test ID
  - View certificate by certificate number
  - View all user certificates
  - View valid certificates only

- **Certificate PDF**
  - Generate certificate PDF
  - Download certificate PDF
  - Multi-language PDF support
  - Update certificate language

- **Certificate QR Code**
  - Generate QR code for certificate
  - Scan certificate QR code
  - Verify certificate validity

### 📋 Should Implement
- **Certificate Screen**
  - Display certificate details
  - Download certificate as PDF
  - Share certificate
  - View certificate QR code
  - Certificate validity period
  - Certificate revocation status

- **CWA (Corona-Warn-App) Integration**
  - Generate CWA link (`cwaLink` query)
  - Export certificate to CWA
  - CWA status checking

---

## 💳 4. Payment Processing

### ✅ Implemented (Backend Ready)
- **Payment Creation**
  - Create payment intent (`createPaymentIntent`)
  - Payment methods: CREDIT_CARD, PAYPAL, BANK_TRANSFER, CRYPTO
  - Payment status: PENDING, COMPLETED, FAILED, CANCELLED, REFUNDED

- **Payment Information**
  - Get payment amount (`paymentAmount` query)
  - View payment discount
  - Payment currency support

- **Payment History**
  - View all payments
  - View payment by ID
  - View user payments
  - Payment status tracking

### 📋 Should Implement
- **Payment Screen**
  - Display payment amount
  - Show discount information
  - Select payment method
  - Process payment
  - Payment confirmation
  - Payment receipt

- **Payment Integration**
  - Stripe integration (backend ready)
  - PayPal integration
  - Payment status updates
  - Payment failure handling
  - Refund requests

---

## 🎫 5. License & Coupon Management

### ✅ Implemented (Backend Ready)
- **License Activation**
  - Activate license by code (`activateLicense`)
  - License validation
  - Usage limit checking
  - License status tracking

- **Coupon Assignment**
  - Assign coupon (`assignCoupon`)
  - Coupon code validation
  - Discount application

- **License Management**
  - View user licenses
  - License expiration tracking
  - License usage count

### 📋 Should Implement
- **License/Coupon Screen**
  - Enter license/coupon code
  - Activate license
  - View active licenses
  - License usage history
  - License expiration warnings

---

## 📦 6. Test Kit Management

### ✅ Implemented (Backend Ready)
- **Test Kit Information**
  - View available test kits
  - View test kit by ID
  - View test kit by serial number
  - View user test kits

- **Test Kit Assignment**
  - Assign test kit to user
  - Mark test kit as used
  - Test kit status tracking

### 📋 Should Implement
- **Test Kit Screen**
  - Browse available test kits
  - View test kit details
  - Scan test kit serial number
  - Test kit assignment
  - Test kit usage tracking

---

## 🔔 7. Notifications

### ✅ Implemented (Backend Ready)
- **Notification Types**
  - CERTIFICATE_READY
  - PAYMENT_SUCCESS
  - PAYMENT_FAILED
  - TEST_RESULT
  - SYSTEM_UPDATE
  - SECURITY_ALERT

- **Notification Management**
  - View all notifications
  - View unread notifications
  - Unread notification count
  - Mark notification as read
  - Mark all as read
  - Archive notification

### 📋 Should Implement
- **Notifications Screen**
  - Notification list
  - Notification details
  - Mark as read/unread
  - Delete notifications
  - Notification filters
  - Push notifications
  - In-app notification badges

---

## 📁 8. File Upload & Media Management

### ✅ Implemented
- **File Upload Endpoints**
  - Upload test photo (`/add-rapid-test-photo`)
  - Upload test video (`/add-rapid-test-video`)
  - Upload identification photo (`/add-identification-photo`)

### 📋 Should Implement
- **Media Upload UI**
  - Camera integration
  - Photo/video capture
  - Image picker from gallery
  - File compression
  - Upload progress indicator
  - Upload retry mechanism
  - Media preview before upload

---

## ⚙️ 9. System & Settings

### ✅ Implemented (Backend Ready)
- **Backend Status** (`/get-be-status-flags`)
  - System status checking
  - CWA availability
  - Payment system status
  - Certificate PDF availability

- **System Information**
  - Backend version
  - Maintenance mode status
  - Feature flags
  - System flags

- **Country Codes** (`countryCodes` query)
  - Available country codes list

### 📋 Should Implement
- **Settings Screen**
  - Language selection (`setLanguage`)
  - App version display
  - System status indicator
  - About page
  - Terms & Conditions
  - Privacy Policy
  - Impressum/Legal

---

## 📄 10. Legal Pages

### ✅ Implemented (Backend Ready)
- **Legal Content**
  - Privacy Policy (`getPrivacyPolicy`)
  - Terms and Conditions (`getTermsAndConditions`)
  - Impressum (`getImpressum`)
  - Multi-language support

### 📋 Should Implement
- **Legal Pages Screen**
  - Display legal content
  - Language selection for legal pages
  - Accept terms during registration
  - Legal page navigation

---

## 🔍 11. Audit & Security

### ✅ Implemented (Backend Ready)
- **Audit Logging**
  - Track user actions
  - Entity change tracking
  - IP address logging
  - User agent tracking

- **Authentication Management**
  - Initialize authentication (`/init-authentication`)
  - Unset authentication (`/unset-authentication`)
  - Reset authentication (`resetAuthentication`)

### 📋 Should Implement
- **Security Features**
  - Two-factor authentication
  - Login history
  - Active sessions management
  - Security alerts
  - Account activity log

---

## 🏠 12. Home/Dashboard

### ✅ Partially Implemented
- **Home Screen**
  - User welcome message
  - Quick action cards
  - Navigation to main features

### 📋 Should Implement
- **Dashboard Features**
  - Recent tests summary
  - Active certificates
  - Pending payments
  - Unread notifications count
  - Quick test start
  - Status overview cards
  - Recent activity feed

---

## 📡 13. Bluetooth Connectivity

### ✅ Implemented
- **Device Scanning**
  - Scan for nearby Bluetooth devices
  - Display device information (name, ID, signal strength)
  - Real-time scan results
  - Permission handling (location, Bluetooth)

- **Device Connection**
  - Connect to Bluetooth devices
  - Connection status monitoring
  - Automatic reconnection support

- **Device Management**
  - View connected device information
  - Browse device services and characteristics
  - Read/write data to characteristics
  - Subscribe to characteristic notifications
  - Disconnect from devices

- **Integration**
  - Bluetooth service layer
  - State management with Provider
  - Error handling and user feedback

### 📋 Should Implement
- **Test Device Integration**
  - Connect to specific test device models
  - Read test results from Bluetooth devices
  - Real-time test data streaming
  - Device pairing and persistence

## 📊 14. Additional Features to Consider

### Based on Backend Capabilities
- **Email Verification**
  - Check email availability (`checkEmail`)
  - Email validation

- **QR Code Scanner**
  - Scan test kit QR codes
  - Scan certificate QR codes
  - Scan license codes

- **Offline Support**
  - Cache user data
  - Queue uploads when offline
  - Sync when online

- **Multi-language Support**
  - Language selection
  - Localized content
  - RTL support

- **Dark Mode**
  - Theme switching
  - System theme detection

- **Biometric Authentication**
  - Fingerprint login
  - Face ID login

- **Export/Share**
  - Share certificates
  - Export test results
  - Share via social media

---

## 🎯 Priority Implementation Order

### Phase 1: Core Features (High Priority)
1. ✅ Authentication (Login/Register) - **DONE**
2. ✅ User Profile Management - **DONE**
3. ✅ Test Selection - **DONE**
4. ✅ Bluetooth Connectivity - **DONE**
5. 🔄 Test Submission Flow - **IN PROGRESS**
6. Certificate Viewing & Download
7. Payment Processing
8. Notifications

### Phase 2: Enhanced Features (Medium Priority)
7. Test History & Status
8. License/Coupon Management
9. Test Kit Management
10. File Upload UI
11. Settings Screen
12. Legal Pages

### Phase 3: Advanced Features (Lower Priority)
13. CWA Integration
14. QR Code Scanner
15. Offline Support
16. Biometric Authentication
17. Advanced Security Features

---

## 📝 Notes

- All backend endpoints are ready and functional
- Mobile API endpoints are available at `/gg-homedx-json/gg-api/v1/*`
- GraphQL API is also available for more complex queries
- Authentication uses JWT tokens (Bearer token or `x-auth-token` header)
- File uploads use multipart/form-data
- All timestamps are in milliseconds (Unix timestamp)

