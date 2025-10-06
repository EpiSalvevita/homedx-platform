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
exports.LicenseResolver = void 0;
const graphql_1 = require("@nestjs/graphql");
const license_type_1 = require("../types/license.type");
const license_types_1 = require("../types/license.types");
const license_service_1 = require("../../services/license.service");
let LicenseResolver = class LicenseResolver {
    constructor(licenseService) {
        this.licenseService = licenseService;
    }
    async licenses() {
        return this.licenseService.findAll();
    }
    async license(id) {
        return this.licenseService.findOne(id);
    }
    async userLicenses(userId) {
        return this.licenseService.findByUserId(userId);
    }
    async createLicense(userId, licenseKey, status, maxUses) {
        console.log('Resolver received individual args:', { userId, licenseKey, status, maxUses });
        const input = { userId, licenseKey, status, maxUses };
        return this.licenseService.create(input);
    }
    async updateLicense(id, maxUses, status) {
        console.log('Update resolver received:', { id, maxUses, status });
        const input = { maxUses, status };
        return this.licenseService.update(id, input);
    }
    async removeLicense(id) {
        return this.licenseService.remove(id);
    }
    async incrementLicenseUses(id) {
        return this.licenseService.incrementUsesCount(id);
    }
    async activateLicense(code) {
        try {
            const license = await this.licenseService.findByLicenseKey(code);
            if (!license) {
                return {
                    success: false,
                    message: 'License not found'
                };
            }
            if (license.status !== 'ACTIVE') {
                return {
                    success: false,
                    message: 'License is not active'
                };
            }
            if (license.usesCount >= license.maxUses) {
                return {
                    success: false,
                    message: 'License usage limit exceeded'
                };
            }
            const updatedLicense = await this.licenseService.incrementUsesCount(license.id);
            return {
                success: true,
                license: updatedLicense
            };
        }
        catch (error) {
            return {
                success: false,
                message: 'Failed to activate license'
            };
        }
    }
    async assignCoupon(licenseCode) {
        try {
            const license = await this.licenseService.findByLicenseKey(licenseCode);
            if (!license) {
                return {
                    success: false,
                    message: 'License not found'
                };
            }
            if (license.status !== 'ACTIVE') {
                return {
                    success: false,
                    message: 'License is not active'
                };
            }
            return {
                success: true,
                licenseCode: license.licenseKey
            };
        }
        catch (error) {
            return {
                success: false,
                message: 'Failed to assign coupon'
            };
        }
    }
};
exports.LicenseResolver = LicenseResolver;
__decorate([
    (0, graphql_1.Query)(() => [license_type_1.License]),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", []),
    __metadata("design:returntype", Promise)
], LicenseResolver.prototype, "licenses", null);
__decorate([
    (0, graphql_1.Query)(() => license_type_1.License, { nullable: true }),
    __param(0, (0, graphql_1.Args)('id')),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String]),
    __metadata("design:returntype", Promise)
], LicenseResolver.prototype, "license", null);
__decorate([
    (0, graphql_1.Query)(() => [license_type_1.License]),
    __param(0, (0, graphql_1.Args)('userId')),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String]),
    __metadata("design:returntype", Promise)
], LicenseResolver.prototype, "userLicenses", null);
__decorate([
    (0, graphql_1.Mutation)(() => license_type_1.License),
    __param(0, (0, graphql_1.Args)('userId')),
    __param(1, (0, graphql_1.Args)('licenseKey')),
    __param(2, (0, graphql_1.Args)('status')),
    __param(3, (0, graphql_1.Args)('maxUses')),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String, String, String, Number]),
    __metadata("design:returntype", Promise)
], LicenseResolver.prototype, "createLicense", null);
__decorate([
    (0, graphql_1.Mutation)(() => license_type_1.License),
    __param(0, (0, graphql_1.Args)('id')),
    __param(1, (0, graphql_1.Args)('maxUses', { nullable: true })),
    __param(2, (0, graphql_1.Args)('status', { nullable: true })),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String, Number, String]),
    __metadata("design:returntype", Promise)
], LicenseResolver.prototype, "updateLicense", null);
__decorate([
    (0, graphql_1.Mutation)(() => license_type_1.License),
    __param(0, (0, graphql_1.Args)('id')),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String]),
    __metadata("design:returntype", Promise)
], LicenseResolver.prototype, "removeLicense", null);
__decorate([
    (0, graphql_1.Mutation)(() => license_type_1.License),
    __param(0, (0, graphql_1.Args)('id')),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String]),
    __metadata("design:returntype", Promise)
], LicenseResolver.prototype, "incrementLicenseUses", null);
__decorate([
    (0, graphql_1.Mutation)(() => license_types_1.ActivateLicenseResponse),
    __param(0, (0, graphql_1.Args)('code')),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String]),
    __metadata("design:returntype", Promise)
], LicenseResolver.prototype, "activateLicense", null);
__decorate([
    (0, graphql_1.Mutation)(() => license_types_1.AssignCouponResponse),
    __param(0, (0, graphql_1.Args)('licenseCode')),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String]),
    __metadata("design:returntype", Promise)
], LicenseResolver.prototype, "assignCoupon", null);
exports.LicenseResolver = LicenseResolver = __decorate([
    (0, graphql_1.Resolver)(() => license_type_1.License),
    __metadata("design:paramtypes", [license_service_1.LicenseService])
], LicenseResolver);
//# sourceMappingURL=license.resolver.js.map