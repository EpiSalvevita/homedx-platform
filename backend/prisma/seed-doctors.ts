import { PrismaClient } from '@prisma/client';
import * as bcrypt from 'bcrypt';
import * as crypto from 'crypto';

const prisma = new PrismaClient();

const doctors = [
  {
    email: 'sarah.mueller@homedx.local',
    firstName: 'Sarah',
    lastName: 'Müller',
    specialization: 'Allgemeinmedizin',
    bio: 'Erfahrene Allgemeinmedizinerin mit über 10 Jahren Erfahrung',
    languages: ['Deutsch', 'Englisch'],
    rating: 4.8,
    reviewCount: 127,
  },
  {
    email: 'michael.schmidt@homedx.local',
    firstName: 'Michael',
    lastName: 'Schmidt',
    specialization: 'Innere Medizin',
    bio: 'Spezialist für Innere Medizin und Präventivmedizin',
    languages: ['Deutsch', 'Englisch', 'Türkisch'],
    rating: 4.9,
    reviewCount: 203,
  },
  {
    email: 'anna.weber@homedx.local',
    firstName: 'Anna',
    lastName: 'Weber',
    specialization: 'Kardiologie',
    bio: 'Kardiologin mit Fokus auf präventive Herzgesundheit',
    languages: ['Deutsch', 'Englisch', 'Russisch'],
    rating: 4.7,
    reviewCount: 89,
  },
  {
    email: 'klaus.becker@homedx.local',
    firstName: 'Klaus',
    lastName: 'Becker',
    specialization: 'Rheumatologie',
    bio: 'Rheumatologe mit Schwerpunkt auf entzündlichen Gelenkerkrankungen',
    languages: ['Deutsch', 'Englisch', 'Türkisch'],
  },
  {
    email: 'julia.schwarz@homedx.local',
    firstName: 'Julia',
    lastName: 'Schwarz',
    specialization: 'Pulmologie',
    bio: 'Pulmologin mit Erfahrung in Atemwegserkrankungen und Post-COVID',
    languages: ['Deutsch', 'Englisch', 'Arabisch'],
  },
];

const defaultAvailability = [
  { dayOfWeek: 1, startTime: '09:00', endTime: '17:00', slotMinutes: 30 },
  { dayOfWeek: 2, startTime: '09:00', endTime: '17:00', slotMinutes: 30 },
  { dayOfWeek: 3, startTime: '09:00', endTime: '17:00', slotMinutes: 30 },
  { dayOfWeek: 4, startTime: '09:00', endTime: '17:00', slotMinutes: 30 },
  { dayOfWeek: 5, startTime: '09:00', endTime: '17:00', slotMinutes: 30 },
];

async function main() {
  const seedPassword = process.env.SEED_DOCTOR_PASSWORD?.trim();
  const password = seedPassword
    ? await bcrypt.hash(seedPassword, 12)
    : await bcrypt.hash(crypto.randomBytes(24).toString('hex'), 12);

  for (const doc of doctors) {
    const user = await prisma.user.upsert({
      where: { email: doc.email },
      update: {
        role: 'DOCTOR',
        firstName: doc.firstName,
        lastName: doc.lastName,
      },
      create: {
        email: doc.email,
        password,
        firstName: doc.firstName,
        lastName: doc.lastName,
        role: 'DOCTOR',
      },
    });

    const profile = await prisma.doctorProfile.upsert({
      where: { userId: user.id },
      update: {
        specialization: doc.specialization,
        bio: doc.bio,
        languages: doc.languages,
        rating: doc.rating,
        reviewCount: doc.reviewCount,
        isActive: true,
      },
      create: {
        userId: user.id,
        specialization: doc.specialization,
        bio: doc.bio,
        languages: doc.languages,
        rating: doc.rating,
        reviewCount: doc.reviewCount,
        isActive: true,
      },
    });

    await prisma.doctorAvailability.deleteMany({ where: { doctorId: profile.id } });
    for (const slot of defaultAvailability) {
      await prisma.doctorAvailability.create({
        data: {
          doctorId: profile.id,
          ...slot,
        },
      });
    }

    console.log(`Seeded doctor: ${doc.email}`);
  }
}

main()
  .catch((e) => {
    console.error(e);
    process.exit(1);
  })
  .finally(async () => {
    await prisma.$disconnect();
  });
