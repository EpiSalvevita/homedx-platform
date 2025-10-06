import { Field, InputType } from '@nestjs/graphql';
import { IsEmail, IsString, IsOptional, MinLength, MaxLength, IsDate, Matches } from 'class-validator';

@InputType()
export class CreateUserInput {
  @Field()
  @IsEmail({}, { message: 'Please provide a valid email address' })
  email: string;

  @Field()
  @IsString()
  @MinLength(8, { message: 'Password must be at least 8 characters long' })
  password: string;

  @Field()
  @IsString()
  @MinLength(2, { message: 'First name must be at least 2 characters long' })
  @MaxLength(50, { message: 'First name cannot be longer than 50 characters' })
  firstName: string;

  @Field()
  @IsString()
  @MinLength(2, { message: 'Last name must be at least 2 characters long' })
  @MaxLength(50, { message: 'Last name cannot be longer than 50 characters' })
  lastName: string;

  @Field({ nullable: true })
  @IsOptional()
  @IsDate()
  dateOfBirth?: Date;

  @Field({ nullable: true })
  @IsOptional()
  @IsString()
  @Matches(/^(male|female|other|prefer_not_to_say)$/, {
    message: 'Gender must be one of: male, female, other, prefer_not_to_say',
  })
  gender?: string;

  @Field({ nullable: true })
  @IsOptional()
  @IsString()
  @MaxLength(20)
  title?: string;

  @Field({ nullable: true })
  @IsOptional()
  @IsString()
  @MinLength(5)
  @MaxLength(100)
  address1?: string;

  @Field({ nullable: true })
  @IsOptional()
  @IsString()
  @MaxLength(100)
  address2?: string;

  @Field({ nullable: true })
  @IsOptional()
  @IsString()
  @Matches(/^[0-9A-Z]{3,10}$/, {
    message: 'Postcode must be between 3 and 10 alphanumeric characters',
  })
  postcode?: string;

  @Field({ nullable: true })
  @IsOptional()
  @IsString()
  @MinLength(2)
  @MaxLength(50)
  city?: string;

  @Field({ nullable: true })
  @IsOptional()
  @IsString()
  @MinLength(2)
  @MaxLength(2)
  country?: string;

  @Field({ nullable: true })
  @IsOptional()
  @IsString()
  @Matches(/^\+?[1-9]\d{1,14}$/, {
    message: 'Phone number must be in E.164 format',
  })
  phone?: string;

  @Field({ nullable: true })
  @IsOptional()
  @IsString()
  @Matches(/^https?:\/\/.+/, {
    message: 'Profile image URL must be a valid URL',
  })
  profileImageUrl?: string;
}

@InputType()
export class UpdateUserInput {
  @Field({ nullable: true })
  @IsOptional()
  @IsString()
  @MinLength(2)
  @MaxLength(50)
  firstName?: string;

  @Field({ nullable: true })
  @IsOptional()
  @IsString()
  @MinLength(2)
  @MaxLength(50)
  lastName?: string;

  @Field({ nullable: true })
  @IsOptional()
  @IsDate()
  dateOfBirth?: Date;

  @Field({ nullable: true })
  @IsOptional()
  @IsString()
  @Matches(/^(male|female|other|prefer_not_to_say)$/, {
    message: 'Gender must be one of: male, female, other, prefer_not_to_say',
  })
  gender?: string;

  @Field({ nullable: true })
  @IsOptional()
  @IsString()
  @MaxLength(20)
  title?: string;

  @Field({ nullable: true })
  @IsOptional()
  @IsString()
  @MinLength(5)
  @MaxLength(100)
  address1?: string;

  @Field({ nullable: true })
  @IsOptional()
  @IsString()
  @MaxLength(100)
  address2?: string;

  @Field({ nullable: true })
  @IsOptional()
  @IsString()
  @Matches(/^[0-9A-Z]{3,10}$/, {
    message: 'Postcode must be between 3 and 10 alphanumeric characters',
  })
  postcode?: string;

  @Field({ nullable: true })
  @IsOptional()
  @IsString()
  @MinLength(2)
  @MaxLength(50)
  city?: string;

  @Field({ nullable: true })
  @IsOptional()
  @IsString()
  @MinLength(2)
  @MaxLength(2)
  country?: string;

  @Field({ nullable: true })
  @IsOptional()
  @IsString()
  @Matches(/^\+?[1-9]\d{1,14}$/, {
    message: 'Phone number must be in E.164 format',
  })
  phone?: string;

  @Field({ nullable: true })
  @IsOptional()
  @IsString()
  @Matches(/^https?:\/\/.+/, {
    message: 'Profile image URL must be a valid URL',
  })
  profileImageUrl?: string;
} 