import { Injectable } from '@nestjs/common';
import { PrismaService } from './prisma.service';
import { LegalPageType } from '../graphql/types/legal-page.types';

@Injectable()
export class LegalPageService {
  constructor(private prisma: PrismaService) {}

  async getLegalPage(type: LegalPageType, language: string = 'de') {
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

  async getLegalPages(
    types?: LegalPageType[],
    language: string = 'de',
    activeOnly: boolean = true,
  ) {
    const where: any = {
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

  async getAllLegalPageTypes(language: string = 'de') {
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
} 