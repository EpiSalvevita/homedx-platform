part of 'cube_service.dart';

// SDK message classification, MT_ERROR catalogs, and EventChannel int parsing.
// Behavior-preserving extract from CubeService — do not change message text or codes
// without MDR/IVDR review (user-facing measurement errors).

bool _cubeSdkMessageIsError(String msgType) {
  return msgType == 'MT_ERROR' || msgType == '1';
}

// ── CubeDLL `MT_ERROR` / device errors (Programmer's Guide §10.4, §10.6) ──

/// `MessageCode` when `MessageType` is `MT_ERROR` (decimal as emitted by native).
const int _emCommandNotSupported = 0x00;
const int _emDeviceError = 0x01;
const int _emCommunicationError = 0x02;
const int _emDateTimeInvalid = 0x03;
const int _emTimeOut = 0x04;
const int _emLicenseMismatch = 0x05;
const int _emTestConfigError = 0x06;

/// German UI text for `MT_ERROR` + messageCode + msgData (device / comm / config lists).
String _cubeMtErrorUserMessage(int messageCode, int data) {
  switch (messageCode) {
    case _emCommandNotSupported:
      return 'Der Befehl wird von diesem Cube nicht unterstützt.';
    case _emDeviceError:
      return _cubeDeviceErrorUserMessage(data);
    case _emCommunicationError:
      return _cubeCommunicationErrorUserMessage(data);
    case _emDateTimeInvalid:
      return 'Ungültiges Datum oder Uhrzeit vom Gerät.';
    case _emTimeOut:
      return data == 1
          ? 'Zeitüberschreitung: das Gerät wurde getrennt.'
          : 'Zeitüberschreitung bei der Kommunikation mit dem Cube.';
    case _emLicenseMismatch:
      return 'Die Cube-Lizenz passt nicht zu diesem Gerät (cube_license.dat).';
    case _emTestConfigError:
      return _cubeTestConfigErrorUserMessage(data);
    default:
      return 'Cube-Messung abgebrochen (SDK-Fehlercode $messageCode, Zusatz $data).';
  }
}

String _cubeDeviceErrorUserMessage(int data) {
  // Values are hex ordinals from the DLL (msgData equals 0xNN as decimal, e.g. 0x91 → 145).
  switch (data) {
    case 0x10:
      return 'Die Testkonfiguration ist abgelaufen (Ablaufdatum überschritten).';
    case 0x11:
      return 'Batterie im Cube zu schwach für diese Messung.';
    case 0x12:
    case 0x13:
    case 0x14:
    case 0x15:
      return 'Fehler bei der Bildaufnahme (Schwarz-/Hellwert). Bitte Kassette und Optik prüfen.';
    case 0x16:
      return 'Auswertung: Testlinie außerhalb des gültigen Bereichs.';
    case 0x17:
      return 'Auswertung: Suchbereich der Testlinie zu klein.';
    case 0x1A:
      return 'Die geladene Testkonfiguration ist ungültig.';
    case 0x1C:
      return 'Testkonfiguration: nicht unterstützte Version.';
    case 0x1D:
      return 'Messung wurde abgebrochen.';
    case 0x1E:
      return 'Vor der nächsten Messung ist ein QC-Test am Gerät erforderlich.';
    case 0x30:
      return 'Zeitüberschreitung beim Auslesen der RFID-Daten von der Kassette.';
    case 0x31:
      return 'RFID-Statusfehler auf der Kassette.';
    case 0x32:
      return 'RFID: empfangener Datensatz zu groß.';
    case 0x33:
      return 'RFID: mehrere Kassetten im Lesefeld (Kollision).';
    case 0x91:
      return 'Die Testkonfiguration (z. B. CRP-.bin) ist für dieses Cube-Modell '
          'nicht freigegeben — sie passt nicht zu Ihrem „Cube plus“. '
          'Bitte die vom Hersteller passende Konfiguration verwenden oder ohne '
          'externe Datei mit Kassetten-Kalibrierung (RFID) messen.';
    case 0x9E:
      return 'Kein gespeichertes Ergebnis mit dieser ID auf dem Gerät.';
    default:
      return 'Gerätefehler beim Cube (Technisch: Data=$data, 0x${data.toRadixString(16)}). '
          'Siehe CubeDLL Programmer’s Guide, Abschnitt „Device errors“.';
  }
}

String _cubeCommunicationErrorUserMessage(int data) {
  switch (data) {
    case 0x00:
      return 'Kommunikation: kein Fehler (unerwartet).';
    default:
      return 'Kommunikationsfehler mit dem Cube (Code $data / 0x${data.toRadixString(16)}).';
  }
}

String _cubeTestConfigErrorUserMessage(int data) {
  switch (data) {
    default:
      return 'Fehler in der Testkonfiguration (SDK 0x06, Detail $data).';
  }
}

/// `MessageData.EInfoMessage.getCode()` from cubelib (`MessageData.kt` / AAR).
/// Older code wrongly assumed hex 0x00–0x04; the SDK uses these ordinals.
const int _imConnectionEstablished = 1;
const int _imDeviceDisconnected = 2;
const int _imPlaceWhite = 3;
const int _imPlaceTest = 4;
const int _imTimerRunning = 5;
const int _imEvaluationRunning = 6;
const int _imEvaluationReadData = 7;
const int _imMeasurementDone = 8;
const int _imMeasureCount = 9;
const int _imDbFormatted = 10;

/// Lifecycle payloads we react to in [CubeService.runTestAndSubmit].
const Set<int> _cubeLifecycleInfoCodes = {
  _imConnectionEstablished,
  _imDeviceDisconnected,
  _imPlaceWhite,
  _imPlaceTest,
  _imTimerRunning,
  _imEvaluationRunning,
  _imEvaluationReadData,
  _imMeasurementDone,
  _imMeasureCount,
  _imDbFormatted,
};

/// StandardMethodCodec may deliver ints as [int], [double], or occasionally
/// [String]. A bad `as num?` cast throws and **kills the EventChannel stream**.
int _cubeEventInt(dynamic v) {
  if (v == null) return 0;
  if (v is int) return v;
  if (v is num) return v.toInt();
  if (v is String) return int.tryParse(v) ?? 0;
  return 0;
}

/// Cubelib `MessageData.EInfoMessage` names (see `infoMessage` from Android bridge).
int? _cubeEInfoMessageNameToCode(String name) {
  switch (name) {
    case 'IM_CONNECTION_ESTABLISHED':
      return _imConnectionEstablished;
    case 'IM_DEVICE_DISCONNECTED':
      return _imDeviceDisconnected;
    case 'IM_PLACE_WHITE':
      return _imPlaceWhite;
    case 'IM_PLACE_TEST':
      return _imPlaceTest;
    case 'IM_TIMER_RUNNING':
      return _imTimerRunning;
    case 'IM_EVALUATION_RUNNING':
      return _imEvaluationRunning;
    case 'IM_EVALUATION_READ_DATA':
      return _imEvaluationReadData;
    case 'IM_MEASUREMENT_DONE':
      return _imMeasurementDone;
    case 'IM_MEASURE_COUNT':
      return _imMeasureCount;
    case 'IM_DB_FORMATTED':
      return _imDbFormatted;
    default:
      return null;
  }
}

/// True when [msgCode] is a cubelib [MessageData.EInfoMessage] code (non-error types only).
bool _cubeSdkMessageIsInfo(String msgType, int msgCode) {
  if (_cubeSdkMessageIsError(msgType)) return false;
  return _cubeLifecycleInfoCodes.contains(msgCode);
}
