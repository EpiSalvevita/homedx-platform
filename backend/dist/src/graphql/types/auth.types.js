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
exports.AuthResponse = exports.CheckEmailResponse = exports.CheckEmailInput = exports.SignupInput = exports.LoginInput = void 0;
const graphql_1 = require("@nestjs/graphql");
const user_type_1 = require("./user.type");
const class_validator_1 = require("class-validator");
let LoginInput = class LoginInput {
};
exports.LoginInput = LoginInput;
__decorate([
    (0, graphql_1.Field)(),
    (0, class_validator_1.IsEmail)(),
    __metadata("design:type", String)
], LoginInput.prototype, "email", void 0);
__decorate([
    (0, graphql_1.Field)(),
    (0, class_validator_1.IsString)(),
    (0, class_validator_1.MinLength)(8),
    __metadata("design:type", String)
], LoginInput.prototype, "password", void 0);
exports.LoginInput = LoginInput = __decorate([
    (0, graphql_1.InputType)()
], LoginInput);
let SignupInput = class SignupInput {
};
exports.SignupInput = SignupInput;
__decorate([
    (0, graphql_1.Field)(),
    (0, class_validator_1.IsEmail)({}, { message: 'Please provide a valid email address' }),
    __metadata("design:type", String)
], SignupInput.prototype, "email", void 0);
__decorate([
    (0, graphql_1.Field)(),
    (0, class_validator_1.IsString)(),
    (0, class_validator_1.MinLength)(8, { message: 'Password must be at least 8 characters long' }),
    __metadata("design:type", String)
], SignupInput.prototype, "password", void 0);
__decorate([
    (0, graphql_1.Field)(),
    (0, class_validator_1.IsString)(),
    (0, class_validator_1.MinLength)(2, { message: 'First name must be at least 2 characters long' }),
    __metadata("design:type", String)
], SignupInput.prototype, "firstName", void 0);
__decorate([
    (0, graphql_1.Field)(),
    (0, class_validator_1.IsString)(),
    (0, class_validator_1.MinLength)(2, { message: 'Last name must be at least 2 characters long' }),
    __metadata("design:type", String)
], SignupInput.prototype, "lastName", void 0);
exports.SignupInput = SignupInput = __decorate([
    (0, graphql_1.InputType)()
], SignupInput);
let CheckEmailInput = class CheckEmailInput {
};
exports.CheckEmailInput = CheckEmailInput;
__decorate([
    (0, graphql_1.Field)(),
    (0, class_validator_1.IsEmail)({}, { message: 'Please provide a valid email address' }),
    __metadata("design:type", String)
], CheckEmailInput.prototype, "email", void 0);
exports.CheckEmailInput = CheckEmailInput = __decorate([
    (0, graphql_1.InputType)()
], CheckEmailInput);
let CheckEmailResponse = class CheckEmailResponse {
};
exports.CheckEmailResponse = CheckEmailResponse;
__decorate([
    (0, graphql_1.Field)(),
    __metadata("design:type", Boolean)
], CheckEmailResponse.prototype, "exists", void 0);
__decorate([
    (0, graphql_1.Field)(),
    __metadata("design:type", Boolean)
], CheckEmailResponse.prototype, "valid", void 0);
exports.CheckEmailResponse = CheckEmailResponse = __decorate([
    (0, graphql_1.ObjectType)()
], CheckEmailResponse);
let AuthResponse = class AuthResponse {
};
exports.AuthResponse = AuthResponse;
__decorate([
    (0, graphql_1.Field)(),
    __metadata("design:type", String)
], AuthResponse.prototype, "access_token", void 0);
__decorate([
    (0, graphql_1.Field)(() => user_type_1.User),
    __metadata("design:type", user_type_1.User)
], AuthResponse.prototype, "user", void 0);
exports.AuthResponse = AuthResponse = __decorate([
    (0, graphql_1.ObjectType)()
], AuthResponse);
//# sourceMappingURL=auth.types.js.map