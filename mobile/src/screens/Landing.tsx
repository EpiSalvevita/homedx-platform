import React, { useEffect } from 'react'
import { NativeStackScreenProps } from '@react-navigation/native-stack'
import { Box, Button, Heading, Image, View, VStack, ZStack } from 'native-base'
import { ScreenProps } from '../models/ScreenProps'
import { Trans, useTranslation } from 'react-i18next'
import Logo from '../assets/images/logo.svg'
import SplashScreen from 'react-native-splash-screen'
import ListView from '../widgets/ListView'
const bg = require('../assets/images/bg_landing.png')

export default function Landing({
  navigation
}: NativeStackScreenProps<ScreenProps, 'Landing'>) {
  const { t } = useTranslation()

  useEffect(() => {
    SplashScreen.hide()
  }, [])

  return (
    <ZStack
      alignItems="flex-start"
      justifyContent="flex-start"
      style={{ flex: 1 }}>
      <Image
        source={bg}
        resizeMode="cover"
        style={{
          width: 100 + '%',
          aspectRatio: 1,
          position: 'absolute',
          top: 0
        }}
      />

      <VStack
        px="4"
        w={100 + '%'}
        h={100 + '%'}
        justifyContent="flex-end"
        space="4">
        <Logo />
        <Heading>
          <Trans i18nKey="landing_title"></Trans>
        </Heading>
        <View>
          <ListView
            data={[
              t('landing_listitems_1'),
              t('landing_listitems_2'),
              t('landing_listitems_3'),
              t('landing_listitems_4')
            ]}
          />
        </View>
        <VStack space="2">
          <Button
            variant={'outline'}
            onPress={() => navigation.navigate('Login')}>
            {t('landing_btn_login')}
          </Button>
          <Button onPress={() => navigation.navigate('Signup')}>
            {t('landing_btn_signup')}
          </Button>
        </VStack>
      </VStack>
    </ZStack>
  )
}
