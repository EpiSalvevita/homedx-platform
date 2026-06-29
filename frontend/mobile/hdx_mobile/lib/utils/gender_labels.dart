const genderPickerLabels = ['Männlich', 'Weiblich', 'Divers'];

String? genderApiToLabel(String? api) {
  switch (api) {
    case 'MALE':
      return 'Männlich';
    case 'FEMALE':
      return 'Weiblich';
    case 'DIVERS':
      return 'Divers';
    default:
      return null;
  }
}

String? labelToGenderApi(String? label) {
  switch (label) {
    case 'Männlich':
      return 'MALE';
    case 'Weiblich':
      return 'FEMALE';
    case 'Divers':
      return 'DIVERS';
    default:
      return null;
  }
}

String formatGenderDe(String? gender) {
  final label = genderApiToLabel(gender);
  if (label != null) return label;
  if (gender == null || gender.isEmpty) return '—';
  return gender;
}
