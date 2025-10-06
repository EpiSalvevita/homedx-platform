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
exports.LegalPageService = void 0;
const common_1 = require("@nestjs/common");
const prisma_service_1 = require("./prisma.service");
let LegalPageService = class LegalPageService {
    constructor(prisma) {
        this.prisma = prisma;
    }
    async getLegalPage(type, language = 'de') {
        return this.prisma.legalPage.findFirst({
            where: {
                type,
                language,
                isActive: true,
            },
            orderBy: {
                updatedAt: 'desc',
            },
        });
    }
    async getLegalPages(types, language = 'de', activeOnly = true) {
        const where = {
            language,
        };
        if (types && types.length > 0) {
            where.type = {
                in: types,
            };
        }
        if (activeOnly) {
            where.isActive = true;
        }
        const pages = await this.prisma.legalPage.findMany({
            where,
            orderBy: [
                { type: 'asc' },
                { updatedAt: 'desc' },
            ],
        });
        const total = await this.prisma.legalPage.count({ where });
        return {
            pages,
            total,
        };
    }
    async getAllLegalPageTypes(language = 'de') {
        const pages = await this.prisma.legalPage.findMany({
            where: {
                language,
                isActive: true,
            },
            select: {
                type: true,
                title: true,
            },
            distinct: ['type'],
            orderBy: {
                type: 'asc',
            },
        });
        return pages;
    }
};
exports.LegalPageService = LegalPageService;
exports.LegalPageService = LegalPageService = __decorate([
    (0, common_1.Injectable)(),
    __metadata("design:paramtypes", [prisma_service_1.PrismaService])
], LegalPageService);
//# sourceMappingURL=legal-page.service.js.map