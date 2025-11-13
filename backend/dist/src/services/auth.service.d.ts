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
            email: string;
            firstName: string;
            lastName: string;
            dateOfBirth: Date | null;
            city: string | null;
            country: string | null;
            phone: string | null;
            id: string;
            address: string | null;
            postalCode: string | null;
            role: import(".prisma/client").$Enums.UserRole;
            status: import(".prisma/client").$Enums.UserStatus;
            emailVerified: boolean;
            createdAt: Date;
            updatedAt: Date;
            lastLoginAt: Date | null;
        };
    }>;
    checkEmail(email: string): Promise<{
        exists: boolean;
        valid: boolean;
    }>;
    validateToken(token: string): Promise<any>;
}
