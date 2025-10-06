import { PrismaService } from './prisma.service';
import { CreateUserInput, UpdateUserInput } from '../graphql/types/user.input';
import { User } from '../graphql/types/user.type';
export declare class UserService {
    private prisma;
    constructor(prisma: PrismaService);
    findAll(): Promise<User[]>;
    findOne(id: string): Promise<User | null>;
    findByEmail(email: string): Promise<User | null>;
    findById(id: string): Promise<User | null>;
    create(data: CreateUserInput): Promise<User>;
    update(id: string, data: UpdateUserInput): Promise<User>;
    remove(id: string): Promise<User>;
}
