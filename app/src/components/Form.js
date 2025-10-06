import React from 'react'

export default function Form(props) {
  return (
    <form
      className={props.className}
      {...props}
      onSubmit={e => {
        e.preventDefault()
        props.onSubmit && props.onSubmit()
      }}>
      {props.children}
    </form>
  )
}
