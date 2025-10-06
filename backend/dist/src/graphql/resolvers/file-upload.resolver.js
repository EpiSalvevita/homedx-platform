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
exports.FileUploadResolver = void 0;
const graphql_1 = require("@nestjs/graphql");
const common_1 = require("@nestjs/common");
const file_upload_service_1 = require("../../services/file-upload.service");
const upload_types_1 = require("../types/upload.types");
const jwt_auth_guard_1 = require("../../auth/jwt-auth.guard");
let FileUploadResolver = class FileUploadResolver {
    constructor(fileUploadService) {
        this.fileUploadService = fileUploadService;
    }
    async uploadTestPhoto(file, fileExtension) {
        const result = await this.fileUploadService.uploadTestPhoto(file);
        return {
            success: true,
            objectName: result.objectName || `test-photo_${Date.now()}.${fileExtension}`
        };
    }
    async uploadTestVideo(file, fileExtension, head, headpre) {
        const result = await this.fileUploadService.uploadTestVideo(file);
        return {
            success: true,
            objectName: result.objectName || `test-video_${Date.now()}.${fileExtension}`,
            validation: 'PENDING'
        };
    }
    async uploadIdFrontPhoto(file, fileExtension) {
        const result = await this.fileUploadService.uploadIdFrontPhoto(file);
        return {
            success: true,
            objectName: result.objectName || `id-front_${Date.now()}.${fileExtension}`
        };
    }
    async uploadIdBackPhoto(file, fileExtension) {
        const result = await this.fileUploadService.uploadIdBackPhoto(file);
        return {
            success: true,
            objectName: result.objectName || `id-back_${Date.now()}.${fileExtension}`
        };
    }
};
exports.FileUploadResolver = FileUploadResolver;
__decorate([
    (0, graphql_1.Mutation)(() => upload_types_1.UploadResponse),
    (0, common_1.UseGuards)(jwt_auth_guard_1.JwtAuthGuard),
    __param(0, (0, graphql_1.Args)({ name: 'file', type: () => upload_types_1.GraphQLUpload })),
    __param(1, (0, graphql_1.Args)('fileExtension')),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [Object, String]),
    __metadata("design:returntype", Promise)
], FileUploadResolver.prototype, "uploadTestPhoto", null);
__decorate([
    (0, graphql_1.Mutation)(() => upload_types_1.UploadResponse),
    (0, common_1.UseGuards)(jwt_auth_guard_1.JwtAuthGuard),
    __param(0, (0, graphql_1.Args)({ name: 'file', type: () => upload_types_1.GraphQLUpload })),
    __param(1, (0, graphql_1.Args)('fileExtension')),
    __param(2, (0, graphql_1.Args)('head', { nullable: true })),
    __param(3, (0, graphql_1.Args)('headpre', { nullable: true })),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [Object, String, String, String]),
    __metadata("design:returntype", Promise)
], FileUploadResolver.prototype, "uploadTestVideo", null);
__decorate([
    (0, graphql_1.Mutation)(() => upload_types_1.UploadResponse),
    (0, common_1.UseGuards)(jwt_auth_guard_1.JwtAuthGuard),
    __param(0, (0, graphql_1.Args)({ name: 'file', type: () => upload_types_1.GraphQLUpload })),
    __param(1, (0, graphql_1.Args)('fileExtension')),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [Object, String]),
    __metadata("design:returntype", Promise)
], FileUploadResolver.prototype, "uploadIdFrontPhoto", null);
__decorate([
    (0, graphql_1.Mutation)(() => upload_types_1.UploadResponse),
    (0, common_1.UseGuards)(jwt_auth_guard_1.JwtAuthGuard),
    __param(0, (0, graphql_1.Args)({ name: 'file', type: () => upload_types_1.GraphQLUpload })),
    __param(1, (0, graphql_1.Args)('fileExtension')),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [Object, String]),
    __metadata("design:returntype", Promise)
], FileUploadResolver.prototype, "uploadIdBackPhoto", null);
exports.FileUploadResolver = FileUploadResolver = __decorate([
    (0, graphql_1.Resolver)(),
    __metadata("design:paramtypes", [file_upload_service_1.FileUploadService])
], FileUploadResolver);
//# sourceMappingURL=file-upload.resolver.js.map