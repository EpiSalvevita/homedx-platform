import { Resolver, Query, Mutation, Args } from '@nestjs/graphql';
import { License } from '../types/license.type';
import { CreateLicenseInput, UpdateLicenseInput } from '../types/license.input';
import { ActivateLicenseResponse, AssignCouponResponse } from '../types/license.types';
import { LicenseService } from '../../services/license.service';

@Resolver(() => License)
export class LicenseResolver {
  constructor(private readonly licenseService: LicenseService) {}

  @Query(() => [License])
  async licenses(): Promise<License[]> {
    return this.licenseService.findAll();
  }

  @Query(() => License, { nullable: true })
  async license(@Args('id') id: string): Promise<License | null> {
    return this.licenseService.findOne(id);
  }

  @Query(() => [License])
  async userLicenses(@Args('userId') userId: string): Promise<License[]> {
    return this.licenseService.findByUserId(userId);
  }

  @Mutation(() => License)
  async createLicense(
    @Args('userId') userId: string,
    @Args('licenseKey') licenseKey: string,
    @Args('status') status: string,
    @Args('maxUses') maxUses: number,
  ): Promise<License> {
    console.log('Resolver received individual args:', { userId, licenseKey, status, maxUses });
    const input = { userId, licenseKey, status, maxUses };
    return this.licenseService.create(input as any);
  }

  @Mutation(() => License)
  async updateLicense(
    @Args('id') id: string,
    @Args('maxUses', { nullable: true }) maxUses?: number,
    @Args('status', { nullable: true }) status?: string,
  ): Promise<License> {
    console.log('Update resolver received:', { id, maxUses, status });
    const input = { maxUses, status };
    return this.licenseService.update(id, input as any);
  }

  @Mutation(() => License)
  async removeLicense(@Args('id') id: string): Promise<License> {
    return this.licenseService.remove(id);
  }

  @Mutation(() => License)
  async incrementLicenseUses(@Args('id') id: string): Promise<License> {
    return this.licenseService.incrementUsesCount(id);
  }

  @Mutation(() => ActivateLicenseResponse)
  async activateLicense(@Args('code') code: string): Promise<ActivateLicenseResponse> {
    try {
      const license = await this.licenseService.findByLicenseKey(code);
      if (!license) {
        return {
          success: false,
          message: 'License not found'
        };
      }

      if (license.status !== 'ACTIVE') {
        return {
          success: false,
          message: 'License is not active'
        };
      }

      if (license.usesCount >= license.maxUses) {
        return {
          success: false,
          message: 'License usage limit exceeded'
        };
      }

      const updatedLicense = await this.licenseService.incrementUsesCount(license.id);
      return {
        success: true,
        license: updatedLicense
      };
    } catch (error) {
      return {
        success: false,
        message: 'Failed to activate license'
      };
    }
  }

  @Mutation(() => AssignCouponResponse)
  async assignCoupon(@Args('licenseCode') licenseCode: string): Promise<AssignCouponResponse> {
    try {
      const license = await this.licenseService.findByLicenseKey(licenseCode);
      if (!license) {
        return {
          success: false,
          message: 'License not found'
        };
      }

      if (license.status !== 'ACTIVE') {
        return {
          success: false,
          message: 'License is not active'
        };
      }

      return {
        success: true,
        licenseCode: license.licenseKey
      };
    } catch (error) {
      return {
        success: false,
        message: 'Failed to assign coupon'
      };
    }
  }
} 