import 'package:flutter_test/flutter_test.dart';
import 'package:hdx_mobile/utils/cube_test_config_assets.dart';

void main() {
  test('crp maps to CRP_250702_216.bin', () {
    expect(cubeConfigAssetBasenameForTestType('crp'), 'CRP_250702_216.bin');
    expect(cubeConfigAssetBasenameForTestType('CRP'), 'CRP_250702_216.bin');
  });

  test('other types do not force an asset', () {
    expect(cubeConfigAssetBasenameForTestType('rheumacheck'), isNull);
    expect(cubeConfigAssetBasenameForTestType(''), isNull);
  });
}
