import '../services/api_service.dart';

class PaymentService {
  final ApiService _api;

  PaymentService(this._api);

  Future<Map<String, dynamic>> createPayment({
    required String userId,
    required double amount,
    required String currency,
    required String paymentMethod,
    required List<dynamic> items,
    String? rapidTestId,
  }) async {
    final response = await _api.post(
      'create-payment',
      body: {
        'amount': amount,
        'currency': currency,
        'paymentMethod': paymentMethod,
        if (rapidTestId != null) 'rapidTestId': rapidTestId,
      },
    );

    if (response['success'] != true) {
      throw Exception(response['error']?.toString() ?? 'Payment creation failed');
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
    required double amount,
    required String currency,
  }) async {
    final response = await _api.post(
      'create-stripe-payment-intent',
      body: {
        'paymentId': paymentId,
        'amount': amount,
        'currency': currency,
      },
    );

    if (response['success'] != true || response['clientSecret'] == null) {
      throw Exception(
        response['error']?.toString() ?? 'Failed to create payment intent',
      );
    }

    return response['clientSecret'] as String;
  }

  Future<Map<String, String>> createPayPalOrder({
    required double amount,
    required String currency,
    String? paymentId,
    String? returnUrl,
    String? cancelUrl,
  }) async {
    final response = await _api.post(
      'create-paypal-order',
      body: {
        'amount': amount,
        'currency': currency,
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

  Future<Map<String, dynamic>> updatePayment({
    required String paymentId,
    String? transactionId,
    String? status,
    String? paymentIntentId,
    String? paypalOrderId,
  }) async {
    final response = await _api.post(
      'update-payment',
      body: {
        'paymentId': paymentId,
        if (transactionId != null) 'transactionId': transactionId,
        if (status != null) 'status': status,
        if (paymentIntentId != null) 'paymentIntentId': paymentIntentId,
        if (paypalOrderId != null) 'paypalOrderId': paypalOrderId,
      },
    );

    if (response['success'] != true) {
      throw Exception(response['error']?.toString() ?? 'Failed to update payment');
    }

    return Map<String, dynamic>.from(response['payment'] as Map);
  }
}
