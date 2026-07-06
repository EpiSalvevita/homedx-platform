import { PrismaClient } from '@prisma/client';
import * as bcrypt from 'bcrypt';
import * as crypto from 'crypto';

const prisma = new PrismaClient();

/**
 * Seeds realistic demo data (availability + patients + appointments) for a
 * single existing DOCTOR account, so the doctor web portal isn't empty
 * during manual UI testing.
 *
 * Usage: MOCK_DOCTOR_EMAIL=someone@example.com npx ts-node prisma/seed-mock-doctor-data.ts
 * Defaults to epirot.alija@salvevita.de when the env var isn't set.
 */
const DOCTOR_EMAIL = process.env.MOCK_DOCTOR_EMAIL?.trim() || 'epirot.alija@salvevita.de';

const defaultAvailability = [
  { dayOfWeek: 1, startTime: '09:00', endTime: '17:00', slotMinutes: 30 },
  { dayOfWeek: 2, startTime: '09:00', endTime: '17:00', slotMinutes: 30 },
  { dayOfWeek: 3, startTime: '09:00', endTime: '17:00', slotMinutes: 30 },
  { dayOfWeek: 4, startTime: '09:00', endTime: '17:00', slotMinutes: 30 },
  { dayOfWeek: 5, startTime: '09:00', endTime: '17:00', slotMinutes: 30 },
];

const mockPatients = [
  { email: 'mock-patient-1@homedx.test', firstName: 'Maria', lastName: 'Fischer', gender: 'FEMALE' as const },
  { email: 'mock-patient-2@homedx.test', firstName: 'Jonas', lastName: 'Weber', gender: 'MALE' as const },
  { email: 'mock-patient-3@homedx.test', firstName: 'Lea', lastName: 'Hoffmann', gender: 'FEMALE' as const },
  { email: 'mock-patient-4@homedx.test', firstName: 'Tobias', lastName: 'Krüger', gender: 'MALE' as const },
];

function hoursFromNow(hours: number): Date {
  return new Date(Date.now() + hours * 60 * 60 * 1000);
}

function fallbackVideoRoom(id: string) {
  const roomName = `homedx-mock-${id}`;
  return { videoRoomName: roomName, videoRoomUrl: `https://homedx.daily.co/${roomName}` };
}

async function main() {
  const doctorUser = await prisma.user.findUnique({ where: { email: DOCTOR_EMAIL } });
  if (!doctorUser) {
    throw new Error(`No user found with email "${DOCTOR_EMAIL}". Register the account first.`);
  }
  if (doctorUser.role !== 'DOCTOR') {
    throw new Error(`User "${DOCTOR_EMAIL}" is not a DOCTOR (role=${doctorUser.role}).`);
  }

  let profile = await prisma.doctorProfile.findUnique({ where: { userId: doctorUser.id } });
  if (!profile) {
    profile = await prisma.doctorProfile.create({
      data: {
        userId: doctorUser.id,
        specialization: 'Endokrinologie',
        isActive: true,
      },
    });
  }

  profile = await prisma.doctorProfile.update({
    where: { id: profile.id },
    data: {
      bio: profile.bio?.trim() ? profile.bio : `Facharzt/Fachärztin für ${profile.specialization} mit Schwerpunkt auf präventiver Diagnostik.`,
      languages: profile.languages.length > 0 ? profile.languages : ['Deutsch', 'Englisch'],
      rating: profile.rating > 0 ? profile.rating : 4.6,
      reviewCount: profile.reviewCount > 0 ? profile.reviewCount : 34,
      isActive: true,
    },
  });
  console.log(`Doctor profile ready: ${DOCTOR_EMAIL} (${profile.specialization})`);

  await prisma.doctorAvailability.deleteMany({ where: { doctorId: profile.id } });
  for (const slot of defaultAvailability) {
    await prisma.doctorAvailability.create({ data: { doctorId: profile.id, ...slot } });
  }
  console.log(`Seeded ${defaultAvailability.length} weekly availability rules.`);

  const seedPassword = process.env.SEED_PATIENT_PASSWORD?.trim();
  const password = await bcrypt.hash(seedPassword || crypto.randomBytes(24).toString('hex'), 12);

  const patients = [];
  for (const p of mockPatients) {
    const user = await prisma.user.upsert({
      where: { email: p.email },
      update: {},
      create: {
        email: p.email,
        password,
        firstName: p.firstName,
        lastName: p.lastName,
        gender: p.gender,
        emailVerified: true,
        status: 'ACTIVE',
      },
    });
    patients.push(user);
  }
  console.log(`Seeded ${patients.length} mock patients.`);

  // Clear previously seeded mock appointments for this doctor so the script is
  // idempotent (times are relative to "now" and would otherwise drift/duplicate).
  await prisma.appointment.deleteMany({
    where: { doctorId: profile.id, notes: { startsWith: '[mock]' } },
  });

  const appointments: Array<{
    patientId: string;
    scheduledAt: Date;
    type: 'ONLINE' | 'IN_PERSON';
    status: 'PENDING' | 'CONFIRMED' | 'COMPLETED';
    testTypeId: string | null;
    notes: string;
    video?: boolean;
  }> = [
    {
      patientId: patients[0].id,
      scheduledAt: hoursFromNow(-120),
      type: 'ONLINE',
      status: 'COMPLETED',
      testTypeId: 'vitamind',
      notes: '[mock] Nachbesprechung Vitamin-D-Test.',
      video: true,
    },
    {
      patientId: patients[1].id,
      scheduledAt: hoursFromNow(-48),
      type: 'IN_PERSON',
      status: 'COMPLETED',
      testTypeId: 'crp',
      notes: '[mock] Kontrolluntersuchung nach CRP-Schnelltest.',
    },
    {
      // Scheduled "now" so canJoin is true immediately for demoing the call flow.
      patientId: patients[2].id,
      scheduledAt: hoursFromNow(0),
      type: 'ONLINE',
      status: 'CONFIRMED',
      testTypeId: 'rheumacheck',
      notes: '[mock] Erstberatung nach positivem RheumaCheck.',
      video: true,
    },
    {
      patientId: patients[3].id,
      scheduledAt: hoursFromNow(3),
      type: 'IN_PERSON',
      status: 'CONFIRMED',
      testTypeId: null,
      notes: '[mock] Routineuntersuchung.',
    },
    {
      patientId: patients[0].id,
      scheduledAt: hoursFromNow(27),
      type: 'ONLINE',
      status: 'CONFIRMED',
      testTypeId: 'vitamind',
      notes: '[mock] Folgetermin Vitamin-D-Substitution.',
      video: true,
    },
    {
      patientId: patients[1].id,
      scheduledAt: hoursFromNow(72),
      type: 'IN_PERSON',
      status: 'PENDING',
      testTypeId: null,
      notes: '[mock] Neue Anfrage, noch nicht bestätigt.',
    },
  ];

  for (const [index, apt] of appointments.entries()) {
    const video = apt.video ? fallbackVideoRoom(`${profile.id.slice(-6)}-${index}`) : {};
    await prisma.appointment.create({
      data: {
        patientId: apt.patientId,
        doctorId: profile.id,
        scheduledAt: apt.scheduledAt,
        type: apt.type,
        status: apt.status,
        testTypeId: apt.testTypeId,
        notes: apt.notes,
        ...video,
      },
    });
  }
  console.log(`Seeded ${appointments.length} mock appointments for ${DOCTOR_EMAIL}.`);
}

main()
  .catch((e) => {
    console.error(e);
    process.exit(1);
  })
  .finally(async () => {
    await prisma.$disconnect();
  });
