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
exports.UpdatePaymentInput = exports.CreatePaymentInput = void 0;
const graphql_1 = require("@nestjs/graphql");
const class_validator_1 = require("class-validator");
let CreatePaymentInput = class CreatePaymentInput {
};
exports.CreatePaymentInput = CreatePaymentInput;
__decorate([
    (0, graphql_1.Field)(),
    (0, class_validator_1.IsString)(),
    __metadata("design:type", String)
], CreatePaymentInput.prototype, "userId", void 0);
__decorate([
    (0, graphql_1.Field)(() => graphql_1.Float),
    (0, class_validator_1.IsNumber)({ maxDecimalPlaces: 2 }),
    (0, class_validator_1.Min)(0, { message: 'Amount must be greater than or equal to 0' }),
    __metadata("design:type", Number)
], CreatePaymentInput.prototype, "amount", void 0);
__decorate([
    (0, graphql_1.Field)(),
    (0, class_validator_1.IsString)(),
    (0, class_validator_1.Matches)(/^[A-Z]{3}$/, {
        message: 'Currency must be a valid 3-letter currency code (e.g., EUR, USD)',
    }),
    __metadata("design:type", String)
], CreatePaymentInput.prototype, "currency", void 0);
__decorate([
    (0, graphql_1.Field)(),
    (0, class_validator_1.IsString)(),
    (0, class_validator_1.Matches)(/^(CREDIT_CARD|PAYPAL|BANK_TRANSFER|STRIPE)$/, {
        message: 'Payment method must be one of: CREDIT_CARD, PAYPAL, BANK_TRANSFER, STRIPE',
    }),
    __metadata("design:type", String)
], CreatePaymentInput.prototype, "paymentMethod", void 0);
__decorate([
    (0, graphql_1.Field)({ nullable: true }),
    (0, class_validator_1.IsOptional)(),
    (0, class_validator_1.IsString)(),
    __metadata("design:type", String)
], CreatePaymentInput.prototype, "rapidTestId", void 0);
__decorate([
    (0, graphql_1.Field)({ nullable: true }),
    (0, class_validator_1.IsOptional)(),
    (0, class_validator_1.IsString)(),
    __metadata("design:type", String)
], CreatePaymentInput.prototype, "transactionId", void 0);
__decorate([
    (0, graphql_1.Field)({ nullable: true }),
    (0, class_validator_1.IsOptional)(),
    (0, class_validator_1.IsString)(),
    __metadata("design:type", String)
], CreatePaymentInput.prototype, "paymentIntentId", void 0);
exports.CreatePaymentInput = CreatePaymentInput = __decorate([
    (0, graphql_1.InputType)()
], CreatePaymentInput);
let UpdatePaymentInput = class UpdatePaymentInput {
};
exports.UpdatePaymentInput = UpdatePaymentInput;
__decorate([
    (0, graphql_1.Field)(() => graphql_1.Float, { nullable: true }),
    (0, class_validator_1.IsOptional)(),
    (0, class_validator_1.IsNumber)({ maxDecimalPlaces: 2 }),
    (0, class_validator_1.Min)(0, { message: 'Amount must be greater than or equal to 0' }),
    __metadata("design:type", Number)
], UpdatePaymentInput.prototype, "amount", void 0);
__decorate([
    (0, graphql_1.Field)({ nullable: true }),
    (0, class_validator_1.IsOptional)(),
    (0, class_validator_1.IsString)(),
    (0, class_validator_1.Matches)(/^[A-Z]{3}$/, {
        message: 'Currency must be a valid 3-letter currency code (e.g., EUR, USD)',
    }),
    __metadata("design:type", String)
], UpdatePaymentInput.prototype, "currency", void 0);
__decorate([
    (0, graphql_1.Field)({ nullable: true }),
    (0, class_validator_1.IsOptional)(),
    (0, class_validator_1.IsString)(),
    (0, class_validator_1.Matches)(/^(PENDING|COMPLETED|FAILED|REFUNDED)$/, {
        message: 'Status must be one of: PENDING, COMPLETED, FAILED, REFUNDED',
    }),
    __metadata("design:type", String)
], UpdatePaymentInput.prototype, "status", void 0);
__decorate([
    (0, graphql_1.Field)({ nullable: true }),
    (0, class_validator_1.IsOptional)(),
    (0, class_validator_1.IsString)(),
    (0, class_validator_1.Matches)(/^(CREDIT_CARD|PAYPAL|BANK_TRANSFER|STRIPE)$/, {
        message: 'Payment method must be one of: CREDIT_CARD, PAYPAL, BANK_TRANSFER, STRIPE',
    }),
    __metadata("design:type", String)
], UpdatePaymentInput.prototype, "paymentMethod", void 0);
__decorate([
    (0, graphql_1.Field)({ nullable: true }),
    (0, class_validator_1.IsOptional)(),
    (0, class_validator_1.IsString)(),
    __metadata("design:type", String)
], UpdatePaymentInput.prototype, "transactionId", void 0);
__decorate([
    (0, graphql_1.Field)({ nullable: true }),
    (0, class_validator_1.IsOptional)(),
    (0, class_validator_1.IsString)(),
    __metadata("design:type", String)
], UpdatePaymentInput.prototype, "paymentIntentId", void 0);
exports.UpdatePaymentInput = UpdatePaymentInput = __decorate([
    (0, graphql_1.InputType)()
], UpdatePaymentInput);
//# sourceMappingURL=payment.input.js.map