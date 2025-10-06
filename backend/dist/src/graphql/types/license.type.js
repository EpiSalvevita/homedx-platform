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
exports.License = exports.LicenseStatus = void 0;
const graphql_1 = require("@nestjs/graphql");
const user_type_1 = require("./user.type");
var LicenseStatus;
(function (LicenseStatus) {
    LicenseStatus["ACTIVE"] = "ACTIVE";
    LicenseStatus["EXPIRED"] = "EXPIRED";
    LicenseStatus["REVOKED"] = "REVOKED";
})(LicenseStatus || (exports.LicenseStatus = LicenseStatus = {}));
(0, graphql_1.registerEnumType)(LicenseStatus, {
    name: 'LicenseStatus',
    description: 'License status enumeration',
});
let License = class License {
};
exports.License = License;
__decorate([
    (0, graphql_1.Field)(),
    __metadata("design:type", String)
], License.prototype, "id", void 0);
__decorate([
    (0, graphql_1.Field)(),
    __metadata("design:type", String)
], License.prototype, "userId", void 0);
__decorate([
    (0, graphql_1.Field)(() => graphql_1.Int),
    __metadata("design:type", Number)
], License.prototype, "maxUses", void 0);
__decorate([
    (0, graphql_1.Field)(() => graphql_1.Int),
    __metadata("design:type", Number)
], License.prototype, "usesCount", void 0);
__decorate([
    (0, graphql_1.Field)({ nullable: true }),
    __metadata("design:type", Date)
], License.prototype, "expiresAt", void 0);
__decorate([
    (0, graphql_1.Field)(),
    __metadata("design:type", Date)
], License.prototype, "createdAt", void 0);
__decorate([
    (0, graphql_1.Field)(),
    __metadata("design:type", Date)
], License.prototype, "updatedAt", void 0);
__decorate([
    (0, graphql_1.Field)(),
    __metadata("design:type", String)
], License.prototype, "licenseKey", void 0);
__decorate([
    (0, graphql_1.Field)({ nullable: true }),
    __metadata("design:type", Date)
], License.prototype, "revokedAt", void 0);
__decorate([
    (0, graphql_1.Field)({ nullable: true }),
    __metadata("design:type", String)
], License.prototype, "revokedReason", void 0);
__decorate([
    (0, graphql_1.Field)(() => LicenseStatus),
    __metadata("design:type", String)
], License.prototype, "status", void 0);
__decorate([
    (0, graphql_1.Field)({ nullable: true }),
    __metadata("design:type", String)
], License.prototype, "description", void 0);
__decorate([
    (0, graphql_1.Field)(() => user_type_1.User, { nullable: true }),
    __metadata("design:type", user_type_1.User)
], License.prototype, "user", void 0);
exports.License = License = __decorate([
    (0, graphql_1.ObjectType)()
], License);
//# sourceMappingURL=license.type.js.map