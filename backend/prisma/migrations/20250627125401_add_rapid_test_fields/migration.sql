-- AlterTable
ALTER TABLE "RapidTest" ADD COLUMN     "agreementGiven" BOOLEAN NOT NULL DEFAULT false,
ADD COLUMN     "identityCard1Url" TEXT,
ADD COLUMN     "identityCard2Url" TEXT,
ADD COLUMN     "identityCardId" TEXT,
ADD COLUMN     "photoUrl" TEXT,
ADD COLUMN     "testDeviceUrl" TEXT,
ADD COLUMN     "videoUrl" TEXT;
