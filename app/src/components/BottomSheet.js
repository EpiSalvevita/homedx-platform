import React from 'react'
import Button from 'components/Button'
import { useHistory } from 'react-router'

import BackIcon from 'assets/icons/ic_back.svg'
import CloseButton from './CloseButton'

export default React.forwardRef(
  (
    {
      style,
      children,
      className,
      onClose,
      title,
      canGoBack,
      backType,
      peek,
      hideSpacer
    },
    ref
  ) => {
    const history = useHistory()
    const back = () => {
      console.log('Back button clicked, going back...')
      history.goBack()
    }

    const handleBackClick = (e) => {
      e.preventDefault()
      e.stopPropagation()
      console.log('Back click handler called, canGoBack:', canGoBack)
      if (canGoBack) {
        back()
      } else if (onClose) {
        onClose()
      }
    }

    return (
      <>
        <div
          style={style}
          ref={ref}
          className={`bottomsheet ${className || ''} ${peek ? 'peek' : ''}`}>
          {(canGoBack || onClose || title) && (
            <div
              className={`row bottomsheet__header ${
                backType === 'close' ? 'inverse' : ''
              }`}>
              {(canGoBack || onClose) && (
                <div className="col-2">
                  {backType !== 'close' && (
                    <Button className="btn--back" onClick={handleBackClick}>
                      <BackIcon />
                    </Button>
                  )}
                  {backType === 'close' && <CloseButton />}
                </div>
              )}
              {title && (
                <div className="col-10">
                  <h2 className="bottomsheet__title">{title}</h2>
                </div>
              )}
            </div>
          )}
          {children}
          {!peek && !hideSpacer && <div className="spacer"></div>}
        </div>
        <div className={`bottomsheet__frame ${className}`}></div>
      </>
    )
  }
)
