export interface CreateUserInput {
  email: string;
  password: string;
  firstName: string;
  lastName: string;
  dateOfBirth?: Date;
  phone?: string;
  address1?: string;
  city?: string;
  postcode?: string;
  country?: string;
}

export interface UpdateUserInput {
  firstName?: string;
  lastName?: string;
  dateOfBirth?: Date;
  phone?: string;
  address1?: string;
  city?: string;
  postcode?: string;
  country?: string;
}
