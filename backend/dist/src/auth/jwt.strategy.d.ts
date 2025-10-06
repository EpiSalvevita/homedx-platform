import { Strategy } from 'passport-jwt';
import { PrismaService } from '../services/prisma.service';
declare const JwtStrategy_base: new (...args: [opt: import("passport-jwt").StrategyOptionsWithRequest] | [opt: import("passport-jwt").StrategyOptionsWithoutRequest]) => Strategy & {
    validate(...args: any[]): unknown;
};
export declare class JwtStrategy extends JwtStrategy_base {
    private prisma;
    constructor(prisma: PrismaService);
    validate(payload: any): Promise<{
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
    }>;
}
export {};
