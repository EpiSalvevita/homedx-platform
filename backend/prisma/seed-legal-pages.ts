import { PrismaClient, LegalPageType } from '@prisma/client';
import { readFileSync } from 'fs';
import { join } from 'path';

/**
 * Loads the German legal pages from prisma/legal-content/ into LegalPage.
 * Upserts by (type, language). Run with: npm run seed:legal
 *
 * The Datenschutz and AGB texts are drafts (see the banner at the top of each file).
 * Do not run this against a production database until those texts are reviewed.
 */
const prisma = new PrismaClient();

const PAGES: Array<{ type: LegalPageType; title: string; file: string; version: string }> = [
  { type: 'IMPRESSUM', title: 'Impressum', file: 'impressum.de.txt', version: '1.0' },
  { type: 'PRIVACY_POLICY', title: 'Datenschutzerklärung', file: 'datenschutz.de.txt', version: '0.1-entwurf' },
  { type: 'TERMS_CONDITIONS', title: 'AGB - Allgemeine Geschäftsbedingungen', file: 'agb.de.txt', version: '0.1-entwurf' },
];

async function main() {
  const dir = join(__dirname, 'legal-content');
  for (const page of PAGES) {
    const content = readFileSync(join(dir, page.file), 'utf8').trim();
    await prisma.legalPage.upsert({
      where: { type_language: { type: page.type, language: 'de' } },
      update: { title: page.title, content, version: page.version, isActive: true },
      create: { type: page.type, language: 'de', title: page.title, content, version: page.version, isActive: true },
    });
    console.log(`Loaded ${page.type} (${page.version})`);
  }
}

main()
  .catch((err) => {
    console.error(err);
    process.exitCode = 1;
  })
  .finally(() => prisma.$disconnect());
