# Doctor Appointments and Video Calls

## Overview

Patients book online consultations in the Flutter mobile app. Doctors manage
availability and join calls from the same Flutter app built for **web**.

Video calls use [Daily.co](https://www.daily.co/) rooms created by the NestJS
backend when an online appointment is booked.

## Environment variables

Add to `backend/.env`:

```env
DAILY_API_KEY=your_daily_rest_api_key
DAILY_DOMAIN=your_daily_subdomain   # optional, e.g. homedx → homedx.daily.co
```

Without `DAILY_API_KEY`, the backend still creates appointments and returns
fallback room URLs for local development. Production video requires a valid
Daily API key.

## Database setup

```bash
cd backend
npx prisma migrate deploy
npm run seed:doctors
```

Seeded doctor accounts (password: `Doctor123!`):

| Email | Specialization |
|-------|----------------|
| sarah.mueller@homedx.local | Allgemeinmedizin |
| michael.schmidt@homedx.local | Innere Medizin |
| anna.weber@homedx.local | Kardiologie |
| klaus.becker@homedx.local | Rheumatologie |
| julia.schwarz@homedx.local | Pulmologie |

## API endpoints (mobile REST)

All endpoints use `POST` under `/gg-homedx-json/gg-api/v1` with JWT auth.

| Endpoint | Role | Purpose |
|----------|------|---------|
| `get-doctors` | Patient | List active doctors |
| `get-doctor-slots` | Patient | Available time slots |
| `book-appointment` | Patient | Book online consultation |
| `list-appointments` | Patient / Doctor | Role-scoped appointment list |
| `get-appointment` | Patient / Doctor | Single appointment |
| `cancel-appointment` | Patient / Doctor | Cancel appointment |
| `get-video-call-token` | Patient / Doctor | Daily join URL + token |
| `get-doctor-availability` | Doctor | Read weekly schedule |
| `set-doctor-availability` | Doctor | Update weekly schedule |

## Flutter clients

### Patient (mobile)

- Browse doctors: `/doctors`
- Book appointment: `/doctors/:id/appointment`
- View appointments: `/appointments`
- Join video call: `/appointments/:id/call` (available 10 min before until 30 min after scheduled time)

### Doctor (web)

```bash
cd frontend/mobile/hdx_mobile
flutter run -d chrome
```

Log in with a seeded `DOCTOR` account. The router redirects to
`/doctor/dashboard`.

- Dashboard: today's appointments + join call
- Availability: `/doctor/availability`
- Video call: `/doctor/appointments/:id/call`

## Manual E2E checklist

1. Run backend: `cd backend && npm run start:dev`
2. Migrate + seed doctors
3. Register or log in as a patient on mobile
4. Book an online appointment with a doctor for a slot within the next hour
5. Log in as the doctor on Flutter web (`flutter run -d chrome`)
6. On patient device, open appointment detail and tap **Videoanruf beitreten**
7. On doctor web dashboard, tap the video icon for the same appointment
8. Confirm both sides see each other in the Daily room
9. Cancel an appointment and verify both sides see `cancelled` status
10. Verify a third user cannot obtain a video token for someone else's appointment
