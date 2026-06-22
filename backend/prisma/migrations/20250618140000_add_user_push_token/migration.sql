-- Add optional FCM push token on users
ALTER TABLE "User" ADD COLUMN IF NOT EXISTS "pushToken" TEXT;
