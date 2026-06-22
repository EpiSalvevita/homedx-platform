import { Type } from 'class-transformer';
import {
  IsArray,
  IsNumber,
  IsOptional,
  IsString,
  MinLength,
  ValidateNested,
} from 'class-validator';
import { LangBodyDto } from './common.dto';

export class GetDoctorsDto extends LangBodyDto {
  @IsOptional()
  @IsString()
  testTypeId?: string;
}

export class DoctorSlotsDto extends LangBodyDto {
  @IsString()
  @MinLength(1)
  doctorId: string;

  @IsOptional()
  @IsString()
  from?: string;

  @IsOptional()
  @IsString()
  to?: string;
}

export class BookAppointmentDto extends LangBodyDto {
  @IsString()
  @MinLength(1)
  doctorId: string;

  @IsString()
  @MinLength(1)
  appointmentTime: string;

  @IsString()
  @MinLength(1)
  type: string;

  @IsOptional()
  @IsString()
  notes?: string;

  @IsOptional()
  @IsString()
  testTypeId?: string;
}

export class AppointmentIdDto {
  @IsString()
  @MinLength(1)
  appointmentId: string;
}

export class AvailabilitySlotDto {
  @IsNumber()
  dayOfWeek: number;

  @IsString()
  startTime: string;

  @IsString()
  endTime: string;

  @IsOptional()
  @IsNumber()
  slotMinutes?: number;
}

export class SetDoctorAvailabilityDto {
  @IsArray()
  @ValidateNested({ each: true })
  @Type(() => AvailabilitySlotDto)
  availability: AvailabilitySlotDto[];
}
