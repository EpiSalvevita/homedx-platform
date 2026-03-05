import { Resolver, Query, Args } from '@nestjs/graphql';
import { LegalPageService } from '../../services/legal-page.service';
import { 
  LegalPage, 
  LegalPageResponse, 
  LegalPageType 
} from '../types/legal-page.types';
import { 
  GetLegalPageInput, 
  GetLegalPagesInput 
} from '../types/legal-page.input';
import { LegalPageType as PrismaLegalPageType } from '@prisma/client';

@Resolver(() => LegalPage)
export class LegalPageResolver {
  constructor(private legalPageService: LegalPageService) {}

  @Query(() => LegalPage, { nullable: true })
  async getLegalPage(
    @Args('input') input: GetLegalPageInput,
  ): Promise<LegalPage | null> {
    const result = await this.legalPageService.getLegalPage(input.type, input.language);
    return result as LegalPage | null;
  }

  @Query(() => LegalPageResponse)
  async getLegalPages(
    @Args('input', { nullable: true }) input?: GetLegalPagesInput,
  ): Promise<LegalPageResponse> {
    const { types, language, activeOnly } = input || {};
    const result = await this.legalPageService.getLegalPages(types, language, activeOnly);
    return {
      pages: result.pages as LegalPage[],
      total: result.total,
    };
  }

  @Query(() => LegalPage, { nullable: true })
  async getPrivacyPolicy(
    @Args('language', { type: () => String, defaultValue: 'de' }) language: string,
  ): Promise<LegalPage | null> {
    const result = await this.legalPageService.getLegalPage(LegalPageType.PRIVACY_POLICY, language);
    return result as LegalPage | null;
  }

  @Query(() => LegalPage, { nullable: true })
  async getTermsAndConditions(
    @Args('language', { type: () => String, defaultValue: 'de' }) language: string,
  ): Promise<LegalPage | null> {
    const result = await this.legalPageService.getLegalPage(LegalPageType.TERMS_CONDITIONS, language);
    return result as LegalPage | null;
  }

  @Query(() => LegalPage, { nullable: true })
  async getImpressum(
    @Args('language', { type: () => String, defaultValue: 'de' }) language: string,
  ): Promise<LegalPage | null> {
    const result = await this.legalPageService.getLegalPage(LegalPageType.IMPRESSUM, language);
    return result as LegalPage | null;
  }
} 