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
exports.UpdateRapidTestInput = exports.CreateRapidTestInput = void 0;
const graphql_1 = require("@nestjs/graphql");
const class_validator_1 = require("class-validator");
let CreateRapidTestInput = class CreateRapidTestInput {
};
exports.CreateRapidTestInput = CreateRapidTestInput;
__decorate([
    (0, graphql_1.Field)(),
    (0, class_validator_1.IsString)(),
    __metadata("design:type", String)
], CreateRapidTestInput.prototype, "userId", void 0);
__decorate([
    (0, graphql_1.Field)(),
    (0, class_validator_1.IsString)(),
    __metadata("design:type", String)
], CreateRapidTestInput.prototype, "testKitId", void 0);
__decorate([
    (0, graphql_1.Field)(),
    (0, class_validator_1.IsDate)(),
    __metadata("design:type", Date)
], CreateRapidTestInput.prototype, "testDate", void 0);
__decorate([
    (0, graphql_1.Field)({ nullable: true }),
    (0, class_validator_1.IsOptional)(),
    (0, class_validator_1.IsUrl)({}, { message: 'Test device URL must be a valid URL' }),
    __metadata("design:type", String)
], CreateRapidTestInput.prototype, "testDeviceUrl", void 0);
__decorate([
    (0, graphql_1.Field)({ nullable: true }),
    (0, class_validator_1.IsOptional)(),
    (0, class_validator_1.IsUrl)({}, { message: 'Identity card 1 URL must be a valid URL' }),
    __metadata("design:type", String)
], CreateRapidTestInput.prototype, "identityCard1Url", void 0);
__decorate([
    (0, graphql_1.Field)({ nullable: true }),
    (0, class_validator_1.IsOptional)(),
    (0, class_validator_1.IsUrl)({}, { message: 'Identity card 2 URL must be a valid URL' }),
    __metadata("design:type", String)
], CreateRapidTestInput.prototype, "identityCard2Url", void 0);
__decorate([
    (0, graphql_1.Field)({ nullable: true }),
    (0, class_validator_1.IsOptional)(),
    (0, class_validator_1.IsUrl)({}, { message: 'Profile picture URL must be a valid URL' }),
    __metadata("design:type", String)
], CreateRapidTestInput.prototype, "profilePicUrl", void 0);
__decorate([
    (0, graphql_1.Field)({ nullable: true }),
    (0, class_validator_1.IsOptional)(),
    (0, class_validator_1.IsString)(),
    (0, class_validator_1.Matches)(/^[A-Z0-9-]+$/, {
        message: 'Identity card ID must contain only uppercase letters, numbers, and hyphens',
    }),
    __metadata("design:type", String)
], CreateRapidTestInput.prototype, "identityCardId", void 0);
exports.CreateRapidTestInput = CreateRapidTestInput = __decorate([
    (0, graphql_1.InputType)()
], CreateRapidTestInput);
let UpdateRapidTestInput = class UpdateRapidTestInput {
};
exports.UpdateRapidTestInput = UpdateRapidTestInput;
__decorate([
    (0, graphql_1.Field)({ nullable: true }),
    (0, class_validator_1.IsOptional)(),
    (0, class_validator_1.IsUrl)({}, { message: 'Test device URL must be a valid URL' }),
    __metadata("design:type", String)
], UpdateRapidTestInput.prototype, "testDeviceUrl", void 0);
__decorate([
    (0, graphql_1.Field)({ nullable: true }),
    (0, class_validator_1.IsOptional)(),
    (0, class_validator_1.IsString)(),
    (0, class_validator_1.Matches)(/^(POSITIVE|NEGATIVE|INVALID|INCONCLUSIVE)$/, {
        message: 'Result must be one of: POSITIVE, NEGATIVE, INVALID, INCONCLUSIVE',
    }),
    __metadata("design:type", String)
], UpdateRapidTestInput.prototype, "result", void 0);
__decorate([
    (0, graphql_1.Field)({ nullable: true }),
    (0, class_validator_1.IsOptional)(),
    (0, class_validator_1.IsString)(),
    (0, class_validator_1.Matches)(/^(PENDING|IN_PROGRESS|COMPLETED|FAILED)$/, {
        message: 'Status must be one of: PENDING, IN_PROGRESS, COMPLETED, FAILED',
    }),
    __metadata("design:type", String)
], UpdateRapidTestInput.prototype, "status", void 0);
__decorate([
    (0, graphql_1.Field)({ nullable: true }),
    (0, class_validator_1.IsOptional)(),
    (0, class_validator_1.IsUrl)({}, { message: 'Certificate URL must be a valid URL' }),
    __metadata("design:type", String)
], UpdateRapidTestInput.prototype, "certificateUrl", void 0);
__decorate([
    (0, graphql_1.Field)({ nullable: true }),
    (0, class_validator_1.IsOptional)(),
    (0, class_validator_1.IsUrl)({}, { message: 'Identity card 1 URL must be a valid URL' }),
    __metadata("design:type", String)
], UpdateRapidTestInput.prototype, "identityCard1Url", void 0);
__decorate([
    (0, graphql_1.Field)({ nullable: true }),
    (0, class_validator_1.IsOptional)(),
    (0, class_validator_1.IsUrl)({}, { message: 'Identity card 2 URL must be a valid URL' }),
    __metadata("design:type", String)
], UpdateRapidTestInput.prototype, "identityCard2Url", void 0);
__decorate([
    (0, graphql_1.Field)({ nullable: true }),
    (0, class_validator_1.IsOptional)(),
    (0, class_validator_1.IsUrl)({}, { message: 'Profile picture URL must be a valid URL' }),
    __metadata("design:type", String)
], UpdateRapidTestInput.prototype, "profilePicUrl", void 0);
__decorate([
    (0, graphql_1.Field)({ nullable: true }),
    (0, class_validator_1.IsOptional)(),
    (0, class_validator_1.IsString)(),
    (0, class_validator_1.Matches)(/^[A-Z0-9-]+$/, {
        message: 'Identity card ID must contain only uppercase letters, numbers, and hyphens',
    }),
    __metadata("design:type", String)
], UpdateRapidTestInput.prototype, "identityCardId", void 0);
__decorate([
    (0, graphql_1.Field)({ nullable: true }),
    (0, class_validator_1.IsOptional)(),
    (0, class_validator_1.IsUrl)({}, { message: 'Video URL must be a valid URL' }),
    __metadata("design:type", String)
], UpdateRapidTestInput.prototype, "videoUrl", void 0);
__decorate([
    (0, graphql_1.Field)({ nullable: true }),
    (0, class_validator_1.IsOptional)(),
    (0, class_validator_1.IsUrl)({}, { message: 'Photo URL must be a valid URL' }),
    __metadata("design:type", String)
], UpdateRapidTestInput.prototype, "photoUrl", void 0);
__decorate([
    (0, graphql_1.Field)({ nullable: true }),
    (0, class_validator_1.IsOptional)(),
    (0, class_validator_1.IsString)(),
    __metadata("design:type", String)
], UpdateRapidTestInput.prototype, "qrCode", void 0);
__decorate([
    (0, graphql_1.Field)({ nullable: true }),
    (0, class_validator_1.IsOptional)(),
    (0, class_validator_1.IsString)(),
    __metadata("design:type", String)
], UpdateRapidTestInput.prototype, "comment", void 0);
__decorate([
    (0, graphql_1.Field)({ nullable: true }),
    (0, class_validator_1.IsOptional)(),
    (0, class_validator_1.IsBoolean)(),
    __metadata("design:type", Boolean)
], UpdateRapidTestInput.prototype, "agreementGiven", void 0);
exports.UpdateRapidTestInput = UpdateRapidTestInput = __decorate([
    (0, graphql_1.InputType)()
], UpdateRapidTestInput);
//# sourceMappingURL=rapid-test.input.js.map