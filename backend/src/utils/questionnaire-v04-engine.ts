/**
 * RheumaCheck V04 catalogue engine (server side).
 *
 * Pure functions, no I/O. Source of truth for behaviour is the handover
 * catalogue work/imports/rheumacheck-v04/catalogue/questionnaires.de-DE.V04.public.json
 * and FACHLICHE_PRUEFPUNKTE / INTERFACE_CONTRACT in the same folder.
 *
 * Rules (fail closed):
 * - An unanswered parent never satisfies a rule, including `neq`.
 * - Cyclic or unknown references are configuration errors (V04CatalogueError).
 * - `required` applies only to visible items.
 * - Answers for items that are not visible are pruned, not validated.
 * - Exclusivity comes only from explicit `exclusiveOptions`; wording is never parsed.
 * - Limits and allowed labels come from `responseContract`, not hard-coded per item.
 * - No scores, sums or risk values are computed here.
 */

export type V04Op = 'eq' | 'neq' | 'in' | 'contains' | 'answered';

export type V04Rule =
  | { any: V04Rule[] }
  | { all: V04Rule[] }
  | { feature: string; op: 'shown' }
  | { item: string; op: V04Op; value?: string; values?: string[] };

export interface V04ResponseContract {
  kind: string;
  minimum?: number;
  maximum?: number;
  maximumLength?: number;
  minimumSelected?: number;
  maximumSelected?: number;
  ratings?: string[];
  optionSource?: { item: string; intersection: string[] };
}

export interface V04Item {
  id: string;
  type: string;
  required: boolean;
  text: string;
  options: string[];
  exclusiveOptions?: string[];
  visibilityRule?: V04Rule;
  optionSource?: { item: string; intersection?: string[] };
  responseContract: V04ResponseContract;
}

export interface V04Questionnaire {
  id: string;
  version: string;
  title: string;
  audience?: string;
  estimatedTime?: string;
  status?: string;
  sections: { id: string; title: string; intro?: string; items: V04Item[] }[];
}

export interface V04Package {
  packageId: string;
  packageVersion: string;
  locale: string;
  status: string;
  questionnaires: V04Questionnaire[];
}

export type V04Answers = Record<string, unknown>;

export class V04CatalogueError extends Error {}

export interface V04ValidationIssue {
  itemId: string;
  code:
    | 'unknown_item'
    | 'required'
    | 'invalid_value'
    | 'option_not_allowed'
    | 'not_storable';
}

export interface V04ValidationResult {
  ok: boolean;
  issues: V04ValidationIssue[];
  /** Answers restricted to visible, storable items. Use this, not the raw input. */
  cleanAnswers: V04Answers;
  visibleItemIds: string[];
}

export function isAnswered(value: unknown): boolean {
  if (value === undefined || value === null || value === '') return false;
  if (Array.isArray(value)) return value.length > 0;
  if (typeof value === 'object') return Object.keys(value as object).length > 0;
  return true;
}

function collectRuleItemRefs(rule: V04Rule | undefined, out: string[] = []): string[] {
  if (!rule) return out;
  if ('any' in rule) rule.any.forEach((r) => collectRuleItemRefs(r, out));
  else if ('all' in rule) rule.all.forEach((r) => collectRuleItemRefs(r, out));
  else if ('item' in rule) out.push(rule.item);
  return out;
}

/**
 * Static checks for one or more questionnaires: unique ids, every reference resolves,
 * no cycles across visibilityRule and optionSource edges.
 */
export function assertCatalogueConsistent(questionnaires: V04Questionnaire[]): void {
  const items = new Map<string, V04Item>();
  for (const q of questionnaires) {
    for (const s of q.sections) {
      for (const item of s.items) {
        if (items.has(item.id)) {
          throw new V04CatalogueError(`Duplicate item id ${item.id}`);
        }
        items.set(item.id, item);
      }
    }
  }

  const edges = (item: V04Item): string[] => {
    const refs = collectRuleItemRefs(item.visibilityRule);
    if (item.optionSource?.item) refs.push(item.optionSource.item);
    return refs;
  };

  for (const item of items.values()) {
    for (const ref of edges(item)) {
      if (!items.has(ref)) {
        throw new V04CatalogueError(`Item ${item.id} references unknown item ${ref}`);
      }
    }
  }

  const state = new Map<string, 'visiting' | 'done'>();
  const visit = (id: string) => {
    const s = state.get(id);
    if (s === 'done') return;
    if (s === 'visiting') {
      throw new V04CatalogueError(`Cyclic dependency at ${id}`);
    }
    state.set(id, 'visiting');
    for (const ref of edges(items.get(id)!)) visit(ref);
    state.set(id, 'done');
  };
  for (const id of items.keys()) visit(id);
}

export interface EvaluateOptions {
  features?: Record<string, boolean>;
}

/**
 * Returns the set of visible item ids for the given answers.
 * Assumes the catalogue has already passed assertCatalogueConsistent.
 */
export function evaluateVisibility(
  items: V04Item[],
  answers: V04Answers,
  options: EvaluateOptions = {},
): Set<string> {
  const byId = new Map(items.map((i) => [i.id, i]));
  const memo = new Map<string, boolean>();
  const features = options.features ?? {};

  const isVisible = (id: string): boolean => {
    const cached = memo.get(id);
    if (cached !== undefined) return cached;
    const item = byId.get(id);
    const result = item ? ruleHolds(item.visibilityRule, answers, features, isVisible) : false;
    memo.set(id, result);
    return result;
  };

  return new Set(items.filter((i) => isVisible(i.id)).map((i) => i.id));
}

