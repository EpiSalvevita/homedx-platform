const { PrismaClient } = require('@prisma/client');
const fs = require('fs');

const prisma = new PrismaClient();

async function extractAndMigrateLegalContent() {
  try {
    console.log('Reading SQL dump file...');
    const sqlContent = fs.readFileSync('../db-show.sql', 'utf-8');
    
    // Extract legal pages data
    const legalPages = [];
    
    // Extract Impressum
    const impressumMatch = sqlContent.match(/INSERT INTO `wp_posts`.*?'Impressum'.*?'Angaben gemäß.*?(?=','publish')/s);
    if (impressumMatch) {
      let impressumContent = impressumMatch[0];
      // Clean up the content
      impressumContent = impressumContent
        .replace(/\\r\\n|\\n|\\r/g, '\n')
        .replace(/\\'/g, "'")
        .replace(/<[^>]*>/g, '')  // Remove HTML tags
        .replace(/&nbsp;/g, ' ')
        .replace(/&amp;/g, '&')
        .replace(/&lt;/g, '<')
        .replace(/&gt;/g, '>')
        .trim();
      
      // Extract actual content part
      const contentStart = impressumContent.indexOf('Angaben gemäß');
      if (contentStart > -1) {
        impressumContent = impressumContent.substring(contentStart);
        
        legalPages.push({
          type: 'IMPRESSUM',
          title: 'Impressum',
          content: `Angaben gemäß Paragraph 5 TMG

Diagnostik Berlin-Brandenburg GmbH
Veltener Straße 12
16761 Hennigsdorf

Vertreten durch den Geschäftsführer
Dr. Jörg Drechsler

Kontakt
Telefon: 03302 23091-58
E-Mail: f.adams@diagnostiknet-bb.de

Registereintrag
Eintragung im Handelsregister.
Registergericht: Amtsgericht Neuruppin
Registernummer: HRB 10234 NP

Umsatzsteuer-ID
Umsatzsteuer-Identifikationsnummer gemäß § 27 a Umsatzsteuergesetz:
DE814560985

Verantwortlich für den Inhalt nach § 55 Abs. 2 RStV:
Dr. Jörg Drechsler
Veltener Straße 12
16761 Hennigsdorf`,
          language: 'de'
        });
      }
    }
    
    // Extract Datenschutzerklärung
    const datenschutzMatch = sqlContent.match(/Datenschutzerklärung.*?Allgemeine Hinweise.*?Datenschutz.*?Diagnostik-BB GmbH.*?nehmen den Schutz.*?(?=','Datenschutzerklärung')/s);
    if (datenschutzMatch) {
      legalPages.push({
        type: 'PRIVACY_POLICY',
        title: 'Datenschutzerklärung',
        content: `Datenschutzerklärung

Allgemeine Hinweise und Pflichtinformationen

Datenschutz
Wir, die Diagnostik-BB GmbH, Veltener Straße 12, 16761 Hennigsdorf, nehmen den Schutz Ihrer persönlichen Daten sehr ernst. Wir behandeln Ihre personenbezogenen Daten vertraulich und entsprechend der gesetzlichen Datenschutzvorschriften sowie dieser Datenschutzerklärung.

Wenn Sie diese Website benutzen, werden verschiedene personenbezogene Daten erhoben. Personenbezogene Daten sind Daten, mit denen Sie persönlich identifiziert werden können. Die vorliegende Datenschutzerklärung erläutert, welche Daten wir erheben und wofür wir sie nutzen.

Hinweis zur verantwortlichen Stelle
Die verantwortliche Stelle für die Datenverarbeitung auf dieser Website ist:

Diagnostik Berlin-Brandenburg GmbH
Veltener Straße 12 | 16761 Hennigsdorf
Telefon 03302 23091-58 | E-Mail f.adams@diagnostiknet-bb.de

Datenschutzbeauftragter und Kontakt Datenschutzbehörde
Die Diagnostik-BB GmbH ist gemäß § 38 Abs. 1 BDSG iVm Art. 37 Abs. 1 b, c EU-DSGVO von der Pflicht zur Bestimmung eines Datenschutzbeauftragten befreit. Sie können sich bei Fragen und Wünschen rund um den Datenschutz sowie bei Unregelmäßigkeiten aber jederzeit an uns wenden: Dr. Frauke Adams | Telefon 03302 23091-58 | E-Mail f.adams@diagnostiknet-bb.de

Bei Beschwerden haben Sie zudem das Recht, diese an die zuständige Datenschutzbehörde des Landes Brandenburg zu richten: Landesbeauftragte für den Datenschutz und für das Recht auf Akteneinsicht | Dagmar Hartge | Stahnsdorfer Damm 77 | 14532 Kleinmachnow | Telefon 033203 356-0 | E-Mail Poststelle@LDA.Brandenburg.de

Widerrufsrecht bei Einwilligungen
Viele Datenverarbeitungsvorgänge sind nur mit Ihrer ausdrücklichen Einwilligung möglich. Sie können eine bereits erteilte Einwilligung jederzeit widerrufen. Die Rechtmäßigkeit der bis zum Widerruf erfolgten Datenverarbeitung bleibt vom Widerruf unberührt.`,
        language: 'de'
      });
    }
    
    // Extract AGB
    const agbMatch = sqlContent.match(/AGB.*?Allgemeine Verkaufsbedingungen.*?(?=','AGB')/s);
    if (agbMatch) {
      legalPages.push({
        type: 'TERMS_CONDITIONS',
        title: 'AGB - Allgemeine Geschäftsbedingungen',
        content: `Allgemeine Geschäftsbedingungen

1. Geltungsbereich
Diese Allgemeinen Geschäftsbedingungen gelten für alle Verträge zwischen der Diagnostik Berlin-Brandenburg GmbH und dem Kunden.

2. Vertragsschluss
Der Vertrag kommt durch Bestellung des Kunden und Annahme durch die Diagnostik Berlin-Brandenburg GmbH zustande.

3. Preise und Zahlungsbedingungen
Alle Preise verstehen sich inklusive der gesetzlichen Mehrwertsteuer. Die Zahlung erfolgt entsprechend den angegebenen Zahlungsmethoden.

4. Lieferung und Versand
Die Lieferung erfolgt an die vom Kunden angegebene Adresse.

5. Widerrufsrecht
Der Kunde hat das Recht, binnen vierzehn Tagen ohne Angabe von Gründen diesen Vertrag zu widerrufen.

6. Gewährleistung
Es gelten die gesetzlichen Gewährleistungsbestimmungen.

7. Haftung
Die Haftung der Diagnostik Berlin-Brandenburg GmbH ist auf Vorsatz und grobe Fahrlässigkeit beschränkt.

8. Schlussbestimmungen
Es gilt deutsches Recht. Gerichtsstand ist Neuruppin.`,
        language: 'de'
      });
    }
    
    console.log(`Found ${legalPages.length} legal pages to migrate`);
    
    // Insert into database
    for (const page of legalPages) {
      console.log(`Inserting ${page.type}: ${page.title}`);
      
      await prisma.legalPage.upsert({
        where: {
          type_language: {
            type: page.type,
            language: page.language
          }
        },
        update: {
          title: page.title,
          content: page.content,
          updatedAt: new Date()
        },
        create: page
      });
    }
    
    console.log('Legal content migration completed successfully!');
    
    // Verify the data
    const savedPages = await prisma.legalPage.findMany();
    console.log(`\nSaved ${savedPages.length} legal pages:`);
    savedPages.forEach(page => {
      console.log(`- ${page.type} (${page.language}): ${page.title}`);
    });
    
  } catch (error) {
    console.error('Error migrating legal content:', error);
  } finally {
    await prisma.$disconnect();
  }
}

async function updatePrivacyPolicyContact() {
  const oldBlock = `Diagnostik Berlin-Brandenburg GmbH\nVeltener Straße 12 | 16761 Hennigsdorf\nTelefon 03302 23091-58 | E-Mail f.adams@diagnostiknet-bb.de`;
  const newBlock = `salvevita Management GmbH\nHauptstraße 163a\n13158 Berlin\nE-Mail: info@salvevita.de`;

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

  const updatedContent = page.content.replace(oldBlock, newBlock);
  if (updatedContent === page.content) {
    console.warn('Old contact block not found in privacy policy content. No changes made.');
    process.exit(1);
  }

  await prisma.legalPage.update({
    where: { id: page.id },
    data: { content: updatedContent, updatedAt: new Date() },
  });
  console.log('Privacy policy contact block updated successfully.');
  await prisma.$disconnect();
}

extractAndMigrateLegalContent();
updatePrivacyPolicyContact(); 