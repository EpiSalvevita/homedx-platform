"use strict";
var __decorate = (this && this.__decorate) || function (decorators, target, key, desc) {
    var c = arguments.length, r = c < 3 ? target : desc === null ? desc = Object.getOwnPropertyDescriptor(target, key) : desc, d;
    if (typeof Reflect === "object" && typeof Reflect.decorate === "function") r = Reflect.decorate(decorators, target, key, desc);
    else for (var i = decorators.length - 1; i >= 0; i--) if (d = decorators[i]) r = (c < 3 ? d(r) : c > 3 ? d(target, key, r) : d(target, key)) || r;
    return c > 3 && r && Object.defineProperty(target, key, r), r;
};
var __metadata = (this && this.__metadata) || function (k, v) {
    if (typeof Reflect === "object" && typeof Reflect.metadata === "function") return Reflect.metadata(k, v);
};
var __param = (this && this.__param) || function (paramIndex, decorator) {
    return function (target, key) { decorator(target, key, paramIndex); }
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.LegalPageResolver = void 0;
const graphql_1 = require("@nestjs/graphql");
const legal_page_service_1 = require("../../services/legal-page.service");
const legal_page_types_1 = require("../types/legal-page.types");
const legal_page_input_1 = require("../types/legal-page.input");
let LegalPageResolver = class LegalPageResolver {
    constructor(legalPageService) {
        this.legalPageService = legalPageService;
    }
    async getLegalPage(input) {
        const result = await this.legalPageService.getLegalPage(input.type, input.language);
        return result;
    }
    async getLegalPages(input) {
        const { types, language, activeOnly } = input || {};
        const result = await this.legalPageService.getLegalPages(types, language, activeOnly);
        return {
            pages: result.pages,
            total: result.total,
        };
    }
    async getPrivacyPolicy(language) {
        const result = await this.legalPageService.getLegalPage(legal_page_types_1.LegalPageType.PRIVACY_POLICY, language);
        return result;
    }
    async getTermsAndConditions(language) {
        const result = await this.legalPageService.getLegalPage(legal_page_types_1.LegalPageType.TERMS_CONDITIONS, language);
        return result;
    }
    async getImpressum(language) {
        const result = await this.legalPageService.getLegalPage(legal_page_types_1.LegalPageType.IMPRESSUM, language);
        return result;
    }
};
exports.LegalPageResolver = LegalPageResolver;
__decorate([
    (0, graphql_1.Query)(() => legal_page_types_1.LegalPage, { nullable: true }),
    __param(0, (0, graphql_1.Args)('input')),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [legal_page_input_1.GetLegalPageInput]),
    __metadata("design:returntype", Promise)
], LegalPageResolver.prototype, "getLegalPage", null);
__decorate([
    (0, graphql_1.Query)(() => legal_page_types_1.LegalPageResponse),
    __param(0, (0, graphql_1.Args)('input', { nullable: true })),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [legal_page_input_1.GetLegalPagesInput]),
    __metadata("design:returntype", Promise)
], LegalPageResolver.prototype, "getLegalPages", null);
__decorate([
    (0, graphql_1.Query)(() => legal_page_types_1.LegalPage, { nullable: true }),
    __param(0, (0, graphql_1.Args)('language', { type: () => String, defaultValue: 'de' })),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String]),
    __metadata("design:returntype", Promise)
], LegalPageResolver.prototype, "getPrivacyPolicy", null);
__decorate([
    (0, graphql_1.Query)(() => legal_page_types_1.LegalPage, { nullable: true }),
    __param(0, (0, graphql_1.Args)('language', { type: () => String, defaultValue: 'de' })),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String]),
    __metadata("design:returntype", Promise)
], LegalPageResolver.prototype, "getTermsAndConditions", null);
__decorate([
    (0, graphql_1.Query)(() => legal_page_types_1.LegalPage, { nullable: true }),
    __param(0, (0, graphql_1.Args)('language', { type: () => String, defaultValue: 'de' })),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String]),
    __metadata("design:returntype", Promise)
], LegalPageResolver.prototype, "getImpressum", null);
exports.LegalPageResolver = LegalPageResolver = __decorate([
    (0, graphql_1.Resolver)(() => legal_page_types_1.LegalPage),
    __metadata("design:paramtypes", [legal_page_service_1.LegalPageService])
], LegalPageResolver);
//# sourceMappingURL=legal-page.resolver.js.map