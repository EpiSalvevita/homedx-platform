import { Module } from '@nestjs/common';
import { GraphQLModule } from '@nestjs/graphql';
import { ApolloDriver, ApolloDriverConfig } from '@nestjs/apollo';
import { JwtModule } from '@nestjs/jwt';
import { PassportModule } from '@nestjs/passport';
import { PrismaService } from './services/prisma.service';
import { UserService } from './services/user.service';
import { UserResolver } from './graphql/resolvers/user.resolver';
import { LicenseService } from './services/license.service';
import { LicenseResolver } from './graphql/resolvers/license.resolver';
import { AuthService } from './services/auth.service';
import { AuthResolver } from './graphql/resolvers/auth.resolver';
import { PaymentService } from './services/payment.service';
import { PaymentResolver } from './graphql/resolvers/payment.resolver';
import { RapidTestService } from './services/rapid-test.service';
import { RapidTestResolver } from './graphql/resolvers/rapid-test.resolver';
import { TestKitService } from './services/test-kit.service';
import { TestKitResolver } from './graphql/resolvers/test-kit.resolver';
import { CertificateService } from './services/certificate.service';
import { CertificateResolver } from './graphql/resolvers/certificate.resolver';
import { AuditLogService } from './services/audit-log.service';
import { AuditLogResolver } from './graphql/resolvers/audit-log.resolver';
import { NotificationService } from './services/notification.service';
import { NotificationResolver } from './graphql/resolvers/notification.resolver';
import { FileUploadService } from './services/file-upload.service';
import { FileUploadResolver } from './graphql/resolvers/file-upload.resolver';
import { SystemResolver } from './graphql/resolvers/system.resolver';
import { LegalPageService } from './services/legal-page.service';
import { LegalPageResolver } from './graphql/resolvers/legal-page.resolver';
import { JwtStrategy } from './auth/jwt.strategy';
// import { NotificationService } from './services/notification.service';
// import { NotificationResolver } from './graphql/resolvers/notification.resolver';

@Module({
  imports: [
    PassportModule,
    GraphQLModule.forRoot<ApolloDriverConfig>({
      driver: ApolloDriver,
      autoSchemaFile: 'schema.gql',
      sortSchema: true,
      playground: true,
      debug: true,
      introspection: true,
    }),
    JwtModule.register({
      secret: process.env.JWT_SECRET || 'your-secret-key',
      signOptions: { expiresIn: '24h' },
    }),
  ],
  providers: [
    PrismaService,
    UserService,
    UserResolver,
    LicenseService,
    LicenseResolver,
    AuthService,
    AuthResolver,
    PaymentService,
    PaymentResolver,
    RapidTestService,
    RapidTestResolver,
    TestKitService,
    TestKitResolver,
    CertificateService,
    CertificateResolver,
    AuditLogService,
    AuditLogResolver,
    NotificationService,
    NotificationResolver,
    FileUploadService,
    FileUploadResolver,
    SystemResolver,
    LegalPageService,
    LegalPageResolver,
    JwtStrategy,
    // NotificationService,
    // NotificationResolver,
  ],
})
export class AppModule {}
