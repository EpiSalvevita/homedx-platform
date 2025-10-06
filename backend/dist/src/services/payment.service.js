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
exports.PaymentService = void 0;
const common_1 = require("@nestjs/common");
const prisma_service_1 = require("./prisma.service");
const payment_type_1 = require("../graphql/types/payment.type");
let PaymentService = class PaymentService {
    constructor(prisma) {
        this.prisma = prisma;
        this.includeRelations = {
            user: true,
        };
    }
    mapPaymentMethod(method) {
        switch (method) {
            case 'CREDIT_CARD':
                return payment_type_1.PaymentMethod.CREDIT_CARD;
            case 'PAYPAL':
                return payment_type_1.PaymentMethod.PAYPAL;
            case 'BANK_TRANSFER':
                return payment_type_1.PaymentMethod.BANK_TRANSFER;
            case 'CRYPTO':
                return payment_type_1.PaymentMethod.CRYPTO;
            default:
                return payment_type_1.PaymentMethod.CREDIT_CARD;
        }
    }
    mapPaymentStatus(status) {
        switch (status) {
            case 'PENDING':
                return payment_type_1.PaymentStatus.PENDING;
            case 'COMPLETED':
                return payment_type_1.PaymentStatus.COMPLETED;
            case 'FAILED':
                return payment_type_1.PaymentStatus.FAILED;
            case 'REFUNDED':
                return payment_type_1.PaymentStatus.REFUNDED;
            case 'CANCELLED':
                return payment_type_1.PaymentStatus.CANCELLED;
            default:
                return payment_type_1.PaymentStatus.PENDING;
        }
    }
    mapPaymentToGraphQL(payment) {
        return Object.assign(Object.assign({}, payment), { method: this.mapPaymentMethod(payment.method), status: this.mapPaymentStatus(payment.status) });
    }
    async findAll() {
        const payments = await this.prisma.payment.findMany({
            include: this.includeRelations
        });
        return payments.map(payment => this.mapPaymentToGraphQL(payment));
    }
    async findOne(id) {
        const payment = await this.prisma.payment.findUnique({
            where: { id },
            include: this.includeRelations
        });
        return payment ? this.mapPaymentToGraphQL(payment) : null;
    }
    async findByUserId(userId) {
        const payments = await this.prisma.payment.findMany({
            where: { userId },
            include: this.includeRelations
        });
        return payments.map(payment => this.mapPaymentToGraphQL(payment));
    }
    async create(data) {
        const payment = await this.prisma.payment.create({
            data: {
                userId: data.userId,
                amount: data.amount,
                currency: data.currency,
                method: data.paymentMethod,
                status: 'PENDING',
                transactionId: data.transactionId,
                description: `Payment for ${data.amount} ${data.currency}`,
            },
            include: this.includeRelations
        });
        return this.mapPaymentToGraphQL(payment);
    }
    async update(id, data) {
        const updateData = {};
        if (data.amount !== undefined)
            updateData.amount = data.amount;
        if (data.currency !== undefined)
            updateData.currency = data.currency;
        if (data.status !== undefined)
            updateData.status = data.status;
        if (data.paymentMethod !== undefined)
            updateData.method = data.paymentMethod;
        if (data.transactionId !== undefined)
            updateData.transactionId = data.transactionId;
        const payment = await this.prisma.payment.update({
            where: { id },
            data: updateData,
            include: this.includeRelations
        });
        return this.mapPaymentToGraphQL(payment);
    }
    async remove(id) {
        const payment = await this.prisma.payment.delete({
            where: { id },
            include: this.includeRelations
        });
        return this.mapPaymentToGraphQL(payment);
    }
    async updateStatus(id, status) {
        const payment = await this.prisma.payment.update({
            where: { id },
            data: { status: status },
            include: this.includeRelations
        });
        return this.mapPaymentToGraphQL(payment);
    }
};
exports.PaymentService = PaymentService;
exports.PaymentService = PaymentService = __decorate([
    (0, common_1.Injectable)(),
    __metadata("design:paramtypes", [prisma_service_1.PrismaService])
], PaymentService);
//# sourceMappingURL=payment.service.js.map