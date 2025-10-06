import React, { useCallback, useState } from 'react'
import CollapsedIcon from 'assets/icons/ic_accordion_collapsed.svg'
import OpenIcon from 'assets/icons/ic_accordion_open.svg'

export default function Accordion({ icons, title, content }) {
  const [isCollapsed, setIsCollapsed] = useState(true)

  const toggle = useCallback(() => {
    setIsCollapsed(!isCollapsed)
  }, [isCollapsed])

  return (
    <div className={`accordion ${isCollapsed ? 'collapsed' : ''}`}>
      <div className="accordion__header" onClick={toggle}>
        {title && <h3 style={{ flex: 1 }}>{title}</h3>}
        {icons && (
          <div className="accordion__icons">
            {icons.map(Icon => (
              <div className="accordion__icon">{Icon}</div>
            ))}
          </div>
        )}
        {isCollapsed ? <CollapsedIcon /> : <OpenIcon />}
      </div>
      <div className="accordion__collapsable">
        {content && <div className="accordion__content">{content}</div>}
      </div>
    </div>
  )
}
