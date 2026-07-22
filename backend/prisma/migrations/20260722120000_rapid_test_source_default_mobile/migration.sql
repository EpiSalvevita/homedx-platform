-- New RapidTest rows default to "mobile" instead of "legacy".
-- Existing rows are left unchanged (may still be "legacy", "cube", or "mobile").
ALTER TABLE "RapidTest" ALTER COLUMN "source" SET DEFAULT 'mobile';
