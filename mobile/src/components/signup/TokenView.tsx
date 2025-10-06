import React, { useContext } from 'react'
import { Button, Checkbox, Heading, Input, Link, Text, View } from 'native-base'
import { Trans, useTranslation } from 'react-i18next'
import { HdxContext } from '../../contexts/HdxContext'

export default function TokenView({
  showTokenTip,
  registrationToken,
  setRegistrationToken,
  showToken,
  setShowToken,
  isLoading,
  setAcceptedLegal,
  acceptedLegal,
  setAcceptedTerms,
  acceptedTerms,
  onNext
}) {
  const { t } = useTranslation()

  const { backendStatus } = useContext(HdxContext)

  return (
    <View>
      <Heading>
        <Trans i18nKey="signup__token__title1">Token & Zustimmung</Trans>
      </Heading>
      <Text>
        <Trans i18nKey="signup__token__text1">
          Sie nutzen einen Token? Dann können Sie Ihn hier angeben. Andernfalls
          benötigen wir nur Ihre Zustimmung zu unseren Datenschutzhinweisen und
          den AGB.
        </Trans>
      </Text>
      <View>
        {backendStatus.paymentIsActive && (
          <Checkbox onChange={val => setShowToken(val)} value={showToken}>
            <Text>
              <Trans i18nKey="'signup__token__checkbox'">
                Ohne Token ist der Kauf von Lizenzen notwendig.
              </Trans>
            </Text>
          </Checkbox>
        )}
      </View>
      {((showToken || !backendStatus.paymentIsActive) && (
        <Input
          type="text"
          placeholder={t('signup__placeholder__token')}
          value={registrationToken}
          onChange={val => setRegistrationToken(val)}
        />
      )) || (
        <View>
          {!backendStatus.stripe && (
            <Text>
              <Trans i18nKey="signup_token_hint_coupon">
                Wenn Sie einen Coupon (QR-Code) haben, können Sie ohne Token mit
                der Registrierung fortfahren
              </Trans>
            </Text>
          )}
          {backendStatus.stripe && (
            <Text>
              <Trans i18nKey="signup_token_hint_payment">
                Ohne Token ist der Kauf von Lizenzen notwendig.
              </Trans>
            </Text>
          )}
        </View>
      )}
      <View>
        <Checkbox onChange={val => !isLoading && setAcceptedLegal(val)}>
          <Text>
            <Trans i18nKey="signup_check_privacy">
              Ich bin damit einverstanden, dass die homeDX GmbH meine
              personenbezogenen Daten, insbesondere die Daten über meine
              Gesundheit, wie in den Datenschutzhinweisen beschrieben,
              verarbeitet. Diese Einwilligung kann ich jederzeit für die Zukunft
              widerrufen *
            </Trans>
          </Text>
        </Checkbox>

        <Checkbox onChange={val => !isLoading && setAcceptedTerms(val)}>
          <Text>
            <Trans i18nKey="signup_check_tos">
              Ich habe die AGB gelesen und akzeptiert *
            </Trans>
          </Text>
        </Checkbox>
      </View>

      <Button
        isDisabled={
          isLoading ||
          !acceptedTerms ||
          !acceptedLegal ||
          (showToken && registrationToken.length < 3)
        }
        onPress={onNext}>
        <Text>
          {(!isLoading && <Trans i18nKey="next">Weiter</Trans>) || (
            <Trans i18nKey="loading">Lädt...</Trans>
          )}
        </Text>
      </Button>
    </View>
  )
}

// import InfoIcon from 'assets/icons/ic_info.svg'
// import { useSelector } from 'react-redux'
// import Checkbox from 'components/Checkbox'
// import TextInput from 'components/TextInput'
// import Button from 'components/Button'
// import { useLocation } from 'react-router'

// export default function TokenView({
// showTokenTip,
// registrationToken,
// setRegistrationToken,
// showToken,
// setShowToken,
// isLoading,
// setAcceptedLegal,
// acceptedLegal,
// setAcceptedTerms,
// acceptedTerms,
// onNext
// }) {
//   const { t } = useTranslation()
//   const { backendStatus } = useSelector(({ base }) => base)
//   const code = useLocation()

