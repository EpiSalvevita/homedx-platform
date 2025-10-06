import { LegalPageType } from './legal-page.types';
export declare class GetLegalPageInput {
    type: LegalPageType;
    language?: string;
}
export declare class GetLegalPagesInput {
    types?: LegalPageType[];
    language?: string;
    activeOnly?: boolean;
}
