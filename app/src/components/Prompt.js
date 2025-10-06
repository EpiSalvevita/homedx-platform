import React from 'react'

export default function Prompt({
  icon,
  iconPosition,
  style,
  title,
  subtitle,
  text,
  content,
  button,
  buttonSecondary,
  direction,
  smallIcon,
  shadow
}) {
  return (
    <div
      style={style}
      className={`prompt ${direction || 'center'} ${shadow ? 'shadow' : ''}`}>
      {icon && (
        <div className="row">
          <div className="col-12">
            <div
              className={`prompt__icon ${smallIcon ? 'small' : ''} ${
                iconPosition === 'right' ? 'right' : ''
              }`}>
              {icon}
            </div>
          </div>
        </div>
      )}
      {title && title.length > 0 && (
        <div className="row">
          <div className="col-12">
            <h1 className="prompt__title">{title}</h1>
          </div>
        </div>
      )}
      {subtitle && subtitle.length > 0 && (
        <div className="row">
          <div className="col-12">
            <h3 className="prompt__subtitle">{subtitle}</h3>
          </div>
        </div>
      )}
      {text && text.length > 0 && (
        <div className="row">
          <div className="col-12">
            <p
              className="prompt__text"
              dangerouslySetInnerHTML={{ __html: text }}></p>
          </div>
        </div>
      )}
      {content && (
        <div className="row">
          <div className="col-12">
            <div className="prompt__content">{content}</div>
          </div>
        </div>
      )}
      {button && (
        <div className="row">
          <div className="col-12">
            <div className="prompt__button">{button}</div>
          </div>
        </div>
      )}
      {buttonSecondary && (
        <div className="row">
          <div className="col-12">
            <div className="prompt__button--secondary">{buttonSecondary}</div>
          </div>
        </div>
      )}
    </div>
  )
}
