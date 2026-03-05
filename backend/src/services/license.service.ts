import { Injectable } from '@nestjs/common';
import { PrismaService } from './prisma.service';
import { LicenseStatus } from '../graphql/types/license.type';

@Injectable()
export class LicenseService {
  constructor(private prisma: PrismaService) {}

  private mapLicenseStatus(status: string): LicenseStatus {
    switch (status) {
      case 'ACTIVE': return LicenseStatus.ACTIVE;
      case 'EXPIRED': return LicenseStatus.EXPIRED;
      case 'REVOKED': return LicenseStatus.REVOKED;
      default: return LicenseStatus.ACTIVE;
    }
  }

  private mapLicenseToGraphQL(license: any) {
    return {
      ...license,
      status: this.mapLicenseStatus(license.status),
    };
  }

  async findAll() {
    const licenses = await this.prisma.license.findMany({
      include: {
        user: true,
      }
    });
    return licenses.map(license => this.mapLicenseToGraphQL(license));
  }

  async findOne(id: string) {
    const license = await this.prisma.license.findUnique({
      where: { id },
      include: {
        user: true,
      }
    });
    return license ? this.mapLicenseToGraphQL(license) : null;
  }

  async findByUserId(userId: string) {
    const licenses = await this.prisma.license.findMany({
      where: { userId },
      include: {
        user: true,
      }
    });
    return licenses.map(license => this.mapLicenseToGraphQL(license));
  }

  async findByLicenseKey(licenseKey: string) {
    const license = await this.prisma.license.findUnique({
      where: { licenseKey },
      include: {
        user: true,
      }
    });
    return license ? this.mapLicenseToGraphQL(license) : null;
  }

  async create(data: any) {
    console.log('CreateLicenseInput received:', JSON.stringify(data, null, 2));
    const license = await this.prisma.license.create({
      data: {
        userId: data.userId,
        licenseKey: data.licenseKey,
        maxUses: data.maxUses,
        usesCount: 0,
        expiresAt: data.expiresAt,
        status: data.status as any
      },
      include: {
        user: true,
      }
    });
    return this.mapLicenseToGraphQL(license);
  }

  async update(id: string, data: any) {
    const { status, ...rest } = data;
    const license = await this.prisma.license.update({
      where: { id },
      data: {
        ...rest,
        ...(status ? { status: status as any } : {})
      },
      include: {
        user: true,
      }
    });
    return this.mapLicenseToGraphQL(license);
  }

  async remove(id: string) {
    const license = await this.prisma.license.delete({
      where: { id },
      include: {
        user: true,
      }
    });
    return this.mapLicenseToGraphQL(license);
  }

  async incrementUsesCount(id: string) {
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
} 