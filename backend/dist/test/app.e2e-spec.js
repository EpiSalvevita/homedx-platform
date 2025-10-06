"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const testing_1 = require("@nestjs/testing");
const request = require("supertest");
const app_module_1 = require("../src/app.module");
describe('AppController (e2e)', () => {
    let app;
    beforeEach(async () => {
        const moduleFixture = await testing_1.Test.createTestingModule({
            imports: [app_module_1.AppModule],
        }).compile();
        app = moduleFixture.createNestApplication();
        await app.init();
    });
    it('/graphql (POST)', () => {
        return request(app.getHttpServer())
            .post('/graphql')
            .send({
            query: `query { 
          backendStatus 
        }`
        })
            .expect(200)
            .expect((res) => {
            expect(res.body.data.backendStatus).toBeDefined();
        });
    });
    afterEach(async () => {
        await app.close();
    });
});
//# sourceMappingURL=app.e2e-spec.js.map