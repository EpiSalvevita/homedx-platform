import { CubeResultDataItem } from '../services/cube.service';

export interface MobileResponse {
  success: boolean;
  error?: string;
  validation?: string[];
}

export interface LoginResponse extends MobileResponse {
  token?: string;
}

export interface UserDataResponse extends MobileResponse {
  userdata?: object;
}

export interface TestListResponse extends MobileResponse {
  testTypes?: object[];
}

export interface TestResultResponse extends MobileResponse {
  lastTests?: object[];
}

export interface BackendStatusResponse extends MobileResponse {
  online?: boolean;
}

export interface AddTestResponse extends MobileResponse {
  rapidTestId?: string;
}

export interface FinalizeTestResponse extends MobileResponse {
  rapidTest?: object;
}

export interface MediaResponse extends MobileResponse {
  objectName?: string;
}

export interface LiveTokenResponse extends MobileResponse {
  liveToken?: string;
}

export interface DoctorsResponse extends MobileResponse {
  doctors?: object[];
}

export interface DoctorSlotsResponse extends MobileResponse {
  slots?: object[];
}

export interface BookAppointmentResponse extends MobileResponse {
  appointmentId?: string;
  appointmentTime?: string;
}

export interface AppointmentsResponse extends MobileResponse {
  appointments?: object[];
}

export interface AppointmentResponse extends MobileResponse {
  appointment?: object;
}

export interface VideoCallTokenResponse extends MobileResponse {
  roomUrl?: string;
  joinUrl?: string;
  token?: string;
  expiresAt?: string;
}

export interface AvailabilityResponse extends MobileResponse {
  availability?: object[];
}

export interface PaymentAmountResponse extends MobileResponse {
  amount?: number;
  reducedAmount?: number;
  discount?: number;
  discountType?: string;
}

export interface PaymentRecordResponse extends MobileResponse {
  payment?: object;
}

export interface StripeIntentResponse extends MobileResponse {
  clientSecret?: string;
  paymentIntentId?: string;
}

export interface PayPalOrderResponse extends MobileResponse {
  orderId?: string;
  approvalUrl?: string;
}

export interface SubmitCubeDataResponse extends MobileResponse {
  testId?: string;
  result?: string;
  resultData?: CubeResultDataItem[];
  certificateId?: string;
}

export interface CertificatePdfResponse extends MobileResponse {
  pdfBase64?: string;
}

export interface NotificationCountResponse extends MobileResponse {
  count?: number;
}

export const MOBILE_API_PATH = 'gg-homedx-json/gg-api/v1';
