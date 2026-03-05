import { Injectable } from '@nestjs/common';
import * as fs from 'fs';
import * as path from 'path';
import { promisify } from 'util';

const writeFile = promisify(fs.writeFile);
const mkdir = promisify(fs.mkdir);

type FileUpload = {
  filename: string;
  mimetype: string;
  encoding: string;
  createReadStream(): any;
};

@Injectable()
export class FileUploadService {
  private readonly uploadDir = 'uploads';

  constructor() {
    this.ensureUploadDir();
  }

  private async ensureUploadDir() {
    const uploadPath = path.join(process.cwd(), this.uploadDir);
    try {
      await mkdir(uploadPath, { recursive: true });
    } catch (error) {
      // Directory already exists
    }
  }

  async uploadFile(file: FileUpload, subdirectory: string): Promise<{ success: boolean; objectName?: string; validation?: string }> {
    try {
      const fileAny = await file as any;
      const fileData = fileAny.file || fileAny;
      const { createReadStream, filename, mimetype } = fileData;
      const allowedMimeTypes = ['image/jpeg', 'image/png', 'image/gif', 'video/mp4', 'video/avi', 'video/mov', 'video/webm'];
      if (!allowedMimeTypes.includes(mimetype)) {
        return {
          success: false,
          validation: `File type ${mimetype} is not allowed. Allowed types: ${allowedMimeTypes.join(', ')}`
        };
      }
      const stream = createReadStream();
      const chunks: Buffer[] = [];
      for await (const chunk of stream) {
        chunks.push(chunk);
      }
      const buffer = Buffer.concat(chunks);
      const maxSize = 10 * 1024 * 1024; // 10MB
      if (buffer.length > maxSize) {
        return {
          success: false,
          validation: 'File size exceeds 10MB limit'
        };
      }
      const subDirPath = path.join(process.cwd(), this.uploadDir, subdirectory);
      await mkdir(subDirPath, { recursive: true });
      const timestamp = Date.now();
      let extension = path.extname(filename);
      if (!extension) {
        if (mimetype === 'image/jpeg') extension = '.jpeg';
        else if (mimetype === 'image/png') extension = '.png';
        else if (mimetype === 'image/gif') extension = '.gif';
        else if (mimetype === 'video/mp4') extension = '.mp4';
        else if (mimetype === 'video/avi') extension = '.avi';
        else if (mimetype === 'video/mov') extension = '.mov';
        else if (mimetype === 'video/webm') extension = '.webm';
        else extension = '';
      }
      const objectName = `${subdirectory}_${timestamp}${extension}`;
      const filePath = path.join(subDirPath, objectName);
      await writeFile(filePath, buffer);
      return {
        success: true,
        objectName
      };
    } catch (error) {
      console.error('File upload error:', error);
      return {
        success: false,
        validation: 'File upload failed'
      };
    }
  }

  async uploadTestPhoto(file: FileUpload): Promise<{ success: boolean; objectName?: string; validation?: string }> {
    return this.uploadFile(file, 'test-photos');
  }

  async uploadTestVideo(file: FileUpload): Promise<{ success: boolean; objectName?: string; validation?: string }> {
    return this.uploadFile(file, 'test-videos');
  }

  async uploadIdFrontPhoto(file: FileUpload): Promise<{ success: boolean; objectName?: string; validation?: string }> {
    return this.uploadFile(file, 'id-front');
  }

  async uploadIdBackPhoto(file: FileUpload): Promise<{ success: boolean; objectName?: string; validation?: string }> {
    return this.uploadFile(file, 'id-back');
  }
} 