import { User } from './user.type';
export declare enum TestKitType {
    COVID_19 = "COVID_19",
    FLU = "FLU",
    STREP_THROAT = "STREP_THROAT",
    PREGNANCY = "PREGNANCY",
    DRUG_TEST = "DRUG_TEST"
}
export declare enum TestKitStatus {
    AVAILABLE = "AVAILABLE",
    USED = "USED",
    EXPIRED = "EXPIRED",
    DAMAGED = "DAMAGED"
}
export declare class TestKit {
    id: string;
    serialNumber: string;
    type: TestKitType;
    manufacturer: string;
    model: string;
    batchNumber: string;
    expirationDate: Date;
    status: TestKitStatus;
    userId?: string;
    purchasedAt?: Date;
    usedAt?: Date;
    createdAt: Date;
    updatedAt: Date;
    user?: User;
}
