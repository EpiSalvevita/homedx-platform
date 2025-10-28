export type TestProps = {
  nextSlide?: () => void
  prevSlide?: () => void
  onReachedEnd?: () => void
  currentIndex?: number
  setState?: (data: TestProps) => void | undefined
}

export interface TestSlideProps {
  onNext: () => void
}
