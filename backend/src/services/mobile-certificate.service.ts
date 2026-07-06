import { ForbiddenException, Injectable, Logger } from '@nestjs/common';
import * as fs from 'fs';
import * as path from 'path';
import PDFDocument from 'pdfkit';
import { PrismaService } from './prisma.service';
import { AuditLogService } from './audit-log.service';

/**
 * Results considered reliable enough to auto-certify. `INVALID` and
 * `INCONCLUSIVE` (and an unset `result`) do not auto-issue a certificate —
 * see docs/regulatory/gap-assessment.md and mdr-compliance.mdc §4 (ISO 14971).
 * This is a regulatory-relevant gate, not just a status check: changing it
 * changes what "having a certificate" implies about a test result.
 */
const CERTIFIABLE_RESULTS = new Set(['POSITIVE', 'NEGATIVE']);

export interface MobileCertificateRecord {
  id: string;
  certificateNumber: string;
  type: string;
  status: string;
  rapidTestId: string;
  testTypeId: string | null;
  testResult: string | null;
  issuedAt: string;
  validFrom: string;
  validUntil: string;
  pdfUrl: string | null;
  language: string | null;
}

@Injectable()
export class MobileCertificateService {
  private readonly logger = new Logger(MobileCertificateService.name);

  constructor(
    private readonly prisma: PrismaService,
    private readonly auditLogService: AuditLogService,
  ) {}

  async issueForRapidTest(rapidTestId: string): Promise<MobileCertificateRecord | null> {
    const rapidTest = await this.prisma.rapidTest.findUnique({
      where: { id: rapidTestId },
      include: { user: true },
    });
    if (!rapidTest || rapidTest.status !== 'COMPLETED') {
      return null;
    }

    if (!rapidTest.result || !CERTIFIABLE_RESULTS.has(rapidTest.result)) {
      this.logger.warn(
        `Certificate not issued for rapidTestId=${rapidTestId}: ` +
          `result=${rapidTest.result ?? '(none)'} is not certifiable.`,
      );
      return null;
    }

    const existing = await this.prisma.certificate.findFirst({
      where: { rapidTestId },
    });
    if (existing) {
      return this.toRecord(existing, rapidTest.testTypeId, rapidTest.result);
    }

    const now = new Date();
    const validUntil = new Date(now.getTime() + 180 * 24 * 60 * 60 * 1000);
    const certificateNumber = `HDX-${Date.now()}-${Math.random().toString(36).slice(2, 8).toUpperCase()}`;

    const certificate = await this.prisma.certificate.create({
      data: {
        userId: rapidTest.userId,
        rapidTestId,
        type: 'TEST_RESULT',
        status: 'ISSUED',
        certificateNumber,
        issuedAt: now,
        validFrom: now,
        validUntil,
        language: 'de',
      },
    });

    const pdfRelative = await this.writePdfFile(certificate, rapidTest);
    const updated = await this.prisma.certificate.update({
      where: { id: certificate.id },
      data: { pdfUrl: pdfRelative },
    });

    try {
      await this.auditLogService.create({
        userId: rapidTest.userId,
        action: 'CREATE',
        entityType: 'CERTIFICATE',
        entityId: updated.id,
        description: `Certificate ${updated.certificateNumber} issued for rapidTestId=${rapidTestId} (result=${rapidTest.result}).`,
      });
    } catch (error) {
      // Audit logging must never block certificate issuance itself.
      this.logger.warn(`Audit log write failed for certificate ${updated.id}: ${error?.message ?? error}`);
    }

    return this.toRecord(updated, rapidTest.testTypeId, rapidTest.result);
  }

  async listForUser(userId: string): Promise<MobileCertificateRecord[]> {
    const certificates = await this.prisma.certificate.findMany({
      where: { userId },
      include: { rapidTest: true },
      orderBy: { issuedAt: 'desc' },
    });
    return certificates.map((c) =>
      this.toRecord(c, c.rapidTest.testTypeId, c.rapidTest.result),
    );
  }

