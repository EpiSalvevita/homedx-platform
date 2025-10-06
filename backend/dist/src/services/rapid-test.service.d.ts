import { PrismaService } from './prisma.service';
import { CreateRapidTestInput, UpdateRapidTestInput } from '../graphql/types/rapid-test.input';
export declare class RapidTestService {
    private prisma;
    constructor(prisma: PrismaService);
    private readonly includeRelations;
    private mapTestStatus;
    private mapTestResult;
    private mapRapidTestToGraphQL;
    findAll(): Promise<any[]>;
    findOne(id: string): Promise<any>;
    findByUserId(userId: string): Promise<any[]>;
    create(data: CreateRapidTestInput): Promise<any>;
    update(id: string, data: UpdateRapidTestInput): Promise<any>;
    remove(id: string): Promise<any>;
}
