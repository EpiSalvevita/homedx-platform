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
exports.RapidTestService = void 0;
const common_1 = require("@nestjs/common");
const prisma_service_1 = require("./prisma.service");
const rapid_test_type_1 = require("../graphql/types/rapid-test.type");
let RapidTestService = class RapidTestService {
    constructor(prisma) {
        this.prisma = prisma;
        this.includeRelations = {
            user: true,
            testKit: true,
            license: {
                include: {
                    user: true
                }
            }
        };
    }
    mapTestStatus(status) {
        switch (status) {
            case 'PENDING':
                return rapid_test_type_1.TestStatus.PENDING;
            case 'IN_PROGRESS':
                return rapid_test_type_1.TestStatus.IN_PROGRESS;
            case 'COMPLETED':
                return rapid_test_type_1.TestStatus.COMPLETED;
            case 'FAILED':
                return rapid_test_type_1.TestStatus.FAILED;
            default:
                return rapid_test_type_1.TestStatus.PENDING;
        }
    }
    mapTestResult(result) {
        if (!result)
            return null;
        switch (result) {
            case 'POSITIVE':
                return rapid_test_type_1.TestResult.POSITIVE;
            case 'NEGATIVE':
                return rapid_test_type_1.TestResult.NEGATIVE;
            case 'INVALID':
                return rapid_test_type_1.TestResult.INVALID;
            case 'INCONCLUSIVE':
                return rapid_test_type_1.TestResult.INCONCLUSIVE;
            default:
                return null;
        }
    }
    mapRapidTestToGraphQL(rapidTest) {
        return Object.assign(Object.assign({}, rapidTest), { status: this.mapTestStatus(rapidTest.status), result: this.mapTestResult(rapidTest.result) });
    }
    async findAll() {
        const rapidTests = await this.prisma.rapidTest.findMany({
            include: this.includeRelations
        });
        return rapidTests.map(test => this.mapRapidTestToGraphQL(test));
    }
    async findOne(id) {
        const rapidTest = await this.prisma.rapidTest.findUnique({
            where: { id },
            include: this.includeRelations
        });
        return rapidTest ? this.mapRapidTestToGraphQL(rapidTest) : null;
    }
    async findByUserId(userId) {
        const rapidTests = await this.prisma.rapidTest.findMany({
            where: { userId },
            include: this.includeRelations
        });
        return rapidTests.map(test => this.mapRapidTestToGraphQL(test));
    }
    async create(data) {
        const rapidTest = await this.prisma.rapidTest.create({
            data: Object.assign(Object.assign({}, data), { status: 'PENDING' }),
            include: this.includeRelations
        });
        return this.mapRapidTestToGraphQL(rapidTest);
    }
    async update(id, data) {
        const rapidTest = await this.prisma.rapidTest.update({
            where: { id },
            data: data,
            include: this.includeRelations
        });
        return this.mapRapidTestToGraphQL(rapidTest);
    }
    async remove(id) {
        const rapidTest = await this.prisma.rapidTest.delete({
            where: { id },
            include: this.includeRelations
        });
        return this.mapRapidTestToGraphQL(rapidTest);
    }
};
exports.RapidTestService = RapidTestService;
exports.RapidTestService = RapidTestService = __decorate([
    (0, common_1.Injectable)(),
    __metadata("design:paramtypes", [prisma_service_1.PrismaService])
], RapidTestService);
//# sourceMappingURL=rapid-test.service.js.map