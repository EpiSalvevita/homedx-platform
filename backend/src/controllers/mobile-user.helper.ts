import { Injectable } from '@nestjs/common';
import { PrismaService } from '../services/prisma.service';

@Injectable()
export class MobileUserHelper {
  constructor(private readonly prisma: PrismaService) {}

  async resolveUserRole(userId: string): Promise<string> {
    if (!userId) return 'USER';
    const user = await this.prisma.user.findUnique({
      where: { id: userId },
      select: { role: true },
    });
    return user?.role ?? 'USER';
  }
}
