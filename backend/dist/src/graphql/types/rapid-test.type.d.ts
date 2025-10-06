import { User } from './user.type';
import { TestKit } from './test-kit.types';
export declare enum TestResult {
    POSITIVE = "POSITIVE",
    NEGATIVE = "NEGATIVE",
    INVALID = "INVALID",
    INCONCLUSIVE = "INCONCLUSIVE"
}
export declare enum TestStatus {
    PENDING = "PENDING",
    IN_PROGRESS = "IN_PROGRESS",
    COMPLETED = "COMPLETED",
    FAILED = "FAILED"
}
export declare class RapidTest {
    id: string;
    userId: string;
    testKitId: string;
    testDate: Date;
    status: TestStatus;
    result?: TestResult;
    resultImageUrl?: string;
    notes?: string;
    createdAt: Date;
    updatedAt: Date;
    completedAt?: Date;
    user: User;
    testKit: TestKit;
}
export declare class SubmitTestResponse {
    success: boolean;
    validation?: string;
}
