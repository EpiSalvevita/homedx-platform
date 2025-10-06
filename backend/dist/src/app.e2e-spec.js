"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const testing_1 = require("@nestjs/testing");
const request = require("supertest");
const app_module_1 = require("../src/app.module");
describe('GraphQL E2E', () => {
    let app;
    beforeAll(async () => {
        const moduleFixture = await testing_1.Test.createTestingModule({
            imports: [app_module_1.AppModule],
        }).compile();
        app = moduleFixture.createNestApplication();
        await app.init();
    });
    describe('Authentication', () => {
        it('should sign up a new user', async () => {
            const res = await request(app.getHttpServer())
                .post('/graphql')
                .send({
                query: `mutation { 
            signup(input: { 
              email: "test@auto.com", 
              password: "password123", 
              firstName: "Test", 
              lastName: "User" 
            }) { 
              user { 
                id 
                email 
                firstName 
                lastName 
              } 
              access_token 
            } 
          }`
            });
            expect(res.status).toBe(200);
            expect(res.body.data.signup.user.email).toBe('test@auto.com');
            expect(res.body.data.signup.access_token).toBeDefined();
        });
        it('should login an existing user', async () => {
            const res = await request(app.getHttpServer())
                .post('/graphql')
                .send({
                query: `mutation { 
            login(input: { 
              email: "test@auto.com", 
              password: "password123" 
            }) { 
              user { 
                id 
                email 
              } 
              access_token 
            } 
          }`
            });
            expect(res.status).toBe(200);
            expect(res.body.data.login.user.email).toBe('test@auto.com');
            expect(res.body.data.login.access_token).toBeDefined();
        });
        it('should check email existence', async () => {
            const res = await request(app.getHttpServer())
                .post('/graphql')
                .send({
                query: `mutation { 
            checkEmail(input: { 
              email: "test@auto.com" 
            }) { 
              exists 
              valid 
            } 
          }`
            });
            expect(res.status).toBe(200);
            expect(res.body.data.checkEmail.exists).toBe(true);
            expect(res.body.data.checkEmail.valid).toBe(true);
        });
    });
    describe('System Operations', () => {
        it('should get backend status', async () => {
            const res = await request(app.getHttpServer())
                .post('/graphql')
                .send({
                query: `query { 
            backendStatus 
          }`
            });
            expect(res.status).toBe(200);
            expect(res.body.data.backendStatus).toBeDefined();
        });
        it('should get payment amount', async () => {
            const res = await request(app.getHttpServer())
                .post('/graphql')
                .send({
                query: `query { 
            paymentAmount 
          }`
            });
            expect(res.status).toBe(200);
            expect(res.body.data.paymentAmount).toBeDefined();
        });
        it('should get country codes', async () => {
            const res = await request(app.getHttpServer())
                .post('/graphql')
                .send({
                query: `query { 
            countryCodes 
          }`
            });
            expect(res.status).toBe(200);
            expect(Array.isArray(res.body.data.countryCodes)).toBe(true);
        });
    });
    describe('License Operations', () => {
        let authToken;
        beforeAll(async () => {
            const res = await request(app.getHttpServer())
                .post('/graphql')
                .send({
                query: `mutation { 
            login(input: { 
              email: "test@auto.com", 
              password: "password123" 
            }) { 
              access_token 
            } 
          }`
            });
            authToken = res.body.data.login.access_token;
        });
        it('should get licenses', async () => {
            const res = await request(app.getHttpServer())
                .post('/graphql')
                .set('Authorization', `Bearer ${authToken}`)
                .send({
                query: `query { 
            licenses { 
              id 
              licenseKey 
              status 
              maxUses 
              usesCount 
            } 
          }`
            });
            expect(res.status).toBe(200);
            expect(Array.isArray(res.body.data.licenses)).toBe(true);
        });
        it('should activate a license', async () => {
            const res = await request(app.getHttpServer())
                .post('/graphql')
                .set('Authorization', `Bearer ${authToken}`)
                .send({
                query: `mutation { 
            activateLicense(code: "TEST-LICENSE-001") { 
              success 
              license { 
                id 
                licenseKey 
                status 
                usesCount 
              } 
              message 
            } 
          }`
            });
            expect(res.status).toBe(200);
            expect(res.body.data.activateLicense.success).toBe(true);
        });
    });
    describe('File Upload Operations', () => {
        let authToken;
        beforeAll(async () => {
            const res = await request(app.getHttpServer())
                .post('/graphql')
                .send({
                query: `mutation { 
            login(input: { 
              email: "test@auto.com", 
              password: "password123" 
            }) { 
              access_token 
            } 
          }`
            });
            authToken = res.body.data.login.access_token;
        });
        it('should upload test photo', async () => {
            const res = await request(app.getHttpServer())
                .post('/graphql')
                .set('Authorization', `Bearer ${authToken}`)
                .send({
                query: `mutation { 
            uploadTestPhoto(
              fileData: "iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNkYPhfDwAChwGA60e6kgAAAABJRU5ErkJggg==", 
              filename: "test.png", 
              mimetype: "image/png"
            ) { 
              success 
              objectName 
              validation 
            } 
          }`
            });
            expect(res.status).toBe(200);
            expect(res.body.data.uploadTestPhoto.success).toBe(true);
        });
    });
    afterAll(async () => {
        await app.close();
    });
});
//# sourceMappingURL=app.e2e-spec.js.map