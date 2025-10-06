/*
  Warnings:

  - The primary key for the `License` table will be changed. If it partially fails, the table could be left without primary key constraint.
  - You are about to drop the column `code` on the `License` table. All the data in the column will be lost.
  - The `status` column on the `License` table would be dropped and recreated. This will lead to data loss if there is data in the column.
  - The primary key for the `Payment` table will be changed. If it partially fails, the table could be left without primary key constraint.
  - You are about to drop the column `paymentIntentId` on the `Payment` table. All the data in the column will be lost.
  - You are about to drop the column `paymentMethod` on the `Payment` table. All the data in the column will be lost.
  - The `status` column on the `Payment` table would be dropped and recreated. This will lead to data loss if there is data in the column.
  - The primary key for the `RapidTest` table will be changed. If it partially fails, the table could be left without primary key constraint.
  - You are about to drop the column `agreementGiven` on the `RapidTest` table. All the data in the column will be lost.
  - You are about to drop the column `certificateUrl` on the `RapidTest` table. All the data in the column will be lost.
  - You are about to drop the column `comment` on the `RapidTest` table. All the data in the column will be lost.
  - You are about to drop the column `identityCard1Url` on the `RapidTest` table. All the data in the column will be lost.
  - You are about to drop the column `identityCard2Url` on the `RapidTest` table. All the data in the column will be lost.
  - You are about to drop the column `identityCardId` on the `RapidTest` table. All the data in the column will be lost.
  - You are about to drop the column `paymentId` on the `RapidTest` table. All the data in the column will be lost.
  - You are about to drop the column `photoUrl` on the `RapidTest` table. All the data in the column will be lost.
  - You are about to drop the column `profilePicUrl` on the `RapidTest` table. All the data in the column will be lost.
  - You are about to drop the column `qrCode` on the `RapidTest` table. All the data in the column will be lost.
  - You are about to drop the column `testDeviceUrl` on the `RapidTest` table. All the data in the column will be lost.
  - You are about to drop the column `videoUrl` on the `RapidTest` table. All the data in the column will be lost.
  - The `status` column on the `RapidTest` table would be dropped and recreated. This will lead to data loss if there is data in the column.
  - The `result` column on the `RapidTest` table would be dropped and recreated. This will lead to data loss if there is data in the column.
  - The primary key for the `User` table will be changed. If it partially fails, the table could be left without primary key constraint.
  - You are about to drop the column `address1` on the `User` table. All the data in the column will be lost.
  - You are about to drop the column `address2` on the `User` table. All the data in the column will be lost.
  - You are about to drop the column `gender` on the `User` table. All the data in the column will be lost.
  - You are about to drop the column `postcode` on the `User` table. All the data in the column will be lost.
  - You are about to drop the column `profileImageUrl` on the `User` table. All the data in the column will be lost.
  - You are about to drop the column `title` on the `User` table. All the data in the column will be lost.
  - A unique constraint covering the columns `[licenseKey]` on the table `License` will be added. If there are existing duplicate values, this will fail.
  - Added the required column `licenseKey` to the `License` table without a default value. This is not possible if the table is not empty.
  - Added the required column `method` to the `Payment` table without a default value. This is not possible if the table is not empty.
  - Added the required column `testKitId` to the `RapidTest` table without a default value. This is not possible if the table is not empty.

*/
-- CreateEnum
CREATE TYPE "UserRole" AS ENUM ('ADMIN', 'USER', 'MODERATOR');

-- CreateEnum
CREATE TYPE "UserStatus" AS ENUM ('ACTIVE', 'INACTIVE', 'SUSPENDED');

-- CreateEnum
CREATE TYPE "TestKitType" AS ENUM ('COVID_19', 'FLU', 'STREP_THROAT', 'PREGNANCY', 'DRUG_TEST');

-- CreateEnum
CREATE TYPE "TestKitStatus" AS ENUM ('AVAILABLE', 'USED', 'EXPIRED', 'DAMAGED');

-- CreateEnum
CREATE TYPE "TestStatus" AS ENUM ('PENDING', 'IN_PROGRESS', 'COMPLETED', 'FAILED');

-- CreateEnum
CREATE TYPE "TestResult" AS ENUM ('POSITIVE', 'NEGATIVE', 'INVALID', 'INCONCLUSIVE');

-- CreateEnum
CREATE TYPE "LicenseStatus" AS ENUM ('ACTIVE', 'EXPIRED', 'REVOKED', 'SUSPENDED');

-- CreateEnum
CREATE TYPE "PaymentMethod" AS ENUM ('CREDIT_CARD', 'PAYPAL', 'BANK_TRANSFER', 'CRYPTO');

-- CreateEnum
CREATE TYPE "PaymentStatus" AS ENUM ('PENDING', 'COMPLETED', 'FAILED', 'REFUNDED', 'CANCELLED');

-- CreateEnum
CREATE TYPE "CertificateType" AS ENUM ('TEST_RESULT', 'VACCINATION', 'RECOVERY', 'MEDICAL_CLEARANCE');

-- CreateEnum
CREATE TYPE "CertificateStatus" AS ENUM ('DRAFT', 'ISSUED', 'EXPIRED', 'REVOKED');

