import { readFileSync } from 'fs';
import { join } from 'path';
import { buildForms } from './questionnaire-forms';
import {
  assertCatalogueConsistent,
  evaluateVisibility,
  V04CatalogueError,
  V04Item,
  V04Package,
  V04Questionnaire,
  validateAnswers,
} from './questionnaire-v04-engine';

const CATALOGUE_PATH = join(
  __dirname,
  '..',
  '..',
  'data',
  'questionnaires',
  'rheumacheck_questionnaires_v04.public.json',
);

function loadCatalogue(): V04Package {
  return JSON.parse(readFileSync(CATALOGUE_PATH, 'utf8')) as V04Package;
}

/** Synthetic fixtures only: no real patient data, no real clinical content. */
function item(partial: Partial<V04Item> & Pick<V04Item, 'id' | 'type' | 'responseContract'>): V04Item {
  return {
    required: false,
    text: `Testfrage ${partial.id}`,
    options: [],
    ...partial,
  };
}

function questionnaire(items: V04Item[]): V04Questionnaire {
  return {
    id: 'TEST-Q',
    version: 'test',
    title: 'Testbogen',
    sections: [{ id: 'S1', title: 'Abschnitt', items }],
  };
}

describe('RheumaCheck V04 catalogue (real file)', () => {
  const pkg = loadCatalogue();

  it('loads all four modules with 171 unique items and consistent references', () => {
    const items = pkg.questionnaires.flatMap((q) => q.sections.flatMap((s) => s.items));
    expect(items).toHaveLength(171);
    expect(new Set(items.map((i) => i.id)).size).toBe(171);
    expect(() => assertCatalogueConsistent(pkg.questionnaires)).not.toThrow();
  });

  it('keeps the expected per-module item counts', () => {
    const counts = Object.fromEntries(
      pkg.questionnaires.map((q) => [q.id, q.sections.reduce((n, s) => n + s.items.length, 0)]),
    );
    expect(counts).toEqual({ 'RC-A': 45, 'RC-B': 34, 'RC-C': 55, 'RC-D': 37 });
  });
});

describe('form split (real catalogue)', () => {
  const forms = buildForms(loadCatalogue());
  const byModule = (id: string) => forms.find((f) => f.moduleId === id)!;

  it('exposes A, B, C, CFU and D as separate forms', () => {
    expect(forms.map((f) => f.moduleId).sort()).toEqual(['A', 'B', 'C', 'CFU', 'D']);
  });

  it('keeps the optional follow-up out of the main experience form', () => {
    const mainIds = byModule('C').questionnaire.sections.flatMap((s) => s.items.map((i) => i.id));
    const fuIds = byModule('CFU').questionnaire.sections.flatMap((s) => s.items.map((i) => i.id));
    expect(mainIds).toHaveLength(47);
    expect(fuIds).toHaveLength(8);
    expect(mainIds.some((id) => id.startsWith('CFU'))).toBe(false);
    expect(byModule('CFU').catalogueId).toBe('RC-C-FU');
  });

  it('assigns patient and professional roles as in the handover', () => {
    expect(byModule('A').role).toBe('patient');
    expect(byModule('C').role).toBe('patient');
    expect(byModule('CFU').role).toBe('patient');
    expect(byModule('B').role).toBe('professional');
    expect(byModule('D').role).toBe('professional');
  });
});

