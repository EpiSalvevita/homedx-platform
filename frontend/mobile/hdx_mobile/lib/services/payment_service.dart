import '../core/api_service.dart';

class PaymentService {
  final ApiService _api;

  PaymentService(this._api);

  Future<Map<String, dynamic>> createPayment({
    required String userId,
    required String paymentMethod,
    String? rapidTestId,
    // Legacy params kept for call-site compatibility; server prefers [items].
    double? amount,
    String? currency,
    List<Map<String, dynamic>>? items,
  }) async {
    final response = await _api.post(
      'create-payment',
      body: {
        'paymentMethod': paymentMethod,
        if (rapidTestId != null) 'rapidTestId': rapidTestId,
        if (items != null && items.isNotEmpty) 'items': items,
      },
    );

    if (response['success'] != true) {
      throw Exception(response['error']?.toString() ?? 'Payment creation failed');
    }

    return Map<String, dynamic>.from(response['payment'] as Map);
  }

  Future<Map<String, dynamic>> getPayment(String paymentId) async {
    final response = await _api.post(
      'get-payment',
      body: {'paymentId': paymentId},
    );

    if (response['success'] != true) {
      throw Exception(response['error']?.toString() ?? 'Failed to get payment');
    }

    return Map<String, dynamic>.from(response['payment'] as Map);
  }

  Future<Map<String, dynamic>> getPaymentAmount() async {
    final response = await _api.post('get-payment-amount', body: {});

    if (response['success'] != true) {
      throw Exception(response['error']?.toString() ?? 'Failed to get payment amount');
    }

    return {
      'amount': response['amount'],
      'discount': response['discount'],
      'discountType': response['discountType'],
      'reducedAmount': response['reducedAmount'],
    };
  }

  Future<List<Map<String, dynamic>>> getUserPayments(String userId) async {
    final response = await _api.post('list-payments', body: {});
    if (response['success'] != true) {
      throw Exception(response['error']?.toString() ?? 'Failed to load payments');
    }
    final raw = response['payments'];
    if (raw is! List) return [];
    return raw
        .whereType<Map>()
        .map((m) => Map<String, dynamic>.from(m))
        .toList();
  }

  Future<String> createStripePaymentIntent({
    required String paymentId,
  }) async {
    final response = await _api.post(
      'create-stripe-payment-intent',
      body: {
        'paymentId': paymentId,
      },
    );

    if (response['success'] != true || response['clientSecret'] == null) {
      throw Exception(
        response['error']?.toString() ?? 'Failed to create payment intent',
      );
    }

    return response['clientSecret'] as String;
  }

  Future<Map<String, dynamic>> confirmStripePayment({
    required String paymentId,
  }) async {
    final response = await _api.post(
      'confirm-stripe-payment',
      body: {'paymentId': paymentId},
    );

    if (response['success'] != true) {
      throw Exception(response['error']?.toString() ?? 'Failed to confirm payment');
    }

    return Map<String, dynamic>.from(response['payment'] as Map);
  }

  Future<Map<String, String>> createPayPalOrder({
    String? paymentId,
    String? returnUrl,
    String? cancelUrl,
    // Legacy — server uses payment record amount when paymentId is set.
    double? amount,
    String? currency,
  }) async {
    final response = await _api.post(
      'create-paypal-order',
      body: {
        if (paymentId != null) 'paymentId': paymentId,
        if (returnUrl != null) 'returnUrl': returnUrl,
        if (cancelUrl != null) 'cancelUrl': cancelUrl,
      },
    );

    if (response['success'] != true ||
        response['orderId'] == null ||
        response['approvalUrl'] == null) {
      throw Exception(response['error']?.toString() ?? 'Failed to create PayPal order');
    }

    return {
      'orderId': response['orderId'] as String,
      'approvalUrl': response['approvalUrl'] as String,
    };
  }

  Future<Map<String, dynamic>> capturePayPalOrder({
    required String paymentId,
    String? paypalOrderId,
  }) async {
    final response = await _api.post(
      'capture-paypal-order',
      body: {
        'paymentId': paymentId,
        if (paypalOrderId != null) 'paypalOrderId': paypalOrderId,
      },
    );

    if (response['success'] != true) {
      throw Exception(response['error']?.toString() ?? 'Failed to capture PayPal order');
    }

    return Map<String, dynamic>.from(response['payment'] as Map);
  }

  Future<Map<String, dynamic>> waitForPaymentCompleted(
    String paymentId, {
    int maxAttempts = 30,
    Duration interval = const Duration(seconds: 2),
  }) async {
    for (var i = 0; i < maxAttempts; i++) {
      final payment = await getPayment(paymentId);
      final status = payment['status']?.toString();
      if (status == 'COMPLETED') {
        return payment;
      }
      if (status == 'FAILED') {
        throw Exception('Payment failed');
      }
      await Future.delayed(interval);
    }
    throw Exception('Payment confirmation timed out');
  }
}
