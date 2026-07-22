import { Global, Module } from '@nestjs/common';
import { JwtModule } from '@nestjs/jwt';
import { PassportModule } from '@nestjs/passport';
import { AuthService } from '../../services/auth.service';
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
  providers: [AuthService, UserService, JwtStrategy, JwtAuthGuard, RolesGuard],
  exports: [AuthService, UserService, JwtModule, PassportModule, JwtStrategy, JwtAuthGuard, RolesGuard],
})
export class AuthModule {}
