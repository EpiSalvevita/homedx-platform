import { Field, ObjectType, registerEnumType } from '@nestjs/graphql';

export enum LegalPageType {
  PRIVACY_POLICY = 'PRIVACY_POLICY',
  TERMS_CONDITIONS = 'TERMS_CONDITIONS',
  IMPRESSUM = 'IMPRESSUM',
  COOKIE_POLICY = 'COOKIE_POLICY',
}

registerEnumType(LegalPageType, {
  name: 'LegalPageType',
  description: 'Type of legal page',
});

@ObjectType()
export class LegalPage {
  @Field()
  id: string;

  @Field(() => LegalPageType)
  type: LegalPageType;

  @Field()
  title: string;

  @Field()
  content: string;

  @Field()
  language: string;

  @Field()
  version: string;

  @Field()
  isActive: boolean;

  @Field()
  createdAt: Date;

  @Field()
  updatedAt: Date;
}

@ObjectType()
export class LegalPageResponse {
  @Field(() => [LegalPage])
  pages: LegalPage[];

  @Field()
  total: number;
} 