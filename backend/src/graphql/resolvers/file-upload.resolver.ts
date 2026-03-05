import { Resolver, Mutation, Args } from '@nestjs/graphql';
import { UseGuards } from '@nestjs/common';
import { FileUploadService } from '../../services/file-upload.service';
import { UploadResponse, Upload, GraphQLUpload } from '../types/upload.types';
import { JwtAuthGuard } from '../../auth/jwt-auth.guard';

type FileUpload = {
  filename: string;
  mimetype: string;
  encoding: string;
  createReadStream(): any;
};

@Resolver()
export class FileUploadResolver {
  constructor(private readonly fileUploadService: FileUploadService) {}

  @Mutation(() => UploadResponse)
  @UseGuards(JwtAuthGuard)
  async uploadTestPhoto(
    @Args({ name: 'file', type: () => GraphQLUpload }) file: FileUpload,
    @Args('fileExtension') fileExtension: string
  ): Promise<UploadResponse> {
    const result = await this.fileUploadService.uploadTestPhoto(file);
    return {
      success: true,
      objectName: result.objectName || `test-photo_${Date.now()}.${fileExtension}`
    };
  }

  @Mutation(() => UploadResponse)
  @UseGuards(JwtAuthGuard)
  async uploadTestVideo(
    @Args({ name: 'file', type: () => GraphQLUpload }) file: FileUpload,
    @Args('fileExtension') fileExtension: string,
    @Args('head', { nullable: true }) head?: string,
    @Args('headpre', { nullable: true }) headpre?: string,
  ): Promise<UploadResponse> {
    const result = await this.fileUploadService.uploadTestVideo(file);
    return {
      success: true,
      objectName: result.objectName || `test-video_${Date.now()}.${fileExtension}`,
      validation: 'PENDING'
    };
  }

  @Mutation(() => UploadResponse)
  @UseGuards(JwtAuthGuard)
  async uploadIdFrontPhoto(
    @Args({ name: 'file', type: () => GraphQLUpload }) file: FileUpload,
    @Args('fileExtension') fileExtension: string,
  ): Promise<UploadResponse> {
    const result = await this.fileUploadService.uploadIdFrontPhoto(file);
    return {
      success: true,
      objectName: result.objectName || `id-front_${Date.now()}.${fileExtension}`
    };
  }

  @Mutation(() => UploadResponse)
  @UseGuards(JwtAuthGuard)
  async uploadIdBackPhoto(
    @Args({ name: 'file', type: () => GraphQLUpload }) file: FileUpload,
    @Args('fileExtension') fileExtension: string,
  ): Promise<UploadResponse> {
    const result = await this.fileUploadService.uploadIdBackPhoto(file);
    return {
      success: true,
      objectName: result.objectName || `id-back_${Date.now()}.${fileExtension}`
    };
  }
} 