declare module '*.svg' {
  import React from 'react'
  import { SvgProps } from 'react-native-svg'
  const content: React.FC<SvgProps>
  export default content
}

// missing declarations
declare module 'react-native-mov-to-mp4'
declare module 'react-native-video'
