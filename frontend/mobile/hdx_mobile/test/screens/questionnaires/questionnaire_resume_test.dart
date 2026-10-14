import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hdx_mobile/core/api_service.dart';
import 'package:hdx_mobile/l10n/app_localizations.dart';
import 'package:hdx_mobile/models/questionnaire/questionnaire_models.dart';
import 'package:hdx_mobile/screens/questionnaires/questionnaire_flow_screen.dart';
import 'package:hdx_mobile/services/questionnaire_service.dart';

/// Synthetic fixture: one doctor-side question, no clinical content.
final _module = QuestionnaireModule.fromJson({
  'moduleId': 'B',
  'catalogueId': 'RC-B',
  'title': 'Testbogen',
  'audience': 'Test',
  'sections': [
    {
      'id': 'S1',
      'title': 'Testabschnitt',
      'items': [
        {
          'id': 'X1',
          'type': 'single',
          'required': true,
          'text': 'Testfrage',
          'options': ['Ja', 'Nein'],
          'responseContract': {'kind': 'categorical_single'},
        },
      ],
    },
  ],
});

QuestionnaireSubmission _draft({required Map<String, dynamic> answers}) =>
    QuestionnaireSubmission.fromJson({
      'id': 'draft-1',
      'moduleId': 'B',
      'moduleVersion': 'v04:test',
      'respondentType': 'physician',
      'status': 'DRAFT',
      'consentStatus': 'NOT_APPLICABLE',
      'language': 'de-DE',
      'answers': answers,
      'createdAt': '2026-10-01T10:00:00.000Z',
      'updatedAt': '2026-10-02T10:00:00.000Z',
      'revision': '2026-10-02T10:00:00.000Z',
    });

class _FakeService extends QuestionnaireService {
  _FakeService(this.draft) : super(ApiService(baseUrl: 'http://127.0.0.1:4000'));

  final QuestionnaireSubmission? draft;
  int saveCalls = 0;

  @override
  Future<QuestionnaireModule> getDefinition(String moduleId) async => _module;

  @override
  Future<QuestionnaireSubmission?> getSubmission({
    String? submissionId,
    String? moduleId,
    String? linkedRapidTestId,
  }) async =>
      draft;

  @override
  Future<QuestionnaireSubmission> saveDraft({
    required String moduleId,
    required Map<String, dynamic> answers,
    String? submissionId,
    String? expectedUpdatedAt,
    String? linkedRapidTestId,
    String? consentStatus,
  }) async {
    saveCalls++;
    throw const QuestionnaireApiException('NOT_EXPECTED_IN_TEST');
  }
}

Future<void> _pump(WidgetTester tester, _FakeService service) async {
  tester.view.physicalSize = const Size(1200, 1600);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  await tester.pumpWidget(
    MaterialApp(
      locale: const Locale('de'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: QuestionnaireFlowScreen(moduleId: 'B', isDoctor: true, service: service),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('a saved draft is offered, not loaded, and nothing is saved', (tester) async {
    final service = _FakeService(_draft(answers: {'X1': 'Ja'}));
    await _pump(tester, service);

    expect(find.text('Gespeicherter Entwurf vorhanden'), findsOneWidget);
    expect(find.text('Entwurf fortsetzen'), findsOneWidget);
    expect(find.text('Testfrage'), findsNothing);
    expect(service.saveCalls, 0);
  });

  testWidgets('confirming the draft loads it into the flow', (tester) async {
    final service = _FakeService(_draft(answers: {'X1': 'Ja'}));
    await _pump(tester, service);

    await tester.tap(find.text('Entwurf fortsetzen'));
    await tester.pumpAndSettle();

    expect(find.text('Gespeicherter Entwurf vorhanden'), findsNothing);
    expect(find.text('Fragebogen starten'), findsOneWidget);
    expect(service.saveCalls, 0);
  });

  testWidgets('an empty draft is loaded without asking', (tester) async {
    final service = _FakeService(_draft(answers: {}));
    await _pump(tester, service);

    expect(find.text('Gespeicherter Entwurf vorhanden'), findsNothing);
    expect(find.text('Fragebogen starten'), findsOneWidget);
  });
}
