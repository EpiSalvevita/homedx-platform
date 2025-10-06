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
exports.UserService = void 0;
const common_1 = require("@nestjs/common");
const prisma_service_1 = require("./prisma.service");
let UserService = class UserService {
    constructor(prisma) {
        this.prisma = prisma;
    }
    async findAll() {
        return this.prisma.user.findMany();
    }
    async findOne(id) {
        return this.prisma.user.findUnique({
            where: { id },
        });
    }
    async findByEmail(email) {
        return this.prisma.user.findUnique({
            where: { email },
        });
    }
    async findById(id) {
        return this.prisma.user.findUnique({
            where: { id },
        });
    }
    async create(data) {
        return this.prisma.user.create({
            data: {
                email: data.email,
                password: data.password,
                firstName: data.firstName,
                lastName: data.lastName,
                phone: data.phone,
                dateOfBirth: data.dateOfBirth,
                address: data.address1,
                city: data.city,
                postalCode: data.postcode,
                country: data.country,
                role: 'USER',
                status: 'ACTIVE',
                emailVerified: false,
            },
        });
    }
    async update(id, data) {
        const updateData = {};
        if (data.firstName !== undefined)
            updateData.firstName = data.firstName;
        if (data.lastName !== undefined)
            updateData.lastName = data.lastName;
        if (data.phone !== undefined)
            updateData.phone = data.phone;
        if (data.dateOfBirth !== undefined)
            updateData.dateOfBirth = data.dateOfBirth;
        if (data.address1 !== undefined)
            updateData.address = data.address1;
        if (data.city !== undefined)
            updateData.city = data.city;
        if (data.postcode !== undefined)
            updateData.postalCode = data.postcode;
        if (data.country !== undefined)
            updateData.country = data.country;
        return this.prisma.user.update({
            where: { id },
            data: updateData,
        });
    }
    async remove(id) {
        return this.prisma.user.delete({
            where: { id },
        });
    }
};
exports.UserService = UserService;
exports.UserService = UserService = __decorate([
    (0, common_1.Injectable)(),
    __metadata("design:paramtypes", [prisma_service_1.PrismaService])
], UserService);
//# sourceMappingURL=user.service.js.map