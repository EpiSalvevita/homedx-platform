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
exports.TestKitResolver = void 0;
const graphql_1 = require("@nestjs/graphql");
const test_kit_types_1 = require("../types/test-kit.types");
const test_kit_input_1 = require("../types/test-kit.input");
const test_kit_service_1 = require("../../services/test-kit.service");
let TestKitResolver = class TestKitResolver {
    constructor(testKitService) {
        this.testKitService = testKitService;
    }
    async testKits() {
        return this.testKitService.findAll();
    }
    async testKit(id) {
        return this.testKitService.findOne(id);
    }
    async testKitBySerialNumber(serialNumber) {
        return this.testKitService.findBySerialNumber(serialNumber);
    }
    async availableTestKits() {
        return this.testKitService.findAvailable();
    }
    async userTestKits(userId) {
        return this.testKitService.findByUserId(userId);
    }
    async createTestKit(input) {
        return this.testKitService.create(input);
    }
    async updateTestKit(id, input) {
        return this.testKitService.update(id, input);
    }
    async removeTestKit(id) {
        return this.testKitService.remove(id);
    }
    async assignTestKitToUser(id, userId) {
        return this.testKitService.assignToUser(id, userId);
    }
    async markTestKitAsUsed(id) {
        return this.testKitService.markAsUsed(id);
    }
};
exports.TestKitResolver = TestKitResolver;
__decorate([
    (0, graphql_1.Query)(() => [test_kit_types_1.TestKit]),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", []),
    __metadata("design:returntype", Promise)
], TestKitResolver.prototype, "testKits", null);
__decorate([
    (0, graphql_1.Query)(() => test_kit_types_1.TestKit, { nullable: true }),
    __param(0, (0, graphql_1.Args)('id')),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String]),
    __metadata("design:returntype", Promise)
], TestKitResolver.prototype, "testKit", null);
__decorate([
    (0, graphql_1.Query)(() => test_kit_types_1.TestKit, { nullable: true }),
    __param(0, (0, graphql_1.Args)('serialNumber')),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String]),
    __metadata("design:returntype", Promise)
], TestKitResolver.prototype, "testKitBySerialNumber", null);
__decorate([
    (0, graphql_1.Query)(() => [test_kit_types_1.TestKit]),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", []),
    __metadata("design:returntype", Promise)
], TestKitResolver.prototype, "availableTestKits", null);
__decorate([
    (0, graphql_1.Query)(() => [test_kit_types_1.TestKit]),
    __param(0, (0, graphql_1.Args)('userId')),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String]),
    __metadata("design:returntype", Promise)
], TestKitResolver.prototype, "userTestKits", null);
__decorate([
    (0, graphql_1.Mutation)(() => test_kit_types_1.TestKit),
    __param(0, (0, graphql_1.Args)('input')),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [test_kit_input_1.CreateTestKitInput]),
    __metadata("design:returntype", Promise)
], TestKitResolver.prototype, "createTestKit", null);
__decorate([
    (0, graphql_1.Mutation)(() => test_kit_types_1.TestKit),
    __param(0, (0, graphql_1.Args)('id')),
    __param(1, (0, graphql_1.Args)('input')),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String, test_kit_input_1.UpdateTestKitInput]),
    __metadata("design:returntype", Promise)
], TestKitResolver.prototype, "updateTestKit", null);
__decorate([
    (0, graphql_1.Mutation)(() => test_kit_types_1.TestKit),
    __param(0, (0, graphql_1.Args)('id')),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String]),
    __metadata("design:returntype", Promise)
], TestKitResolver.prototype, "removeTestKit", null);
__decorate([
    (0, graphql_1.Mutation)(() => test_kit_types_1.TestKit),
    __param(0, (0, graphql_1.Args)('id')),
    __param(1, (0, graphql_1.Args)('userId')),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String, String]),
    __metadata("design:returntype", Promise)
], TestKitResolver.prototype, "assignTestKitToUser", null);
__decorate([
    (0, graphql_1.Mutation)(() => test_kit_types_1.TestKit),
    __param(0, (0, graphql_1.Args)('id')),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String]),
    __metadata("design:returntype", Promise)
], TestKitResolver.prototype, "markTestKitAsUsed", null);
exports.TestKitResolver = TestKitResolver = __decorate([
    (0, graphql_1.Resolver)(() => test_kit_types_1.TestKit),
    __metadata("design:paramtypes", [test_kit_service_1.TestKitService])
], TestKitResolver);
//# sourceMappingURL=test-kit.resolver.js.map