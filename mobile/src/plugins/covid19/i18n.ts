import rapidTest from './rapidtest/lang'
import pcrTest from './pcrtest/lang'
import antibodyTest from './antibodytest/lang'

const covid19 = {
  de: {
    rapidTest: rapidTest.de,
    pcrTest: pcrTest.de,
    antibodyTest: antibodyTest.de
  },
  en: {
    rapidTest: rapidTest.en,
    pcrTest: pcrTest.en,
    antibodyTest: antibodyTest.en
  },
  fr: {
    rapidTest: rapidTest.fr,
    pcrTest: pcrTest.fr,
    antibodyTest: antibodyTest.fr
  }
}
export default covid19
