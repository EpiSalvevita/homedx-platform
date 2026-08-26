import 'package:flutter_test/flutter_test.dart';
import 'package:hdx_mobile/utils/app_assets.dart';

void main() {
  test('doctorPortraitFor is stable for the same id and name', () {
    const id = 'doc-klaus-becker';
    const name = 'Dr. Klaus Becker';
    final first = AppAssets.doctorPortraitFor(id, doctorName: name);
    expect(first, AppAssets.doctorPortraitFor(id, doctorName: name));
    expect(AppAssets.doctorAvatarsMale, contains(first));
  });

  test('women get female illustrations, men get male ones', () {
    expect(
      AppAssets.doctorAvatarsFemale,
      contains(AppAssets.doctorPortraitFor('a', doctorName: 'Dr. Sarah Müller')),
    );
    expect(
      AppAssets.doctorAvatarsFemale,
      contains(AppAssets.doctorPortraitFor('b', doctorName: 'Dr. Anna Weber')),
    );
    expect(
      AppAssets.doctorAvatarsMale,
      contains(AppAssets.doctorPortraitFor('c', doctorName: 'Dr. Michael Schmidt')),
    );
  });

  test('two women can receive different female faces', () {
    final sarah = AppAssets.doctorPortraitFor('doc-sarah', doctorName: 'Dr. Sarah Müller');
    final anna = AppAssets.doctorPortraitFor('doc-anna', doctorName: 'Dr. Anna Weber');
    expect(sarah, isNot(anna));
  });
}
