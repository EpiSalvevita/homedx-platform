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
exports.CertificateResolver = void 0;
const graphql_1 = require("@nestjs/graphql");
const certificate_types_1 = require("../types/certificate.types");
const certificate_input_1 = require("../types/certificate.input");
const certificate_types_2 = require("../types/certificate.types");
const certificate_service_1 = require("../../services/certificate.service");
let CertificateResolver = class CertificateResolver {
    constructor(certificateService) {
        this.certificateService = certificateService;
    }
    async certificates() {
        return this.certificateService.findAll();
    }
    async certificate(testId) {
        return this.certificateService.findByRapidTestId(testId);
    }
    async certificateByNumber(certificateNumber) {
        return this.certificateService.findByCertificateNumber(certificateNumber);
    }
    async userCertificates(userId) {
        return this.certificateService.findByUserId(userId);
    }
    async validCertificates(userId) {
        return this.certificateService.findValidByUserId(userId);
    }
    async createCertificate(input) {
        return this.certificateService.create(input);
    }
    async updateCertificate(id, input) {
        return this.certificateService.update(id, input);
    }
    async removeCertificate(id) {
        return this.certificateService.remove(id);
    }
    async issueCertificate(id) {
        return this.certificateService.issue(id);
    }
    async revokeCertificate(id, reason) {
        return this.certificateService.revoke(id, reason);
    }
    async generateCertificateQR(id) {
        return this.certificateService.generateQRCode(id);
    }
    async generateCertificatePDF(id) {
        return this.certificateService.generatePDF(id);
    }
    async updateCertificateLanguage(testId, language) {
        try {
            const certificate = await this.certificateService.findByRapidTestId(testId);
            if (!certificate) {
                return {
                    success: false,
                    message: 'Certificate not found'
                };
            }
            const updatedCertificate = await this.certificateService.update(certificate.id, {
                language: language
            });
            const pdfUrl = await this.certificateService.generatePDF(updatedCertificate.id);
            return {
                success: true,
                certificate: {
                    id: updatedCertificate.id,
                    pdf: {
                        url: pdfUrl,
                        language: language
                    }
                }
            };
        }
        catch (error) {
            return {
                success: false,
                message: 'Failed to update certificate language'
            };
        }
    }
    async downloadCertificatePdf() {
        try {
            const mockPdf = 'data:application/pdf;base64,JVBERi0xLjQKJcOkw7zDtsO...';
            return {
                success: true,
                pdf: mockPdf
            };
        }
        catch (error) {
            return {
                success: false,
                message: 'Failed to download certificate PDF'
            };
        }
    }
};
exports.CertificateResolver = CertificateResolver;
__decorate([
    (0, graphql_1.Query)(() => [certificate_types_1.Certificate]),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", []),
    __metadata("design:returntype", Promise)
], CertificateResolver.prototype, "certificates", null);
__decorate([
    (0, graphql_1.Query)(() => certificate_types_1.Certificate, { nullable: true }),
    __param(0, (0, graphql_1.Args)('testId')),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String]),
    __metadata("design:returntype", Promise)
], CertificateResolver.prototype, "certificate", null);
__decorate([
    (0, graphql_1.Query)(() => certificate_types_1.Certificate, { nullable: true }),
    __param(0, (0, graphql_1.Args)('certificateNumber')),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String]),
    __metadata("design:returntype", Promise)
], CertificateResolver.prototype, "certificateByNumber", null);
__decorate([
    (0, graphql_1.Query)(() => [certificate_types_1.Certificate]),
    __param(0, (0, graphql_1.Args)('userId')),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String]),
    __metadata("design:returntype", Promise)
], CertificateResolver.prototype, "userCertificates", null);
__decorate([
    (0, graphql_1.Query)(() => [certificate_types_1.Certificate]),
    __param(0, (0, graphql_1.Args)('userId')),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String]),
    __metadata("design:returntype", Promise)
], CertificateResolver.prototype, "validCertificates", null);
__decorate([
    (0, graphql_1.Mutation)(() => certificate_types_1.Certificate),
    __param(0, (0, graphql_1.Args)('input')),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [certificate_input_1.CreateCertificateInput]),
    __metadata("design:returntype", Promise)
], CertificateResolver.prototype, "createCertificate", null);
__decorate([
    (0, graphql_1.Mutation)(() => certificate_types_1.Certificate),
    __param(0, (0, graphql_1.Args)('id')),
    __param(1, (0, graphql_1.Args)('input')),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String, certificate_input_1.UpdateCertificateInput]),
    __metadata("design:returntype", Promise)
], CertificateResolver.prototype, "updateCertificate", null);
__decorate([
    (0, graphql_1.Mutation)(() => certificate_types_1.Certificate),
    __param(0, (0, graphql_1.Args)('id')),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String]),
    __metadata("design:returntype", Promise)
], CertificateResolver.prototype, "removeCertificate", null);
__decorate([
    (0, graphql_1.Mutation)(() => certificate_types_1.Certificate),
    __param(0, (0, graphql_1.Args)('id')),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String]),
    __metadata("design:returntype", Promise)
], CertificateResolver.prototype, "issueCertificate", null);
__decorate([
    (0, graphql_1.Mutation)(() => certificate_types_1.Certificate),
    __param(0, (0, graphql_1.Args)('id')),
    __param(1, (0, graphql_1.Args)('reason')),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String, String]),
    __metadata("design:returntype", Promise)
], CertificateResolver.prototype, "revokeCertificate", null);
__decorate([
    (0, graphql_1.Mutation)(() => String),
    __param(0, (0, graphql_1.Args)('id')),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String]),
    __metadata("design:returntype", Promise)
], CertificateResolver.prototype, "generateCertificateQR", null);
__decorate([
    (0, graphql_1.Mutation)(() => String),
    __param(0, (0, graphql_1.Args)('id')),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String]),
    __metadata("design:returntype", Promise)
], CertificateResolver.prototype, "generateCertificatePDF", null);
__decorate([
    (0, graphql_1.Mutation)(() => certificate_types_2.UpdateCertificateLanguageResponse),
    __param(0, (0, graphql_1.Args)('testId')),
    __param(1, (0, graphql_1.Args)('language')),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String, String]),
    __metadata("design:returntype", Promise)
], CertificateResolver.prototype, "updateCertificateLanguage", null);
__decorate([
    (0, graphql_1.Mutation)(() => certificate_types_2.DownloadCertificatePdfResponse),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", []),
    __metadata("design:returntype", Promise)
], CertificateResolver.prototype, "downloadCertificatePdf", null);
exports.CertificateResolver = CertificateResolver = __decorate([
    (0, graphql_1.Resolver)(() => certificate_types_1.Certificate),
    __metadata("design:paramtypes", [certificate_service_1.CertificateService])
], CertificateResolver);
//# sourceMappingURL=certificate.resolver.js.map