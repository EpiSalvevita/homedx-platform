import { Global, Module } from '@nestjs/common';
import { JwtModule } from '@nestjs/jwt';
import { PassportModule } from '@nestjs/passport';
import { AuthService } from '../../services/auth.service';
import { EmailService } from '../../services/email.service';
import { UserService } from '../../services/user.service';
import { JwtStrategy } from '../../auth/jwt.strategy';
import { JwtAuthGuard } from '../../auth/jwt-auth.guard';
import { RolesGuard } from '../../auth/roles.guard';
import { MobileAuthController } from '../../controllers/mobile-auth.controller';
import { getJwtSecret } from '../../config/env.config';

@Global()
@Module({
  imports: [
    PassportModule,
    JwtModule.register({
      secret: getJwtSecret(),
      signOptions: { expiresIn: '24h' },
    }),
  ],
  controllers: [MobileAuthController],
  providers: [AuthService, EmailService, UserService, JwtStrategy, JwtAuthGuard, RolesGuard],
  exports: [AuthService, EmailService, UserService, JwtModule, PassportModule, JwtStrategy, JwtAuthGuard, RolesGuard],
})
export class AuthModule {}
