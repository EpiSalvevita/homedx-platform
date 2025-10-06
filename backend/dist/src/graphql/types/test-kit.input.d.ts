import { TestKitType, TestKitStatus } from './test-kit.types';
export declare class CreateTestKitInput {
    serialNumber: string;
    type: TestKitType;
    manufacturer: string;
    model: string;
    batchNumber: string;
    expirationDate: Date;
    status?: TestKitStatus;
    userId?: string;
}
export declare class UpdateTestKitInput {
    serialNumber?: string;
    type?: TestKitType;
    manufacturer?: string;
    model?: string;
    batchNumber?: string;
    expirationDate?: Date;
    status?: TestKitStatus;
    userId?: string;
}
