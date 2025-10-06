import React from 'react'
import AccountIcon from 'assets/icons/ic_account.svg'
import Logo from 'assets/icons/ic_logo.svg'
import Button from './Button'
import LinkButton from './LinkButton'

import BackIcon from 'assets/icons/ic_back.svg'
import { useHistory } from 'react-router'

export default function TopBar({ show, showBack, showAccount = true }) {
  const history = useHistory()

  const back = () => {
    history.goBack()
  }

  return (
    <div className={`topbar ${show ? 'show' : ''}`}>
      <div className="row">
        <div className="col-9">
          <div className="row" style={{ alignItems: 'center' }}>
            {showBack && (
              <Button className="btn--back" onClick={back}>
                <BackIcon />
              </Button>
            )}
            <div className="topbar__icon">
              <Logo />
            </div>
          </div>
        </div>
        {showAccount && (
          <div className="col-3">
            <div className="topbar__buttons">
              <LinkButton className="ghost" to="my-account">
                <AccountIcon />
              </LinkButton>
            </div>
          </div>
        )}
      </div>
    </div>
  )
}
