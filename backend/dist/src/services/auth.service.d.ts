import { JwtService } from '@nestjs/jwt';
import { PrismaService } from './prisma.service';
export declare class AuthService {
    private prisma;
    private jwtService;
    constructor(prisma: PrismaService, jwtService: JwtService);
    validateUser(email: string, password: string): Promise<any>;
    login(email: string, password: string): Promise<{
        access_token: string;
        user: any;
    }>;
    signup(email: string, password: string, firstName: string, lastName: string): Promise<{
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
    checkEmail(email: string): Promise<{
        exists: boolean;
        valid: boolean;
    }>;
    validateToken(token: string): Promise<any>;
}
