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
exports.SubmitTestResponse = exports.RapidTest = exports.TestStatus = exports.TestResult = void 0;
const graphql_1 = require("@nestjs/graphql");
const user_type_1 = require("./user.type");
const test_kit_types_1 = require("./test-kit.types");
var TestResult;
(function (TestResult) {
    TestResult["POSITIVE"] = "POSITIVE";
    TestResult["NEGATIVE"] = "NEGATIVE";
    TestResult["INVALID"] = "INVALID";
    TestResult["INCONCLUSIVE"] = "INCONCLUSIVE";
})(TestResult || (exports.TestResult = TestResult = {}));
var TestStatus;
(function (TestStatus) {
    TestStatus["PENDING"] = "PENDING";
    TestStatus["IN_PROGRESS"] = "IN_PROGRESS";
    TestStatus["COMPLETED"] = "COMPLETED";
    TestStatus["FAILED"] = "FAILED";
})(TestStatus || (exports.TestStatus = TestStatus = {}));
(0, graphql_1.registerEnumType)(TestResult, {
    name: 'TestResult',
    description: 'Rapid test result enumeration',
});
(0, graphql_1.registerEnumType)(TestStatus, {
    name: 'TestStatus',
    description: 'Rapid test status enumeration',
});
let RapidTest = class RapidTest {
};
exports.RapidTest = RapidTest;
__decorate([
    (0, graphql_1.Field)(),
    __metadata("design:type", String)
], RapidTest.prototype, "id", void 0);
__decorate([
    (0, graphql_1.Field)(),
    __metadata("design:type", String)
], RapidTest.prototype, "userId", void 0);
__decorate([
    (0, graphql_1.Field)(),
    __metadata("design:type", String)
], RapidTest.prototype, "testKitId", void 0);
__decorate([
    (0, graphql_1.Field)(),
    __metadata("design:type", Date)
], RapidTest.prototype, "testDate", void 0);
__decorate([
    (0, graphql_1.Field)(() => TestStatus),
    __metadata("design:type", String)
], RapidTest.prototype, "status", void 0);
__decorate([
    (0, graphql_1.Field)(() => TestResult, { nullable: true }),
    __metadata("design:type", String)
], RapidTest.prototype, "result", void 0);
__decorate([
    (0, graphql_1.Field)({ nullable: true }),
    __metadata("design:type", String)
], RapidTest.prototype, "resultImageUrl", void 0);
__decorate([
    (0, graphql_1.Field)({ nullable: true }),
    __metadata("design:type", String)
], RapidTest.prototype, "notes", void 0);
__decorate([
    (0, graphql_1.Field)(),
    __metadata("design:type", Date)
], RapidTest.prototype, "createdAt", void 0);
__decorate([
    (0, graphql_1.Field)(),
    __metadata("design:type", Date)
], RapidTest.prototype, "updatedAt", void 0);
__decorate([
    (0, graphql_1.Field)({ nullable: true }),
    __metadata("design:type", Date)
], RapidTest.prototype, "completedAt", void 0);
__decorate([
    (0, graphql_1.Field)(() => user_type_1.User),
    __metadata("design:type", user_type_1.User)
], RapidTest.prototype, "user", void 0);
__decorate([
    (0, graphql_1.Field)(() => test_kit_types_1.TestKit),
    __metadata("design:type", test_kit_types_1.TestKit)
], RapidTest.prototype, "testKit", void 0);
exports.RapidTest = RapidTest = __decorate([
    (0, graphql_1.ObjectType)()
], RapidTest);
let SubmitTestResponse = class SubmitTestResponse {
};
exports.SubmitTestResponse = SubmitTestResponse;
__decorate([
    (0, graphql_1.Field)(),
    __metadata("design:type", Boolean)
], SubmitTestResponse.prototype, "success", void 0);
__decorate([
    (0, graphql_1.Field)({ nullable: true }),
    __metadata("design:type", String)
], SubmitTestResponse.prototype, "validation", void 0);
exports.SubmitTestResponse = SubmitTestResponse = __decorate([
    (0, graphql_1.ObjectType)()
], SubmitTestResponse);
//# sourceMappingURL=rapid-test.type.js.map