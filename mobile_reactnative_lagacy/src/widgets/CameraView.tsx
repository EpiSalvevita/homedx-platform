import { View, Text, StyleSheet } from 'react-native'
import React, { ReactNode } from 'react'
import { Camera, useCameraDevices } from 'react-native-vision-camera'

type CameraViewProps = {
  show?: boolean
  overlay?: ReactNode | ReactNode[]
  photo?: boolean
  video?: boolean
}

const CameraView = React.forwardRef(
  (props: CameraViewProps, ref: React.LegacyRef<Camera>) => {
    const devices = useCameraDevices('wide-angle-camera') || {}
    const device = devices.back

    const { show, overlay, photo, video } = props
    return (
      <>
        {(show === true && (
          <View
            style={{
              position: 'absolute',
              top: 0,
              left: 0,
              bottom: 0,
              right: 0
            }}>
            {(show === true && device && (
              <Camera
                video={video}
                photo={photo}
                ref={ref}
                isActive={true}
                audio={false}
                device={device}
                style={
                  (StyleSheet.absoluteFill,
                  { flex: 1, minWidth: 200, minHeight: 400 })
                }
              />
            )) || <Text>Loading...</Text>}
            <View style={StyleSheet.absoluteFill}>{overlay}</View>
          </View>
        )) || <></>}
      </>
    )
  }
)

export default CameraView
