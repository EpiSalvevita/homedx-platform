import { Field, InputType } from '@nestjs/graphql';
import { LegalPageType } from './legal-page.types';

@InputType()
export class GetLegalPageInput {
  @Field(() => LegalPageType)
  type: LegalPageType;

  @Field({ defaultValue: 'de' })
  language?: string;
}

@InputType()
export class GetLegalPagesInput {
  @Field(() => [LegalPageType], { nullable: true })
  types?: LegalPageType[];

  @Field({ defaultValue: 'de' })
  language?: string;

  @Field({ defaultValue: true })
  activeOnly?: boolean;
} 