-- CreateEnum
CREATE TYPE "AuditAction" AS ENUM ('CREATE', 'UPDATE', 'DELETE', 'LOGIN', 'LOGOUT', 'VIEW', 'EXPORT');

-- CreateEnum
CREATE TYPE "AuditEntityType" AS ENUM ('USER', 'RAPID_TEST', 'TEST_KIT', 'PAYMENT', 'CERTIFICATE', 'LICENSE');

-- CreateEnum
CREATE TYPE "NotificationType" AS ENUM ('TEST_RESULT', 'CERTIFICATE_READY', 'PAYMENT_SUCCESS', 'PAYMENT_FAILED', 'SYSTEM_UPDATE', 'SECURITY_ALERT');

-- CreateEnum
CREATE TYPE "NotificationStatus" AS ENUM ('UNREAD', 'READ', 'ARCHIVED');

-- CreateEnum
CREATE TYPE "NotificationPriority" AS ENUM ('LOW', 'MEDIUM', 'HIGH', 'URGENT');

-- DropForeignKey
ALTER TABLE "License" DROP CONSTRAINT "License_userId_fkey";

-- DropForeignKey
ALTER TABLE "Payment" DROP CONSTRAINT "Payment_userId_fkey";

-- DropForeignKey
ALTER TABLE "RapidTest" DROP CONSTRAINT "RapidTest_licenseId_fkey";

-- DropForeignKey
ALTER TABLE "RapidTest" DROP CONSTRAINT "RapidTest_paymentId_fkey";

-- DropForeignKey
ALTER TABLE "RapidTest" DROP CONSTRAINT "RapidTest_userId_fkey";

-- DropIndex
DROP INDEX "License_code_key";

-- DropIndex
DROP INDEX "RapidTest_paymentId_key";

-- AlterTable
ALTER TABLE "License" DROP CONSTRAINT "License_pkey",
DROP COLUMN "code",
ADD COLUMN     "description" TEXT,
ADD COLUMN     "licenseKey" TEXT NOT NULL,
ADD COLUMN     "revokedAt" TIMESTAMP(3),
ADD COLUMN     "revokedReason" TEXT,
ALTER COLUMN "id" DROP DEFAULT,
ALTER COLUMN "id" SET DATA TYPE TEXT,
ALTER COLUMN "userId" SET DATA TYPE TEXT,
DROP COLUMN "status",
ADD COLUMN     "status" "LicenseStatus" NOT NULL DEFAULT 'ACTIVE',
ADD CONSTRAINT "License_pkey" PRIMARY KEY ("id");
DROP SEQUENCE "License_id_seq";

-- AlterTable
ALTER TABLE "Payment" DROP CONSTRAINT "Payment_pkey",
DROP COLUMN "paymentIntentId",
DROP COLUMN "paymentMethod",
ADD COLUMN     "completedAt" TIMESTAMP(3),
ADD COLUMN     "description" TEXT,
ADD COLUMN     "failureReason" TEXT,
ADD COLUMN     "method" "PaymentMethod" NOT NULL,
ALTER COLUMN "id" DROP DEFAULT,
ALTER COLUMN "id" SET DATA TYPE TEXT,
ALTER COLUMN "userId" SET DATA TYPE TEXT,
DROP COLUMN "status",
ADD COLUMN     "status" "PaymentStatus" NOT NULL DEFAULT 'PENDING',
ADD CONSTRAINT "Payment_pkey" PRIMARY KEY ("id");
DROP SEQUENCE "Payment_id_seq";

-- AlterTable
ALTER TABLE "RapidTest" DROP CONSTRAINT "RapidTest_pkey",
DROP COLUMN "agreementGiven",
DROP COLUMN "certificateUrl",
DROP COLUMN "comment",
DROP COLUMN "identityCard1Url",
DROP COLUMN "identityCard2Url",
DROP COLUMN "identityCardId",
DROP COLUMN "paymentId",
DROP COLUMN "photoUrl",
DROP COLUMN "profilePicUrl",
DROP COLUMN "qrCode",
DROP COLUMN "testDeviceUrl",
DROP COLUMN "videoUrl",
ADD COLUMN     "completedAt" TIMESTAMP(3),
ADD COLUMN     "notes" TEXT,
ADD COLUMN     "resultImageUrl" TEXT,
ADD COLUMN     "testKitId" TEXT NOT NULL,
ALTER COLUMN "id" DROP DEFAULT,
ALTER COLUMN "id" SET DATA TYPE TEXT,
ALTER COLUMN "userId" SET DATA TYPE TEXT,
DROP COLUMN "status",
ADD COLUMN     "status" "TestStatus" NOT NULL DEFAULT 'PENDING',
DROP COLUMN "result",
ADD COLUMN     "result" "TestResult",
ALTER COLUMN "licenseId" SET DATA TYPE TEXT,
ADD CONSTRAINT "RapidTest_pkey" PRIMARY KEY ("id");
DROP SEQUENCE "RapidTest_id_seq";

