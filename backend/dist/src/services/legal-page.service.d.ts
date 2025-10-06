import { PrismaService } from './prisma.service';
import { LegalPageType } from '../graphql/types/legal-page.types';
export declare class LegalPageService {
    private prisma;
    constructor(prisma: PrismaService);
    getLegalPage(type: LegalPageType, language?: string): Promise<{
        id: string;
        createdAt: Date;
        updatedAt: Date;
        language: string;
        type: import(".prisma/client").$Enums.LegalPageType;
        title: string;
        content: string;
        version: string;
        isActive: boolean;
    }>;
    getLegalPages(types?: LegalPageType[], language?: string, activeOnly?: boolean): Promise<{
        pages: {
            id: string;
            createdAt: Date;
            updatedAt: Date;
            language: string;
            type: import(".prisma/client").$Enums.LegalPageType;
            title: string;
            content: string;
            version: string;
            isActive: boolean;
        }[];
        total: number;
    }>;
    getAllLegalPageTypes(language?: string): Promise<{
        type: import(".prisma/client").$Enums.LegalPageType;
        title: string;
    }[]>;
}
