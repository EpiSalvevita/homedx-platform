export declare class User {
    id: string;
    email: string;
    firstName: string;
    lastName: string;
    phone?: string;
    dateOfBirth?: Date;
    address?: string;
    city?: string;
    postalCode?: string;
    country?: string;
    role: string;
    status: string;
    emailVerified: boolean;
    createdAt: Date;
    updatedAt: Date;
    lastLoginAt?: Date;
    profileImageUrl?: string;
}
