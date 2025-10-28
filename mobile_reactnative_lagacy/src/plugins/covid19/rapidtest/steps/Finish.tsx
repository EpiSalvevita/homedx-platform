import { Box, Button, Modal, Spinner } from 'native-base'
import React, { useCallback, useContext, useEffect, useState } from 'react'

import useHomedx from '../../../../hooks/useHomedx'
import { TestSlideProps } from '../../../../models/TestProps'
import { RapidTestContext } from '../RapidTest'

export default function Finish({ onNext }: TestSlideProps) {
  const { testData } = useContext(RapidTestContext)
  const { submitTest } = useHomedx()
  const [isLoading, setIsLoading] = useState<boolean>(false)
  const [isShowSuccess, setIsShowSuccess] = useState<boolean>(false)
  const [isShowError, setIsShowError] = useState<boolean>(false)

  useEffect(() => {
    submit()
  }, [])

  const submit = useCallback(async () => {
    setIsLoading(true)
    if (!testData) {
      setIsLoading(false)
      setIsShowError(true)
      return
    }

    const res = await submitTest(testData)

    if (res.success) {
      setIsShowSuccess(true)
    } else {
      setIsShowError(true)
    }
  }, [testData])

  return (
    <>
      <Box flex="1" alignItems="center" justifyContent="center">
        {isLoading && <Spinner size="lg" />}
      </Box>
      <Modal isOpen={isShowSuccess}>
        <Modal.Content>
          <Modal.Header>Erfolg!</Modal.Header>
          <Modal.Body>Ihr Test wurde erfolgreich eingereicht!</Modal.Body>
          <Modal.Footer>
            <Button onPress={onNext}>Weiter</Button>
          </Modal.Footer>
        </Modal.Content>
      </Modal>
      <Modal isOpen={isShowError}>
        <Modal.Content>
          <Modal.Header>Fehlgeschlagen!</Modal.Header>
          <Modal.Body>
            Bitte versuchen Sie es erneut. Sollten Sie keinen Erfolg haben,
            brechen Sie den Test ab und melden dies bitte dem Support.
          </Modal.Body>
          <Modal.Footer>
            <Button.Group>
              <Button onPress={submit}>Erneut versuchen</Button>
              <Button onPress={onNext}>Abbrechen</Button>
            </Button.Group>
          </Modal.Footer>
        </Modal.Content>
      </Modal>
    </>
  )
}
