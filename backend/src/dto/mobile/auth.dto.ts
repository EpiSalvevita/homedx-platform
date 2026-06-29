import { IsEmail, IsIn, IsOptional, IsString, MinLength, ValidateIf } from 'class-validator';
import { IsStrongPassword } from '../../auth/is-strong-password.decorator';
import { PASSWORD_MIN_LENGTH } from '../../auth/password-policy';
import { MEDICAL_SPECIALIZATIONS } from '../../utils/medical-specializations';
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
  @MinLength(PASSWORD_MIN_LENGTH)
  @IsStrongPassword()
  password: string;

  @IsOptional()
  @IsIn(['DOCTOR'])
  role?: 'DOCTOR';

  @ValidateIf((body) => body.role === 'DOCTOR')
  @IsString()
  @IsIn(MEDICAL_SPECIALIZATIONS as unknown as string[])
  specialization?: string;

  @ValidateIf((body) => body.role === 'DOCTOR')
  @IsString()
  @MinLength(1)
  clinic_address?: string;
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

  @IsOptional()
  @IsIn(['MALE', 'FEMALE', 'DIVERS'])
  gender?: 'MALE' | 'FEMALE' | 'DIVERS';
}

export class RequestPasswordResetDto extends LangBodyDto {
  @IsEmail()
  email: string;
}

export class ResetPasswordDto extends LangBodyDto {
  @IsString()
  @MinLength(1)
  token: string;

  @IsString()
  @MinLength(PASSWORD_MIN_LENGTH)
  @IsStrongPassword()
  password: string;
}
