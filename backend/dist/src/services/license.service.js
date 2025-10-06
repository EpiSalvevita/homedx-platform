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
var __rest = (this && this.__rest) || function (s, e) {
    var t = {};
    for (var p in s) if (Object.prototype.hasOwnProperty.call(s, p) && e.indexOf(p) < 0)
        t[p] = s[p];
    if (s != null && typeof Object.getOwnPropertySymbols === "function")
        for (var i = 0, p = Object.getOwnPropertySymbols(s); i < p.length; i++) {
            if (e.indexOf(p[i]) < 0 && Object.prototype.propertyIsEnumerable.call(s, p[i]))
                t[p[i]] = s[p[i]];
        }
    return t;
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.LicenseService = void 0;
const common_1 = require("@nestjs/common");
const prisma_service_1 = require("./prisma.service");
const license_type_1 = require("../graphql/types/license.type");
let LicenseService = class LicenseService {
    constructor(prisma) {
        this.prisma = prisma;
    }
    mapLicenseStatus(status) {
        switch (status) {
            case 'ACTIVE': return license_type_1.LicenseStatus.ACTIVE;
            case 'EXPIRED': return license_type_1.LicenseStatus.EXPIRED;
            case 'REVOKED': return license_type_1.LicenseStatus.REVOKED;
            default: return license_type_1.LicenseStatus.ACTIVE;
        }
    }
    mapLicenseToGraphQL(license) {
        return Object.assign(Object.assign({}, license), { status: this.mapLicenseStatus(license.status) });
    }
    async findAll() {
        const licenses = await this.prisma.license.findMany({
            include: {
                user: true,
            }
        });
        return licenses.map(license => this.mapLicenseToGraphQL(license));
    }
    async findOne(id) {
        const license = await this.prisma.license.findUnique({
            where: { id },
            include: {
                user: true,
            }
        });
        return license ? this.mapLicenseToGraphQL(license) : null;
    }
    async findByUserId(userId) {
        const licenses = await this.prisma.license.findMany({
            where: { userId },
            include: {
                user: true,
            }
        });
        return licenses.map(license => this.mapLicenseToGraphQL(license));
    }
    async findByLicenseKey(licenseKey) {
        const license = await this.prisma.license.findUnique({
            where: { licenseKey },
            include: {
                user: true,
            }
        });
        return license ? this.mapLicenseToGraphQL(license) : null;
    }
    async create(data) {
        console.log('CreateLicenseInput received:', JSON.stringify(data, null, 2));
        const license = await this.prisma.license.create({
            data: {
                userId: data.userId,
                licenseKey: data.licenseKey,
                maxUses: data.maxUses,
                usesCount: 0,
                expiresAt: data.expiresAt,
                status: data.status
            },
            include: {
                user: true,
            }
        });
        return this.mapLicenseToGraphQL(license);
    }
    async update(id, data) {
        const { status } = data, rest = __rest(data, ["status"]);
        const license = await this.prisma.license.update({
            where: { id },
            data: Object.assign(Object.assign({}, rest), (status ? { status: status } : {})),
            include: {
                user: true,
            }
        });
        return this.mapLicenseToGraphQL(license);
    }
    async remove(id) {
        const license = await this.prisma.license.delete({
            where: { id },
            include: {
                user: true,
            }
        });
        return this.mapLicenseToGraphQL(license);
    }
    async incrementUsesCount(id) {
        const license = await this.prisma.license.update({
            where: { id },
            data: {
                usesCount: { increment: 1 }
            },
            include: {
                user: true,
            }
        });
        return this.mapLicenseToGraphQL(license);
    }
};
exports.LicenseService = LicenseService;
exports.LicenseService = LicenseService = __decorate([
    (0, common_1.Injectable)(),
    __metadata("design:paramtypes", [prisma_service_1.PrismaService])
], LicenseService);
//# sourceMappingURL=license.service.js.map