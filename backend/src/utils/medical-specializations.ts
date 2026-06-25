/** Fachrichtungen offered in doctor registration (aligned with app test mapping + seeds). */
export const MEDICAL_SPECIALIZATIONS = [
  'Allgemeinmedizin',
  'Endokrinologie',
  'Innere Medizin',
  'Kardiologie',
  'Pulmologie',
  'Rheumatologie',
] as const;

export type MedicalSpecialization = (typeof MEDICAL_SPECIALIZATIONS)[number];

export function isMedicalSpecialization(value: string): boolean {
  return MEDICAL_SPECIALIZATIONS.includes(value as MedicalSpecialization);
}
