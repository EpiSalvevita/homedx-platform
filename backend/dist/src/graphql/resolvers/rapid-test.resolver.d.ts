import { RapidTest, SubmitTestResponse } from '../types/rapid-test.type';
import { CreateRapidTestInput, UpdateRapidTestInput } from '../types/rapid-test.input';
import { RapidTestService } from '../../services/rapid-test.service';
import { PrismaService } from '../../services/prisma.service';
import { User } from '../types/user.type';
export declare class RapidTestResolver {
    private readonly rapidTestService;
    private readonly prisma;
    constructor(rapidTestService: RapidTestService, prisma: PrismaService);
    rapidTests(): Promise<RapidTest[]>;
    rapidTest(id: string): Promise<RapidTest | null>;
    userRapidTests(userId: string): Promise<RapidTest[]>;
    lastRapidTest(user: User): Promise<RapidTest | null>;
    testStatus(user: User): Promise<string>;
    liveToken(): Promise<string>;
    cwaLink(rapidTestId: string): Promise<string>;
    submitTest(videoUrl: string, photoUrl: string, testDeviceUrl: string, testDate: number, liveToken: string, agreementGiven?: boolean, paymentId?: string, licenseCode?: string, identityCard1Url?: string, identityCard2Url?: string, identifyUrl?: string, identityCardId?: string): Promise<SubmitTestResponse>;
    createRapidTest(input: CreateRapidTestInput): Promise<RapidTest>;
    updateRapidTest(id: string, input: UpdateRapidTestInput): Promise<RapidTest>;
    removeRapidTest(id: string): Promise<RapidTest>;
}
