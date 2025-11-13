import { PrismaService } from './prisma.service';
import { LegalPageType } from '../graphql/types/legal-page.types';
export declare class LegalPageService {
    private prisma;
    constructor(prisma: PrismaService);
    getLegalPage(type: LegalPageType, language?: string): Promise<{
        title: string;
        id: string;
        createdAt: Date;
        updatedAt: Date;
        type: import(".prisma/client").$Enums.LegalPageType;
        version: string;
        language: string;
        content: string;
        isActive: boolean;
    }>;
    getLegalPages(types?: LegalPageType[], language?: string, activeOnly?: boolean): Promise<{
        pages: {
            title: string;
            id: string;
            createdAt: Date;
            updatedAt: Date;
            type: import(".prisma/client").$Enums.LegalPageType;
            version: string;
            language: string;
            content: string;
            isActive: boolean;
        }[];
        total: number;
    }>;
    getAllLegalPageTypes(language?: string): Promise<{
        title: string;
        type: import(".prisma/client").$Enums.LegalPageType;
    }[]>;
}
