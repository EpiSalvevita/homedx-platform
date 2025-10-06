import ContentPage from 'components/ContentPage'
import React from 'react'
import { useParams } from 'react-router'

export default function Content() {
  const { content } = useParams()

  switch (content) {
    case 'support':
    case 'contact':
      return <ContentPage src={`${BASE}/kontakt`} />
    case 'help':
    case 'faq':
      return <ContentPage src={`${BASE}/faq`} />
    case 'imprint':
      return <ContentPage src={`${BASE}/impressum`} />
    case 'terms':
      return <ContentPage src={`${BASE}/agbs`} />
    case 'privacy':
    default:
      return <ContentPage src={`${BASE}/datenschutz-app`} />
  }
}
