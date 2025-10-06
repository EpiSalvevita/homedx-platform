"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const core_1 = require("@nestjs/core");
const common_1 = require("@nestjs/common");
const app_module_1 = require("./app.module");
const graphqlUploadExpress = require('graphql-upload/graphqlUploadExpress.mjs').default;
async function bootstrap() {
    const app = await core_1.NestFactory.create(app_module_1.AppModule);
    app.enableCors({
        origin: ['http://localhost:3000', 'http://localhost:3001', 'http://localhost:8080', 'http://localhost:8000'],
        credentials: true,
    });
    app.use(graphqlUploadExpress({ maxFileSize: 10000000, maxFiles: 5 }));
    app.useGlobalPipes(new common_1.ValidationPipe({
        transform: true,
        whitelist: true,
        forbidNonWhitelisted: false,
    }));
    await app.listen(4000);
}
bootstrap();
//# sourceMappingURL=main.js.map