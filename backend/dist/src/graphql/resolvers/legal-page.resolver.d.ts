import { LegalPageService } from '../../services/legal-page.service';
import { LegalPage, LegalPageResponse } from '../types/legal-page.types';
import { GetLegalPageInput, GetLegalPagesInput } from '../types/legal-page.input';
export declare class LegalPageResolver {
    private legalPageService;
    constructor(legalPageService: LegalPageService);
    getLegalPage(input: GetLegalPageInput): Promise<LegalPage | null>;
    getLegalPages(input?: GetLegalPagesInput): Promise<LegalPageResponse>;
    getPrivacyPolicy(language: string): Promise<LegalPage | null>;
    getTermsAndConditions(language: string): Promise<LegalPage | null>;
    getImpressum(language: string): Promise<LegalPage | null>;
}
