import React, { useRef } from 'react'
import Button from 'components/Button'

export default function BooleanAnswer({ next }) {
  return (
    <div className="row">
      <div className="col-6">
        <Button onClick={() => next(true)}>JA</Button>
      </div>
      <div className="col-6">
        <Button onClick={() => next(false)}>NEIN</Button>
      </div>
    </div>
  )
}
