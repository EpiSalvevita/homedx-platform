import { Resolver, Query, Mutation, Args } from '@nestjs/graphql';
import { Certificate } from '../types/certificate.types';
import { CreateCertificateInput, UpdateCertificateInput } from '../types/certificate.input';
import { UpdateCertificateLanguageResponse, DownloadCertificatePdfResponse } from '../types/certificate.types';
import { CertificateService } from '../../services/certificate.service';

@Resolver(() => Certificate)
export class CertificateResolver {
  constructor(private readonly certificateService: CertificateService) {}

  @Query(() => [Certificate])
  async certificates(): Promise<Certificate[]> {
    return this.certificateService.findAll();
  }

  @Query(() => Certificate, { nullable: true })
  async certificate(@Args('testId') testId: string): Promise<Certificate | null> {
    return this.certificateService.findByRapidTestId(testId);
  }

  @Query(() => Certificate, { nullable: true })
  async certificateByNumber(@Args('certificateNumber') certificateNumber: string): Promise<Certificate | null> {
    return this.certificateService.findByCertificateNumber(certificateNumber);
  }

  @Query(() => [Certificate])
  async userCertificates(@Args('userId') userId: string): Promise<Certificate[]> {
    return this.certificateService.findByUserId(userId);
  }

  @Query(() => [Certificate])
  async validCertificates(@Args('userId') userId: string): Promise<Certificate[]> {
    return this.certificateService.findValidByUserId(userId);
  }

  @Mutation(() => Certificate)
  async createCertificate(@Args('input') input: CreateCertificateInput): Promise<Certificate> {
    return this.certificateService.create(input);
  }

  @Mutation(() => Certificate)
  async updateCertificate(
    @Args('id') id: string,
    @Args('input') input: UpdateCertificateInput,
  ): Promise<Certificate> {
    return this.certificateService.update(id, input);
  }

  @Mutation(() => Certificate)
  async removeCertificate(@Args('id') id: string): Promise<Certificate> {
    return this.certificateService.remove(id);
  }

  @Mutation(() => Certificate)
  async issueCertificate(@Args('id') id: string): Promise<Certificate> {
    return this.certificateService.issue(id);
  }

  @Mutation(() => Certificate)
  async revokeCertificate(
    @Args('id') id: string,
    @Args('reason') reason: string,
  ): Promise<Certificate> {
    return this.certificateService.revoke(id, reason);
  }

  @Mutation(() => String)
  async generateCertificateQR(@Args('id') id: string): Promise<string> {
    return this.certificateService.generateQRCode(id);
  }

  @Mutation(() => String)
  async generateCertificatePDF(@Args('id') id: string): Promise<string> {
    return this.certificateService.generatePDF(id);
  }

  @Mutation(() => UpdateCertificateLanguageResponse)
  async updateCertificateLanguage(
    @Args('testId') testId: string,
    @Args('language') language: string,
  ): Promise<UpdateCertificateLanguageResponse> {
    try {
      const certificate = await this.certificateService.findByRapidTestId(testId);
      if (!certificate) {
        return {
          success: false,
          message: 'Certificate not found'
        };
      }

      // Update the certificate with new language
      const updatedCertificate = await this.certificateService.update(certificate.id, {
        language: language
      } as any);

      // Generate new PDF URL with updated language
      const pdfUrl = await this.certificateService.generatePDF(updatedCertificate.id);

      return {
        success: true,
        certificate: {
          id: updatedCertificate.id,
          pdf: {
            url: pdfUrl,
            language: language
          }
        }
      };
    } catch (error) {
      return {
        success: false,
        message: 'Failed to update certificate language'
      };
    }
  }

  @Mutation(() => DownloadCertificatePdfResponse)
  async downloadCertificatePdf(): Promise<DownloadCertificatePdfResponse> {
    try {
      // This would typically get the current user's certificate
      // For now, we'll return a mock PDF
      const mockPdf = 'data:application/pdf;base64,JVBERi0xLjQKJcOkw7zDtsO...'; // Mock base64 PDF
      
      return {
        success: true,
        pdf: mockPdf
      };
    } catch (error) {
      return {
        success: false,
        message: 'Failed to download certificate PDF'
      };
    }
  }
} 