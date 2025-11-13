import general from './general'
import covid19 from '../plugins/covid19'
import auth from '../plugins/auth'
// import { i18n as authentication } from '../plugins/authentication'

const de = {
  general: general.de,
  covid19: covid19.i18n.de,
  auth: auth.i18n.de
}

const en = {
  general: general.en,
  covid19: covid19.i18n.en,
  auth: auth.i18n.en
}

const fr = {
  general: general.fr,
  covid19: covid19.i18n.fr,
  auth: auth.i18n.fr
}

const lang = { de, en, fr }
export default lang
