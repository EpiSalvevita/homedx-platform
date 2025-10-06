import { TestKit } from '../types/test-kit.types';
import { CreateTestKitInput, UpdateTestKitInput } from '../types/test-kit.input';
import { TestKitService } from '../../services/test-kit.service';
export declare class TestKitResolver {
    private readonly testKitService;
    constructor(testKitService: TestKitService);
    testKits(): Promise<TestKit[]>;
    testKit(id: string): Promise<TestKit | null>;
    testKitBySerialNumber(serialNumber: string): Promise<TestKit | null>;
    availableTestKits(): Promise<TestKit[]>;
    userTestKits(userId: string): Promise<TestKit[]>;
    createTestKit(input: CreateTestKitInput): Promise<TestKit>;
    updateTestKit(id: string, input: UpdateTestKitInput): Promise<TestKit>;
    removeTestKit(id: string): Promise<TestKit>;
    assignTestKitToUser(id: string, userId: string): Promise<TestKit>;
    markTestKitAsUsed(id: string): Promise<TestKit>;
}
