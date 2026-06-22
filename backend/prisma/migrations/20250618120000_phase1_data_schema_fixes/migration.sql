-- Phase 1 data: fix appointment testTypeId misuse, structured Cube fields, payment provider IDs

-- Appointment: rapidTestId was storing test type slugs (e.g. "rheumacheck"), not RapidTest IDs
ALTER TABLE "Appointment" RENAME COLUMN "rapidTestId" TO "testTypeId";

ALTER TABLE "Appointment" ADD COLUMN "linkedRapidTestId" TEXT;

-- RapidTest: first-class Cube metadata (notes JSON kept for backward compatibility)
ALTER TABLE "RapidTest" ADD COLUMN "testTypeId" TEXT;
ALTER TABLE "RapidTest" ADD COLUMN "source" TEXT DEFAULT 'legacy';
ALTER TABLE "RapidTest" ADD COLUMN "deviceSerial" TEXT;
ALTER TABLE "RapidTest" ADD COLUMN "cubeResultData" JSONB;
ALTER TABLE "RapidTest" ADD COLUMN "cubeRawData" JSONB;

-- Payment: provider-specific external IDs + optional link to a test
ALTER TABLE "Payment" ADD COLUMN "rapidTestId" TEXT;
ALTER TABLE "Payment" ADD COLUMN "stripePaymentIntentId" TEXT;
ALTER TABLE "Payment" ADD COLUMN "paypalOrderId" TEXT;

-- Backfill structured Cube fields from legacy notes JSON where possible
UPDATE "RapidTest"
SET
  "testTypeId" = CASE
    WHEN "notes" IS NOT NULL AND "notes" LIKE '{%' THEN ("notes"::json->>'testTypeId')
    ELSE NULL
  END,
  "source" = CASE
    WHEN "notes" IS NOT NULL AND "notes" LIKE '{%' THEN COALESCE("notes"::json->>'source', 'legacy')
    ELSE 'legacy'
  END,
  "deviceSerial" = CASE
    WHEN "notes" IS NOT NULL AND "notes" LIKE '{%' THEN ("notes"::json->>'deviceSerial')
    ELSE NULL
  END,
  "cubeResultData" = CASE
    WHEN "notes" IS NOT NULL AND "notes" LIKE '{%' THEN ("notes"::json->'resultData')
    ELSE NULL
  END,
  "cubeRawData" = CASE
    WHEN "notes" IS NOT NULL AND "notes" LIKE '{%' THEN ("notes"::json->'rawData')
    ELSE NULL
  END
WHERE "notes" IS NOT NULL;

ALTER TABLE "Appointment"
  ADD CONSTRAINT "Appointment_linkedRapidTestId_fkey"
  FOREIGN KEY ("linkedRapidTestId") REFERENCES "RapidTest"("id")
  ON DELETE SET NULL ON UPDATE CASCADE;

ALTER TABLE "Payment"
  ADD CONSTRAINT "Payment_rapidTestId_fkey"
  FOREIGN KEY ("rapidTestId") REFERENCES "RapidTest"("id")
  ON DELETE SET NULL ON UPDATE CASCADE;
