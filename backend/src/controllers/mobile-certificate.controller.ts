import { Body, Controller, Post, Request, UseGuards } from '@nestjs/common';
import { MobileCertificateService } from '../services/mobile-certificate.service';
import { JwtAuthGuard } from '../auth/jwt-auth.guard';
import { CertificateIdDto } from '../dto/mobile/certificate.dto';
import { sanitizeMobileError } from '../utils/mobile-error.util';
import { CertificatePdfResponse, MOBILE_API_PATH } from './mobile.types';

@Controller(MOBILE_API_PATH)
export class MobileCertificateController {
  constructor(private readonly mobileCertificateService: MobileCertificateService) {}

  @Post('list-certificates')
  @UseGuards(JwtAuthGuard)
  async listCertificates(@Request() req: { user?: { sub: string } }) {
    try {
      const userId = req.user?.sub;
      if (!userId) {
        return { success: false, error: 'Invalid token' };
      }
      const certificates = await this.mobileCertificateService.listForUser(userId);
      return { success: true, certificates };
    } catch (error) {
      return sanitizeMobileError(error, 'Failed to list certificates');
    }
  }

  @Post('get-certificate')
  @UseGuards(JwtAuthGuard)
  async getCertificate(
    @Request() req: { user?: { sub: string } },
    @Body() body: CertificateIdDto,
  ) {
    try {
      const userId = req.user?.sub;
      if (!userId) {
        return { success: false, error: 'Invalid token' };
      }
      const certificate = await this.mobileCertificateService.getForUser(
        userId,
        body.certificateId,
      );
      return { success: true, certificate };
    } catch (error) {
      return sanitizeMobileError(error, 'Failed to get certificate');
    }
  }

  @Post('get-certificate-pdf')
  @UseGuards(JwtAuthGuard)
  async getCertificatePdf(
    @Request() req: { user?: { sub: string } },
    @Body() body: CertificateIdDto,
  ): Promise<CertificatePdfResponse> {
    try {
      const userId = req.user?.sub;
      if (!userId) {
        return { success: false, error: 'Invalid token' };
      }
      const pdfBuffer = await this.mobileCertificateService.getPdfBufferForUser(
        userId,
        body.certificateId,
      );
      return { success: true, pdfBase64: pdfBuffer.toString('base64') };
    } catch (error) {
      return sanitizeMobileError(error, 'Failed to get certificate PDF');
    }
  }
}
