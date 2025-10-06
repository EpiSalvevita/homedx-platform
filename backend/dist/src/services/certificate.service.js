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
exports.CertificateService = void 0;
const common_1 = require("@nestjs/common");
const prisma_service_1 = require("./prisma.service");
const certificate_types_1 = require("../graphql/types/certificate.types");
let CertificateService = class CertificateService {
    constructor(prisma) {
        this.prisma = prisma;
    }
    mapCertificateType(type) {
        switch (type) {
            case 'TEST_RESULT':
                return certificate_types_1.CertificateType.TEST_RESULT;
            case 'VACCINATION':
                return certificate_types_1.CertificateType.VACCINATION;
            case 'RECOVERY':
                return certificate_types_1.CertificateType.RECOVERY;
            case 'MEDICAL_CLEARANCE':
                return certificate_types_1.CertificateType.MEDICAL_CLEARANCE;
            default:
                return certificate_types_1.CertificateType.TEST_RESULT;
        }
    }
    mapCertificateStatus(status) {
        switch (status) {
            case 'DRAFT':
                return certificate_types_1.CertificateStatus.DRAFT;
            case 'ISSUED':
                return certificate_types_1.CertificateStatus.ISSUED;
            case 'EXPIRED':
                return certificate_types_1.CertificateStatus.EXPIRED;
            case 'REVOKED':
                return certificate_types_1.CertificateStatus.REVOKED;
            default:
                return certificate_types_1.CertificateStatus.DRAFT;
        }
    }
    mapCertificateToGraphQL(certificate) {
        return Object.assign(Object.assign({}, certificate), { type: this.mapCertificateType(certificate.type), status: this.mapCertificateStatus(certificate.status) });
    }
    async findAll() {
        const certificates = await this.prisma.certificate.findMany({
            include: {
                user: true,
                rapidTest: {
                    include: {
                        user: true,
                        testKit: true,
                    },
                },
            },
        });
        return certificates.map(certificate => this.mapCertificateToGraphQL(certificate));
    }
    async findOne(id) {
        const certificate = await this.prisma.certificate.findUnique({
            where: { id },
            include: {
                user: true,
                rapidTest: {
                    include: {
                        user: true,
                        testKit: true,
                    },
                },
            },
        });
        return certificate ? this.mapCertificateToGraphQL(certificate) : null;
    }
    async findByCertificateNumber(certificateNumber) {
        const certificate = await this.prisma.certificate.findUnique({
            where: { certificateNumber },
            include: {
                user: true,
                rapidTest: {
                    include: {
                        user: true,
                        testKit: true,
                    },
                },
            },
        });
        return certificate ? this.mapCertificateToGraphQL(certificate) : null;
    }
    async findByRapidTestId(rapidTestId) {
        const certificate = await this.prisma.certificate.findFirst({
            where: { rapidTestId },
            include: {
                user: true,
                rapidTest: {
                    include: {
                        user: true,
                        testKit: true,
                    },
                },
            },
        });
        return certificate ? this.mapCertificateToGraphQL(certificate) : null;
    }
    async findByUserId(userId) {
        const certificates = await this.prisma.certificate.findMany({
            where: { userId },
            include: {
                user: true,
                rapidTest: {
                    include: {
                        user: true,
                        testKit: true,
                    },
                },
            },
        });
        return certificates.map(certificate => this.mapCertificateToGraphQL(certificate));
    }
    async findValidByUserId(userId) {
        const now = new Date();
        const certificates = await this.prisma.certificate.findMany({
            where: {
                userId,
                status: 'ISSUED',
                validFrom: { lte: now },
                validUntil: { gte: now },
                revokedAt: null,
            },
            include: {
                user: true,
                rapidTest: {
                    include: {
                        user: true,
                        testKit: true,
                    },
                },
            },
        });
        return certificates.map(certificate => this.mapCertificateToGraphQL(certificate));
    }
    async create(data) {
        const certificate = await this.prisma.certificate.create({
            data: data,
            include: {
                user: true,
                rapidTest: {
                    include: {
                        user: true,
                        testKit: true,
                    },
                },
            },
        });
        return this.mapCertificateToGraphQL(certificate);
    }
    async update(id, data) {
        const certificate = await this.prisma.certificate.update({
            where: { id },
            data: data,
            include: {
                user: true,
                rapidTest: {
                    include: {
                        user: true,
                        testKit: true,
                    },
                },
            },
        });
        return this.mapCertificateToGraphQL(certificate);
    }
    async remove(id) {
        const certificate = await this.prisma.certificate.delete({
            where: { id },
            include: {
                user: true,
                rapidTest: {
                    include: {
                        user: true,
                        testKit: true,
                    },
                },
            },
        });
        return this.mapCertificateToGraphQL(certificate);
    }
    async issue(id) {
        const certificate = await this.prisma.certificate.update({
            where: { id },
            data: {
                status: 'ISSUED',
                issuedAt: new Date(),
            },
            include: {
                user: true,
                rapidTest: {
                    include: {
                        user: true,
                        testKit: true,
                    },
                },
            },
        });
        return this.mapCertificateToGraphQL(certificate);
    }
    async revoke(id, reason) {
        const certificate = await this.prisma.certificate.update({
            where: { id },
            data: {
                status: 'REVOKED',
                revokedAt: new Date(),
                revokedReason: reason,
            },
            include: {
                user: true,
                rapidTest: {
                    include: {
                        user: true,
                        testKit: true,
                    },
                },
            },
        });
        return this.mapCertificateToGraphQL(certificate);
    }
    async generateQRCode(id) {
        return `https://api.example.com/certificates/${id}/qr`;
    }
    async generatePDF(id) {
        return `https://api.example.com/certificates/${id}/pdf`;
    }
};
exports.CertificateService = CertificateService;
exports.CertificateService = CertificateService = __decorate([
    (0, common_1.Injectable)(),
    __metadata("design:paramtypes", [prisma_service_1.PrismaService])
], CertificateService);
//# sourceMappingURL=certificate.service.js.map