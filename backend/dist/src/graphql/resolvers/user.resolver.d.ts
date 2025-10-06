import { UserService } from '../../services/user.service';
import { User } from '../types/user.type';
import { CreateUserInput, UpdateUserInput } from '../types/user.input';
export declare class UserResolver {
    private readonly userService;
    constructor(userService: UserService);
    users(): Promise<User[]>;
    user(id: string): Promise<User | null>;
    userByEmail(email: string): Promise<User | null>;
    createUser(input: CreateUserInput): Promise<User>;
    updateUser(id: string, input: UpdateUserInput): Promise<User>;
    removeUser(id: string): Promise<User>;
}
