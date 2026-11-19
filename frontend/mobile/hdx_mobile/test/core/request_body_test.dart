import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:hdx_mobile/core/api_service.dart';
import 'package:hdx_mobile/services/payment_service.dart';
import 'package:hdx_mobile/services/questionnaire_service.dart';

/// Request-body tests through the REAL ApiService / service methods with a
/// mocked HTTP client. They guard the `'k': ?x` null-aware map elements:
/// optional keys must be ABSENT (not null) when unset and present with the
/// exact value when set. Synthetic values only.
void main() {
  late List<Map<String, dynamic>> bodies;
  late List<Uri> uris;
  late ApiService api;

  setUp(() {
    bodies = [];
    uris = [];
    final mock = MockClient((http.Request req) async {
      uris.add(req.url);
      bodies.add(jsonDecode(req.body) as Map<String, dynamic>);
      // Failure response: tests only assert on what was sent.
      return http.Response(
        jsonEncode({'success': false, 'error': 'stub'}),
        200,
        headers: {'content-type': 'application/json'},
      );
    });
    api = ApiService(baseUrl: 'http://test.invalid/api', client: mock);
  });

  tearDown(() => api.dispose());

  Future<void> swallow(Future<Object?> f) async {
    try {
      await f;
    } catch (_) {}
  }

  group('submit-cube-data', () {
    test('unset optional params are absent, not null', () async {
      await swallow(api.submitCubeData(testTypeId: 'synthetic-type'));
      expect(uris.single.path, endsWith('/submit-cube-data'));
      expect(bodies.single, {'testTypeId': 'synthetic-type'});
    });

    test('all params set are sent with exact values', () async {
      final rows = [
        {'name': 'synthetic', 'class': 'POSITIVE', 'value': 1.5},
        {'name': 'synthetic2', 'class': 'NEGATIVE'},
      ];
      await swallow(api.submitCubeData(
        testTypeId: 'synthetic-type',
        rapidTestId: 'rt-1',
        rawData: [1, 2, 3],
        deviceSerial: 'SN-0',
        measurementTimestamp: 1700000000,
        result: 'positive',
        resultData: rows,
      ));
      expect(bodies.single, {
        'testTypeId': 'synthetic-type',
        'rapidTestId': 'rt-1',
        'rawData': [1, 2, 3],
        'deviceSerial': 'SN-0',
        'measurementTimestamp': 1700000000,
        'result': 'positive',
        'resultData': rows,
      });
    });

    test('empty resultData and empty result are still sent (not dropped)',
        () async {
      await swallow(api.submitCubeData(
        testTypeId: 'synthetic-type',
        resultData: const [],
        result: '',
      ));
      expect(bodies.single.containsKey('resultData'), isTrue);
      expect(bodies.single['resultData'], isEmpty);
      expect(bodies.single['result'], '');
    });
  });

  group('PaymentService', () {
    test('createPayment: rapidTestId absent vs present', () async {
      final svc = PaymentService(api);
      await swallow(svc.createPayment(userId: 'u', paymentMethod: 'stripe'));
      await swallow(svc.createPayment(
          userId: 'u', paymentMethod: 'stripe', rapidTestId: 'rt-1'));
      expect(bodies[0], {'paymentMethod': 'stripe'});
      expect(bodies[1], {'paymentMethod': 'stripe', 'rapidTestId': 'rt-1'});
    });

    test('createPayPalOrder: keys absent vs present', () async {
      final svc = PaymentService(api);
      await swallow(svc.createPayPalOrder());
      await swallow(svc.createPayPalOrder(
        paymentId: 'p-1',
        returnUrl: 'https://example.invalid/ok',
        cancelUrl: 'https://example.invalid/cancel',
      ));
      expect(bodies[0], <String, dynamic>{});
      expect(bodies[1], {
        'paymentId': 'p-1',
        'returnUrl': 'https://example.invalid/ok',
        'cancelUrl': 'https://example.invalid/cancel',
      });
    });

    test('capturePayPalOrder: paypalOrderId absent vs present', () async {
      final svc = PaymentService(api);
      await swallow(svc.capturePayPalOrder(paymentId: 'p-1'));
      await swallow(
          svc.capturePayPalOrder(paymentId: 'p-1', paypalOrderId: 'o-1'));
      expect(bodies[0], {'paymentId': 'p-1'});
      expect(bodies[1], {'paymentId': 'p-1', 'paypalOrderId': 'o-1'});
    });
  });

  group('QuestionnaireService', () {
    final answers = {'q1': 'a', 'q2': 2};
    final fullOptional = {
      'submissionId': 's-1',
      'expectedUpdatedAt': '2026-01-01T00:00:00Z',
      'linkedRapidTestId': 'rt-1',
      'consentStatus': 'granted',
    };

    test('saveDraft: optional keys absent vs present', () async {
      final svc = QuestionnaireService(api);
      await swallow(svc.saveDraft(moduleId: 'm', answers: answers));
      await swallow(svc.saveDraft(
        moduleId: 'm',
        answers: answers,
        submissionId: 's-1',
        expectedUpdatedAt: '2026-01-01T00:00:00Z',
        linkedRapidTestId: 'rt-1',
        consentStatus: 'granted',
      ));
      expect(uris[0].path, endsWith('/save-questionnaire-draft'));
      expect(bodies[0], {'moduleId': 'm', 'answers': answers});
      expect(bodies[1], {'moduleId': 'm', 'answers': answers, ...fullOptional});
    });

    test('submit: optional keys absent vs present', () async {
      final svc = QuestionnaireService(api);
      await swallow(svc.submit(moduleId: 'm', answers: answers));
      await swallow(svc.submit(
        moduleId: 'm',
        answers: answers,
        submissionId: 's-1',
        expectedUpdatedAt: '2026-01-01T00:00:00Z',
        linkedRapidTestId: 'rt-1',
        consentStatus: 'granted',
      ));
      expect(uris[0].path, endsWith('/submit-questionnaire'));
      expect(bodies[0], {'moduleId': 'm', 'answers': answers});
      expect(bodies[1], {'moduleId': 'm', 'answers': answers, ...fullOptional});
    });

    test('getSubmission: keys absent vs present', () async {
      final svc = QuestionnaireService(api);
      await swallow(svc.getSubmission());
      await swallow(svc.getSubmission(
          submissionId: 's-1', moduleId: 'm', linkedRapidTestId: 'rt-1'));
      expect(uris[0].path, endsWith('/get-questionnaire-submission'));
      expect(bodies[0], <String, dynamic>{});
      expect(bodies[1], {
        'submissionId': 's-1',
        'moduleId': 'm',
        'linkedRapidTestId': 'rt-1',
      });
    });
  });
}
