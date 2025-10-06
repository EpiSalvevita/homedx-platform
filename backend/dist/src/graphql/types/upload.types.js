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
Object.defineProperty(exports, "__esModule", { value: true });
exports.Upload = exports.UploadResponse = exports.GraphQLUpload = void 0;
const graphql_1 = require("@nestjs/graphql");
const graphql_2 = require("graphql");
exports.GraphQLUpload = new graphql_2.GraphQLScalarType({
    name: 'Upload',
    description: 'The `Upload` scalar type represents a file upload.',
    parseValue: (value) => value,
    serialize: (value) => value,
    parseLiteral: (ast) => ast,
});
let UploadResponse = class UploadResponse {
};
exports.UploadResponse = UploadResponse;
__decorate([
    (0, graphql_1.Field)(),
    __metadata("design:type", Boolean)
], UploadResponse.prototype, "success", void 0);
__decorate([
    (0, graphql_1.Field)({ nullable: true }),
    __metadata("design:type", String)
], UploadResponse.prototype, "objectName", void 0);
__decorate([
    (0, graphql_1.Field)({ nullable: true }),
    __metadata("design:type", String)
], UploadResponse.prototype, "validation", void 0);
exports.UploadResponse = UploadResponse = __decorate([
    (0, graphql_1.ObjectType)()
], UploadResponse);
let Upload = class Upload {
};
exports.Upload = Upload;
__decorate([
    (0, graphql_1.Field)(),
    __metadata("design:type", String)
], Upload.prototype, "filename", void 0);
__decorate([
    (0, graphql_1.Field)(),
    __metadata("design:type", String)
], Upload.prototype, "mimetype", void 0);
__decorate([
    (0, graphql_1.Field)(),
    __metadata("design:type", String)
], Upload.prototype, "encoding", void 0);
exports.Upload = Upload = __decorate([
    (0, graphql_1.ObjectType)()
], Upload);
//# sourceMappingURL=upload.types.js.map