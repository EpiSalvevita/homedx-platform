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
Object.defineProperty(exports, "__esModule", { value: true });
exports.DownloadCertificatePdfResponse = exports.UpdateCertificateLanguageResponse = exports.CertificateWithPdf = exports.CertificatePdf = exports.Certificate = exports.CertificateStatus = exports.CertificateType = void 0;
const graphql_1 = require("@nestjs/graphql");
const user_type_1 = require("./user.type");
const rapid_test_type_1 = require("./rapid-test.type");
var CertificateType;
(function (CertificateType) {
    CertificateType["TEST_RESULT"] = "TEST_RESULT";
    CertificateType["VACCINATION"] = "VACCINATION";
    CertificateType["RECOVERY"] = "RECOVERY";
    CertificateType["MEDICAL_CLEARANCE"] = "MEDICAL_CLEARANCE";
})(CertificateType || (exports.CertificateType = CertificateType = {}));
var CertificateStatus;
(function (CertificateStatus) {
    CertificateStatus["DRAFT"] = "DRAFT";
    CertificateStatus["ISSUED"] = "ISSUED";
    CertificateStatus["EXPIRED"] = "EXPIRED";
    CertificateStatus["REVOKED"] = "REVOKED";
})(CertificateStatus || (exports.CertificateStatus = CertificateStatus = {}));
(0, graphql_1.registerEnumType)(CertificateType, {
    name: 'CertificateType',
    description: 'Certificate type enumeration',
});
(0, graphql_1.registerEnumType)(CertificateStatus, {
    name: 'CertificateStatus',
    description: 'Certificate status enumeration',
});
let Certificate = class Certificate {
};
exports.Certificate = Certificate;
__decorate([
    (0, graphql_1.Field)(),
    __metadata("design:type", String)
], Certificate.prototype, "id", void 0);
__decorate([
    (0, graphql_1.Field)(),
    __metadata("design:type", String)
], Certificate.prototype, "userId", void 0);
__decorate([
    (0, graphql_1.Field)(),
    __metadata("design:type", String)
], Certificate.prototype, "rapidTestId", void 0);
__decorate([
    (0, graphql_1.Field)(() => CertificateType),
    __metadata("design:type", String)
], Certificate.prototype, "type", void 0);
__decorate([
    (0, graphql_1.Field)(() => CertificateStatus),
    __metadata("design:type", String)
], Certificate.prototype, "status", void 0);
__decorate([
    (0, graphql_1.Field)(),
    __metadata("design:type", String)
], Certificate.prototype, "certificateNumber", void 0);
__decorate([
    (0, graphql_1.Field)(),
    __metadata("design:type", Date)
], Certificate.prototype, "issuedAt", void 0);
__decorate([
    (0, graphql_1.Field)(),
    __metadata("design:type", Date)
], Certificate.prototype, "validFrom", void 0);
__decorate([
    (0, graphql_1.Field)(),
    __metadata("design:type", Date)
], Certificate.prototype, "validUntil", void 0);
__decorate([
    (0, graphql_1.Field)({ nullable: true }),
    __metadata("design:type", String)
], Certificate.prototype, "qrCodeUrl", void 0);
__decorate([
    (0, graphql_1.Field)({ nullable: true }),
    __metadata("design:type", String)
], Certificate.prototype, "pdfUrl", void 0);
__decorate([
    (0, graphql_1.Field)({ nullable: true }),
    __metadata("design:type", Date)
], Certificate.prototype, "revokedAt", void 0);
__decorate([
    (0, graphql_1.Field)({ nullable: true }),
    __metadata("design:type", String)
], Certificate.prototype, "revokedReason", void 0);
__decorate([
    (0, graphql_1.Field)(),
    __metadata("design:type", Date)
], Certificate.prototype, "createdAt", void 0);
__decorate([
    (0, graphql_1.Field)(),
    __metadata("design:type", Date)
], Certificate.prototype, "updatedAt", void 0);
__decorate([
    (0, graphql_1.Field)(() => user_type_1.User),
    __metadata("design:type", user_type_1.User)
], Certificate.prototype, "user", void 0);
__decorate([
    (0, graphql_1.Field)(() => rapid_test_type_1.RapidTest),
    __metadata("design:type", rapid_test_type_1.RapidTest)
], Certificate.prototype, "rapidTest", void 0);
exports.Certificate = Certificate = __decorate([
    (0, graphql_1.ObjectType)()
], Certificate);
let CertificatePdf = class CertificatePdf {
};
exports.CertificatePdf = CertificatePdf;
__decorate([
    (0, graphql_1.Field)(),
    __metadata("design:type", String)
], CertificatePdf.prototype, "url", void 0);
__decorate([
    (0, graphql_1.Field)(),
    __metadata("design:type", String)
], CertificatePdf.prototype, "language", void 0);
exports.CertificatePdf = CertificatePdf = __decorate([
    (0, graphql_1.ObjectType)()
], CertificatePdf);
let CertificateWithPdf = class CertificateWithPdf {
};
exports.CertificateWithPdf = CertificateWithPdf;
__decorate([
    (0, graphql_1.Field)(),
    __metadata("design:type", String)
], CertificateWithPdf.prototype, "id", void 0);
__decorate([
    (0, graphql_1.Field)(() => CertificatePdf, { nullable: true }),
    __metadata("design:type", CertificatePdf)
], CertificateWithPdf.prototype, "pdf", void 0);
exports.CertificateWithPdf = CertificateWithPdf = __decorate([
    (0, graphql_1.ObjectType)()
], CertificateWithPdf);
let UpdateCertificateLanguageResponse = class UpdateCertificateLanguageResponse {
};
exports.UpdateCertificateLanguageResponse = UpdateCertificateLanguageResponse;
__decorate([
    (0, graphql_1.Field)(),
    __metadata("design:type", Boolean)
], UpdateCertificateLanguageResponse.prototype, "success", void 0);
__decorate([
    (0, graphql_1.Field)(() => CertificateWithPdf, { nullable: true }),
    __metadata("design:type", CertificateWithPdf)
], UpdateCertificateLanguageResponse.prototype, "certificate", void 0);
__decorate([
    (0, graphql_1.Field)({ nullable: true }),
    __metadata("design:type", String)
], UpdateCertificateLanguageResponse.prototype, "message", void 0);
exports.UpdateCertificateLanguageResponse = UpdateCertificateLanguageResponse = __decorate([
    (0, graphql_1.ObjectType)()
], UpdateCertificateLanguageResponse);
let DownloadCertificatePdfResponse = class DownloadCertificatePdfResponse {
};
exports.DownloadCertificatePdfResponse = DownloadCertificatePdfResponse;
__decorate([
    (0, graphql_1.Field)(),
    __metadata("design:type", Boolean)
], DownloadCertificatePdfResponse.prototype, "success", void 0);
__decorate([
    (0, graphql_1.Field)({ nullable: true }),
    __metadata("design:type", String)
], DownloadCertificatePdfResponse.prototype, "pdf", void 0);
__decorate([
    (0, graphql_1.Field)({ nullable: true }),
    __metadata("design:type", String)
], DownloadCertificatePdfResponse.prototype, "message", void 0);
exports.DownloadCertificatePdfResponse = DownloadCertificatePdfResponse = __decorate([
    (0, graphql_1.ObjectType)()
], DownloadCertificatePdfResponse);
//# sourceMappingURL=certificate.types.js.map