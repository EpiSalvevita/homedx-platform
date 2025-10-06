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
exports.TestKit = exports.TestKitStatus = exports.TestKitType = void 0;
const graphql_1 = require("@nestjs/graphql");
const user_type_1 = require("./user.type");
var TestKitType;
(function (TestKitType) {
    TestKitType["COVID_19"] = "COVID_19";
    TestKitType["FLU"] = "FLU";
    TestKitType["STREP_THROAT"] = "STREP_THROAT";
    TestKitType["PREGNANCY"] = "PREGNANCY";
    TestKitType["DRUG_TEST"] = "DRUG_TEST";
})(TestKitType || (exports.TestKitType = TestKitType = {}));
var TestKitStatus;
(function (TestKitStatus) {
    TestKitStatus["AVAILABLE"] = "AVAILABLE";
    TestKitStatus["USED"] = "USED";
    TestKitStatus["EXPIRED"] = "EXPIRED";
    TestKitStatus["DAMAGED"] = "DAMAGED";
})(TestKitStatus || (exports.TestKitStatus = TestKitStatus = {}));
(0, graphql_1.registerEnumType)(TestKitType, {
    name: 'TestKitType',
    description: 'Test kit type enumeration',
});
(0, graphql_1.registerEnumType)(TestKitStatus, {
    name: 'TestKitStatus',
    description: 'Test kit status enumeration',
});
let TestKit = class TestKit {
};
exports.TestKit = TestKit;
__decorate([
    (0, graphql_1.Field)(),
    __metadata("design:type", String)
], TestKit.prototype, "id", void 0);
__decorate([
    (0, graphql_1.Field)(),
    __metadata("design:type", String)
], TestKit.prototype, "serialNumber", void 0);
__decorate([
    (0, graphql_1.Field)(() => TestKitType),
    __metadata("design:type", String)
], TestKit.prototype, "type", void 0);
__decorate([
    (0, graphql_1.Field)(),
    __metadata("design:type", String)
], TestKit.prototype, "manufacturer", void 0);
__decorate([
    (0, graphql_1.Field)(),
    __metadata("design:type", String)
], TestKit.prototype, "model", void 0);
__decorate([
    (0, graphql_1.Field)(),
    __metadata("design:type", String)
], TestKit.prototype, "batchNumber", void 0);
__decorate([
    (0, graphql_1.Field)(),
    __metadata("design:type", Date)
], TestKit.prototype, "expirationDate", void 0);
__decorate([
    (0, graphql_1.Field)(() => TestKitStatus),
    __metadata("design:type", String)
], TestKit.prototype, "status", void 0);
__decorate([
    (0, graphql_1.Field)({ nullable: true }),
    __metadata("design:type", String)
], TestKit.prototype, "userId", void 0);
__decorate([
    (0, graphql_1.Field)({ nullable: true }),
    __metadata("design:type", Date)
], TestKit.prototype, "purchasedAt", void 0);
__decorate([
    (0, graphql_1.Field)({ nullable: true }),
    __metadata("design:type", Date)
], TestKit.prototype, "usedAt", void 0);
__decorate([
    (0, graphql_1.Field)(),
    __metadata("design:type", Date)
], TestKit.prototype, "createdAt", void 0);
__decorate([
    (0, graphql_1.Field)(),
    __metadata("design:type", Date)
], TestKit.prototype, "updatedAt", void 0);
__decorate([
    (0, graphql_1.Field)(() => user_type_1.User, { nullable: true }),
    __metadata("design:type", user_type_1.User)
], TestKit.prototype, "user", void 0);
exports.TestKit = TestKit = __decorate([
    (0, graphql_1.ObjectType)()
], TestKit);
//# sourceMappingURL=test-kit.types.js.map