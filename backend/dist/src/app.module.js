"use strict";
var __decorate = (this && this.__decorate) || function (decorators, target, key, desc) {
    var c = arguments.length, r = c < 3 ? target : desc === null ? desc = Object.getOwnPropertyDescriptor(target, key) : desc, d;
    if (typeof Reflect === "object" && typeof Reflect.decorate === "function") r = Reflect.decorate(decorators, target, key, desc);
    else for (var i = decorators.length - 1; i >= 0; i--) if (d = decorators[i]) r = (c < 3 ? d(r) : c > 3 ? d(target, key, r) : d(target, key)) || r;
    return c > 3 && r && Object.defineProperty(target, key, r), r;
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.AppModule = void 0;
const common_1 = require("@nestjs/common");
const graphql_1 = require("@nestjs/graphql");
const apollo_1 = require("@nestjs/apollo");
const jwt_1 = require("@nestjs/jwt");
const passport_1 = require("@nestjs/passport");
const platform_express_1 = require("@nestjs/platform-express");
const prisma_service_1 = require("./services/prisma.service");
const user_service_1 = require("./services/user.service");
const user_resolver_1 = require("./graphql/resolvers/user.resolver");
const license_service_1 = require("./services/license.service");
const license_resolver_1 = require("./graphql/resolvers/license.resolver");
const auth_service_1 = require("./services/auth.service");
const auth_resolver_1 = require("./graphql/resolvers/auth.resolver");
const payment_service_1 = require("./services/payment.service");
const payment_resolver_1 = require("./graphql/resolvers/payment.resolver");
const rapid_test_service_1 = require("./services/rapid-test.service");
const rapid_test_resolver_1 = require("./graphql/resolvers/rapid-test.resolver");
const test_kit_service_1 = require("./services/test-kit.service");
const test_kit_resolver_1 = require("./graphql/resolvers/test-kit.resolver");
const certificate_service_1 = require("./services/certificate.service");
const certificate_resolver_1 = require("./graphql/resolvers/certificate.resolver");
const audit_log_service_1 = require("./services/audit-log.service");
const audit_log_resolver_1 = require("./graphql/resolvers/audit-log.resolver");
const notification_service_1 = require("./services/notification.service");
const notification_resolver_1 = require("./graphql/resolvers/notification.resolver");
const file_upload_service_1 = require("./services/file-upload.service");
const file_upload_resolver_1 = require("./graphql/resolvers/file-upload.resolver");
const system_resolver_1 = require("./graphql/resolvers/system.resolver");
const legal_page_service_1 = require("./services/legal-page.service");
const legal_page_resolver_1 = require("./graphql/resolvers/legal-page.resolver");
const jwt_strategy_1 = require("./auth/jwt.strategy");
const mobile_controller_1 = require("./controllers/mobile.controller");
const jwt_auth_guard_1 = require("./auth/jwt-auth.guard");
let AppModule = class AppModule {
};
exports.AppModule = AppModule;
exports.AppModule = AppModule = __decorate([
    (0, common_1.Module)({
        imports: [
            passport_1.PassportModule,
            platform_express_1.MulterModule.register({
                dest: './uploads',
            }),
            graphql_1.GraphQLModule.forRoot({
                driver: apollo_1.ApolloDriver,
                autoSchemaFile: 'schema.gql',
                sortSchema: true,
                playground: true,
                debug: true,
                introspection: true,
            }),
            jwt_1.JwtModule.register({
                secret: process.env.JWT_SECRET || 'your-secret-key',
                signOptions: { expiresIn: '24h' },
            }),
        ],
        controllers: [mobile_controller_1.MobileController],
        providers: [
            prisma_service_1.PrismaService,
            user_service_1.UserService,
            user_resolver_1.UserResolver,
            license_service_1.LicenseService,
            license_resolver_1.LicenseResolver,
            auth_service_1.AuthService,
            auth_resolver_1.AuthResolver,
            payment_service_1.PaymentService,
            payment_resolver_1.PaymentResolver,
            rapid_test_service_1.RapidTestService,
            rapid_test_resolver_1.RapidTestResolver,
            test_kit_service_1.TestKitService,
            test_kit_resolver_1.TestKitResolver,
            certificate_service_1.CertificateService,
            certificate_resolver_1.CertificateResolver,
            audit_log_service_1.AuditLogService,
            audit_log_resolver_1.AuditLogResolver,
            notification_service_1.NotificationService,
            notification_resolver_1.NotificationResolver,
            file_upload_service_1.FileUploadService,
            file_upload_resolver_1.FileUploadResolver,
            system_resolver_1.SystemResolver,
            legal_page_service_1.LegalPageService,
            legal_page_resolver_1.LegalPageResolver,
            jwt_strategy_1.JwtStrategy,
            jwt_auth_guard_1.JwtAuthGuard,
        ],
    })
], AppModule);
//# sourceMappingURL=app.module.js.map