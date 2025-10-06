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
exports.LegalPageResponse = exports.LegalPage = exports.LegalPageType = void 0;
const graphql_1 = require("@nestjs/graphql");
var LegalPageType;
(function (LegalPageType) {
    LegalPageType["PRIVACY_POLICY"] = "PRIVACY_POLICY";
    LegalPageType["TERMS_CONDITIONS"] = "TERMS_CONDITIONS";
    LegalPageType["IMPRESSUM"] = "IMPRESSUM";
    LegalPageType["COOKIE_POLICY"] = "COOKIE_POLICY";
})(LegalPageType || (exports.LegalPageType = LegalPageType = {}));
(0, graphql_1.registerEnumType)(LegalPageType, {
    name: 'LegalPageType',
    description: 'Type of legal page',
});
let LegalPage = class LegalPage {
};
exports.LegalPage = LegalPage;
__decorate([
    (0, graphql_1.Field)(),
    __metadata("design:type", String)
], LegalPage.prototype, "id", void 0);
__decorate([
    (0, graphql_1.Field)(() => LegalPageType),
    __metadata("design:type", String)
], LegalPage.prototype, "type", void 0);
__decorate([
    (0, graphql_1.Field)(),
    __metadata("design:type", String)
], LegalPage.prototype, "title", void 0);
__decorate([
    (0, graphql_1.Field)(),
    __metadata("design:type", String)
], LegalPage.prototype, "content", void 0);
__decorate([
    (0, graphql_1.Field)(),
    __metadata("design:type", String)
], LegalPage.prototype, "language", void 0);
__decorate([
    (0, graphql_1.Field)(),
    __metadata("design:type", String)
], LegalPage.prototype, "version", void 0);
__decorate([
    (0, graphql_1.Field)(),
    __metadata("design:type", Boolean)
], LegalPage.prototype, "isActive", void 0);
__decorate([
    (0, graphql_1.Field)(),
    __metadata("design:type", Date)
], LegalPage.prototype, "createdAt", void 0);
__decorate([
    (0, graphql_1.Field)(),
    __metadata("design:type", Date)
], LegalPage.prototype, "updatedAt", void 0);
exports.LegalPage = LegalPage = __decorate([
    (0, graphql_1.ObjectType)()
], LegalPage);
let LegalPageResponse = class LegalPageResponse {
};
exports.LegalPageResponse = LegalPageResponse;
__decorate([
    (0, graphql_1.Field)(() => [LegalPage]),
    __metadata("design:type", Array)
], LegalPageResponse.prototype, "pages", void 0);
__decorate([
    (0, graphql_1.Field)(),
    __metadata("design:type", Number)
], LegalPageResponse.prototype, "total", void 0);
exports.LegalPageResponse = LegalPageResponse = __decorate([
    (0, graphql_1.ObjectType)()
], LegalPageResponse);
//# sourceMappingURL=legal-page.types.js.map