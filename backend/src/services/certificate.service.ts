import { Injectable } from '@nestjs/common';
import { PrismaService } from './prisma.service';
import { CertificateType, CertificateStatus } from '../graphql/types/certificate.types';

@Injectable()
export class CertificateService {
  constructor(private prisma: PrismaService) {}

  private mapCertificateType(type: string): CertificateType {
    switch (type) {
      case 'TEST_RESULT':
        return CertificateType.TEST_RESULT;
      case 'VACCINATION':
        return CertificateType.VACCINATION;
      case 'RECOVERY':
        return CertificateType.RECOVERY;
      case 'MEDICAL_CLEARANCE':
        return CertificateType.MEDICAL_CLEARANCE;
      default:
        return CertificateType.TEST_RESULT;
    }
  }

  private mapCertificateStatus(status: string): CertificateStatus {
    switch (status) {
      case 'DRAFT':
        return CertificateStatus.DRAFT;
      case 'ISSUED':
        return CertificateStatus.ISSUED;
      case 'EXPIRED':
        return CertificateStatus.EXPIRED;
      case 'REVOKED':
        return CertificateStatus.REVOKED;
      default:
        return CertificateStatus.DRAFT;
    }
  }

  private mapCertificateToGraphQL(certificate: any) {
    return {
      ...certificate,
      type: this.mapCertificateType(certificate.type),
      status: this.mapCertificateStatus(certificate.status),
    };
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

  async findOne(id: string) {
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

  async findByCertificateNumber(certificateNumber: string) {
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

  async findByRapidTestId(rapidTestId: string) {
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

  async findByUserId(userId: string) {
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

  async findValidByUserId(userId: string) {
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

  async create(data: any) {
    const certificate = await this.prisma.certificate.create({
      data: data as any,
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

  async update(id: string, data: any) {
    const certificate = await this.prisma.certificate.update({
      where: { id },
      data: data as any,
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

  async remove(id: string) {
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

  async issue(id: string) {
    const certificate = await this.prisma.certificate.update({
      where: { id },
      data: {
        status: 'ISSUED' as any,
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

  async revoke(id: string, reason: string) {
    const certificate = await this.prisma.certificate.update({
      where: { id },
      data: {
        status: 'REVOKED' as any,
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

  async generateQRCode(id: string): Promise<string> {
    // This would typically generate a QR code and return the URL
    // For now, return a placeholder
    return `https://api.example.com/certificates/${id}/qr`;
  }

  async generatePDF(id: string): Promise<string> {
    // This would typically generate a PDF and return the URL
    // For now, return a placeholder
    return `https://api.example.com/certificates/${id}/pdf`;
  }
} 