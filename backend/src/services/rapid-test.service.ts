import { Injectable } from '@nestjs/common';
import { Prisma } from '@prisma/client';
import { PrismaService } from './prisma.service';
import { CreateRapidTestInput, UpdateRapidTestInput } from '../dto/rapid-test.dto';

@Injectable()
export class RapidTestService {
  constructor(private prisma: PrismaService) {}

  private readonly includeRelations = {
    user: true,
    testKit: true,
    license: {
      include: {
        user: true,
      },
    },
  };

  async findAll() {
    return this.prisma.rapidTest.findMany({
      include: this.includeRelations,
    });
  }

  async findOne(id: string) {
    return this.prisma.rapidTest.findUnique({
      where: { id },
      include: this.includeRelations,
    });
  }

  async findByUserId(userId: string) {
    return this.prisma.rapidTest.findMany({
      where: { userId },
      include: this.includeRelations,
    });
  }

  async create(data: CreateRapidTestInput) {
    return this.prisma.rapidTest.create({
      data: {
        ...data,
        status: 'PENDING',
      },
      include: this.includeRelations,
    });
  }

  async update(id: string, data: UpdateRapidTestInput) {
    return this.prisma.rapidTest.update({
      where: { id },
      data: data as Prisma.RapidTestUpdateInput,
      include: this.includeRelations,
    });
  }

  async remove(id: string) {
    return this.prisma.rapidTest.delete({
      where: { id },
      include: this.includeRelations,
    });
  }
}