  async getForUser(userId: string, certificateId: string): Promise<MobileCertificateRecord> {
    const certificate = await this.prisma.certificate.findUnique({
      where: { id: certificateId },
      include: { rapidTest: true },
    });
    if (!certificate || certificate.userId !== userId) {
      throw new ForbiddenException('Certificate not found');
    }
    return this.toRecord(
      certificate,
      certificate.rapidTest.testTypeId,
      certificate.rapidTest.result,
    );
  }

  async getPdfBufferForUser(userId: string, certificateId: string): Promise<Buffer> {
    const certificate = await this.prisma.certificate.findUnique({
      where: { id: certificateId },
      include: { rapidTest: true, user: true },
    });
    if (!certificate || certificate.userId !== userId) {
      throw new ForbiddenException('Certificate not found');
    }

    if (certificate.pdfUrl) {
      const filePath = path.join(process.cwd(), 'uploads', certificate.pdfUrl);
      if (fs.existsSync(filePath)) {
        return fs.readFileSync(filePath);
      }
    }

    return this.buildPdfBuffer(certificate, certificate.rapidTest);
  }

  private async writePdfFile(
    certificate: { id: string; certificateNumber: string; issuedAt: Date; validUntil: Date },
    rapidTest: { testTypeId: string | null; result: string | null; user: { firstName: string; lastName: string } },
  ): Promise<string> {
    const dir = path.join(process.cwd(), 'uploads', 'certificates');
    fs.mkdirSync(dir, { recursive: true });
    const filename = `${certificate.id}.pdf`;
    const relative = `certificates/${filename}`;
    const buffer = await this.buildPdfBuffer(certificate, rapidTest);
    fs.writeFileSync(path.join(process.cwd(), 'uploads', relative), buffer);
    return relative;
  }

  private buildPdfBuffer(
    certificate: {
      certificateNumber: string;
      issuedAt: Date;
      validUntil: Date;
      user?: { firstName: string; lastName: string };
    },
    rapidTest: { testTypeId: string | null; result: string | null; user?: { firstName: string; lastName: string } },
  ): Promise<Buffer> {
    const user = rapidTest.user ?? certificate.user;
    const doc = new PDFDocument({ margin: 50 });
    const chunks: Buffer[] = [];
    doc.on('data', (chunk) => chunks.push(chunk as Buffer));

    const done = new Promise<Buffer>((resolve, reject) => {
      doc.on('end', () => resolve(Buffer.concat(chunks)));
      doc.on('error', reject);
    });

    doc.fontSize(20).text('HomeDX Test Certificate', { align: 'center' });
    doc.moveDown();
    doc.fontSize(12).text(`Certificate: ${certificate.certificateNumber}`);
    if (user) {
      doc.text(`Name: ${user.firstName} ${user.lastName}`);
    }
    doc.text(`Test type: ${rapidTest.testTypeId ?? '—'}`);
    doc.text(`Result: ${rapidTest.result ?? '—'}`);
    doc.text(`Issued: ${certificate.issuedAt.toISOString().slice(0, 10)}`);
    doc.text(`Valid until: ${certificate.validUntil.toISOString().slice(0, 10)}`);
    doc.end();

    return done;
  }

  private toRecord(
    certificate: {
      id: string;
      certificateNumber: string;
      type: string;
      status: string;
      rapidTestId: string;
      issuedAt: Date;
      validFrom: Date;
      validUntil: Date;
      pdfUrl: string | null;
      language: string | null;
    },
    testTypeId: string | null,
    testResult: string | null,
  ): MobileCertificateRecord {
    return {
      id: certificate.id,
      certificateNumber: certificate.certificateNumber,
      type: certificate.type,
      status: certificate.status,
      rapidTestId: certificate.rapidTestId,
      testTypeId,
      testResult,
      issuedAt: certificate.issuedAt.toISOString(),
      validFrom: certificate.validFrom.toISOString(),
      validUntil: certificate.validUntil.toISOString(),
      pdfUrl: certificate.pdfUrl,
      language: certificate.language,
    };
  }
}