//   useEffect(() => {
//     setTimeout(() => {
//       // wont update properly without the timeout
//       if (code?.hash) {
//         setShowToken(true)
//         setRegistrationToken(code?.hash.replace('#', ''))
//       }
//     }, 0)
//   }, [code?.hash, setRegistrationToken, setShowToken])

//   return (
//    <View style={{ flex: 1, justifyContent: 'flex-end' }}>
//       <h1>
//         <Trans i18nKey="signup__token__title1">Token & Zustimmung</Trans>
//       </h1>
// <p>
//   <Trans i18nKey="signup__token__text1">
//     Sie nutzen einen Token? Dann können Sie Ihn hier angeben. Andernfalls
//     benötigen wir nur Ihre Zustimmung zu unseren Datenschutzhinweisen und
//     den AGB.
//   </Trans>
// </p>
//      <View className="row">
//        <View className="col-12">
//<View className="row">
//   {backendStatus.paymentIsActive && (
//    <View className="col-12">
//       <Checkbox
//         label={t('signup__token__checkbox')}
//         onChange={e => setShowToken(e.target.checked)}
//         value={showToken}
//       />
//    </View>
//   )}
//</View>
//          <View className="row">
//            <View className="col-10">
// {((showToken || !backendStatus.paymentIsActive) && (
//   <TextInput
//     showAsRequired={!backendStatus.paymentIsActive}
//     required={!backendStatus.paymentIsActive}
//     className="alt"
//     type="text"
//     placeholder={t('signup__placeholder__token')}
//     value={registrationToken}
//     onChange={val => setRegistrationToken(val)}
//   />
// )) || (
//   <small style={{ marginLeft: 41, opacity: 0.6 }}>
//     {!backendStatus.stripe && (
//       <Trans i18nKey="signup__token__hint_coupon">
//         Wenn Sie einen Coupon (QR-Code) haben, können Sie ohne
//         Token mit der Registrierung fortfahren
//       </Trans>
//     )}
//     {backendStatus.stripe && (
//       <Trans i18nKey="signup__token__hint_payment">
//         Ohne Token ist der Kauf von Lizenzen notwendig.
//       </Trans>
//     )}
//   </small>
// )}
//            </View>
//             {(showToken || !backendStatus.paymentIsActive) && (
//              <View className="col-2 password__show" onClick={showTokenTip}>
//                 <InfoIcon />
//              </View>
//             )}
//          </View>
//        </View>
//      </View>
//<View className="row">
//  <View className="col-12">
//     <Checkbox
//       id="legal"
//       required
//       onChange={ev => !isLoading && setAcceptedLegal(ev.target.checked)}
//       label={
//        <View style={{ display: 'inline' }}>
//           <Trans i18nKey="signup__check_privacy">
//             Ich bin damit einverstanden, dass die homeDX GmbH meine
//             personenbezogenen Daten, insbesondere die Daten über meine
//             Gesundheit, wie in den
//             <a
//               href={`${process.env.WP_BASE_URL}/datenschutz-app`}
//               target={'_blank'}
//               rel="noreferrer">
//               Datenschutzhinweisen
//             </a>
//             beschrieben, verarbeitet. <br /> Diese Einwilligung kann ich
//             jederzeit für die Zukunft widerrufen *
//           </Trans>
//        </View>
//       }
//     />
//  </View>
//  <View className="col-12">
//     <Checkbox
//       id="terms"
//       required
//       onChange={ev => !isLoading && setAcceptedTerms(ev.target.checked)}
//       label={
//         <Trans i18nKey="signup__check_legal">
//           Ich habe die
//           <a
//             href={`${process.env.WP_BASE_URL}/agbs`}
//             target={'_blank'}
//             rel="noreferrer">
//             AGB
//           </a>
//           gelesen und akzeptiert *
//         </Trans>
//       }
//     />
//  </View>
//</View>
//      <View className="row">
//        <View className="col-12">
// <Button
//   disabled={
//     isLoading ||
//     !acceptedTerms ||
//     !acceptedLegal ||
//     (showToken && registrationToken.length < 3)
//   }
//   onClick={onNext}>
//   {(!isLoading && <Trans i18nKey="next">Weiter</Trans>) || (
//     <Trans i18nKey="loading">Lädt...</Trans>
//   )}
// </Button>
//        </View>
//      </View>
//    </View>
//   )
// }
