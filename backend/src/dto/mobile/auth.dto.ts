import { IsEmail, IsOptional, IsString, MinLength } from 'class-validator';
import { LangBodyDto } from './common.dto';

export class LoginDto extends LangBodyDto {
  @IsString()
  user: string;

  @IsString()
  @MinLength(1)
  pw: string;
}

export class RegisterDto extends LangBodyDto {
  @IsString()
  @MinLength(1)
  firstname: string;

  @IsString()
  @MinLength(1)
  lastname: string;

  @IsEmail()
  email: string;

  @IsString()
  @MinLength(6)
  password: string;
}

export class UpdateUserDataDto extends LangBodyDto {
  @IsOptional()
  @IsString()
  first_name?: string;

  @IsOptional()
  @IsString()
  last_name?: string;

  @IsOptional()
  dob?: number;

  @IsOptional()
  @IsString()
  city?: string;

  @IsOptional()
  @IsString()
  country?: string;

  @IsOptional()
  @IsString()
  phone?: string;

  @IsOptional()
  @IsString()
  address1?: string;

  @IsOptional()
  @IsString()
  postcode?: string;
}
