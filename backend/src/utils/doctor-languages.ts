/** Languages offered for doctor profiles and patient booking filters. */
export const DOCTOR_LANGUAGES = [
  'Deutsch',
  'Englisch',
  'Französisch',
  'Türkisch',
  'Arabisch',
  'Russisch',
] as const;

export type DoctorLanguage = (typeof DOCTOR_LANGUAGES)[number];

export function isDoctorLanguage(value: string): boolean {
  return DOCTOR_LANGUAGES.includes(value as DoctorLanguage);
}