-- AlterTable
ALTER TABLE "User" DROP CONSTRAINT "User_pkey",
DROP COLUMN "address1",
DROP COLUMN "address2",
DROP COLUMN "gender",
DROP COLUMN "postcode",
DROP COLUMN "profileImageUrl",
DROP COLUMN "title",
ADD COLUMN     "address" TEXT,
ADD COLUMN     "emailVerified" BOOLEAN NOT NULL DEFAULT false,
ADD COLUMN     "lastLoginAt" TIMESTAMP(3),
ADD COLUMN     "postalCode" TEXT,
ADD COLUMN     "role" "UserRole" NOT NULL DEFAULT 'USER',
ADD COLUMN     "status" "UserStatus" NOT NULL DEFAULT 'ACTIVE',
ALTER COLUMN "id" DROP DEFAULT,
ALTER COLUMN "id" SET DATA TYPE TEXT,
ADD CONSTRAINT "User_pkey" PRIMARY KEY ("id");
DROP SEQUENCE "User_id_seq";

-- CreateTable
CREATE TABLE "TestKit" (
    "id" TEXT NOT NULL,
    "serialNumber" TEXT NOT NULL,
    "type" "TestKitType" NOT NULL,
    "manufacturer" TEXT NOT NULL,
    "model" TEXT NOT NULL,
    "batchNumber" TEXT NOT NULL,
    "expirationDate" TIMESTAMP(3) NOT NULL,
    "status" "TestKitStatus" NOT NULL DEFAULT 'AVAILABLE',
    "userId" TEXT,
    "purchasedAt" TIMESTAMP(3),
    "usedAt" TIMESTAMP(3),
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "TestKit_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "Certificate" (
    "id" TEXT NOT NULL,
    "userId" TEXT NOT NULL,
    "rapidTestId" TEXT NOT NULL,
    "type" "CertificateType" NOT NULL,
    "status" "CertificateStatus" NOT NULL DEFAULT 'DRAFT',
    "certificateNumber" TEXT NOT NULL,
    "issuedAt" TIMESTAMP(3) NOT NULL,
    "validFrom" TIMESTAMP(3) NOT NULL,
    "validUntil" TIMESTAMP(3) NOT NULL,
    "qrCodeUrl" TEXT,
    "pdfUrl" TEXT,
    "revokedAt" TIMESTAMP(3),
    "revokedReason" TEXT,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "Certificate_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "AuditLog" (
    "id" TEXT NOT NULL,
    "userId" TEXT NOT NULL,
    "action" "AuditAction" NOT NULL,
    "entityType" "AuditEntityType" NOT NULL,
    "entityId" TEXT,
    "oldValues" TEXT,
    "newValues" TEXT,
    "ipAddress" TEXT,
    "userAgent" TEXT,
    "description" TEXT,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "AuditLog_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "Notification" (
    "id" TEXT NOT NULL,
    "userId" TEXT NOT NULL,
    "type" "NotificationType" NOT NULL,
    "status" "NotificationStatus" NOT NULL DEFAULT 'UNREAD',
    "priority" "NotificationPriority" NOT NULL DEFAULT 'MEDIUM',
    "title" TEXT NOT NULL,
    "message" TEXT NOT NULL,
    "data" TEXT,
    "readAt" TIMESTAMP(3),
    "archivedAt" TIMESTAMP(3),
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "Notification_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE UNIQUE INDEX "TestKit_serialNumber_key" ON "TestKit"("serialNumber");

-- CreateIndex
CREATE UNIQUE INDEX "Certificate_certificateNumber_key" ON "Certificate"("certificateNumber");

-- CreateIndex
CREATE UNIQUE INDEX "License_licenseKey_key" ON "License"("licenseKey");

-- AddForeignKey
ALTER TABLE "TestKit" ADD CONSTRAINT "TestKit_userId_fkey" FOREIGN KEY ("userId") REFERENCES "User"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "RapidTest" ADD CONSTRAINT "RapidTest_licenseId_fkey" FOREIGN KEY ("licenseId") REFERENCES "License"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "RapidTest" ADD CONSTRAINT "RapidTest_testKitId_fkey" FOREIGN KEY ("testKitId") REFERENCES "TestKit"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "RapidTest" ADD CONSTRAINT "RapidTest_userId_fkey" FOREIGN KEY ("userId") REFERENCES "User"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "License" ADD CONSTRAINT "License_userId_fkey" FOREIGN KEY ("userId") REFERENCES "User"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Payment" ADD CONSTRAINT "Payment_userId_fkey" FOREIGN KEY ("userId") REFERENCES "User"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Certificate" ADD CONSTRAINT "Certificate_rapidTestId_fkey" FOREIGN KEY ("rapidTestId") REFERENCES "RapidTest"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Certificate" ADD CONSTRAINT "Certificate_userId_fkey" FOREIGN KEY ("userId") REFERENCES "User"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "AuditLog" ADD CONSTRAINT "AuditLog_userId_fkey" FOREIGN KEY ("userId") REFERENCES "User"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Notification" ADD CONSTRAINT "Notification_userId_fkey" FOREIGN KEY ("userId") REFERENCES "User"("id") ON DELETE RESTRICT ON UPDATE CASCADE;