describe('visibility', () => {
  it('treats an unanswered parent as not satisfying neq', () => {
    const items = [
      item({ id: 'P', type: 'categorical_single', responseContract: { kind: 'categorical_single' }, options: ['Ja', 'Nein'] }),
      item({
        id: 'K',
        type: 'categorical_single',
        responseContract: { kind: 'categorical_single' },
        options: ['x'],
        visibilityRule: { item: 'P', op: 'neq', value: 'Nein' },
      }),
    ];
    expect(evaluateVisibility(items, {}).has('K')).toBe(false);
    expect(evaluateVisibility(items, { P: 'Ja' }).has('K')).toBe(true);
    expect(evaluateVisibility(items, { P: 'Nein' }).has('K')).toBe(false);
  });

  it('hides children of hidden parents', () => {
    const items = [
      item({ id: 'P', type: 'categorical_single', responseContract: { kind: 'categorical_single' }, options: ['Ja'], visibilityRule: { feature: 'never', op: 'shown' } }),
      item({ id: 'K', type: 'categorical_single', responseContract: { kind: 'categorical_single' }, options: ['x'], visibilityRule: { item: 'P', op: 'answered' } }),
    ];
    expect(evaluateVisibility(items, { P: 'Ja' }).has('K')).toBe(false);
  });

  it('throws on cyclic references', () => {
    const items = [
      item({ id: 'A1', type: 'categorical_single', responseContract: { kind: 'categorical_single' }, options: ['x'], visibilityRule: { item: 'B1', op: 'answered' } }),
      item({ id: 'B1', type: 'categorical_single', responseContract: { kind: 'categorical_single' }, options: ['x'], visibilityRule: { item: 'A1', op: 'answered' } }),
    ];
    expect(() => assertCatalogueConsistent([questionnaire(items)])).toThrow(V04CatalogueError);
  });

  it('throws on unknown references', () => {
    const items = [
      item({ id: 'A1', type: 'categorical_single', responseContract: { kind: 'categorical_single' }, options: ['x'], visibilityRule: { item: 'NOPE', op: 'answered' } }),
    ];
    expect(() => assertCatalogueConsistent([questionnaire(items)])).toThrow(/unknown item NOPE/);
  });
});

