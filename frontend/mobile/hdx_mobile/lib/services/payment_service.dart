import 'graphql_service.dart';

class PaymentService {
  final GraphQLService _graphQLService;

  PaymentService(this._graphQLService);

  Future<Map<String, dynamic>> createPayment({
    required String userId,
    required double amount,
    required String currency,
    required String paymentMethod,
    required List<dynamic> items,
  }) async {
    try {
      const mutation = '''
        mutation CreatePayment(\$input: CreatePaymentInput!) {
          createPayment(input: \$input) {
            id
            userId
            amount
            currency
            method
            status
            description
            transactionId
            createdAt
            updatedAt
            completedAt
            failureReason
          }
        }
      ''';

      final variables = {
        'input': {
          'userId': userId,
          'amount': amount,
          'currency': currency,
          'paymentMethod': paymentMethod,
        },
      };

      print('Creating payment with variables: $variables');
      
      final result = await _graphQLService.mutate(
        mutation: mutation,
        variables: variables,
      );

      print('Payment mutation result: hasException=${result.hasException}, data=${result.data}');

      if (result.hasException) {
        final errors = result.exception?.graphqlErrors ?? [];
        final linkException = result.exception?.linkException;
        
        String errorMessage = 'Payment creation failed';
        if (errors.isNotEmpty) {
          errorMessage = errors.map((e) => e.message).join(', ');
          print('GraphQL errors: ${errors.map((e) => e.message).join(', ')}');
        } else if (linkException != null) {
          errorMessage = linkException.toString();
          print('Link exception: $linkException');
        }
        
        throw Exception(errorMessage);
      }

      if (result.data != null && result.data!['createPayment'] != null) {
        return Map<String, dynamic>.from(result.data!['createPayment']);
      } else {
        throw Exception('Invalid response from server: ${result.data}');
      }
    } catch (e) {
      // Re-throw if it's already an Exception, otherwise wrap it
      if (e is Exception) {
        rethrow;
      }
      throw Exception('Failed to create payment: $e');
    }
  }

  Future<Map<String, dynamic>> getPaymentAmount() async {
    try {
      const query = '''
        query GetPaymentAmount {
          paymentAmount {
            amount
            discount
            discountType
            reducedAmount
          }
        }
      ''';

      final result = await _graphQLService.query(query: query);

      if (result.hasException) {
        throw Exception(result.exception?.graphqlErrors.first.message ?? 'Failed to get payment amount');
      }

      if (result.data != null && result.data!['paymentAmount'] != null) {
        return Map<String, dynamic>.from(result.data!['paymentAmount']);
      } else {
        throw Exception('Invalid response from server');
      }
    } catch (e) {
      throw Exception('Failed to get payment amount: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getUserPayments(String userId) async {
    try {
      const query = '''
        query GetUserPayments(\$userId: String!) {
          userPayments(userId: \$userId) {
            id
            userId
            amount
            currency
            method
            status
            description
            transactionId
            createdAt
            updatedAt
            completedAt
            failureReason
          }
        }
      ''';

      final result = await _graphQLService.query(
        query: query,
        variables: {'userId': userId},
      );

      if (result.hasException) {
        throw Exception(result.exception?.graphqlErrors.first.message ?? 'Failed to get user payments');
      }

      if (result.data != null && result.data!['userPayments'] != null) {
        final List<dynamic> payments = result.data!['userPayments'];
        return payments.map((p) => Map<String, dynamic>.from(p)).toList();
      } else {
        return [];
      }
    } catch (e) {
      throw Exception('Failed to get user payments: $e');
    }
  }

  /// Create a Stripe payment intent via backend
  /// Returns the client secret for Stripe SDK
  Future<String> createStripePaymentIntent({
    required String paymentId,
    required double amount,
    required String currency,
  }) async {
    try {
      const mutation = '''
        mutation CreatePaymentIntent(\$input: CreateStripePaymentIntentInput!) {
          createPaymentIntent(input: \$input) {
            clientSecret
            paymentIntentId
          }
        }
      ''';

      print('Creating Stripe payment intent - paymentId: $paymentId, amount: $amount, currency: $currency');
      
      final result = await _graphQLService.mutate(
        mutation: mutation,
        variables: {
          'input': {
            'amount': amount,
            'currency': currency,
            'paymentId': paymentId,
          },
        },
      );

      print('Stripe payment intent result: hasException=${result.hasException}, data=${result.data}');

      if (result.hasException) {
        final errors = result.exception?.graphqlErrors ?? [];
        final linkException = result.exception?.linkException;
        
        String errorMessage = 'Failed to create payment intent';
        if (errors.isNotEmpty) {
          errorMessage = errors.map((e) => e.message).join(', ');
          print('GraphQL errors: $errorMessage');
        } else if (linkException != null) {
          errorMessage = linkException.toString();
          print('Link exception: $linkException');
        }
        
        throw Exception(errorMessage);
      }

      if (result.data != null && result.data!['createPaymentIntent'] != null) {
        final response = result.data!['createPaymentIntent'];
        if (response['clientSecret'] != null) {
          return response['clientSecret'];
        }
      }
      throw Exception('Invalid response from server');
    } catch (e) {
      throw Exception('Failed to create Stripe payment intent: $e');
    }
  }

  /// Create a PayPal order via backend
  /// Returns the approval URL and order ID
  Future<Map<String, String>> createPayPalOrder({
    required double amount,
    required String currency,
    String? returnUrl,
    String? cancelUrl,
  }) async {
    try {
      const mutation = '''
        mutation CreatePayPalOrder(\$input: CreatePayPalOrderInput!) {
          createPayPalOrder(input: \$input) {
            orderId
            approvalUrl
          }
        }
      ''';

      final input = <String, dynamic>{
        'amount': amount,
        'currency': currency,
      };
      if (returnUrl != null) input['returnUrl'] = returnUrl;
      if (cancelUrl != null) input['cancelUrl'] = cancelUrl;

      final result = await _graphQLService.mutate(
        mutation: mutation,
        variables: {'input': input},
      );

      if (result.hasException) {
        throw Exception(result.exception?.graphqlErrors.first.message ?? 'Failed to create PayPal order');
      }

      if (result.data != null && result.data!['createPayPalOrder'] != null) {
        final response = result.data!['createPayPalOrder'];
        return {
          'orderId': response['orderId'],
          'approvalUrl': response['approvalUrl'],
        };
      }
      throw Exception('Invalid response from server');
    } catch (e) {
      throw Exception('Failed to create PayPal order: $e');
    }
  }

  /// Update payment with transaction ID and status
  Future<Map<String, dynamic>> updatePayment({
    required String paymentId,
    String? transactionId,
    String? status,
  }) async {
    try {
      const mutation = '''
        mutation UpdatePayment(\$id: String!, \$input: UpdatePaymentInput!) {
          updatePayment(id: \$id, input: \$input) {
            id
            status
            transactionId
            updatedAt
          }
        }
      ''';

      final input = <String, dynamic>{};
      if (transactionId != null) input['transactionId'] = transactionId;
      if (status != null) input['status'] = status;

      final result = await _graphQLService.mutate(
        mutation: mutation,
        variables: {
          'id': paymentId,
          'input': input,
        },
      );

      if (result.hasException) {
        throw Exception(result.exception?.graphqlErrors.first.message ?? 'Failed to update payment');
      }

      if (result.data != null && result.data!['updatePayment'] != null) {
        return Map<String, dynamic>.from(result.data!['updatePayment']);
      } else {
        throw Exception('Invalid response from server');
      }
    } catch (e) {
      throw Exception('Failed to update payment: $e');
    }
  }
}

