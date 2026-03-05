import { Injectable } from '@nestjs/common';
import { PrismaService } from './prisma.service';
import { CreateUserInput, UpdateUserInput } from '../graphql/types/user.input';
import { User } from '../graphql/types/user.type';

@Injectable()
export class UserService {
  constructor(private prisma: PrismaService) {}

  async findAll(): Promise<User[]> {
    return this.prisma.user.findMany();
  }

  async findOne(id: string): Promise<User | null> {
    return this.prisma.user.findUnique({
      where: { id },
    });
  }

  async findByEmail(email: string): Promise<User | null> {
    return this.prisma.user.findUnique({
      where: { email },
    });
  }

  async findById(id: string): Promise<User | null> {
    return this.prisma.user.findUnique({
      where: { id },
    });
  }

  async create(data: CreateUserInput): Promise<User> {
    return this.prisma.user.create({
      data: {
        email: data.email,
        password: data.password,
        firstName: data.firstName,
        lastName: data.lastName,
        phone: data.phone,
        dateOfBirth: data.dateOfBirth,
        address: data.address1,
        city: data.city,
        postalCode: data.postcode,
        country: data.country,
        role: 'USER',
        status: 'ACTIVE',
        emailVerified: false,
      },
    });
  }

  async update(id: string, data: UpdateUserInput): Promise<User> {
    const updateData: any = {};
    
    if (data.firstName !== undefined) updateData.firstName = data.firstName;
    if (data.lastName !== undefined) updateData.lastName = data.lastName;
    if (data.phone !== undefined) updateData.phone = data.phone;
    if (data.dateOfBirth !== undefined) updateData.dateOfBirth = data.dateOfBirth;
    if (data.address1 !== undefined) updateData.address = data.address1;
    if (data.city !== undefined) updateData.city = data.city;
    if (data.postcode !== undefined) updateData.postalCode = data.postcode;
    if (data.country !== undefined) updateData.country = data.country;

    return this.prisma.user.update({
      where: { id },
      data: updateData,
    });
  }

  async remove(id: string): Promise<User> {
    return this.prisma.user.delete({
      where: { id },
    });
  }
} 