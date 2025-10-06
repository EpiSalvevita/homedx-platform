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
exports.UpdateCertificateInput = exports.CreateCertificateInput = void 0;
const graphql_1 = require("@nestjs/graphql");
const class_validator_1 = require("class-validator");
const certificate_types_1 = require("./certificate.types");
let CreateCertificateInput = class CreateCertificateInput {
};
exports.CreateCertificateInput = CreateCertificateInput;
__decorate([
    (0, graphql_1.Field)(),
    (0, class_validator_1.IsString)(),
    __metadata("design:type", String)
], CreateCertificateInput.prototype, "userId", void 0);
__decorate([
    (0, graphql_1.Field)(),
    (0, class_validator_1.IsString)(),
    __metadata("design:type", String)
], CreateCertificateInput.prototype, "rapidTestId", void 0);
__decorate([
    (0, graphql_1.Field)(() => certificate_types_1.CertificateType),
    (0, class_validator_1.IsEnum)(certificate_types_1.CertificateType),
    __metadata("design:type", String)
], CreateCertificateInput.prototype, "type", void 0);
__decorate([
    (0, graphql_1.Field)(() => certificate_types_1.CertificateStatus, { nullable: true }),
    (0, class_validator_1.IsOptional)(),
    (0, class_validator_1.IsEnum)(certificate_types_1.CertificateStatus),
    __metadata("design:type", String)
], CreateCertificateInput.prototype, "status", void 0);
__decorate([
    (0, graphql_1.Field)(),
    (0, class_validator_1.IsString)(),
    __metadata("design:type", String)
], CreateCertificateInput.prototype, "certificateNumber", void 0);
__decorate([
    (0, graphql_1.Field)(),
    (0, class_validator_1.IsDate)(),
    __metadata("design:type", Date)
], CreateCertificateInput.prototype, "issuedAt", void 0);
__decorate([
    (0, graphql_1.Field)(),
    (0, class_validator_1.IsDate)(),
    __metadata("design:type", Date)
], CreateCertificateInput.prototype, "validFrom", void 0);
__decorate([
    (0, graphql_1.Field)(),
    (0, class_validator_1.IsDate)(),
    __metadata("design:type", Date)
], CreateCertificateInput.prototype, "validUntil", void 0);
__decorate([
    (0, graphql_1.Field)({ nullable: true }),
    (0, class_validator_1.IsOptional)(),
    (0, class_validator_1.IsUrl)(),
    __metadata("design:type", String)
], CreateCertificateInput.prototype, "qrCodeUrl", void 0);
__decorate([
    (0, graphql_1.Field)({ nullable: true }),
    (0, class_validator_1.IsOptional)(),
    (0, class_validator_1.IsUrl)(),
    __metadata("design:type", String)
], CreateCertificateInput.prototype, "pdfUrl", void 0);
exports.CreateCertificateInput = CreateCertificateInput = __decorate([
    (0, graphql_1.InputType)()
], CreateCertificateInput);
let UpdateCertificateInput = class UpdateCertificateInput {
};
exports.UpdateCertificateInput = UpdateCertificateInput;
__decorate([
    (0, graphql_1.Field)(() => certificate_types_1.CertificateType, { nullable: true }),
    (0, class_validator_1.IsOptional)(),
    (0, class_validator_1.IsEnum)(certificate_types_1.CertificateType),
    __metadata("design:type", String)
], UpdateCertificateInput.prototype, "type", void 0);
__decorate([
    (0, graphql_1.Field)(() => certificate_types_1.CertificateStatus, { nullable: true }),
    (0, class_validator_1.IsOptional)(),
    (0, class_validator_1.IsEnum)(certificate_types_1.CertificateStatus),
    __metadata("design:type", String)
], UpdateCertificateInput.prototype, "status", void 0);
__decorate([
    (0, graphql_1.Field)({ nullable: true }),
    (0, class_validator_1.IsOptional)(),
    (0, class_validator_1.IsDate)(),
    __metadata("design:type", Date)
], UpdateCertificateInput.prototype, "issuedAt", void 0);
__decorate([
    (0, graphql_1.Field)({ nullable: true }),
    (0, class_validator_1.IsOptional)(),
    (0, class_validator_1.IsDate)(),
    __metadata("design:type", Date)
], UpdateCertificateInput.prototype, "validFrom", void 0);
__decorate([
    (0, graphql_1.Field)({ nullable: true }),
    (0, class_validator_1.IsOptional)(),
    (0, class_validator_1.IsDate)(),
    __metadata("design:type", Date)
], UpdateCertificateInput.prototype, "validUntil", void 0);
__decorate([
    (0, graphql_1.Field)({ nullable: true }),
    (0, class_validator_1.IsOptional)(),
    (0, class_validator_1.IsUrl)(),
    __metadata("design:type", String)
], UpdateCertificateInput.prototype, "qrCodeUrl", void 0);
__decorate([
    (0, graphql_1.Field)({ nullable: true }),
    (0, class_validator_1.IsOptional)(),
    (0, class_validator_1.IsUrl)(),
    __metadata("design:type", String)
], UpdateCertificateInput.prototype, "pdfUrl", void 0);
__decorate([
    (0, graphql_1.Field)({ nullable: true }),
    (0, class_validator_1.IsOptional)(),
    (0, class_validator_1.IsDate)(),
    __metadata("design:type", Date)
], UpdateCertificateInput.prototype, "revokedAt", void 0);
__decorate([
    (0, graphql_1.Field)({ nullable: true }),
    (0, class_validator_1.IsOptional)(),
    (0, class_validator_1.IsString)(),
    __metadata("design:type", String)
], UpdateCertificateInput.prototype, "revokedReason", void 0);
exports.UpdateCertificateInput = UpdateCertificateInput = __decorate([
    (0, graphql_1.InputType)()
], UpdateCertificateInput);
//# sourceMappingURL=certificate.input.js.map