export declare enum LegalPageType {
    PRIVACY_POLICY = "PRIVACY_POLICY",
    TERMS_CONDITIONS = "TERMS_CONDITIONS",
    IMPRESSUM = "IMPRESSUM",
    COOKIE_POLICY = "COOKIE_POLICY"
}
export declare class LegalPage {
    id: string;
    type: LegalPageType;
    title: string;
    content: string;
    language: string;
    version: string;
    isActive: boolean;
    createdAt: Date;
    updatedAt: Date;
}
export declare class LegalPageResponse {
    pages: LegalPage[];
    total: number;
}
