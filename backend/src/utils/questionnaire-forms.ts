import {
  assertCatalogueConsistent,
  V04Package,
  V04Questionnaire,
} from './questionnaire-v04-engine';

/**
 * Maps the RheumaCheck V04 catalogue onto the API modules the app uses.
 *
 * API keys stay short (A, B, C, CFU, D) so existing app routes keep working.
 * The catalogue keeps its own ids (RC-A …) and is stored alongside.
 *
 * RC-C contains section C-S07 (optional follow-up). It is split into its own form
 * because the handover requires follow-up to be a separate invitation, never a
 * fifth obligatory part of the experience questionnaire.
 */

export type V04ApiModuleId = 'A' | 'B' | 'C' | 'CFU' | 'D';
export type V04Role = 'patient' | 'professional';

export interface V04Form {
  moduleId: V04ApiModuleId;
  catalogueId: string;
  role: V04Role;
  /** Catalogue questionnaire restricted to this form's sections. */
  questionnaire: V04Questionnaire;
}

export const FOLLOW_UP_SECTION_ID = 'C-S07';

const FORM_BY_CATALOGUE_ID: Record<string, { moduleId: V04ApiModuleId; role: V04Role }> = {
  'RC-A': { moduleId: 'A', role: 'patient' },
  'RC-B': { moduleId: 'B', role: 'professional' },
  'RC-C': { moduleId: 'C', role: 'patient' },
  'RC-D': { moduleId: 'D', role: 'professional' },
};

export function buildForms(pkg: V04Package): V04Form[] {
  assertCatalogueConsistent(pkg.questionnaires);
  const forms: V04Form[] = [];

  for (const q of pkg.questionnaires) {
    const mapping = FORM_BY_CATALOGUE_ID[q.id];
    if (!mapping) {
      throw new Error(`Unmapped catalogue questionnaire ${q.id}`);
    }

    const mainSections = q.sections.filter((s) => s.id !== FOLLOW_UP_SECTION_ID);
    const followUpSections = q.sections.filter((s) => s.id === FOLLOW_UP_SECTION_ID);

    forms.push({
      moduleId: mapping.moduleId,
      catalogueId: q.id,
      role: mapping.role,
      questionnaire: { ...q, sections: mainSections },
    });

    if (followUpSections.length > 0) {
      forms.push({
        moduleId: 'CFU',
        catalogueId: `${q.id}-FU`,
        role: mapping.role,
        questionnaire: { ...q, id: `${q.id}-FU`, sections: followUpSections },
      });
    }
  }

  for (const form of forms) {
    assertCatalogueConsistent([form.questionnaire]);
  }
  return forms;
}
