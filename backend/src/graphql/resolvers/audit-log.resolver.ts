import { Resolver, Query, Mutation, Args } from '@nestjs/graphql';
// import { UseGuards } from '@nestjs/common';
import { AuditLog } from '../types/audit-log.types';
import { CreateAuditLogInput, UpdateAuditLogInput } from '../types/audit-log.input';
import { AuditLogService } from '../../services/audit-log.service';
// import { JwtAuthGuard } from '../../auth/jwt-auth.guard';

@Resolver(() => AuditLog)
export class AuditLogResolver {
  constructor(private readonly auditLogService: AuditLogService) {}

  @Query(() => [AuditLog])
  // @UseGuards(JwtAuthGuard)
  async auditLogs(): Promise<AuditLog[]> {
    return this.auditLogService.findAll();
  }

  @Query(() => AuditLog, { nullable: true })
  // @UseGuards(JwtAuthGuard)
  async auditLog(@Args('id') id: string): Promise<AuditLog | null> {
    return this.auditLogService.findOne(id);
  }

  @Query(() => [AuditLog])
  // @UseGuards(JwtAuthGuard)
  async userAuditLogs(@Args('userId') userId: string): Promise<AuditLog[]> {
    return this.auditLogService.findByUserId(userId);
  }

  @Query(() => [AuditLog])
  // @UseGuards(JwtAuthGuard)
  async entityAuditLogs(
    @Args('entityType') entityType: string,
    @Args('entityId') entityId: string,
  ): Promise<AuditLog[]> {
    return this.auditLogService.findByEntity(entityType, entityId);
  }

  @Query(() => [AuditLog])
  // @UseGuards(JwtAuthGuard)
  async auditLogsByAction(@Args('action') action: string): Promise<AuditLog[]> {
    return this.auditLogService.findByAction(action);
  }

  @Query(() => [AuditLog])
  // @UseGuards(JwtAuthGuard)
  async auditLogsByDateRange(
    @Args('startDate') startDate: Date,
    @Args('endDate') endDate: Date,
  ): Promise<AuditLog[]> {
    return this.auditLogService.findByDateRange(startDate, endDate);
  }

  @Mutation(() => AuditLog)
  async createAuditLog(@Args('input') input: CreateAuditLogInput): Promise<AuditLog> {
    return this.auditLogService.create(input);
  }

  // ⚠️  PRODUCTION WARNING: Remove this mutation before deploying to production!
  // Audit logs should be immutable for security and compliance reasons.
  // Only use this for development/testing purposes.
  @Mutation(() => AuditLog)
  async updateAuditLog(
    @Args('id') id: string,
    @Args('input') input: UpdateAuditLogInput,
  ): Promise<AuditLog> {
    return this.auditLogService.update(id, input);
  }

  // ⚠️  PRODUCTION WARNING: Remove this mutation before deploying to production!
  // Audit logs should be immutable for security and compliance reasons.
  // Only use this for development/testing purposes.
  @Mutation(() => AuditLog)
  async removeAuditLog(@Args('id') id: string): Promise<AuditLog> {
    return this.auditLogService.remove(id);
  }
} 