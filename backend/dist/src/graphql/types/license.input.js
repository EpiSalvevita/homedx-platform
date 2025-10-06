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
exports.UpdateLicenseInput = exports.CreateLicenseInput = void 0;
const graphql_1 = require("@nestjs/graphql");
const license_type_1 = require("./license.type");
let CreateLicenseInput = class CreateLicenseInput {
};
exports.CreateLicenseInput = CreateLicenseInput;
__decorate([
    (0, graphql_1.Field)(),
    __metadata("design:type", String)
], CreateLicenseInput.prototype, "userId", void 0);
__decorate([
    (0, graphql_1.Field)(() => graphql_1.Int),
    __metadata("design:type", Number)
], CreateLicenseInput.prototype, "maxUses", void 0);
__decorate([
    (0, graphql_1.Field)({ nullable: true }),
    __metadata("design:type", Date)
], CreateLicenseInput.prototype, "expiresAt", void 0);
__decorate([
    (0, graphql_1.Field)(),
    __metadata("design:type", String)
], CreateLicenseInput.prototype, "licenseKey", void 0);
__decorate([
    (0, graphql_1.Field)(() => license_type_1.LicenseStatus),
    __metadata("design:type", String)
], CreateLicenseInput.prototype, "status", void 0);
__decorate([
    (0, graphql_1.Field)({ nullable: true }),
    __metadata("design:type", String)
], CreateLicenseInput.prototype, "description", void 0);
exports.CreateLicenseInput = CreateLicenseInput = __decorate([
    (0, graphql_1.InputType)()
], CreateLicenseInput);
let UpdateLicenseInput = class UpdateLicenseInput {
};
exports.UpdateLicenseInput = UpdateLicenseInput;
__decorate([
    (0, graphql_1.Field)(() => graphql_1.Int, { nullable: true }),
    __metadata("design:type", Number)
], UpdateLicenseInput.prototype, "maxUses", void 0);
__decorate([
    (0, graphql_1.Field)({ nullable: true }),
    __metadata("design:type", Date)
], UpdateLicenseInput.prototype, "expiresAt", void 0);
__decorate([
    (0, graphql_1.Field)(() => license_type_1.LicenseStatus, { nullable: true }),
    __metadata("design:type", String)
], UpdateLicenseInput.prototype, "status", void 0);
__decorate([
    (0, graphql_1.Field)({ nullable: true }),
    __metadata("design:type", Date)
], UpdateLicenseInput.prototype, "revokedAt", void 0);
__decorate([
    (0, graphql_1.Field)({ nullable: true }),
    __metadata("design:type", String)
], UpdateLicenseInput.prototype, "revokedReason", void 0);
__decorate([
    (0, graphql_1.Field)({ nullable: true }),
    __metadata("design:type", String)
], UpdateLicenseInput.prototype, "description", void 0);
exports.UpdateLicenseInput = UpdateLicenseInput = __decorate([
    (0, graphql_1.InputType)()
], UpdateLicenseInput);
//# sourceMappingURL=license.input.js.map