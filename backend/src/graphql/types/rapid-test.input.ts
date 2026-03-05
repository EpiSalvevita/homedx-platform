import { Field, InputType } from '@nestjs/graphql';
import { IsString, IsOptional, IsUrl, IsDate, IsBoolean, Matches } from 'class-validator';

@InputType()
export class CreateRapidTestInput {
  @Field()
  @IsString()
  userId: string;

  @Field()
  @IsString()
  testKitId: string;

  @Field()
  @IsDate()
  testDate: Date;

  @Field({ nullable: true })
  @IsOptional()
  @IsUrl({}, { message: 'Test device URL must be a valid URL' })
  testDeviceUrl?: string;

  @Field({ nullable: true })
  @IsOptional()
  @IsUrl({}, { message: 'Identity card 1 URL must be a valid URL' })
  identityCard1Url?: string;

  @Field({ nullable: true })
  @IsOptional()
  @IsUrl({}, { message: 'Identity card 2 URL must be a valid URL' })
  identityCard2Url?: string;

  @Field({ nullable: true })
  @IsOptional()
  @IsUrl({}, { message: 'Profile picture URL must be a valid URL' })
  profilePicUrl?: string;

  @Field({ nullable: true })
  @IsOptional()
  @IsString()
  @Matches(/^[A-Z0-9-]+$/, {
    message: 'Identity card ID must contain only uppercase letters, numbers, and hyphens',
  })
  identityCardId?: string;
}

@InputType()
export class UpdateRapidTestInput {
  @Field({ nullable: true })
  @IsOptional()
  @IsUrl({}, { message: 'Test device URL must be a valid URL' })
  testDeviceUrl?: string;

  @Field({ nullable: true })
  @IsOptional()
  @IsString()
  @Matches(/^(POSITIVE|NEGATIVE|INVALID|INCONCLUSIVE)$/, {
    message: 'Result must be one of: POSITIVE, NEGATIVE, INVALID, INCONCLUSIVE',
  })
  result?: string;

  @Field({ nullable: true })
  @IsOptional()
  @IsString()
  @Matches(/^(PENDING|IN_PROGRESS|COMPLETED|FAILED)$/, {
    message: 'Status must be one of: PENDING, IN_PROGRESS, COMPLETED, FAILED',
  })
  status?: string;

  @Field({ nullable: true })
  @IsOptional()
  @IsUrl({}, { message: 'Certificate URL must be a valid URL' })
  certificateUrl?: string;

  @Field({ nullable: true })
  @IsOptional()
  @IsUrl({}, { message: 'Identity card 1 URL must be a valid URL' })
  identityCard1Url?: string;

  @Field({ nullable: true })
  @IsOptional()
  @IsUrl({}, { message: 'Identity card 2 URL must be a valid URL' })
  identityCard2Url?: string;

  @Field({ nullable: true })
  @IsOptional()
  @IsUrl({}, { message: 'Profile picture URL must be a valid URL' })
  profilePicUrl?: string;

  @Field({ nullable: true })
  @IsOptional()
  @IsString()
  @Matches(/^[A-Z0-9-]+$/, {
    message: 'Identity card ID must contain only uppercase letters, numbers, and hyphens',
  })
  identityCardId?: string;

  @Field({ nullable: true })
  @IsOptional()
  @IsUrl({}, { message: 'Video URL must be a valid URL' })
  videoUrl?: string;

  @Field({ nullable: true })
  @IsOptional()
  @IsUrl({}, { message: 'Photo URL must be a valid URL' })
  photoUrl?: string;

  @Field({ nullable: true })
  @IsOptional()
  @IsString()
  qrCode?: string;

  @Field({ nullable: true })
  @IsOptional()
  @IsString()
  comment?: string;

  @Field({ nullable: true })
  @IsOptional()
  @IsBoolean()
  agreementGiven?: boolean;
} 