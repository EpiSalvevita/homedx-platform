import { Resolver, Mutation, Args, Query } from '@nestjs/graphql';
import { UseGuards } from '@nestjs/common';
import { AuthService } from '../../services/auth.service';
import { LoginInput, SignupInput, AuthResponse, CheckEmailInput, CheckEmailResponse } from '../types/auth.types';
import { SystemResponse } from '../types/system.types';
import { User } from '../types/user.type';
import { CurrentUser } from '../../auth/current-user.decorator';
import { JwtAuthGuard } from '../../auth/jwt-auth.guard';

@Resolver()
export class AuthResolver {
  constructor(private authService: AuthService) {}

  @Query(() => User)
  @UseGuards(JwtAuthGuard)
  async me(@CurrentUser() user: User) {
    return user;
  }

  @Mutation(() => AuthResponse)
  async login(@Args('input') input: LoginInput) {
    return this.authService.login(input.email, input.password);
  }

  @Mutation(() => AuthResponse)
  async signup(@Args('input') input: SignupInput) {
    return this.authService.signup(
      input.email,
      input.password,
      input.firstName,
      input.lastName,
    );
  }

  @Mutation(() => String)
  async testMutation() {
    return 'test';
  }

  @Mutation(() => CheckEmailResponse)
  async checkEmail(@Args('email') email: string) {
    return this.authService.checkEmail(email);
  }

  @Mutation(() => SystemResponse)
  async setLanguage(@Args('language') language: string): Promise<SystemResponse> {
    // This would typically update the user's language preference
    // For now, return success
    return {
      success: true,
      message: `Language set to ${language}`
    };
  }
} 