describe('validateAnswers', () => {
  const single = item({
    id: 'S',
    type: 'categorical_single',
    required: true,
    responseContract: { kind: 'categorical_single' },
    options: ['Ja', 'Nein'],
  });

  it('requires visible required items only', () => {
    const hidden = item({
      id: 'H',
      type: 'categorical_single',
      required: true,
      responseContract: { kind: 'categorical_single' },
      options: ['x'],
      visibilityRule: { item: 'S', op: 'eq', value: 'Ja' },
    });
    const q = questionnaire([single, hidden]);
    const res = validateAnswers(q, { S: 'Nein' });
    expect(res.issues).toEqual([]);
    expect(res.ok).toBe(true);
    expect(res.visibleItemIds).toEqual(['S']);
  });

  it('reports missing required visible items in strict mode, not in draft mode', () => {
    const q = questionnaire([single]);
    expect(validateAnswers(q, {}).issues).toEqual([{ itemId: 'S', code: 'required' }]);
    expect(validateAnswers(q, {}, { strict: false }).ok).toBe(true);
  });

  it('prunes answers to items that became invisible instead of validating them', () => {
    const child = item({
      id: 'C',
      type: 'categorical_single',
      responseContract: { kind: 'categorical_single' },
      options: ['x'],
      visibilityRule: { item: 'S', op: 'eq', value: 'Ja' },
    });
    const q = questionnaire([single, child]);
    const res = validateAnswers(q, { S: 'Nein', C: 'x' });
    expect(res.ok).toBe(true);
    expect(res.cleanAnswers).toEqual({ S: 'Nein' });
  });

  it('rejects unknown item ids and options not in the list', () => {
    const q = questionnaire([single]);
    const res = validateAnswers(q, { S: 'Vielleicht', ZZ: 'x' });
    expect(res.issues).toEqual(
      expect.arrayContaining([
        { itemId: 'S', code: 'invalid_value' },
        { itemId: 'ZZ', code: 'unknown_item' },
      ]),
    );
  });

  it('enforces explicit exclusive options alone and never by wording', () => {
    const multi = item({
      id: 'M',
      type: 'multi',
      responseContract: { kind: 'categorical_multi' },
      options: ['keine', 'Schmerzmittel', 'Kortison'],
      exclusiveOptions: ['keine'],
    });
    const q = questionnaire([multi]);
    expect(validateAnswers(q, { M: ['keine', 'Kortison'] }).issues).toEqual([{ itemId: 'M', code: 'invalid_value' }]);
    expect(validateAnswers(q, { M: ['keine'] }).ok).toBe(true);
    // "Kortison" is not exclusive even though the reference heuristic would have treated some words as exclusive.
    expect(validateAnswers(q, { M: ['Schmerzmittel', 'Kortison'] }).ok).toBe(true);
  });

  it('rejects duplicate multi-select values', () => {
    const multi = item({
      id: 'M',
      type: 'multi',
      responseContract: { kind: 'categorical_multi' },
      options: ['a', 'b'],
    });
    expect(validateAnswers(questionnaire([multi]), { M: ['a', 'a'] }).ok).toBe(false);
  });

  it('accepts only integer numeric 0–10 for scales (no strings, booleans or arrays)', () => {
    const scale = item({
      id: 'SC',
      type: 'scale_0_10',
      required: true,
      responseContract: { kind: 'integer', minimum: 0, maximum: 10 },
      options: ['0', '10'],
    });
    const q = questionnaire([scale]);
    expect(validateAnswers(q, { SC: 4 }).ok).toBe(true);
    expect(validateAnswers(q, { SC: 0 }).ok).toBe(true);
    expect(validateAnswers(q, { SC: 10 }).ok).toBe(true);
    for (const bad of ['4', 11, -1, 4.5, true, [4], null]) {
      expect(validateAnswers(q, { SC: bad }).ok).toBe(false);
    }
  });

  it('requires a complete matrix with allowed ratings only', () => {
    const matrix = item({
      id: 'MX',
      type: 'matrix_presence',
      required: true,
      responseContract: { kind: 'matrix', ratings: ['regelhaft', 'manchmal'] },
      options: ['Zeile 1', 'Zeile 2'],
    });
    const q = questionnaire([matrix]);
    expect(validateAnswers(q, { MX: { 'Zeile 1': 'regelhaft' } }).ok).toBe(false);
    expect(validateAnswers(q, { MX: { 'Zeile 1': 'regelhaft', 'Zeile 2': 'manchmal' } }).ok).toBe(true);
    expect(validateAnswers(q, { MX: { 'Zeile 1': 'regelhaft', 'Zeile 2': 'sehr oft' } }).ok).toBe(false);
  });

  it('enforces ranking bounds from responseContract', () => {
    const rank = item({
      id: 'R',
      type: 'rank_top3',
      required: true,
      responseContract: { kind: 'ranked_codes', minimumSelected: 1, maximumSelected: 3 },
      options: ['a', 'b', 'c', 'd'],
    });
    const q = questionnaire([rank]);
    expect(validateAnswers(q, { R: ['a', 'b', 'c', 'd'] }).ok).toBe(false);
    expect(validateAnswers(q, { R: ['a', 'a'] }).ok).toBe(false);
    expect(validateAnswers(q, { R: ['a', 'c'] }).ok).toBe(true);
  });

  it('limits free text by responseContract.maximumLength', () => {
    const text = item({
      id: 'T',
      type: 'textarea',
      responseContract: { kind: 'string', maximumLength: 5 },
      options: [],
    });
    const q = questionnaire([text]);
    expect(validateAnswers(q, { T: 'abcde' }).ok).toBe(true);
    expect(validateAnswers(q, { T: 'abcdef' }).ok).toBe(false);
  });

  it('never stores UI-only review controls', () => {
    const review = item({
      id: 'RV',
      type: 'review',
      required: true,
      responseContract: { kind: 'ui_control_not_research_response' },
      options: ['Absenden'],
    });
    const q = questionnaire([review]);
    expect(validateAnswers(q, {}).ok).toBe(true);
    expect(validateAnswers(q, { RV: 'Absenden' }).issues).toEqual([{ itemId: 'RV', code: 'not_storable' }]);
  });

  it('rejects options restricted by optionSource unless the parent selected them', () => {
    const parent = item({
      id: 'P',
      type: 'multi',
      responseContract: { kind: 'categorical_multi' },
      options: ['Termin', 'Labor'],
    });
    const child = item({
      id: 'C',
      type: 'multi',
      responseContract: { kind: 'categorical_multi' },
      options: ['Termin', 'Labor', 'keine'],
      optionSource: { item: 'P', intersection: ['Termin'] },
    });
    const q = questionnaire([parent, child]);
    expect(validateAnswers(q, { P: ['Labor'], C: ['Termin'] }).issues).toEqual([{ itemId: 'C', code: 'option_not_allowed' }]);
    expect(validateAnswers(q, { P: ['Termin'], C: ['Termin'] }).ok).toBe(true);
  });
});
