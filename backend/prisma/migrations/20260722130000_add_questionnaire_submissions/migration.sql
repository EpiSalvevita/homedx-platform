-- Questionnaire submissions (RheumaCheck A–D) — was in schema via db push but never migrated for CI.

-- CreateEnum
CREATE TYPE "QuestionnaireSubmissionStatus" AS ENUM ('DRAFT', 'SUBMITTED');

-- CreateEnum
CREATE TYPE "QuestionnaireConsentStatus" AS ENUM ('YES', 'NO', 'WITHDRAWN', 'NOT_APPLICABLE');

-- AlterEnum
ALTER TYPE "AuditEntityType" ADD VALUE 'QUESTIONNAIRE_SUBMISSION';

-- CreateTable
CREATE TABLE "QuestionnaireSubmission" (
    "id" TEXT NOT NULL,
    "userId" TEXT NOT NULL,
    "moduleId" TEXT NOT NULL,
    "moduleVersion" TEXT NOT NULL,
    "respondentType" TEXT NOT NULL,
    "status" "QuestionnaireSubmissionStatus" NOT NULL DEFAULT 'DRAFT',
    "consentStatus" "QuestionnaireConsentStatus" NOT NULL DEFAULT 'NOT_APPLICABLE',
    "language" TEXT NOT NULL DEFAULT 'de-DE',
    "answers" JSONB NOT NULL DEFAULT '{}',
    "linkedRapidTestId" TEXT,
    "submittedAt" TIMESTAMP(3),
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "QuestionnaireSubmission_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE INDEX "QuestionnaireSubmission_userId_moduleId_idx" ON "QuestionnaireSubmission"("userId", "moduleId");

-- CreateIndex
CREATE INDEX "QuestionnaireSubmission_moduleId_status_idx" ON "QuestionnaireSubmission"("moduleId", "status");

-- CreateIndex
CREATE INDEX "QuestionnaireSubmission_linkedRapidTestId_idx" ON "QuestionnaireSubmission"("linkedRapidTestId");

-- AddForeignKey
ALTER TABLE "QuestionnaireSubmission" ADD CONSTRAINT "QuestionnaireSubmission_userId_fkey" FOREIGN KEY ("userId") REFERENCES "User"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "QuestionnaireSubmission" ADD CONSTRAINT "QuestionnaireSubmission_linkedRapidTestId_fkey" FOREIGN KEY ("linkedRapidTestId") REFERENCES "RapidTest"("id") ON DELETE SET NULL ON UPDATE CASCADE;
