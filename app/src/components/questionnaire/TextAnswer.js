import React, { useRef, useState, useEffect } from 'react'
import Button from 'components/Button'

export default function TextAnswer({ next, prefill }) {
  let inputRef = useRef(null)
  const [value, setValue] = useState('')

  useEffect(() => {
    setValue(prefill || '')
  }, [prefill])

  return (
    <div className="action">
      <input
        ref={inputRef}
        className="action__input--text"
        value={value}
        onChange={e => setValue(e.target.value)}
      />
      <Button
        onClick={() =>
          inputRef.current.value.length >= 3 && next(inputRef.current.value)
        }
        className="light">
        {'>'}
      </Button>
    </div>
  )
}
