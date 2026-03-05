-- CreateEnum
CREATE TYPE "LegalPageType" AS ENUM ('PRIVACY_POLICY', 'TERMS_CONDITIONS', 'IMPRESSUM', 'COOKIE_POLICY');

-- CreateTable
CREATE TABLE "LegalPage" (
    "id" TEXT NOT NULL,
    "type" "LegalPageType" NOT NULL,
    "title" TEXT NOT NULL,
    "content" TEXT NOT NULL,
    "language" TEXT NOT NULL DEFAULT 'de',
    "version" TEXT NOT NULL DEFAULT '1.0',
    "isActive" BOOLEAN NOT NULL DEFAULT true,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "LegalPage_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE UNIQUE INDEX "LegalPage_type_language_key" ON "LegalPage"("type", "language");
