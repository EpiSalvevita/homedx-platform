import React from 'react'
import TopBar from './TopBar'
import ResultLoader from 'base/ResultLoader'

export default function ContentPage({ src }) {
  return (
    <>
      <TopBar show={true} showBack showAccount={false} />
      <iframe width="100%" height="100%" title="iframe__content" src={src} />
      <ResultLoader title="Die Seite wird geladen..." />
    </>
  )
}
