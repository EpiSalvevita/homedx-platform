/// Maps backend profile/update validation messages to German UI text.
String localizeProfileError(String message) {
  final lower = message.toLowerCase();

  if (lower.contains('property email should not exist')) {
    return 'E-Mail kann hier nicht geändert werden. Bitte laden Sie die Seite neu (Strg+Shift+R) und versuchen Sie es erneut.';
  }
  if (lower.contains('gender must be one of')) {
    return 'Bitte wählen Sie ein gültiges Geschlecht aus.';
  }
  if (lower.contains('invalid request')) {
    return 'Ungültige Anfrage. Bitte prüfen Sie Ihre Eingaben und versuchen Sie es erneut.';
  }

  return message;
}
