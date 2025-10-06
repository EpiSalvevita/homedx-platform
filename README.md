# homeDX - Digital Health Testing Platform

## 🤖 AI Assistant Context

This is a comprehensive digital health testing platform for rapid diagnostic tests (primarily COVID-19, but extensible to other medical tests). The application enables users to perform supervised rapid tests, generate digital certificates, and manage their testing history through a secure web-based interface.

## 🏗️ Architecture Overview

### System Components
- **Frontend**: React 17 SPA with Redux state management
- **Backend**: NestJS GraphQL API with TypeScript
- **Database**: PostgreSQL with Prisma ORM
- **Authentication**: JWT-based with Passport
- **File Storage**: Local file system (configurable for cloud)
- **Payment**: Stripe integration
- **Analytics**: Matomo tracking
- **Monitoring**: Sentry error tracking

### Technology Stack
```
Frontend: React 17 + Redux + Apollo Client + SCSS + Webpack
Backend: NestJS + GraphQL + Prisma + PostgreSQL + JWT
DevOps: Docker + Environment-based configs
```

## 📁 Project Structure

```
hdx-dev/
├── app/                          # React Frontend
│   ├── src/
│   │   ├── components/           # Reusable UI components
│   │   │   ├── authentication_steps/  # Auth flow components
│   │   │   ├── certificate/           # Certificate display/management
│   │   │   ├── questionnaire/         # Test questionnaire components
│   │   │   ├── signup/               # User registration components
│   │   │   └── test_steps/           # Test execution workflow
│   │   ├── screens/              # Main application screens
│   │   │   ├── Dashboard.js          # Main user dashboard
│   │   │   ├── NewTest.js            # Test execution interface
│   │   │   ├── MyResult.js           # Test results viewer
│   │   │   ├── Authentication.js     # Login/signup
│   │   │   ├── Payment.js            # Payment processing
│   │   │   └── Profile.js            # User profile management
│   │   ├── services/             # API service layer
│   │   │   ├── graphql.js            # GraphQL queries/mutations
│   │   │   ├── auth.service.js       # Authentication services
│   │   │   ├── test.service.js       # Test-related services
│   │   │   └── payment.service.js    # Payment services
│   │   ├── base/                 # Base components & utilities
│   │   ├── assets/               # Static assets (icons, images)
│   │   ├── i18n/                 # Internationalization files
│   │   └── style/                # SCSS stylesheets
│   ├── public/                   # Static public files
│   └── dist/                     # Built application
├── backend/                      # NestJS Backend
│   ├── src/
│   │   ├── auth/                 # Authentication modules
│   │   ├── graphql/
│   │   │   ├── resolvers/        # GraphQL resolvers
│   │   │   └── types/            # GraphQL type definitions
│   │   ├── services/             # Business logic services
│   │   │   ├── auth.service.ts       # User authentication
│   │   │   ├── rapid-test.service.ts # Test processing
│   │   │   ├── certificate.service.ts # Certificate generation
│   │   │   ├── payment.service.ts    # Payment processing
│   │   │   └── prisma.service.ts     # Database connection
│   │   └── prisma/               # Database schema & migrations
│   └── uploads/                  # File upload storage
└── db-show.sql                  # Database dump (production data)
```

## 🎯 Core Functionality

### 1. User Management
- **Registration/Login**: JWT-based authentication
- **Profile Management**: Personal information, preferences
- **Role System**: USER, ADMIN, MODERATOR roles
- **Email Verification**: Account validation system

### 2. Rapid Testing Workflow
- **Test Kit Management**: Physical test kit tracking with batch numbers
- **Test Execution**: Step-by-step guided testing process
- **Identity Verification**: ID card upload and validation
- **Media Capture**: Photo/video recording of test process
- **Result Processing**: Automated result analysis and validation

### 3. Certificate Generation
- **Digital Certificates**: PDF generation with QR codes
- **Certificate Types**: Test Result, Vaccination, Recovery, Medical Clearance
- **Multi-language Support**: German, English, French
- **Verification System**: QR code scanning for authenticity

### 4. Payment Processing
- **Stripe Integration**: Credit card, PayPal, bank transfer, crypto
- **Payment Tracking**: Transaction status and history
- **Discount System**: Coupon and license-based discounts
- **Invoice Generation**: Payment receipts and documentation

### 5. License Management
- **License Keys**: Unique codes for test access
- **Usage Tracking**: Monitor license consumption
- **Activation System**: License validation and assignment
- **Coupon Integration**: Discount code system

## 🗄️ Database Schema

### Core Entities
```sql
User (id, email, firstName, lastName, role, status, ...)
RapidTest (id, userId, testKitId, result, status, ...)
TestKit (id, serialNumber, type, manufacturer, batchNumber, ...)
Certificate (id, userId, rapidTestId, type, status, ...)
Payment (id, userId, amount, status, method, ...)
License (id, userId, licenseKey, maxUses, usesCount, ...)
AuditLog (id, userId, action, entityType, ...)
Notification (id, userId, type, status, ...)
LegalPage (id, type, language, content, ...)
```

### Key Relationships
- Users → Multiple Tests, Certificates, Payments, Licenses
- Tests → Specific Test Kits and Users
- Certificates → Generated from Completed Tests
- Payments → Associated with Users and Tests
- Audit Logs → Track All User Actions

## 🔐 Security Features

### Authentication & Authorization
- JWT tokens with 24-hour expiration
- Password requirements: 8+ chars, uppercase, lowercase, number, special char
- Role-based access control
- Secure file upload validation

### Data Protection
- Comprehensive audit logging
- GDPR compliance with legal page management
- Input validation and sanitization
- Secure file storage with validation

