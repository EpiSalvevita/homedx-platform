"use strict";
var __decorate = (this && this.__decorate) || function (decorators, target, key, desc) {
    var c = arguments.length, r = c < 3 ? target : desc === null ? desc = Object.getOwnPropertyDescriptor(target, key) : desc, d;
    if (typeof Reflect === "object" && typeof Reflect.decorate === "function") r = Reflect.decorate(decorators, target, key, desc);
    else for (var i = decorators.length - 1; i >= 0; i--) if (d = decorators[i]) r = (c < 3 ? d(r) : c > 3 ? d(target, key, r) : d(target, key)) || r;
    return c > 3 && r && Object.defineProperty(target, key, r), r;
};
var __metadata = (this && this.__metadata) || function (k, v) {
    if (typeof Reflect === "object" && typeof Reflect.metadata === "function") return Reflect.metadata(k, v);
};
var __param = (this && this.__param) || function (paramIndex, decorator) {
    return function (target, key) { decorator(target, key, paramIndex); }
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.MobileController = void 0;
const common_1 = require("@nestjs/common");
const platform_express_1 = require("@nestjs/platform-express");
const auth_service_1 = require("../services/auth.service");
const user_service_1 = require("../services/user.service");
const rapid_test_service_1 = require("../services/rapid-test.service");
const file_upload_service_1 = require("../services/file-upload.service");
const jwt_auth_guard_1 = require("../auth/jwt-auth.guard");
const jwt_1 = require("@nestjs/jwt");
let MobileController = class MobileController {
    constructor(authService, userService, rapidTestService, fileUploadService, jwtService) {
        this.authService = authService;
        this.userService = userService;
        this.rapidTestService = rapidTestService;
        this.fileUploadService = fileUploadService;
        this.jwtService = jwtService;
    }
    async login(body) {
        try {
            const { user, pw } = body;
            const result = await this.authService.login(user, pw);
            return {
                success: true,
                token: result.access_token,
            };
        }
        catch (error) {
            return {
                success: false,
                error: error.message || 'Login failed',
            };
        }
    }
    async registerAccount(body) {
        try {
            const { firstname, lastname, email, password } = body;
            const existingUser = await this.userService.findByEmail(email);
            if (existingUser) {
                return { success: false, error: 'User already exists' };
            }
            await this.authService.signup(email, password, firstname, lastname);
            return { success: true };
        }
        catch (error) {
            return {
                success: false,
                error: error.message || 'Registration failed',
            };
        }
    }
    async getUserData(token) {
        var _a;
        try {
            const user = await this.authService.validateToken(token);
            if (!user) {
                return { success: false, error: 'Invalid token' };
            }
            const userData = await this.userService.findById(user.sub);
            return {
                success: true,
                userdata: {
                    id: userData.id,
                    firstname: userData.firstName,
                    lastname: userData.lastName,
                    email: userData.email,
                    dob: (_a = userData.dateOfBirth) === null || _a === void 0 ? void 0 : _a.getTime(),
                    city: userData.city,
                    country: userData.country,
                    phone: userData.phone,
                    address1: userData.address,
                    postcode: userData.postalCode,
                    testaccount: userData.role === 'ADMIN',
                    authorized: 'accepted',
                },
            };
        }
        catch (error) {
            return {
                success: false,
                error: error.message || 'Failed to get user data',
            };
        }
    }
    async updateUserData(token, body) {
        try {
            const user = await this.authService.validateToken(token);
            if (!user) {
                return { success: false, error: 'Invalid token' };
            }
            await this.userService.update(user.sub, {
                firstName: body.first_name,
                lastName: body.last_name,
                dateOfBirth: body.dob ? new Date(body.dob) : undefined,
                city: body.city,
                country: body.country,
                phone: body.phone,
                address1: body.address1,
                postcode: body.postcode,
            });
            return { success: true };
        }
        catch (error) {
            return {
                success: false,
                error: error.message || 'Failed to update user data',
            };
        }
    }
    async getTestTypeList(body) {
        try {
            const testTypes = [
                { name: 'COVID-19 Rapid Test', id: 'covid-rapid' },
                { name: 'Antigen Test', id: 'antigen' },
                { name: 'PCR Test', id: 'pcr' },
            ];
            return {
                success: true,
                testTypes,
            };
        }
        catch (error) {
            return {
                success: false,
                error: error.message || 'Failed to get test types',
            };
        }
    }
    async addTest(token, body) {
        try {
            const user = await this.authService.validateToken(token);
            if (!user) {
                return { success: false, error: 'Invalid token' };
            }
            await this.rapidTestService.create({
                userId: user.sub,
                testKitId: body.testTypeId,
                testDate: new Date(),
            });
            return { success: true };
        }
        catch (error) {
            return {
                success: false,
                error: error.message || 'Failed to add test',
            };
        }
    }
    async getLastTest(token) {
        try {
            const user = await this.authService.validateToken(token);
            if (!user) {
                return { success: false, error: 'Invalid token' };
            }
            const tests = await this.rapidTestService.findByUserId(user.sub);
            const lastTests = tests.map(test => ({
                lastTest: {
                    result: test.result || 'pending',
                    testDate: test.createdAt.getTime(),
                },
            }));
            return {
                success: true,
                lastTests,
            };
        }
        catch (error) {
            return {
                success: false,
                error: error.message || 'Failed to get test results',
            };
        }
    }
    async addRapidTestPhoto(token, file, body) {
        try {
            const user = await this.authService.validateToken(token);
            if (!user) {
                return { success: false, error: 'Invalid token' };
            }
            const uploadResult = await this.fileUploadService.uploadFile(file, 'photos');
            return {
                success: true,
                objectName: uploadResult.objectName,
            };
        }
        catch (error) {
            return {
                success: false,
                error: error.message || 'Failed to upload photo',
            };
        }
    }
    async addRapidTestVideo(token, file, body) {
        try {
            const user = await this.authService.validateToken(token);
            if (!user) {
                return { success: false, error: 'Invalid token' };
            }
            const uploadResult = await this.fileUploadService.uploadFile(file, 'videos');
            return {
                success: true,
                objectName: uploadResult.objectName,
            };
        }
        catch (error) {
            return {
                success: false,
                error: error.message || 'Failed to upload video',
            };
        }
    }
    async addIdentificationPhoto(token, file, body) {
        try {
            const user = await this.authService.validateToken(token);
            if (!user) {
                return { success: false, error: 'Invalid token' };
            }
            const uploadResult = await this.fileUploadService.uploadFile(file, 'identification');
            return {
                success: true,
                objectName: uploadResult.objectName,
            };
        }
        catch (error) {
            return {
                success: false,
                error: error.message || 'Failed to upload identification photo',
            };
        }
    }
    async getBackendStatus(body) {
        try {
            return {
                success: true,
                cwa: true,
                cwaLaive: true,
            };
        }
        catch (error) {
            return {
                success: false,
                error: error.message || 'Failed to get backend status',
            };
        }
    }
    async getLiveToken(token) {
        try {
            const user = await this.authService.validateToken(token);
            if (!user) {
                return { success: false, error: 'Invalid token' };
            }
            const liveToken = `live_${Date.now()}_${user.id}`;
            return {
                success: true,
                liveToken,
            };
        }
        catch (error) {
            return {
                success: false,
                error: error.message || 'Failed to get live token',
            };
        }
    }
    async initAuthentication(token) {
        try {
            const user = await this.authService.validateToken(token);
            if (!user) {
                return { success: false, error: 'Invalid token' };
            }
            return { success: true };
        }
        catch (error) {
            return {
                success: false,
                error: error.message || 'Failed to initialize authentication',
            };
        }
    }
    async unsetAuthentication(token) {
        try {
            const user = await this.authService.validateToken(token);
            if (!user) {
                return { success: false, error: 'Invalid token' };
            }
            return { success: true };
        }
        catch (error) {
            return {
                success: false,
                error: error.message || 'Failed to unset authentication',
            };
        }
    }
};
exports.MobileController = MobileController;
__decorate([
    (0, common_1.Post)('login'),
    __param(0, (0, common_1.Body)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [Object]),
    __metadata("design:returntype", Promise)
], MobileController.prototype, "login", null);
__decorate([
    (0, common_1.Post)('register-account'),
    __param(0, (0, common_1.Body)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [Object]),
    __metadata("design:returntype", Promise)
], MobileController.prototype, "registerAccount", null);
__decorate([
    (0, common_1.Post)('get-user-data'),
    (0, common_1.UseGuards)(jwt_auth_guard_1.JwtAuthGuard),
    __param(0, (0, common_1.Headers)('x-auth-token')),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String]),
    __metadata("design:returntype", Promise)
], MobileController.prototype, "getUserData", null);
__decorate([
    (0, common_1.Post)('update-user-data'),
    (0, common_1.UseGuards)(jwt_auth_guard_1.JwtAuthGuard),
    __param(0, (0, common_1.Headers)('x-auth-token')),
    __param(1, (0, common_1.Body)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String, Object]),
    __metadata("design:returntype", Promise)
], MobileController.prototype, "updateUserData", null);
__decorate([
    (0, common_1.Post)('get-test-type-list'),
    __param(0, (0, common_1.Body)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [Object]),
    __metadata("design:returntype", Promise)
], MobileController.prototype, "getTestTypeList", null);
__decorate([
    (0, common_1.Post)('add-test'),
    (0, common_1.UseGuards)(jwt_auth_guard_1.JwtAuthGuard),
    __param(0, (0, common_1.Headers)('x-auth-token')),
    __param(1, (0, common_1.Body)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String, Object]),
    __metadata("design:returntype", Promise)
], MobileController.prototype, "addTest", null);
__decorate([
    (0, common_1.Post)('get-last-test'),
    (0, common_1.UseGuards)(jwt_auth_guard_1.JwtAuthGuard),
    __param(0, (0, common_1.Headers)('x-auth-token')),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String]),
    __metadata("design:returntype", Promise)
], MobileController.prototype, "getLastTest", null);
__decorate([
    (0, common_1.Post)('add-rapid-test-photo'),
    (0, common_1.UseGuards)(jwt_auth_guard_1.JwtAuthGuard),
    (0, common_1.UseInterceptors)((0, platform_express_1.FileInterceptor)('media')),
    __param(0, (0, common_1.Headers)('x-auth-token')),
    __param(1, (0, common_1.UploadedFile)()),
    __param(2, (0, common_1.Body)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String, Object, Object]),
    __metadata("design:returntype", Promise)
], MobileController.prototype, "addRapidTestPhoto", null);
__decorate([
    (0, common_1.Post)('add-rapid-test-video'),
    (0, common_1.UseGuards)(jwt_auth_guard_1.JwtAuthGuard),
    (0, common_1.UseInterceptors)((0, platform_express_1.FileInterceptor)('media')),
    __param(0, (0, common_1.Headers)('x-auth-token')),
    __param(1, (0, common_1.UploadedFile)()),
    __param(2, (0, common_1.Body)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String, Object, Object]),
    __metadata("design:returntype", Promise)
], MobileController.prototype, "addRapidTestVideo", null);
__decorate([
    (0, common_1.Post)('add-identification-photo'),
    (0, common_1.UseGuards)(jwt_auth_guard_1.JwtAuthGuard),
    (0, common_1.UseInterceptors)((0, platform_express_1.FileInterceptor)('media')),
    __param(0, (0, common_1.Headers)('x-auth-token')),
    __param(1, (0, common_1.UploadedFile)()),
    __param(2, (0, common_1.Body)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String, Object, Object]),
    __metadata("design:returntype", Promise)
], MobileController.prototype, "addIdentificationPhoto", null);
__decorate([
    (0, common_1.Post)('get-be-status-flags'),
    __param(0, (0, common_1.Body)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [Object]),
    __metadata("design:returntype", Promise)
], MobileController.prototype, "getBackendStatus", null);
__decorate([
    (0, common_1.Post)('get-live-token'),
    (0, common_1.UseGuards)(jwt_auth_guard_1.JwtAuthGuard),
    __param(0, (0, common_1.Headers)('x-auth-token')),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String]),
    __metadata("design:returntype", Promise)
], MobileController.prototype, "getLiveToken", null);
__decorate([
    (0, common_1.Post)('init-authentication'),
    (0, common_1.UseGuards)(jwt_auth_guard_1.JwtAuthGuard),
    __param(0, (0, common_1.Headers)('x-auth-token')),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String]),
    __metadata("design:returntype", Promise)
], MobileController.prototype, "initAuthentication", null);
__decorate([
    (0, common_1.Post)('unset-authentication'),
    (0, common_1.UseGuards)(jwt_auth_guard_1.JwtAuthGuard),
    __param(0, (0, common_1.Headers)('x-auth-token')),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String]),
    __metadata("design:returntype", Promise)
], MobileController.prototype, "unsetAuthentication", null);
exports.MobileController = MobileController = __decorate([
    (0, common_1.Controller)('gg-homedx-json/gg-api/v1'),
    __metadata("design:paramtypes", [auth_service_1.AuthService,
        user_service_1.UserService,
        rapid_test_service_1.RapidTestService,
        file_upload_service_1.FileUploadService,
        jwt_1.JwtService])
], MobileController);
//# sourceMappingURL=mobile.controller.js.map