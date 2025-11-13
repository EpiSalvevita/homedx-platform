import React, { ProviderExoticComponent, ProviderProps } from 'react'
import { TestProps } from '../models/TestProps'

export default function TestView<T extends TestProps>({
  steps,
  provider: Provider,
  state
}: {
  steps: any[]
  state: T
  provider: ProviderExoticComponent<ProviderProps<T>>
}) {
  const nextSlide = () => {
    const index = (state.currentIndex || 0) + 1

    if (index >= steps.length) {
      state.onReachedEnd && state.onReachedEnd()
      return
    }

    state.setState && state.setState({ currentIndex: index })
  }
  const prevSlide = () => {}

  return (
    <Provider value={{ ...state, nextSlide, prevSlide }}>
      {steps.map(
        (Step, i) => state.currentIndex === i && <Step onNext={nextSlide} />
      )}
    </Provider>
  )
}
