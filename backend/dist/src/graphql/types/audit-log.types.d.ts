import { User } from './user.type';
export declare enum AuditAction {
    CREATE = "CREATE",
    UPDATE = "UPDATE",
    DELETE = "DELETE",
    LOGIN = "LOGIN",
    LOGOUT = "LOGOUT",
    VIEW = "VIEW",
    EXPORT = "EXPORT"
}
export declare enum AuditEntityType {
    USER = "USER",
    RAPID_TEST = "RAPID_TEST",
    TEST_KIT = "TEST_KIT",
    PAYMENT = "PAYMENT",
    CERTIFICATE = "CERTIFICATE",
    LICENSE = "LICENSE"
}
export declare class AuditLog {
    id: string;
    userId: string;
    action: AuditAction;
    entityType: AuditEntityType;
    entityId?: string;
    oldValues?: string;
    newValues?: string;
    ipAddress?: string;
    userAgent?: string;
    description?: string;
    createdAt: Date;
    user: User;
}
