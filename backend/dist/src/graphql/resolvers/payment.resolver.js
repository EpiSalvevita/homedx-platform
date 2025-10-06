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
exports.PaymentResolver = void 0;
const graphql_1 = require("@nestjs/graphql");
const payment_type_1 = require("../types/payment.type");
const payment_input_1 = require("../types/payment.input");
const payment_service_1 = require("../../services/payment.service");
let PaymentResolver = class PaymentResolver {
    constructor(paymentService) {
        this.paymentService = paymentService;
    }
    async payments() {
        return this.paymentService.findAll();
    }
    async payment(id) {
        return this.paymentService.findOne(id);
    }
    async userPayments(userId) {
        return this.paymentService.findByUserId(userId);
    }
    async createPayment(input) {
        return this.paymentService.create(input);
    }
    async updatePayment(id, input) {
        return this.paymentService.update(id, input);
    }
    async removePayment(id) {
        return this.paymentService.remove(id);
    }
    async updatePaymentStatus(id, status) {
        return this.paymentService.updateStatus(id, status);
    }
};
exports.PaymentResolver = PaymentResolver;
__decorate([
    (0, graphql_1.Query)(() => [payment_type_1.Payment]),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", []),
    __metadata("design:returntype", Promise)
], PaymentResolver.prototype, "payments", null);
__decorate([
    (0, graphql_1.Query)(() => payment_type_1.Payment, { nullable: true }),
    __param(0, (0, graphql_1.Args)('id')),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String]),
    __metadata("design:returntype", Promise)
], PaymentResolver.prototype, "payment", null);
__decorate([
    (0, graphql_1.Query)(() => [payment_type_1.Payment]),
    __param(0, (0, graphql_1.Args)('userId')),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String]),
    __metadata("design:returntype", Promise)
], PaymentResolver.prototype, "userPayments", null);
__decorate([
    (0, graphql_1.Mutation)(() => payment_type_1.Payment),
    __param(0, (0, graphql_1.Args)('input')),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [payment_input_1.CreatePaymentInput]),
    __metadata("design:returntype", Promise)
], PaymentResolver.prototype, "createPayment", null);
__decorate([
    (0, graphql_1.Mutation)(() => payment_type_1.Payment),
    __param(0, (0, graphql_1.Args)('id')),
    __param(1, (0, graphql_1.Args)('input')),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String, payment_input_1.UpdatePaymentInput]),
    __metadata("design:returntype", Promise)
], PaymentResolver.prototype, "updatePayment", null);
__decorate([
    (0, graphql_1.Mutation)(() => payment_type_1.Payment),
    __param(0, (0, graphql_1.Args)('id')),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String]),
    __metadata("design:returntype", Promise)
], PaymentResolver.prototype, "removePayment", null);
__decorate([
    (0, graphql_1.Mutation)(() => payment_type_1.Payment),
    __param(0, (0, graphql_1.Args)('id')),
    __param(1, (0, graphql_1.Args)('status')),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String, String]),
    __metadata("design:returntype", Promise)
], PaymentResolver.prototype, "updatePaymentStatus", null);
exports.PaymentResolver = PaymentResolver = __decorate([
    (0, graphql_1.Resolver)(() => payment_type_1.Payment),
    __metadata("design:paramtypes", [payment_service_1.PaymentService])
], PaymentResolver);
//# sourceMappingURL=payment.resolver.js.map