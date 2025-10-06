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
exports.SystemResolver = void 0;
const graphql_1 = require("@nestjs/graphql");
const system_types_1 = require("../types/system.types");
let SystemResolver = class SystemResolver {
    async backendStatus() {
        return {
            maintenance: false,
            version: '1.0.0',
            flags: [
                { key: 'feature_flags_enabled', value: 'true' },
                { key: 'maintenance_mode', value: 'false' },
                { key: 'payment_is_active', value: 'true' }
            ],
            paymentIsActive: true,
            stripe: true,
            cwa: false,
            cwaLaive: false,
            certificatePdf: true
        };
    }
    async paymentAmount() {
        return {
            amount: 29.99,
            reducedAmount: 24.99,
            discount: 5.00,
            discountType: 'percentage'
        };
    }
    async countryCodes() {
        return ['DE', 'AT', 'CH', 'FR', 'IT', 'ES', 'NL', 'BE', 'LU', 'US', 'CA', 'GB'];
    }
    async profileImage() {
        return 'https://example.com/default-profile.png';
    }
    async qrCode() {
        return 'https://example.com/qr-code.png';
    }
    async createPaymentIntent() {
        return {
            success: true,
            secret: 'pi_test_secret_' + Math.random().toString(36).substr(2, 9)
        };
    }
    async resetAuthentication() {
        return {
            success: true
        };
    }
    async resetCWALink() {
        return {
            success: true
        };
    }
};
exports.SystemResolver = SystemResolver;
__decorate([
    (0, graphql_1.Query)(() => system_types_1.BackendStatus),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", []),
    __metadata("design:returntype", Promise)
], SystemResolver.prototype, "backendStatus", null);
__decorate([
    (0, graphql_1.Query)(() => system_types_1.PaymentAmount),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", []),
    __metadata("design:returntype", Promise)
], SystemResolver.prototype, "paymentAmount", null);
__decorate([
    (0, graphql_1.Query)(() => [String]),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", []),
    __metadata("design:returntype", Promise)
], SystemResolver.prototype, "countryCodes", null);
__decorate([
    (0, graphql_1.Query)(() => String),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", []),
    __metadata("design:returntype", Promise)
], SystemResolver.prototype, "profileImage", null);
__decorate([
    (0, graphql_1.Query)(() => String),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", []),
    __metadata("design:returntype", Promise)
], SystemResolver.prototype, "qrCode", null);
__decorate([
    (0, graphql_1.Mutation)(() => system_types_1.SystemResponse),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", []),
    __metadata("design:returntype", Promise)
], SystemResolver.prototype, "createPaymentIntent", null);
__decorate([
    (0, graphql_1.Mutation)(() => system_types_1.SystemResponse),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", []),
    __metadata("design:returntype", Promise)
], SystemResolver.prototype, "resetAuthentication", null);
__decorate([
    (0, graphql_1.Mutation)(() => system_types_1.SystemResponse),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", []),
    __metadata("design:returntype", Promise)
], SystemResolver.prototype, "resetCWALink", null);
exports.SystemResolver = SystemResolver = __decorate([
    (0, graphql_1.Resolver)()
], SystemResolver);
//# sourceMappingURL=system.resolver.js.map