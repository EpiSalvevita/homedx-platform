import { AuthService } from '../../services/auth.service';
import { LoginInput, SignupInput } from '../types/auth.types';
import { SystemResponse } from '../types/system.types';
import { User } from '../types/user.type';
export declare class AuthResolver {
    private authService;
    constructor(authService: AuthService);
    me(user: User): Promise<User>;
    login(input: LoginInput): Promise<{
        access_token: string;
        user: any;
    }>;
    signup(input: SignupInput): Promise<{
        access_token: string;
        user: {
            id: string;
            email: string;
            firstName: string;
            lastName: string;
            dateOfBirth: Date | null;
            city: string | null;
            country: string | null;
            phone: string | null;
            createdAt: Date;
            updatedAt: Date;
            address: string | null;
            emailVerified: boolean;
            lastLoginAt: Date | null;
            postalCode: string | null;
            role: import(".prisma/client").$Enums.UserRole;
            status: import(".prisma/client").$Enums.UserStatus;
        };
    }>;
    testMutation(): Promise<string>;
    checkEmail(email: string): Promise<{
        exists: boolean;
        valid: boolean;
    }>;
    setLanguage(language: string): Promise<SystemResponse>;
}
