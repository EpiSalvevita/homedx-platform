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
exports.SystemResponse = exports.PaymentAmount = exports.BackendStatus = exports.SystemFlag = void 0;
const graphql_1 = require("@nestjs/graphql");
let SystemFlag = class SystemFlag {
};
exports.SystemFlag = SystemFlag;
__decorate([
    (0, graphql_1.Field)(),
    __metadata("design:type", String)
], SystemFlag.prototype, "key", void 0);
__decorate([
    (0, graphql_1.Field)(),
    __metadata("design:type", String)
], SystemFlag.prototype, "value", void 0);
exports.SystemFlag = SystemFlag = __decorate([
    (0, graphql_1.ObjectType)()
], SystemFlag);
let BackendStatus = class BackendStatus {
};
exports.BackendStatus = BackendStatus;
__decorate([
    (0, graphql_1.Field)(),
    __metadata("design:type", Boolean)
], BackendStatus.prototype, "maintenance", void 0);
__decorate([
    (0, graphql_1.Field)(),
    __metadata("design:type", String)
], BackendStatus.prototype, "version", void 0);
__decorate([
    (0, graphql_1.Field)(() => [SystemFlag]),
    __metadata("design:type", Array)
], BackendStatus.prototype, "flags", void 0);
__decorate([
    (0, graphql_1.Field)(),
    __metadata("design:type", Boolean)
], BackendStatus.prototype, "paymentIsActive", void 0);
__decorate([
    (0, graphql_1.Field)(),
    __metadata("design:type", Boolean)
], BackendStatus.prototype, "stripe", void 0);
__decorate([
    (0, graphql_1.Field)(),
    __metadata("design:type", Boolean)
], BackendStatus.prototype, "cwa", void 0);
__decorate([
    (0, graphql_1.Field)(),
    __metadata("design:type", Boolean)
], BackendStatus.prototype, "cwaLaive", void 0);
__decorate([
    (0, graphql_1.Field)(),
    __metadata("design:type", Boolean)
], BackendStatus.prototype, "certificatePdf", void 0);
exports.BackendStatus = BackendStatus = __decorate([
    (0, graphql_1.ObjectType)()
], BackendStatus);
let PaymentAmount = class PaymentAmount {
};
exports.PaymentAmount = PaymentAmount;
__decorate([
    (0, graphql_1.Field)(),
    __metadata("design:type", Number)
], PaymentAmount.prototype, "amount", void 0);
__decorate([
    (0, graphql_1.Field)(),
    __metadata("design:type", Number)
], PaymentAmount.prototype, "reducedAmount", void 0);
__decorate([
    (0, graphql_1.Field)(),
    __metadata("design:type", Number)
], PaymentAmount.prototype, "discount", void 0);
__decorate([
    (0, graphql_1.Field)(),
    __metadata("design:type", String)
], PaymentAmount.prototype, "discountType", void 0);
exports.PaymentAmount = PaymentAmount = __decorate([
    (0, graphql_1.ObjectType)()
], PaymentAmount);
let SystemResponse = class SystemResponse {
};
exports.SystemResponse = SystemResponse;
__decorate([
    (0, graphql_1.Field)(),
    __metadata("design:type", Boolean)
], SystemResponse.prototype, "success", void 0);
__decorate([
    (0, graphql_1.Field)({ nullable: true }),
    __metadata("design:type", String)
], SystemResponse.prototype, "secret", void 0);
__decorate([
    (0, graphql_1.Field)({ nullable: true }),
    __metadata("design:type", String)
], SystemResponse.prototype, "message", void 0);
exports.SystemResponse = SystemResponse = __decorate([
    (0, graphql_1.ObjectType)()
], SystemResponse);
//# sourceMappingURL=system.types.js.map