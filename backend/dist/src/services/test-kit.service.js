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
exports.TestKitService = void 0;
const common_1 = require("@nestjs/common");
const prisma_service_1 = require("./prisma.service");
const test_kit_types_1 = require("../graphql/types/test-kit.types");
let TestKitService = class TestKitService {
    constructor(prisma) {
        this.prisma = prisma;
    }
    mapTestKitType(type) {
        switch (type) {
            case 'COVID_19':
                return test_kit_types_1.TestKitType.COVID_19;
            case 'FLU':
                return test_kit_types_1.TestKitType.FLU;
            case 'STREP_THROAT':
                return test_kit_types_1.TestKitType.STREP_THROAT;
            case 'PREGNANCY':
                return test_kit_types_1.TestKitType.PREGNANCY;
            case 'DRUG_TEST':
                return test_kit_types_1.TestKitType.DRUG_TEST;
            default:
                return test_kit_types_1.TestKitType.COVID_19;
        }
    }
    mapTestKitStatus(status) {
        switch (status) {
            case 'AVAILABLE':
                return test_kit_types_1.TestKitStatus.AVAILABLE;
            case 'USED':
                return test_kit_types_1.TestKitStatus.USED;
            case 'EXPIRED':
                return test_kit_types_1.TestKitStatus.EXPIRED;
            case 'DAMAGED':
                return test_kit_types_1.TestKitStatus.DAMAGED;
            default:
                return test_kit_types_1.TestKitStatus.AVAILABLE;
        }
    }
    mapTestKitToGraphQL(testKit) {
        return Object.assign(Object.assign({}, testKit), { type: this.mapTestKitType(testKit.type), status: this.mapTestKitStatus(testKit.status) });
    }
    async findAll() {
        const testKits = await this.prisma.testKit.findMany({
            include: {
                user: true,
                rapidTests: {
                    include: {
                        user: true,
                        testKit: true,
                    },
                },
            },
        });
        return testKits.map(testKit => this.mapTestKitToGraphQL(testKit));
    }
    async findOne(id) {
        const testKit = await this.prisma.testKit.findUnique({
            where: { id },
            include: {
                user: true,
                rapidTests: {
                    include: {
                        user: true,
                        testKit: true,
                    },
                },
            },
        });
        return testKit ? this.mapTestKitToGraphQL(testKit) : null;
    }
    async findBySerialNumber(serialNumber) {
        const testKit = await this.prisma.testKit.findUnique({
            where: { serialNumber },
            include: {
                user: true,
                rapidTests: {
                    include: {
                        user: true,
                        testKit: true,
                    },
                },
            },
        });
        return testKit ? this.mapTestKitToGraphQL(testKit) : null;
    }
    async findAvailable() {
        const testKits = await this.prisma.testKit.findMany({
            where: { status: 'AVAILABLE' },
            include: {
                user: true,
                rapidTests: {
                    include: {
                        user: true,
                        testKit: true,
                    },
                },
            },
        });
        return testKits.map(testKit => this.mapTestKitToGraphQL(testKit));
    }
    async findByUserId(userId) {
        const testKits = await this.prisma.testKit.findMany({
            where: { userId },
            include: {
                user: true,
                rapidTests: {
                    include: {
                        user: true,
                        testKit: true,
                    },
                },
            },
        });
        return testKits.map(testKit => this.mapTestKitToGraphQL(testKit));
    }
    async create(data) {
        const testKit = await this.prisma.testKit.create({
            data: data,
            include: {
                user: true,
                rapidTests: {
                    include: {
                        user: true,
                        testKit: true,
                    },
                },
            },
        });
        return this.mapTestKitToGraphQL(testKit);
    }
    async update(id, data) {
        const testKit = await this.prisma.testKit.update({
            where: { id },
            data: data,
            include: {
                user: true,
                rapidTests: {
                    include: {
                        user: true,
                        testKit: true,
                    },
                },
            },
        });
        return this.mapTestKitToGraphQL(testKit);
    }
    async remove(id) {
        const testKit = await this.prisma.testKit.delete({
            where: { id },
            include: {
                user: true,
                rapidTests: {
                    include: {
                        user: true,
                        testKit: true,
                    },
                },
            },
        });
        return this.mapTestKitToGraphQL(testKit);
    }
    async assignToUser(id, userId) {
        const testKit = await this.prisma.testKit.update({
            where: { id },
            data: {
                userId,
                status: 'AVAILABLE',
                purchasedAt: new Date(),
            },
            include: {
                user: true,
                rapidTests: {
                    include: {
                        user: true,
                        testKit: true,
                    },
                },
            },
        });
        return this.mapTestKitToGraphQL(testKit);
    }
    async markAsUsed(id) {
        const testKit = await this.prisma.testKit.update({
            where: { id },
            data: {
                status: 'USED',
                usedAt: new Date(),
            },
            include: {
                user: true,
                rapidTests: {
                    include: {
                        user: true,
                        testKit: true,
                    },
                },
            },
        });
        return this.mapTestKitToGraphQL(testKit);
    }
};
exports.TestKitService = TestKitService;
exports.TestKitService = TestKitService = __decorate([
    (0, common_1.Injectable)(),
    __metadata("design:paramtypes", [prisma_service_1.PrismaService])
], TestKitService);
//# sourceMappingURL=test-kit.service.js.map