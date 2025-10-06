import React, { useEffect, useState } from 'react'

export default function PaymentMethodSwitcher({
  className,
  methods,
  onSwitched
}) {
  const [method, setMethod] = useState(null)

  useEffect(() => {
    !method && methods[0] && setMethod(methods[0].value)
    onSwitched && onSwitched(method)
    return () => {}
  }, [methods, method, onSwitched])

  return (
    <div className={`pmswitcher ${className}`}>
      {methods.map(({ label, value }) => (
        <div
          className={`pmswitcher__item ${value === method ? 'active' : ''}`}
          onClick={() => setMethod(value)}>
          {label}
        </div>
      ))}
    </div>
  )
}
