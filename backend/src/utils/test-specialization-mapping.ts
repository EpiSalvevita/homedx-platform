const BY_TEST_TYPE_ID: Record<string, string[]> = {
  rheumacheck: ['Rheumatologie'],
  crp: ['Innere Medizin', 'Allgemeinmedizin'],
  vitamind: ['Endokrinologie', 'Allgemeinmedizin'],
  'covid-rapid': ['Pulmologie', 'Allgemeinmedizin'],
  antigen: ['Allgemeinmedizin'],
  pcr: ['Pulmologie', 'Innere Medizin'],
};

const DEFAULT_SPECIALIZATIONS = ['Allgemeinmedizin'];

export function specializationsForTestType(testTypeId?: string | null): string[] {
  if (!testTypeId || testTypeId.trim().length === 0) {
    return DEFAULT_SPECIALIZATIONS;
  }
  const key = testTypeId.trim().toLowerCase();
  return BY_TEST_TYPE_ID[key] ?? DEFAULT_SPECIALIZATIONS;
}

export function doctorMatchesTestType(
  testTypeId: string | null | undefined,
  doctorSpecialization: string,
): boolean {
  const specs = specializationsForTestType(testTypeId);
  const candidate = doctorSpecialization.toLowerCase();
  return specs.some((s) => candidate.includes(s.toLowerCase()));
}