### Privacy
- Data encryption in transit and at rest
- User consent management
- Right to data deletion
- Privacy policy integration

## 🌐 Internationalization

### Supported Languages
- German (de) - Primary
- English (en)
- French (fr)

### Implementation
- i18next with react-i18next
- Language detection from browser/localStorage
- Dynamic content loading
- Legal pages in multiple languages

## 🧪 Testing

### Frontend Tests
- Unit tests for utility functions
- Password validation tests
- Jest configuration

### Backend Tests
- E2E tests with Supertest
- GraphQL endpoint testing
- Integration tests

### Test Coverage
- Limited coverage (needs improvement)
- Focus on critical business logic
- Password validation thoroughly tested

## 🚀 Development Setup

### Prerequisites
- Node.js 16+
- Docker (for PostgreSQL container)
- npm/yarn

### Frontend Setup
```bash
cd app
npm install
npm run serve:dev  # Development server on :3000
npm run build:prod # Production build
```

### Backend Setup
```bash
# 1. Start PostgreSQL container first
docker start hdx-postgres

# 2. Setup backend
cd backend
npm install
npx prisma migrate dev  # Database setup
npm run start:dev       # Development server on :4000
```

### Environment Variables
```env
# Database
DATABASE_URL="postgresql://user:password@localhost:5432/homedx"

# JWT
JWT_SECRET="your-secret-key"

# Stripe
STRIPE_PUBLIC_KEY="pk_test_..."
STRIPE_SECRET_KEY="sk_test_..."

# File Upload
UPLOAD_PATH="./uploads"
```

## 🚀 Deployment

### Database Setup (Required First)

**Note**: The application uses a Docker PostgreSQL container (`hdx-postgres`) that must be running before starting the backend services.

### Production Deployment
```bash
# 1. Start database
docker start hdx-postgres

# Verify it's running
docker ps | grep postgres

# Check database connection
psql -h localhost -U devuser -d devdb -c "\dt"

# 2. Build and start backend
cd backend
npm install
npm run build
npm run start:prod

# 3. Build and serve frontend
cd ../app
npm install
npm run build:prod
# Serve the dist/ folder with your preferred web server
```

### Docker Container Management
```bash

# Stop database
docker stop hdx-postgres

# View database logs
docker logs hdx-postgres

# Access database shell
docker exec -it hdx-postgres psql -U devuser -d devdb
```

## 📊 Monitoring & Analytics

### Error Tracking
- Sentry integration for error monitoring
- Production error reporting
- Performance tracking

### Analytics
- Matomo integration for usage analytics
- Page view tracking
- User behavior analysis

### Logging
- Comprehensive audit logs
- User action tracking
- System event logging

## 🔧 Configuration

### Frontend Config
- Webpack 4 with Babel transpilation
- SCSS compilation with PostCSS
- Environment-specific builds
- Hot reloading in development

### Backend Config
- NestJS with GraphQL
- Prisma database connection
- File upload handling
- CORS configuration

## 📱 Key User Flows

### 1. User Registration
1. User visits landing page
2. Clicks signup → Authentication screen
3. Fills form with email, password, name
4. Account created → JWT token issued
5. Redirected to dashboard

### 2. Test Execution
1. User clicks "New Test" from dashboard
2. Selects test kit or enters license code
3. Follows step-by-step test instructions
4. Captures photos/videos of test process
5. Uploads ID for verification
6. Submits test for processing
7. Receives results and certificate

### 3. Payment Processing
1. User initiates payment for test
2. Stripe payment form displayed
3. Payment processed securely
4. Transaction recorded in database
5. User receives confirmation

## 🛠️ API Endpoints

### GraphQL Schema
- **Queries**: User data, test results, certificates, payments
- **Mutations**: Login, signup, test submission, payment creation
- **Subscriptions**: Real-time updates (if implemented)

### Key Resolvers
- `AuthResolver`: Login, signup, user management
- `RapidTestResolver`: Test execution and results
- `CertificateResolver`: Certificate generation
- `PaymentResolver`: Payment processing
- `LicenseResolver`: License management

## 🔍 AI Assistant Guidelines

### When Working with This Codebase:

1. **Authentication**: Always check for JWT tokens in requests
2. **File Uploads**: Use GraphQL upload mutations for media files
3. **Internationalization**: Use `useTranslation()` hook for text
4. **State Management**: Use Redux for global state, local state for components
5. **Database**: Use Prisma client for all database operations
6. **Validation**: Server-side validation with class-validator
7. **Error Handling**: Implement proper error boundaries and logging

### Common Patterns:
- GraphQL queries in `services/graphql.js`
- Redux actions in `reducers/` directory
- Component structure: functional components with hooks
- Service layer pattern for API calls
- Prisma service for database operations

### Security Considerations:
- Always validate user input
- Check user permissions before operations
- Log all significant actions
- Handle file uploads securely
- Protect sensitive data in responses

## 📈 Performance Considerations

- Apollo Client caching for GraphQL queries
- Redux state persistence
- Image optimization with Webpack
- Lazy loading for large components
- Database query optimization with Prisma

## 🚨 Known Issues & Limitations

1. **Test Coverage**: Limited test coverage across the application
2. **File Storage**: Local file storage may not scale for production
3. **Error Handling**: Some error handling could be improved
4. **Performance**: Large database dump suggests optimization needs
5. **Security**: Additional security measures may be needed for production

## 📞 Support & Maintenance

- **Error Monitoring**: Sentry dashboard
- **Analytics**: Matomo dashboard
- **Database**: Prisma Studio for data management
- **Logs**: Application logs for debugging

---

*This README is designed to help AI assistants understand the homeDX application structure, functionality, and development patterns. For specific implementation details, refer to the source code and inline documentation.*
