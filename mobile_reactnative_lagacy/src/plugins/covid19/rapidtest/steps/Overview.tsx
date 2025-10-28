import React from 'react'

import { Box, Button, Heading, Text, View } from 'native-base'
import ListView from '../../../../widgets/ListView'
import { Trans, useTranslation } from 'react-i18next'
import { TestSlideProps } from '../../../../models/TestProps'

export default function Overview({ onNext }: TestSlideProps) {
  const { t } = useTranslation('covid19')

  return (
    <Box flex="1" justifyContent={'flex-end'}>
      <Heading>
        <Trans i18nKey="overview_title">So geht's</Trans>
      </Heading>
      <Text py="4">
        <Trans i18nKey="overview_text">
          Für eine erfolgreiche Online-Zertifizierung werden Sie nun die
          folgenden Schritte durchführen. Dieser Prozess dauert etwa 20 Minuten.
        </Trans>
      </Text>
      <Heading>
        <Trans i18nKey="overview_title">Schnelltest</Trans>
      </Heading>

      <View my="4">
        <ListView
          data={[
            t('rapidTest_overview_step_1'),
            t('rapidTest_overview_step_2'),
            t('rapidTest_overview_step_3'),
            t('rapidTest_overview_step_4')
          ]}></ListView>
      </View>

      <Button onPress={onNext}>{t('rapidTest_overview_btn_next')}</Button>
    </Box>
  )
}
