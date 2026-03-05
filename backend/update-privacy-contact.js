const { PrismaClient } = require('@prisma/client');
const prisma = new PrismaClient();

async function updateImpressum() {
  const newImpressum = `salvevita Managementgesellschaft mbH\nHauptstraße 163a\n13158 Berlin\n\nAmtsgericht Charlottenburg HRB 241406 B\nUmsatzsteuer-ID DE353284481\n\nGeschäftsführer: Dr Robert Lange`;

  const page = await prisma.legalPage.findFirst({
    where: {
      type: 'IMPRESSUM',
      language: 'de',
      isActive: true,
    },
    orderBy: { updatedAt: 'desc' },
  });

  if (!page) {
    console.error('No active German Impressum found!');
    process.exit(1);
  }

  await prisma.legalPage.update({
    where: { id: page.id },
    data: { content: newImpressum, updatedAt: new Date() },
  });
  console.log('Impressum updated successfully (without the word Impressum at the top).');
  await prisma.$disconnect();
}

async function updatePrivacyPolicyCompanyLine() {
  const oldLine = 'Wir, die Diagnostik-BB GmbH, Veltener Straße 12, 16761 Hennigsdorf,';
  const newLine = 'Wir, die salvevita Management GmbH, Hauptstraße 163a, 13158 Berlin,';

  const page = await prisma.legalPage.findFirst({
    where: {
      type: 'PRIVACY_POLICY',
      language: 'de',
      isActive: true,
    },
    orderBy: { updatedAt: 'desc' },
  });

  if (!page) {
    console.error('No active German privacy policy found!');
    process.exit(1);
  }

  const updatedContent = page.content.replace(oldLine, newLine);
  if (updatedContent === page.content) {
    console.warn('Old company line not found in privacy policy content. No changes made.');
    process.exit(1);
  }

  await prisma.legalPage.update({
    where: { id: page.id },
    data: { content: updatedContent, updatedAt: new Date() },
  });
  console.log('Privacy policy company line updated successfully.');
  await prisma.$disconnect();
}

updateImpressum();
updatePrivacyPolicyCompanyLine(); 