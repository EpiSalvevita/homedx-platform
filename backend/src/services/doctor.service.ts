import { Injectable, NotFoundException } from '@nestjs/common';
import { PrismaService } from './prisma.service';
import { doctorMatchesTestType } from '../utils/test-specialization-mapping';

export interface DoctorListItem {
  id: string;
  name: string;
  specialization: string;
  imageUrl: string | null;
  rating: number;
  reviewCount: number;
  bio: string | null;
  languages: string[];
}

export interface AvailabilitySlotItem {
  id: string;
  dateTime: string;
  isAvailable: boolean;
  duration: number;
}

@Injectable()
export class DoctorService {
  constructor(private prisma: PrismaService) {}

  async listDoctors(testTypeId?: string): Promise<DoctorListItem[]> {
    const doctors = await this.prisma.doctorProfile.findMany({
      where: { isActive: true },
      include: { user: true },
      orderBy: { rating: 'desc' },
    });

    const mapped = doctors.map((d) => ({
      id: d.id,
      name: `Dr. ${d.user.firstName} ${d.user.lastName}`,
      specialization: d.specialization,
      imageUrl: null,
      rating: d.rating,
      reviewCount: d.reviewCount,
      bio: d.bio,
      languages: d.languages,
    }));

    if (!testTypeId || testTypeId.trim().length === 0) {
      return mapped;
    }

    const filtered = mapped.filter((d) =>
      doctorMatchesTestType(testTypeId, d.specialization),
    );
    return filtered.length > 0 ? filtered : mapped;
  }

  async getDoctorProfileIdForUser(userId: string): Promise<string | null> {
    const profile = await this.prisma.doctorProfile.findUnique({
      where: { userId },
      select: { id: true },
    });
    return profile?.id ?? null;
  }

  async getAvailableSlots(
    doctorId: string,
    from?: Date,
    to?: Date,
  ): Promise<AvailabilitySlotItem[]> {
    const doctor = await this.prisma.doctorProfile.findUnique({
      where: { id: doctorId },
      include: { availability: true },
    });
    if (!doctor) {
      throw new NotFoundException('Doctor not found');
    }

    const start = from ?? new Date();
    const end = to ?? new Date(start.getTime() + 7 * 24 * 60 * 60 * 1000);

    const booked = await this.prisma.appointment.findMany({
      where: {
        doctorId,
        status: { in: ['PENDING', 'CONFIRMED'] },
        scheduledAt: { gte: start, lte: end },
      },
      select: { scheduledAt: true, durationMin: true },
    });

    const bookedTimes = new Set(
      booked.map((a) => a.scheduledAt.toISOString()),
    );

    const slots: AvailabilitySlotItem[] = [];
    const cursor = new Date(start);
    cursor.setHours(0, 0, 0, 0);

    while (cursor <= end) {
      const dayOfWeek = cursor.getDay() === 0 ? 7 : cursor.getDay();
      const dayRules = doctor.availability.filter((a) => a.dayOfWeek === dayOfWeek);

      for (const rule of dayRules) {
        const [startHour, startMin] = rule.startTime.split(':').map(Number);
        const [endHour, endMin] = rule.endTime.split(':').map(Number);
        const dayStart = new Date(cursor);
        dayStart.setHours(startHour, startMin, 0, 0);
        const dayEnd = new Date(cursor);
        dayEnd.setHours(endHour, endMin, 0, 0);

        let slotTime = new Date(dayStart);
        while (slotTime < dayEnd) {
          const slotEnd = new Date(slotTime.getTime() + rule.slotMinutes * 60 * 1000);
          if (slotEnd > dayEnd) break;

          if (slotTime > new Date() && !bookedTimes.has(slotTime.toISOString())) {
            slots.push({
              id: `${doctorId}_${slotTime.getTime()}`,
              dateTime: slotTime.toISOString(),
              isAvailable: true,
              duration: rule.slotMinutes,
            });
          }

          slotTime = slotEnd;
        }
      }

      cursor.setDate(cursor.getDate() + 1);
    }

    return slots.sort((a, b) => a.dateTime.localeCompare(b.dateTime));
  }

  async setAvailability(
    userId: string,
    slots: Array<{
      dayOfWeek: number;
      startTime: string;
      endTime: string;
      slotMinutes?: number;
    }>,
  ) {
    const profile = await this.prisma.doctorProfile.findUnique({
      where: { userId },
    });
    if (!profile) {
      throw new NotFoundException('Doctor profile not found');
    }

    await this.prisma.$transaction([
      this.prisma.doctorAvailability.deleteMany({
        where: { doctorId: profile.id },
      }),
      ...slots.map((slot) =>
        this.prisma.doctorAvailability.create({
          data: {
            doctorId: profile.id,
            dayOfWeek: slot.dayOfWeek,
            startTime: slot.startTime,
            endTime: slot.endTime,
            slotMinutes: slot.slotMinutes ?? 30,
          },
        }),
      ),
    ]);

    return this.prisma.doctorAvailability.findMany({
      where: { doctorId: profile.id },
      orderBy: { dayOfWeek: 'asc' },
    });
  }

  async getAvailability(userId: string) {
    const profile = await this.prisma.doctorProfile.findUnique({
      where: { userId },
      include: { availability: { orderBy: { dayOfWeek: 'asc' } } },
    });
    if (!profile) {
      throw new NotFoundException('Doctor profile not found');
    }
    return profile.availability;
  }
}
