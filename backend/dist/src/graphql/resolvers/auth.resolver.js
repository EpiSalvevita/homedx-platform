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
exports.AuthResolver = void 0;
const graphql_1 = require("@nestjs/graphql");
const common_1 = require("@nestjs/common");
const auth_service_1 = require("../../services/auth.service");
const auth_types_1 = require("../types/auth.types");
const system_types_1 = require("../types/system.types");
const user_type_1 = require("../types/user.type");
const current_user_decorator_1 = require("../../auth/current-user.decorator");
const jwt_auth_guard_1 = require("../../auth/jwt-auth.guard");
let AuthResolver = class AuthResolver {
    constructor(authService) {
        this.authService = authService;
    }
    async me(user) {
        return user;
    }
    async login(input) {
        return this.authService.login(input.email, input.password);
    }
    async signup(input) {
        return this.authService.signup(input.email, input.password, input.firstName, input.lastName);
    }
    async testMutation() {
        return 'test';
    }
    async checkEmail(email) {
        return this.authService.checkEmail(email);
    }
    async setLanguage(language) {
        return {
            success: true,
            message: `Language set to ${language}`
        };
    }
};
exports.AuthResolver = AuthResolver;
__decorate([
    (0, graphql_1.Query)(() => user_type_1.User),
    (0, common_1.UseGuards)(jwt_auth_guard_1.JwtAuthGuard),
    __param(0, (0, current_user_decorator_1.CurrentUser)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [user_type_1.User]),
    __metadata("design:returntype", Promise)
], AuthResolver.prototype, "me", null);
__decorate([
    (0, graphql_1.Mutation)(() => auth_types_1.AuthResponse),
    __param(0, (0, graphql_1.Args)('input')),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [auth_types_1.LoginInput]),
    __metadata("design:returntype", Promise)
], AuthResolver.prototype, "login", null);
__decorate([
    (0, graphql_1.Mutation)(() => auth_types_1.AuthResponse),
    __param(0, (0, graphql_1.Args)('input')),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [auth_types_1.SignupInput]),
    __metadata("design:returntype", Promise)
], AuthResolver.prototype, "signup", null);
__decorate([
    (0, graphql_1.Mutation)(() => String),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", []),
    __metadata("design:returntype", Promise)
], AuthResolver.prototype, "testMutation", null);
__decorate([
    (0, graphql_1.Mutation)(() => auth_types_1.CheckEmailResponse),
    __param(0, (0, graphql_1.Args)('email')),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String]),
    __metadata("design:returntype", Promise)
], AuthResolver.prototype, "checkEmail", null);
__decorate([
    (0, graphql_1.Mutation)(() => system_types_1.SystemResponse),
    __param(0, (0, graphql_1.Args)('language')),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String]),
    __metadata("design:returntype", Promise)
], AuthResolver.prototype, "setLanguage", null);
exports.AuthResolver = AuthResolver = __decorate([
    (0, graphql_1.Resolver)(),
    __metadata("design:paramtypes", [auth_service_1.AuthService])
], AuthResolver);
//# sourceMappingURL=auth.resolver.js.map