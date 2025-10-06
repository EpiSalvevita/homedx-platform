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
exports.Payment = exports.PaymentStatus = exports.PaymentMethod = void 0;
const graphql_1 = require("@nestjs/graphql");
const user_type_1 = require("./user.type");
var PaymentMethod;
(function (PaymentMethod) {
    PaymentMethod["CREDIT_CARD"] = "CREDIT_CARD";
    PaymentMethod["PAYPAL"] = "PAYPAL";
    PaymentMethod["BANK_TRANSFER"] = "BANK_TRANSFER";
    PaymentMethod["CRYPTO"] = "CRYPTO";
})(PaymentMethod || (exports.PaymentMethod = PaymentMethod = {}));
var PaymentStatus;
(function (PaymentStatus) {
    PaymentStatus["PENDING"] = "PENDING";
    PaymentStatus["COMPLETED"] = "COMPLETED";
    PaymentStatus["FAILED"] = "FAILED";
    PaymentStatus["REFUNDED"] = "REFUNDED";
    PaymentStatus["CANCELLED"] = "CANCELLED";
})(PaymentStatus || (exports.PaymentStatus = PaymentStatus = {}));
(0, graphql_1.registerEnumType)(PaymentMethod, {
    name: 'PaymentMethod',
    description: 'Payment method enumeration',
});
(0, graphql_1.registerEnumType)(PaymentStatus, {
    name: 'PaymentStatus',
    description: 'Payment status enumeration',
});
let Payment = class Payment {
};
exports.Payment = Payment;
__decorate([
    (0, graphql_1.Field)(),
    __metadata("design:type", String)
], Payment.prototype, "id", void 0);
__decorate([
    (0, graphql_1.Field)(),
    __metadata("design:type", String)
], Payment.prototype, "userId", void 0);
__decorate([
    (0, graphql_1.Field)(),
    __metadata("design:type", Number)
], Payment.prototype, "amount", void 0);
__decorate([
    (0, graphql_1.Field)(),
    __metadata("design:type", String)
], Payment.prototype, "currency", void 0);
__decorate([
    (0, graphql_1.Field)(() => PaymentMethod),
    __metadata("design:type", String)
], Payment.prototype, "method", void 0);
__decorate([
    (0, graphql_1.Field)(() => PaymentStatus),
    __metadata("design:type", String)
], Payment.prototype, "status", void 0);
__decorate([
    (0, graphql_1.Field)({ nullable: true }),
    __metadata("design:type", String)
], Payment.prototype, "transactionId", void 0);
__decorate([
    (0, graphql_1.Field)({ nullable: true }),
    __metadata("design:type", String)
], Payment.prototype, "description", void 0);
__decorate([
    (0, graphql_1.Field)({ nullable: true }),
    __metadata("design:type", String)
], Payment.prototype, "failureReason", void 0);
__decorate([
    (0, graphql_1.Field)(),
    __metadata("design:type", Date)
], Payment.prototype, "createdAt", void 0);
__decorate([
    (0, graphql_1.Field)(),
    __metadata("design:type", Date)
], Payment.prototype, "updatedAt", void 0);
__decorate([
    (0, graphql_1.Field)({ nullable: true }),
    __metadata("design:type", Date)
], Payment.prototype, "completedAt", void 0);
__decorate([
    (0, graphql_1.Field)(() => user_type_1.User),
    __metadata("design:type", user_type_1.User)
], Payment.prototype, "user", void 0);
exports.Payment = Payment = __decorate([
    (0, graphql_1.ObjectType)()
], Payment);
//# sourceMappingURL=payment.type.js.map