function ruleHolds(
  rule: V04Rule | undefined,
  answers: V04Answers,
  features: Record<string, boolean>,
  isVisible: (id: string) => boolean,
): boolean {
  if (!rule) return true;
  if ('any' in rule) return rule.any.some((r) => ruleHolds(r, answers, features, isVisible));
  if ('all' in rule) return rule.all.every((r) => ruleHolds(r, answers, features, isVisible));
  if ('feature' in rule) return features[rule.feature] === true;

  if (!isVisible(rule.item)) return false;
  const value = answers[rule.item];
  if (!isAnswered(value)) return false;

  switch (rule.op) {
    case 'answered':
      return true;
    case 'eq':
      return value === rule.value;
    case 'neq':
      return value !== rule.value;
    case 'in':
      return typeof value === 'string' && (rule.values ?? []).includes(value);
    case 'contains':
      return Array.isArray(value) && value.includes(rule.value);
    default:
      return false;
  }
}

function checkValue(
  item: V04Item,
  value: unknown,
  answers: V04Answers,
  strict: boolean,
): V04ValidationIssue['code'] | null {
  const contract = item.responseContract;
  const options = item.options ?? [];

  switch (contract.kind) {
    case 'categorical_single':
      return typeof value === 'string' && options.includes(value) ? null : 'invalid_value';

    case 'categorical_multi': {
      if (!Array.isArray(value) || !value.every((v) => typeof v === 'string')) return 'invalid_value';
      if (new Set(value).size !== value.length) return 'invalid_value';
      if (!value.every((v) => options.includes(v))) return 'invalid_value';
      const exclusive = item.exclusiveOptions ?? [];
      if (value.some((v) => exclusive.includes(v)) && value.length > 1) return 'invalid_value';
      return optionSourceCheck(item, value, answers);
    }

    case 'ranked_codes': {
      if (!Array.isArray(value) || !value.every((v) => typeof v === 'string')) return 'invalid_value';
      if (new Set(value).size !== value.length) return 'invalid_value';
      const min = strict ? (contract.minimumSelected ?? 1) : 0;
      const max = contract.maximumSelected ?? options.length;
      if (value.length < min || value.length > max) return 'invalid_value';
      return value.every((v) => options.includes(v)) ? null : 'invalid_value';
    }

    case 'matrix': {
      const ratings = contract.ratings ?? [];
      if (typeof value !== 'object' || value === null || Array.isArray(value)) return 'invalid_value';
      const row = value as Record<string, unknown>;
      if (!Object.keys(row).every((k) => options.includes(k))) return 'invalid_value';
      // Drafts may hold a partial matrix; submit requires every row to be rated.
      const valid = (o: string) => typeof row[o] === 'string' && ratings.includes(row[o] as string);
      if (!strict) return Object.keys(row).every(valid) ? null : 'invalid_value';
      return options.every(valid) ? null : 'invalid_value';
    }

    case 'integer': {
      const min = contract.minimum ?? 0;
      const max = contract.maximum ?? 10;
      return typeof value === 'number' && Number.isInteger(value) && value >= min && value <= max
        ? null
        : 'invalid_value';
    }

    case 'string': {
      const limit = contract.maximumLength ?? 500;
      return typeof value === 'string' && value.length <= limit ? null : 'invalid_value';
    }

    case 'ui_control_not_research_response':
      return 'not_storable';

    default:
      return 'invalid_value';
  }
}

function optionSourceCheck(
  item: V04Item,
  value: string[],
  answers: V04Answers,
): V04ValidationIssue['code'] | null {
  const source = item.optionSource;
  if (!source) return null;
  const parent = answers[source.item];
  const parentSelection = Array.isArray(parent) ? (parent as string[]) : [];
  const restricted = source.intersection ?? [];
  const disallowed = value.some((v) => restricted.includes(v) && !parentSelection.includes(v));
  return disallowed ? 'option_not_allowed' : null;
}

/**
 * Validates a complete answer set against a questionnaire.
 * Use before saving a draft (lenient on required) and before finalizing (strict).
 */
export function validateAnswers(
  questionnaire: V04Questionnaire,
  answers: V04Answers,
  options: EvaluateOptions & { strict?: boolean } = {},
): V04ValidationResult {
  const items = questionnaire.sections.flatMap((s) => s.items);
  const byId = new Map(items.map((i) => [i.id, i]));
  const strict = options.strict ?? true;
  const issues: V04ValidationIssue[] = [];

  for (const key of Object.keys(answers)) {
    if (!byId.has(key)) issues.push({ itemId: key, code: 'unknown_item' });
  }

  const visible = evaluateVisibility(items, answers, options);
  const cleanAnswers: V04Answers = {};

  for (const item of items) {
    if (!visible.has(item.id)) continue;
    const value = answers[item.id];
    const answered = isAnswered(value);

    if (item.responseContract.kind === 'ui_control_not_research_response') {
      if (answered) issues.push({ itemId: item.id, code: 'not_storable' });
      continue;
    }

    if (!answered) {
      if (strict && item.required) issues.push({ itemId: item.id, code: 'required' });
      continue;
    }

    const code = checkValue(item, value, answers, strict);
    if (code) {
      issues.push({ itemId: item.id, code });
    } else {
      cleanAnswers[item.id] = value;
    }
  }

  return {
    ok: issues.length === 0,
    issues,
    cleanAnswers,
    visibleItemIds: items.filter((i) => visible.has(i.id)).map((i) => i.id),
  };
}
