import React, { useRef, useEffect, useState } from 'react'
import Button from 'components/Button'

export default function DateAnswer({ next, prefill }) {
  let inputRef = useRef(null)
  const [value, setValue] = useState(Date.now())

  useEffect(() => {
    setValue(prefill || Date.now())
  }, [prefill])

  return (
    <div className="action">
      <input
        type="date"
        ref={inputRef}
        className="action__input--text"
        value={value}
        onChange={e => setValue(e.target.value)}
      />
      <Button
        onClick={() => inputRef.current.value && next(inputRef.current.value)}
        className="light">
        {'>'}
      </Button>
    </div>
  )
}
