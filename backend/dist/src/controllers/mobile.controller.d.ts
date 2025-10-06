import { AuthService } from '../services/auth.service';
import { UserService } from '../services/user.service';
import { RapidTestService } from '../services/rapid-test.service';
import { FileUploadService } from '../services/file-upload.service';
import { JwtService } from '@nestjs/jwt';
interface MobileResponse {
    success: boolean;
    error?: string;
    validation?: string[];
}
interface LoginResponse extends MobileResponse {
    token?: string;
}
interface UserDataResponse extends MobileResponse {
    userdata?: any;
}
interface TestListResponse extends MobileResponse {
    testTypes?: any[];
}
interface TestResultResponse extends MobileResponse {
    lastTests?: any[];
}
interface BackendStatusResponse extends MobileResponse {
    cwa?: boolean;
    cwaLaive?: boolean;
}
interface MediaResponse extends MobileResponse {
    objectName?: string;
}
interface LiveTokenResponse extends MobileResponse {
    liveToken?: string;
}
export declare class MobileController {
    private readonly authService;
    private readonly userService;
    private readonly rapidTestService;
    private readonly fileUploadService;
    private readonly jwtService;
    constructor(authService: AuthService, userService: UserService, rapidTestService: RapidTestService, fileUploadService: FileUploadService, jwtService: JwtService);
    login(body: {
        user: string;
        pw: string;
        lang?: string;
    }): Promise<LoginResponse>;
    registerAccount(body: {
        firstname: string;
        lastname: string;
        email: string;
        password: string;
        lang?: string;
    }): Promise<MobileResponse>;
    getUserData(token: string): Promise<UserDataResponse>;
    updateUserData(token: string, body: any): Promise<MobileResponse>;
    getTestTypeList(body: {
        lang?: string;
    }): Promise<TestListResponse>;
    addTest(token: string, body: {
        testTypeId: string;
        lang?: string;
    }): Promise<MobileResponse>;
    getLastTest(token: string): Promise<TestResultResponse>;
    addRapidTestPhoto(token: string, file: any, body: {
        fileExtension: string;
    }): Promise<MediaResponse>;
    addRapidTestVideo(token: string, file: any, body: {
        fileExtension: string;
    }): Promise<MediaResponse>;
    addIdentificationPhoto(token: string, file: any, body: {
        fileExtension: string;
        type: string;
    }): Promise<MediaResponse>;
    getBackendStatus(body: {
        lang?: string;
    }): Promise<BackendStatusResponse>;
    getLiveToken(token: string): Promise<LiveTokenResponse>;
    initAuthentication(token: string): Promise<MobileResponse>;
    unsetAuthentication(token: string): Promise<MobileResponse>;
}
export {};
