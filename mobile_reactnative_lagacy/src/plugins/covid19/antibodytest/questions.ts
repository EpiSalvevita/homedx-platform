import {
  QuestionnaireQuestion,
  QuestionnaireSelectItem,
  QuestionnaireCheckItem
} from '../../../widgets/Questionnaire'

const preExistingIllness_values: QuestionnaireCheckItem[] = [
  {
    label: 'Diabetes',
    value: 'diabetes'
  },
  {
    label: 'Herz-Kreislauf-Erkrankung',
    value: 'heart'
  },
  {
    label: 'Immunschwäche',
    value: 'immunity'
  },
  {
    label: 'Autoimmunerkrankung',
    value: 'autoimmunity'
  },
  { label: 'Weitere Erkrankungen', value: 'other' }
]

const vaccines: QuestionnaireCheckItem[] = [
  { label: 'BioNTech', value: 'biontech' },
  { label: 'Moderna', value: 'moderna' },
  { label: 'Johnson & Johnson', value: 'jj' },
  { label: 'AstraZeneca', value: 'astrazeneca' }
]

const symptoms: QuestionnaireCheckItem[] = [
  { value: 'none', label: 'Keine' },
  { value: 'mildcold', label: 'Milde Erkältungssymptome' },
  {
    value: 'badCold',
    label: 'Schwere Erkältungssymptome inkl. Gliederschmerzen'
  },
  {
    value: 'hospital',
    label: 'Ich wurde im Krankenhaus behandelt'
  },
  {
    value: 'artificialRespiration',
    label: 'Ich musste künstlich beatmet werden'
  }
]

export const data: { [key: string]: QuestionnaireQuestion } = {
  preExistingIllness: {
    key: 'preExistingIllness',
    label: 'Vorerkrankungen?',
    question: 'Haben Sie Vorerkrankungen?',
    type: 'boolean'
  },
  preExistingIllness_values: {
    key: 'preExistingIllness_values',
    label: 'Auswahl Vorerk.',
    question: 'Bitte wählen Sie zutreffende:',
    type: 'check',
    checkData: preExistingIllness_values,
    checkOptions: {
      mapped: true,
      showExtraTextField: true,
      extraTextFieldLabel: 'Weitere Erkrankungen'
    }
  },
  medication: {
    key: 'medication',
    label: 'Medikamente?',
    question:
      'Nehmen Sie derzeit oder haben Sie innerhalb des letzten Jahrs Medikamente eingenommen, die das Immunsystem schwächen (z.B. Cortison oder Biologika)?',
    type: 'boolean'
  },
  drugList: {
    key: 'drugList',
    label: 'Angabe Medik.',
    question: 'Wenn ja, welche?',
    type: 'text'
  },
  numberOfVaccinations: {
    key: 'numberOfVaccinations',
    label: 'Impfungen?',
    question: 'Wie viele Impfungen gegen COVID-19 haben Sie erhalten?',
    type: 'number'
  },
  lastVaccinationDate: {
    key: 'lastVaccinationDate',
    label: 'Letzte Impfung',
    question: 'Wann haben Sie Ihre letzte Impfung bekommen?',
    type: 'date'
  },
  vaccines: {
    key: 'vaccines',
    label: 'Impfstoffe',
    question:
      'Mit dem oder den Impfstoff(en) welcher Hersteller wurden Sie geimpft?',
    type: 'check',
    checkData: vaccines
  },
  testedPositive: {
    key: 'testedPositive',
    label: 'Positiv?',
    question:
      'Wurden Sie einmal oder mehrfach positiv auf SARS-CoV-2 getestet?',
    type: 'boolean'
  },
  testedPositiveDate: {
    key: 'testedPositiveDate',
    label: 'Letzte Erkrankung',
    question: 'Wann war die letzte Erkrankung?',
    type: 'date'
  },
  symptoms: {
    key: 'symptoms',
    label: 'Symptome',
    question: 'Welche Symptome haben Sie entwickelt?',
    type: 'check',
    checkData: symptoms
  },
  telemedicineQuestions_heardOf: {
    key: 'telemedicineQuestions_heardOf',
    label: '1. Tel.Med.',
    question:
      'Haben Sie schon einmal etwas über telemedizinische Diagnose und Behandlungsformen gehört?',
    type: 'boolean'
  },
  telemedicineQuestions_receivedConsultation: {
    key: 'telemedicineQuestions_receivedConsultation',
    label: '2. Tel.Med.',
    question: 'Haben Sie bereits eine telemedizinische Beratung erhalten?',
    type: 'boolean'
  },
  telemedicineQuestions_useInAdvance: {
    key: 'telemedicineQuestions_useInAdvance',
    label: '3. Tel.Med.',
    question:
      'Würden Sie ein solches Verfahren im Vorfeld eines Arztbesuches nutzen?',
    type: 'boolean'
  },
  telemedicineQuestions_examineAndTreat: {
    key: 'telemedicineQuestions_examineAndTreat',
    label: '4. Tel.Med.',
    question:
      'Würden Sie sich prinzipiell telemedizinisch untersuchen und behandeln lassen?',
    type: 'boolean'
  }
}
const startQuestions = {
  preExistingIllness: data.preExistingIllness,
  medication: data.medication,
  numberOfVaccinations: data.numberOfVaccinations,
  testedPositive: data.testedPositive,
  telemedicineQuestions_heardOf: data.telemedicineQuestions_heardOf,
  telemedicineQuestions_receivedConsultation:
    data.telemedicineQuestions_receivedConsultation,
  telemedicineQuestions_useInAdvance: data.telemedicineQuestions_useInAdvance,
  telemedicineQuestions_examineAndTreat:
    data.telemedicineQuestions_examineAndTreat
}

const questions = Object.values(startQuestions)
export default questions
