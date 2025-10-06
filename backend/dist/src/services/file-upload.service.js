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
var __asyncValues = (this && this.__asyncValues) || function (o) {
    if (!Symbol.asyncIterator) throw new TypeError("Symbol.asyncIterator is not defined.");
    var m = o[Symbol.asyncIterator], i;
    return m ? m.call(o) : (o = typeof __values === "function" ? __values(o) : o[Symbol.iterator](), i = {}, verb("next"), verb("throw"), verb("return"), i[Symbol.asyncIterator] = function () { return this; }, i);
    function verb(n) { i[n] = o[n] && function (v) { return new Promise(function (resolve, reject) { v = o[n](v), settle(resolve, reject, v.done, v.value); }); }; }
    function settle(resolve, reject, d, v) { Promise.resolve(v).then(function(v) { resolve({ value: v, done: d }); }, reject); }
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.FileUploadService = void 0;
const common_1 = require("@nestjs/common");
const fs = require("fs");
const path = require("path");
const util_1 = require("util");
const writeFile = (0, util_1.promisify)(fs.writeFile);
const mkdir = (0, util_1.promisify)(fs.mkdir);
let FileUploadService = class FileUploadService {
    constructor() {
        this.uploadDir = 'uploads';
        this.ensureUploadDir();
    }
    async ensureUploadDir() {
        const uploadPath = path.join(process.cwd(), this.uploadDir);
        try {
            await mkdir(uploadPath, { recursive: true });
        }
        catch (error) {
        }
    }
    async uploadFile(file, subdirectory) {
        var _a, e_1, _b, _c;
        try {
            const fileAny = await file;
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
            const chunks = [];
            try {
                for (var _d = true, stream_1 = __asyncValues(stream), stream_1_1; stream_1_1 = await stream_1.next(), _a = stream_1_1.done, !_a; _d = true) {
                    _c = stream_1_1.value;
                    _d = false;
                    const chunk = _c;
                    chunks.push(chunk);
                }
            }
            catch (e_1_1) { e_1 = { error: e_1_1 }; }
            finally {
                try {
                    if (!_d && !_a && (_b = stream_1.return)) await _b.call(stream_1);
                }
                finally { if (e_1) throw e_1.error; }
            }
            const buffer = Buffer.concat(chunks);
            const maxSize = 10 * 1024 * 1024;
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
                if (mimetype === 'image/jpeg')
                    extension = '.jpeg';
                else if (mimetype === 'image/png')
                    extension = '.png';
                else if (mimetype === 'image/gif')
                    extension = '.gif';
                else if (mimetype === 'video/mp4')
                    extension = '.mp4';
                else if (mimetype === 'video/avi')
                    extension = '.avi';
                else if (mimetype === 'video/mov')
                    extension = '.mov';
                else if (mimetype === 'video/webm')
                    extension = '.webm';
                else
                    extension = '';
            }
            const objectName = `${subdirectory}_${timestamp}${extension}`;
            const filePath = path.join(subDirPath, objectName);
            await writeFile(filePath, buffer);
            return {
                success: true,
                objectName
            };
        }
        catch (error) {
            console.error('File upload error:', error);
            return {
                success: false,
                validation: 'File upload failed'
            };
        }
    }
    async uploadTestPhoto(file) {
        return this.uploadFile(file, 'test-photos');
    }
    async uploadTestVideo(file) {
        return this.uploadFile(file, 'test-videos');
    }
    async uploadIdFrontPhoto(file) {
        return this.uploadFile(file, 'id-front');
    }
    async uploadIdBackPhoto(file) {
        return this.uploadFile(file, 'id-back');
    }
};
exports.FileUploadService = FileUploadService;
exports.FileUploadService = FileUploadService = __decorate([
    (0, common_1.Injectable)(),
    __metadata("design:paramtypes", [])
], FileUploadService);
//# sourceMappingURL=file-upload.service.js.map