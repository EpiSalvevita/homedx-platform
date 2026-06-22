import { Injectable, Logger } from '@nestjs/common';

@Injectable()
export class PushService {
  private readonly logger = new Logger(PushService.name);

  async sendToToken(
    token: string,
    payload: { title: string; body: string },
  ): Promise<void> {
    if (!process.env.FIREBASE_SERVICE_ACCOUNT_JSON?.trim()) {
      this.logger.debug(
        `Push skipped (no FIREBASE_SERVICE_ACCOUNT_JSON): ${payload.title}`,
      );
      return;
    }

    try {
      // Optional: load firebase-admin when credentials are configured.
      const admin = await import('firebase-admin');
      if (!admin.apps.length) {
        const cred = JSON.parse(process.env.FIREBASE_SERVICE_ACCOUNT_JSON);
        admin.initializeApp({
          credential: admin.credential.cert(cred),
        });
      }
      await admin.messaging().send({
        token,
        notification: { title: payload.title, body: payload.body },
      });
    } catch (error) {
      this.logger.warn(`Push send failed: ${error?.message ?? error}`);
    }
  }
}
