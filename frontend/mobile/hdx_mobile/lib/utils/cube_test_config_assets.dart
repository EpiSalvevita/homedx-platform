/// Cube evaluation config blobs shipped as Android APK assets
/// (`android/app/src/main/assets/`). Used when the user does not pick a file
/// and RFID/cassette-stored calibration is not desired for that assay.
///
/// Basenames only — [CubeService.startEvaluation] passes them to the native
/// `AssetManager.open(name)`.
String? cubeConfigAssetBasenameForTestType(String testTypeId) {
  switch (testTypeId.trim().toLowerCase()) {
    case 'crp':
      return 'CRP_250702_216.bin';
    default:
      return null;
  }
}
