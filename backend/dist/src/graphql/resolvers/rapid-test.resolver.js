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
exports.RapidTestResolver = void 0;
const graphql_1 = require("@nestjs/graphql");
const rapid_test_type_1 = require("../types/rapid-test.type");
const rapid_test_input_1 = require("../types/rapid-test.input");
const rapid_test_service_1 = require("../../services/rapid-test.service");
const prisma_service_1 = require("../../services/prisma.service");
const current_user_decorator_1 = require("../../auth/current-user.decorator");
const user_type_1 = require("../types/user.type");
let RapidTestResolver = class RapidTestResolver {
    constructor(rapidTestService, prisma) {
        this.rapidTestService = rapidTestService;
        this.prisma = prisma;
    }
    async rapidTests() {
        return this.rapidTestService.findAll();
    }
    async rapidTest(id) {
        return this.rapidTestService.findOne(id);
    }
    async userRapidTests(userId) {
        return this.rapidTestService.findByUserId(userId);
    }
    async lastRapidTest(user) {
        if (!user || !user.id) {
            return null;
        }
        const userTests = await this.rapidTestService.findByUserId(user.id);
        return userTests.length > 0 ? userTests[userTests.length - 1] : null;
    }
    async testStatus(user) {
        const userTests = await this.rapidTestService.findByUserId(user.id);
        const lastTest = userTests.length > 0 ? userTests[userTests.length - 1] : null;
        return JSON.stringify({
            id: (lastTest === null || lastTest === void 0 ? void 0 : lastTest.id) || null,
            status: (lastTest === null || lastTest === void 0 ? void 0 : lastTest.status) || 'NO_TEST',
            result: (lastTest === null || lastTest === void 0 ? void 0 : lastTest.result) || null,
            createdAt: (lastTest === null || lastTest === void 0 ? void 0 : lastTest.createdAt) || null,
            updatedAt: (lastTest === null || lastTest === void 0 ? void 0 : lastTest.updatedAt) || null
        });
    }
    async liveToken() {
        return Math.floor(1000 + Math.random() * 9000).toString();
    }
    async cwaLink(rapidTestId) {
        return `https://cwa.example.com/test/${rapidTestId}`;
    }
    async submitTest(videoUrl, photoUrl, testDeviceUrl, testDate, liveToken, agreementGiven, paymentId, licenseCode, identityCard1Url, identityCard2Url, identifyUrl, identityCardId) {
        try {
            let testKit = await this.prisma.testKit.findFirst({
                where: { status: 'AVAILABLE' }
            });
            if (!testKit) {
                testKit = await this.prisma.testKit.create({
                    data: {
                        serialNumber: `DEFAULT-${Date.now()}`,
                        type: 'COVID_19',
                        manufacturer: 'Default Manufacturer',
                        model: 'Default Model',
                        batchNumber: 'DEFAULT-BATCH',
                        expirationDate: new Date(Date.now() + 365 * 24 * 60 * 60 * 1000),
                        status: 'AVAILABLE'
                    }
                });
            }
            const testInput = {
                testDate: new Date(testDate),
                videoUrl,
                photoUrl,
                testDeviceUrl,
                agreementGiven: agreementGiven || false,
                identityCard1Url,
                identityCard2Url,
                identityCardId,
                userId: 'cmc4w7oml0002v8zucjwlb0z7',
                testKitId: testKit.id
            };
            const newTest = await this.rapidTestService.create(testInput);
            return {
                success: true,
                validation: 'PENDING'
            };
        }
        catch (error) {
            console.error('Error in submitTest:', error);
            return {
                success: false,
                validation: 'FAILED'
            };
        }
    }
    async createRapidTest(input) {
        return this.rapidTestService.create(input);
    }
    async updateRapidTest(id, input) {
        return this.rapidTestService.update(id, input);
    }
    async removeRapidTest(id) {
        return this.rapidTestService.remove(id);
    }
};
exports.RapidTestResolver = RapidTestResolver;
__decorate([
    (0, graphql_1.Query)(() => [rapid_test_type_1.RapidTest]),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", []),
    __metadata("design:returntype", Promise)
], RapidTestResolver.prototype, "rapidTests", null);
__decorate([
    (0, graphql_1.Query)(() => rapid_test_type_1.RapidTest, { nullable: true }),
    __param(0, (0, graphql_1.Args)('id')),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String]),
    __metadata("design:returntype", Promise)
], RapidTestResolver.prototype, "rapidTest", null);
__decorate([
    (0, graphql_1.Query)(() => [rapid_test_type_1.RapidTest]),
    __param(0, (0, graphql_1.Args)('userId')),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String]),
    __metadata("design:returntype", Promise)
], RapidTestResolver.prototype, "userRapidTests", null);
__decorate([
    (0, graphql_1.Query)(() => rapid_test_type_1.RapidTest, { nullable: true }),
    __param(0, (0, current_user_decorator_1.CurrentUser)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [user_type_1.User]),
    __metadata("design:returntype", Promise)
], RapidTestResolver.prototype, "lastRapidTest", null);
__decorate([
    (0, graphql_1.Query)(() => String),
    __param(0, (0, current_user_decorator_1.CurrentUser)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [user_type_1.User]),
    __metadata("design:returntype", Promise)
], RapidTestResolver.prototype, "testStatus", null);
__decorate([
    (0, graphql_1.Query)(() => String),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", []),
    __metadata("design:returntype", Promise)
], RapidTestResolver.prototype, "liveToken", null);
__decorate([
    (0, graphql_1.Query)(() => String),
    __param(0, (0, graphql_1.Args)('rapidTestId')),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String]),
    __metadata("design:returntype", Promise)
], RapidTestResolver.prototype, "cwaLink", null);
__decorate([
    (0, graphql_1.Mutation)(() => rapid_test_type_1.SubmitTestResponse),
    __param(0, (0, graphql_1.Args)('videoUrl')),
    __param(1, (0, graphql_1.Args)('photoUrl')),
    __param(2, (0, graphql_1.Args)('testDeviceUrl')),
    __param(3, (0, graphql_1.Args)('testDate')),
    __param(4, (0, graphql_1.Args)('liveToken')),
    __param(5, (0, graphql_1.Args)('agreementGiven', { nullable: true })),
    __param(6, (0, graphql_1.Args)('paymentId', { nullable: true })),
    __param(7, (0, graphql_1.Args)('licenseCode', { nullable: true })),
    __param(8, (0, graphql_1.Args)('identityCard1Url', { nullable: true })),
    __param(9, (0, graphql_1.Args)('identityCard2Url', { nullable: true })),
    __param(10, (0, graphql_1.Args)('identifyUrl', { nullable: true })),
    __param(11, (0, graphql_1.Args)('identityCardId', { nullable: true })),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String, String, String, Number, String, Boolean, String, String, String, String, String, String]),
    __metadata("design:returntype", Promise)
], RapidTestResolver.prototype, "submitTest", null);
__decorate([
    (0, graphql_1.Mutation)(() => rapid_test_type_1.RapidTest),
    __param(0, (0, graphql_1.Args)('input')),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [rapid_test_input_1.CreateRapidTestInput]),
    __metadata("design:returntype", Promise)
], RapidTestResolver.prototype, "createRapidTest", null);
__decorate([
    (0, graphql_1.Mutation)(() => rapid_test_type_1.RapidTest),
    __param(0, (0, graphql_1.Args)('id')),
    __param(1, (0, graphql_1.Args)('input')),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String, rapid_test_input_1.UpdateRapidTestInput]),
    __metadata("design:returntype", Promise)
], RapidTestResolver.prototype, "updateRapidTest", null);
__decorate([
    (0, graphql_1.Mutation)(() => rapid_test_type_1.RapidTest),
    __param(0, (0, graphql_1.Args)('id')),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String]),
    __metadata("design:returntype", Promise)
], RapidTestResolver.prototype, "removeRapidTest", null);
exports.RapidTestResolver = RapidTestResolver = __decorate([
    (0, graphql_1.Resolver)(() => rapid_test_type_1.RapidTest),
    __metadata("design:paramtypes", [rapid_test_service_1.RapidTestService,
        prisma_service_1.PrismaService])
], RapidTestResolver);
//# sourceMappingURL=rapid-test.resolver.js.map