import { User } from './user.type';
export declare class LoginInput {
    email: string;
    password: string;
}
export declare class SignupInput {
    email: string;
    password: string;
    firstName: string;
    lastName: string;
}
export declare class CheckEmailInput {
    email: string;
}
export declare class CheckEmailResponse {
    exists: boolean;
    valid: boolean;
}
export declare class AuthResponse {
    access_token: string;
    user: User;
}
