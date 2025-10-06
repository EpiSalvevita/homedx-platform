import { Resolver, Query, Mutation, Args } from '@nestjs/graphql';
import { UseGuards } from '@nestjs/common';
import { UserService } from '../../services/user.service';
import { User } from '../types/user.type';
import { CreateUserInput, UpdateUserInput } from '../types/user.input';
import { JwtAuthGuard } from '../../auth/jwt-auth.guard';

@Resolver(() => User)
export class UserResolver {
  constructor(private readonly userService: UserService) {}

  @Query(() => [User])
  async users(): Promise<User[]> {
    return this.userService.findAll();
  }

  @Query(() => User, { nullable: true })
  async user(@Args('id') id: string): Promise<User | null> {
    return this.userService.findOne(id);
  }

  @Query(() => User, { nullable: true })
  async userByEmail(@Args('email') email: string): Promise<User | null> {
    return this.userService.findByEmail(email);
  }

  @Mutation(() => User)
  async createUser(@Args('input') input: CreateUserInput): Promise<User> {
    return this.userService.create(input);
  }

  @Mutation(() => User)
  async updateUser(
    @Args('id') id: string,
    @Args('input') input: UpdateUserInput,
  ): Promise<User> {
    return this.userService.update(id, input);
  }

  @Mutation(() => User)
  async removeUser(@Args('id') id: string): Promise<User> {
    return this.userService.remove(id);
  }
} 