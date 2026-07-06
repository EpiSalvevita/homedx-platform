/**
 * Unit-style coverage for MobileCertificateService.issueForRapidTest —
 * previously untested (see docs/regulatory/gap-assessment.md §3). Named
 * `.e2e-spec.ts` to match this repo's `test:e2e` jest config (see
 * jest-e2e.json), consistent with the "CubeService metadata parsing"
 * block in submit-cube-data.e2e-spec.ts.
 *
 * `pdfkit` and `fs` are mocked because this test instantiates the service
 * directly (outside Nest's runtime/module resolution), and `pdfkit`'s
 * default export does not interop cleanly with ts-jest in that context —
 * the same reason `MobileCertificateService` is always fully mocked via
 * `useValue` in the other e2e specs rather than exercised for real.
 *
 * ts-jest does not hoist `jest.mock()` above imports (that's a Babel-only
 * behavior), so these calls must appear before the import they affect.
 */
jest.mock('fs', () => ({
  mkdirSync: jest.fn(),
  writeFileSync: jest.fn(),
  existsSync: jest.fn(() => false),
  readFileSync: jest.fn(),
}));

jest.mock('pdfkit', () => {
  const MockPdf = jest.fn().mockImplementation(() => {
    const handlers: Record<string, (arg?: unknown) => void> = {};
    const doc = {
      on: jest.fn((event: string, cb: (arg?: unknown) => void) => {
        handlers[event] = cb;
        return doc;
      }),
      fontSize: jest.fn(() => doc),
      text: jest.fn(() => doc),
      moveDown: jest.fn(() => doc),
      end: jest.fn(() => {
        handlers['data']?.(Buffer.from('fake-pdf'));
        handlers['end']?.();
      }),
    };
    return doc;
  });
  return { __esModule: true, default: MockPdf };
});

import { MobileCertificateService } from '../src/services/mobile-certificate.service';

function createPrismaMock(rapidTest: Record<string, unknown> | null) {
  const certificates: Record<string, unknown>[] = [];
  return {
    rapidTest: {
      findUnique: jest.fn(async () => rapidTest),
    },
    certificate: {
      findFirst: jest.fn(async () => certificates[0] ?? null),
      create: jest.fn(async ({ data }: { data: Record<string, unknown> }) => {
        const cert = { id: `cert-${certificates.length + 1}`, ...data };
        certificates.push(cert);
        return cert;
      }),
      update: jest.fn(
        async ({
          where,
          data,
        }: {
          where: { id: string };
          data: Record<string, unknown>;
        }) => {
          const idx = certificates.findIndex((c) => c.id === where.id);
          certificates[idx] = { ...certificates[idx], ...data };
          return certificates[idx];
        },
      ),
    },
    _certificates: certificates,
  };
}

function baseRapidTest(overrides: Record<string, unknown> = {}) {
  return {
    id: 'rt-1',
    userId: 'user-1',
    status: 'COMPLETED',
    testTypeId: 'rheumacheck',
    result: 'POSITIVE',
    user: { firstName: 'Test', lastName: 'User' },
    ...overrides,
  };
}

describe('MobileCertificateService.issueForRapidTest — result gate', () => {
  it('issues a certificate for a POSITIVE result', async () => {
    const prisma = createPrismaMock(baseRapidTest({ result: 'POSITIVE' }));
    const auditLogService = { create: jest.fn(async () => ({})) };
    const service = new MobileCertificateService(prisma as never, auditLogService as never);

    const cert = await service.issueForRapidTest('rt-1');

    expect(cert).not.toBeNull();
    expect(prisma.certificate.create).toHaveBeenCalledTimes(1);
    expect(auditLogService.create).toHaveBeenCalledWith(
      expect.objectContaining({ action: 'CREATE', entityType: 'CERTIFICATE' }),
    );
  });

  it('issues a certificate for a NEGATIVE result', async () => {
    const prisma = createPrismaMock(baseRapidTest({ result: 'NEGATIVE' }));
    const auditLogService = { create: jest.fn(async () => ({})) };
    const service = new MobileCertificateService(prisma as never, auditLogService as never);

    const cert = await service.issueForRapidTest('rt-1');

    expect(cert).not.toBeNull();
    expect(prisma.certificate.create).toHaveBeenCalledTimes(1);
  });

  it('does NOT issue a certificate for an INVALID result', async () => {
    const prisma = createPrismaMock(baseRapidTest({ result: 'INVALID' }));
    const auditLogService = { create: jest.fn(async () => ({})) };
    const service = new MobileCertificateService(prisma as never, auditLogService as never);

    const cert = await service.issueForRapidTest('rt-1');

    expect(cert).toBeNull();
    expect(prisma.certificate.create).not.toHaveBeenCalled();
    expect(auditLogService.create).not.toHaveBeenCalled();
  });

  it('does NOT issue a certificate for an INCONCLUSIVE result', async () => {
    const prisma = createPrismaMock(baseRapidTest({ result: 'INCONCLUSIVE' }));
    const auditLogService = { create: jest.fn(async () => ({})) };
    const service = new MobileCertificateService(prisma as never, auditLogService as never);

    const cert = await service.issueForRapidTest('rt-1');

    expect(cert).toBeNull();
    expect(prisma.certificate.create).not.toHaveBeenCalled();
  });

  it('does NOT issue a certificate when result is unset', async () => {
    const prisma = createPrismaMock(baseRapidTest({ result: null }));
    const auditLogService = { create: jest.fn(async () => ({})) };
    const service = new MobileCertificateService(prisma as never, auditLogService as never);

    const cert = await service.issueForRapidTest('rt-1');

    expect(cert).toBeNull();
    expect(prisma.certificate.create).not.toHaveBeenCalled();
  });

  it('does NOT issue a certificate when the RapidTest is not COMPLETED', async () => {
    const prisma = createPrismaMock(baseRapidTest({ status: 'IN_PROGRESS' }));
    const auditLogService = { create: jest.fn(async () => ({})) };
    const service = new MobileCertificateService(prisma as never, auditLogService as never);

    const cert = await service.issueForRapidTest('rt-1');

    expect(cert).toBeNull();
    expect(prisma.certificate.create).not.toHaveBeenCalled();
  });

  it('is idempotent: does not create a second certificate if one already exists', async () => {
    const prisma = createPrismaMock(baseRapidTest({ result: 'POSITIVE' }));
    const auditLogService = { create: jest.fn(async () => ({})) };
    const service = new MobileCertificateService(prisma as never, auditLogService as never);

    await service.issueForRapidTest('rt-1');
    await service.issueForRapidTest('rt-1');

    expect(prisma.certificate.create).toHaveBeenCalledTimes(1);
  });

  it('audit logging failure does not prevent certificate issuance', async () => {
    const prisma = createPrismaMock(baseRapidTest({ result: 'POSITIVE' }));
    const auditLogService = {
      create: jest.fn(async () => {
        throw new Error('audit db unavailable');
      }),
    };
    const service = new MobileCertificateService(prisma as never, auditLogService as never);

    const cert = await service.issueForRapidTest('rt-1');

    expect(cert).not.toBeNull();
  });
});
