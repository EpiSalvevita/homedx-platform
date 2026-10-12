import '../l10n/app_localizations.dart';

List<String> genderPickerLabels(AppLocalizations l10n) => [
      l10n.profileGenderMale,
      l10n.profileGenderFemale,
      l10n.profileGenderDivers,
    ];

String? genderApiToLabel(String? api, AppLocalizations l10n) {
  switch (api) {
    case 'MALE':
      return l10n.profileGenderMale;
    case 'FEMALE':
      return l10n.profileGenderFemale;
    case 'DIVERS':
      return l10n.profileGenderDivers;
    default:
      return null;
  }
}

String? labelToGenderApi(String? label, AppLocalizations l10n) {
  if (label == null) return null;
  if (label == l10n.profileGenderMale) return 'MALE';
  if (label == l10n.profileGenderFemale) return 'FEMALE';
  if (label == l10n.profileGenderDivers) return 'DIVERS';
  return null;
}

String formatGenderDe(String? gender, AppLocalizations l10n) {
  final label = genderApiToLabel(gender, l10n);
  if (label != null) return label;
  if (gender == null || gender.isEmpty) return '—';
  return gender;
}
