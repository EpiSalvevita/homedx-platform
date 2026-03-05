import { Field, ObjectType, InputType } from '@nestjs/graphql';
import { User } from './user.type';
import { IsEmail, IsString, MinLength } from 'class-validator';

@InputType()
export class LoginInput {
  @Field()
  @IsEmail()
  email: string;

  @Field()
  @IsString()
  @MinLength(8)
  password: string;
}

@InputType()
export class SignupInput {
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
  firstName: string;

  @Field()
  @IsString()
  @MinLength(2, { message: 'Last name must be at least 2 characters long' })
  lastName: string;
}

@InputType()
export class CheckEmailInput {
  @Field()
  @IsEmail({}, { message: 'Please provide a valid email address' })
  email: string;
}

@ObjectType()
export class CheckEmailResponse {
  @Field()
  exists: boolean;

  @Field()
  valid: boolean;
}

@ObjectType()
export class AuthResponse {
  @Field()
  access_token: string;

  @Field(() => User)
  user: User;
} 