import { FileUploadService } from '../../services/file-upload.service';
import { UploadResponse } from '../types/upload.types';
type FileUpload = {
    filename: string;
    mimetype: string;
    encoding: string;
    createReadStream(): any;
};
export declare class FileUploadResolver {
    private readonly fileUploadService;
    constructor(fileUploadService: FileUploadService);
    uploadTestPhoto(file: FileUpload, fileExtension: string): Promise<UploadResponse>;
    uploadTestVideo(file: FileUpload, fileExtension: string, head?: string, headpre?: string): Promise<UploadResponse>;
    uploadIdFrontPhoto(file: FileUpload, fileExtension: string): Promise<UploadResponse>;
    uploadIdBackPhoto(file: FileUpload, fileExtension: string): Promise<UploadResponse>;
}
export {};
