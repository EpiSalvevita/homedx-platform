import { Module } from '@nestjs/common';
import { PaymentService } from '../../services/payment.service';
import { MobilePaymentService } from '../../services/mobile-payment.service';
import { StripeService } from '../../services/stripe.service';
import { PayPalService } from '../../services/paypal.service';
import { MobilePaymentController } from '../../controllers/mobile-payment.controller';
import { WebhooksController } from '../../controllers/webhooks.controller';
import { NotificationsModule } from '../notifications/notifications.module';

@Module({
  imports: [NotificationsModule],
  controllers: [MobilePaymentController, WebhooksController],
  providers: [PaymentService, MobilePaymentService, StripeService, PayPalService],
  exports: [PaymentService, MobilePaymentService, StripeService, PayPalService],
})
export class PaymentsModule {}
