export interface CreateRapidTestInput {
  userId: string;
  testKitId: string;
  testDate: Date;
  testDeviceUrl?: string;
  identityCard1Url?: string;
  identityCard2Url?: string;
  profilePicUrl?: string;
  identityCardId?: string;
  videoUrl?: string;
  photoUrl?: string;
  agreementGiven?: boolean;
}

export interface UpdateRapidTestInput {
  testDeviceUrl?: string;
  result?: string;
  status?: string;
  certificateUrl?: string;
  identityCard1Url?: string;
  identityCard2Url?: string;
  profilePicUrl?: string;
  identityCardId?: string;
  videoUrl?: string;
  photoUrl?: string;
  qrCode?: string;
  comment?: string;
  agreementGiven?: boolean;
}
