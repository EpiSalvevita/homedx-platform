import { Body, Controller, Post } from '@nestjs/common';
import { LegalPageService } from '../services/legal-page.service';
import { Public } from '../auth/public.decorator';
import { GetLegalPageDto } from '../dto/mobile/legal.dto';
import { sanitizeMobileError } from '../util/mobile-error.util';
import { MOBILE_API_PATH, MobileResponse } from './mobile.types';

export interface LegalPageResponse extends MobileResponse {
  legalPage?: {
    type: string;
    title: string;
    content: string;
    language: string;
    version: string;
  };
}

@Controller(MOBILE_API_PATH)
export class MobileLegalController {
  constructor(private readonly legalPageService: LegalPageService) {}

  /**
   * Public by design — consent/legal content must be readable before a
   * user is authenticated (e.g. before signup). See
   * docs/regulatory/gap-assessment.md §6/§7: previously no mobile-facing
   * endpoint exposed the already-populated LegalPage content.
   */
  @Public()
  @Post('get-legal-page')
  async getLegalPage(@Body() body: GetLegalPageDto): Promise<LegalPageResponse> {
    try {
      const page = await this.legalPageService.getLegalPage(
        body.type,
        body.language ?? 'de',
      );
      if (!page) {
        return { success: false, error: 'Legal page not found' };
      }
      return {
        success: true,
        legalPage: {
          type: page.type,
          title: page.title,
          content: page.content,
          language: page.language,
          version: page.version,
        },
      };
    } catch (error) {
      return sanitizeMobileError(error, 'Failed to load legal page');
    }
  }
}
