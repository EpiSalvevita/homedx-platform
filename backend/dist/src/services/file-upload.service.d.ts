type FileUpload = {
    filename: string;
    mimetype: string;
    encoding: string;
    createReadStream(): any;
};
export declare class FileUploadService {
    private readonly uploadDir;
    constructor();
    private ensureUploadDir;
    uploadFile(file: FileUpload, subdirectory: string): Promise<{
        success: boolean;
        objectName?: string;
        validation?: string;
    }>;
    uploadTestPhoto(file: FileUpload): Promise<{
        success: boolean;
        objectName?: string;
        validation?: string;
    }>;
    uploadTestVideo(file: FileUpload): Promise<{
        success: boolean;
        objectName?: string;
        validation?: string;
    }>;
    uploadIdFrontPhoto(file: FileUpload): Promise<{
        success: boolean;
        objectName?: string;
        validation?: string;
    }>;
    uploadIdBackPhoto(file: FileUpload): Promise<{
        success: boolean;
        objectName?: string;
        validation?: string;
    }>;
}
export {};
