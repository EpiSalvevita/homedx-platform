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
exports.UpdateTestKitInput = exports.CreateTestKitInput = void 0;
const graphql_1 = require("@nestjs/graphql");
const class_validator_1 = require("class-validator");
const test_kit_types_1 = require("./test-kit.types");
let CreateTestKitInput = class CreateTestKitInput {
};
exports.CreateTestKitInput = CreateTestKitInput;
__decorate([
    (0, graphql_1.Field)(),
    (0, class_validator_1.IsString)(),
    __metadata("design:type", String)
], CreateTestKitInput.prototype, "serialNumber", void 0);
__decorate([
    (0, graphql_1.Field)(() => test_kit_types_1.TestKitType),
    (0, class_validator_1.IsEnum)(test_kit_types_1.TestKitType),
    __metadata("design:type", String)
], CreateTestKitInput.prototype, "type", void 0);
__decorate([
    (0, graphql_1.Field)(),
    (0, class_validator_1.IsString)(),
    __metadata("design:type", String)
], CreateTestKitInput.prototype, "manufacturer", void 0);
__decorate([
    (0, graphql_1.Field)(),
    (0, class_validator_1.IsString)(),
    __metadata("design:type", String)
], CreateTestKitInput.prototype, "model", void 0);
__decorate([
    (0, graphql_1.Field)(),
    (0, class_validator_1.IsString)(),
    __metadata("design:type", String)
], CreateTestKitInput.prototype, "batchNumber", void 0);
__decorate([
    (0, graphql_1.Field)(),
    (0, class_validator_1.IsDate)(),
    __metadata("design:type", Date)
], CreateTestKitInput.prototype, "expirationDate", void 0);
__decorate([
    (0, graphql_1.Field)(() => test_kit_types_1.TestKitStatus, { nullable: true }),
    (0, class_validator_1.IsOptional)(),
    (0, class_validator_1.IsEnum)(test_kit_types_1.TestKitStatus),
    __metadata("design:type", String)
], CreateTestKitInput.prototype, "status", void 0);
__decorate([
    (0, graphql_1.Field)({ nullable: true }),
    (0, class_validator_1.IsOptional)(),
    (0, class_validator_1.IsString)(),
    __metadata("design:type", String)
], CreateTestKitInput.prototype, "userId", void 0);
exports.CreateTestKitInput = CreateTestKitInput = __decorate([
    (0, graphql_1.InputType)()
], CreateTestKitInput);
let UpdateTestKitInput = class UpdateTestKitInput {
};
exports.UpdateTestKitInput = UpdateTestKitInput;
__decorate([
    (0, graphql_1.Field)({ nullable: true }),
    (0, class_validator_1.IsOptional)(),
    (0, class_validator_1.IsString)(),
    __metadata("design:type", String)
], UpdateTestKitInput.prototype, "serialNumber", void 0);
__decorate([
    (0, graphql_1.Field)(() => test_kit_types_1.TestKitType, { nullable: true }),
    (0, class_validator_1.IsOptional)(),
    (0, class_validator_1.IsEnum)(test_kit_types_1.TestKitType),
    __metadata("design:type", String)
], UpdateTestKitInput.prototype, "type", void 0);
__decorate([
    (0, graphql_1.Field)({ nullable: true }),
    (0, class_validator_1.IsOptional)(),
    (0, class_validator_1.IsString)(),
    __metadata("design:type", String)
], UpdateTestKitInput.prototype, "manufacturer", void 0);
__decorate([
    (0, graphql_1.Field)({ nullable: true }),
    (0, class_validator_1.IsOptional)(),
    (0, class_validator_1.IsString)(),
    __metadata("design:type", String)
], UpdateTestKitInput.prototype, "model", void 0);
__decorate([
    (0, graphql_1.Field)({ nullable: true }),
    (0, class_validator_1.IsOptional)(),
    (0, class_validator_1.IsString)(),
    __metadata("design:type", String)
], UpdateTestKitInput.prototype, "batchNumber", void 0);
__decorate([
    (0, graphql_1.Field)({ nullable: true }),
    (0, class_validator_1.IsOptional)(),
    (0, class_validator_1.IsDate)(),
    __metadata("design:type", Date)
], UpdateTestKitInput.prototype, "expirationDate", void 0);
__decorate([
    (0, graphql_1.Field)(() => test_kit_types_1.TestKitStatus, { nullable: true }),
    (0, class_validator_1.IsOptional)(),
    (0, class_validator_1.IsEnum)(test_kit_types_1.TestKitStatus),
    __metadata("design:type", String)
], UpdateTestKitInput.prototype, "status", void 0);
__decorate([
    (0, graphql_1.Field)({ nullable: true }),
    (0, class_validator_1.IsOptional)(),
    (0, class_validator_1.IsString)(),
    __metadata("design:type", String)
], UpdateTestKitInput.prototype, "userId", void 0);
exports.UpdateTestKitInput = UpdateTestKitInput = __decorate([
    (0, graphql_1.InputType)()
], UpdateTestKitInput);
//# sourceMappingURL=test-kit.input.js.map