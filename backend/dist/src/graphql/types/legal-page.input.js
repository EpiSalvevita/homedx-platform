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
exports.GetLegalPagesInput = exports.GetLegalPageInput = void 0;
const graphql_1 = require("@nestjs/graphql");
const legal_page_types_1 = require("./legal-page.types");
let GetLegalPageInput = class GetLegalPageInput {
};
exports.GetLegalPageInput = GetLegalPageInput;
__decorate([
    (0, graphql_1.Field)(() => legal_page_types_1.LegalPageType),
    __metadata("design:type", String)
], GetLegalPageInput.prototype, "type", void 0);
__decorate([
    (0, graphql_1.Field)({ defaultValue: 'de' }),
    __metadata("design:type", String)
], GetLegalPageInput.prototype, "language", void 0);
exports.GetLegalPageInput = GetLegalPageInput = __decorate([
    (0, graphql_1.InputType)()
], GetLegalPageInput);
let GetLegalPagesInput = class GetLegalPagesInput {
};
exports.GetLegalPagesInput = GetLegalPagesInput;
__decorate([
    (0, graphql_1.Field)(() => [legal_page_types_1.LegalPageType], { nullable: true }),
    __metadata("design:type", Array)
], GetLegalPagesInput.prototype, "types", void 0);
__decorate([
    (0, graphql_1.Field)({ defaultValue: 'de' }),
    __metadata("design:type", String)
], GetLegalPagesInput.prototype, "language", void 0);
__decorate([
    (0, graphql_1.Field)({ defaultValue: true }),
    __metadata("design:type", Boolean)
], GetLegalPagesInput.prototype, "activeOnly", void 0);
exports.GetLegalPagesInput = GetLegalPagesInput = __decorate([
    (0, graphql_1.InputType)()
], GetLegalPagesInput);
//# sourceMappingURL=legal-page.input.js.map