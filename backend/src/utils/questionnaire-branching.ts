export const FORM_DEPTH_KEY = '__formDepth';
export const FORM_DEPTH_KURZ = 'kurz';
export const FORM_DEPTH_VOLL = 'voll';

export interface QuestionnaireShowIf {
  field: string;
  equals: string;
}

export interface QuestionnaireFieldDef {
  id: string;
  type: string;
  required: boolean;
  label: string;
  options?: string[];
  show_if?: QuestionnaireShowIf;
  /** Which form depths include this field. Omitted / empty = both. */
  depth?: string[];
}

export interface QuestionnaireSectionDef {
  section_id: string;
  title: string;
  fields: QuestionnaireFieldDef[];
}

export interface QuestionnaireModuleDef {
  module_id: string;
  title: string;
  target_group: string;
  timing?: string;
  purpose?: string;
  sections: QuestionnaireSectionDef[];
}

export interface QuestionnairePackageDef {
  project: string;
  package_version: string;
  language: string;
  form_depths?: string[];
  default_form_depth?: string;
  modules: QuestionnaireModuleDef[];
}

export function normalizeFormDepth(raw: unknown): string {
  return raw === FORM_DEPTH_VOLL ? FORM_DEPTH_VOLL : FORM_DEPTH_KURZ;
}

export function formDepthFromAnswers(answers: Record<string, unknown>): string {
  return normalizeFormDepth(answers[FORM_DEPTH_KEY]);
}

function fieldIncludesDepth(field: QuestionnaireFieldDef, formDepth: string): boolean {
  const depth = field.depth;
  if (!depth || depth.length === 0) return true;
  return depth.includes(formDepth);
}

function matchesShowIf(
  showIf: QuestionnaireShowIf | undefined,
  answers: Record<string, unknown>,
): boolean {
  if (!showIf) return true;
  const value = answers[showIf.field];
  if (Array.isArray(value)) {
    return value.includes(showIf.equals);
  }
  return String(value ?? '') === showIf.equals;
}

/** Supplemental rules from docs/imports/anamnesefrageboegen/markdown/03_branching_logic.md */
function passesSupplementalRules(
  moduleId: string,
  fieldId: string,
  answers: Record<string, unknown>,
): boolean {
  if (moduleId === 'A') {
    const jointPain = String(answers.A_joint_pain ?? '');
    if (jointPain === 'nein') {
      const shortRouteHidden = new Set([
        'A_symptom_duration',
        'A_morning_stiffness',
        'A_morning_stiffness_duration',
        'A_affected_joints',
        'A_joint_count',
        'A_joint_swelling',
        'A_symmetrical',
        'A_pain_nrs',
        'A_function_limit',
        'A_known_lab_values',
        'A_prior_physician_contact',
      ]);
      if (shortRouteHidden.has(fieldId)) return false;
    }
    const vollPain = String(answers.A_v05 ?? '');
    if (vollPain === 'nein') {
      const vollHidden = new Set([
        'A_v06',
        'A_v07',
        'A_v08',
        'A_v09',
        'A_v10',
        'A_v11',
        'A_v12',
        'A_v13',
        'A_v14',
        'A_v15',
        'A_v16',
      ]);
      if (vollHidden.has(fieldId)) return false;
    }
  }

  if (moduleId === 'C') {
    const usedApp = String(answers.C_used_app ?? '');
    if (usedApp === 'nein') {
      const appOnly = new Set([
        'C_instructions_clear',
        'C_steps_easy',
        'C_visual_readability',
      ]);
      if (appOnly.has(fieldId)) return false;
    }
    const testPerformed = String(answers.C_test_performed ?? '');
    if (testPerformed === 'nein' || testPerformed === 'weiß nicht') {
      const testOnly = new Set([
        'C_instructions_clear',
        'C_steps_easy',
        'C_visual_readability',
        'C_result_shown',
        'C_result_understood',
        'C_overall_nrs',
        'C_would_reuse',
      ]);
      if (testOnly.has(fieldId)) return false;
    }
    const resultShown = String(answers.C_result_shown ?? '');
    if (resultShown === 'nein' || resultShown === 'weiß nicht') {
      if (fieldId === 'C_result_understood') return false;
    }
  }

  return true;
}

export function isFieldVisible(
  moduleId: string,
  field: QuestionnaireFieldDef,
  answers: Record<string, unknown>,
): boolean {
  const depth = formDepthFromAnswers(answers);
  if (!fieldIncludesDepth(field, depth)) return false;
  if (!matchesShowIf(field.show_if, answers)) return false;
  return passesSupplementalRules(moduleId, field.id, answers);
}

export function listVisibleFields(
  module: QuestionnaireModuleDef,
  answers: Record<string, unknown>,
): QuestionnaireFieldDef[] {
  const visible: QuestionnaireFieldDef[] = [];
  for (const section of module.sections) {
    for (const field of section.fields) {
      if (isFieldVisible(module.module_id, field, answers)) {
        visible.push(field);
      }
    }
  }
  return visible;
}

export function validateAnswersForModule(
  module: QuestionnaireModuleDef,
  answers: Record<string, unknown>,
): string[] {
  const errors: string[] = [];
  const visible = listVisibleFields(module, answers);

  for (const field of visible) {
    if (!field.required) continue;
    const value = answers[field.id];
    if (value === undefined || value === null || value === '') {
      errors.push(`Field ${field.id} is required`);
      continue;
    }
    if (field.type === 'multi_choice' && Array.isArray(value) && value.length === 0) {
      errors.push(`Field ${field.id} is required`);
    }
  }

  // Patient consent gate for module A (shared by kurz + voll)
  if (module.module_id === 'A') {
    if (answers.A_consent_info_read !== 'ja') {
      errors.push('Consent must be accepted for module A');
    }
  }

  return errors;
}
