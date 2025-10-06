import React from 'react'
import LinkButton from 'components/LinkButton'

import MyResultIcon from 'assets/icons/ic_my-result.svg'
import NewIcon from 'assets/icons/ic_new.svg'
import ProfileIcon from 'assets/icons/ic_profile.svg'
import { useSelector } from 'react-redux'

export default function BottomBar({ show, pathname }) {
  const isTested = useSelector(
    ({ test }) =>
      test.lastRapidtest && Object.keys(test.lastRapidtest).length > 0
  )
  const profilePhoto = useSelector(({ auth }) => auth.profilePhoto)

  return (
    <div
      className={`bottombar ${show ? 'show' : ''} ${isTested ? '' : 'empty'}`}>
      <div className="row">
        <div className={`${pathname === '/my-result' ? 'active' : ''}`}>
          <LinkButton to="my-result">
            <MyResultIcon />
          </LinkButton>
        </div>
        <div className={`btn--highlight`}>
          <LinkButton to={'new-test'}>
            <NewIcon />
          </LinkButton>
        </div>
        <div className={`${pathname === '/profile' ? 'active' : ''}`}>
          <LinkButton to="profile">
            {!profilePhoto && <ProfileIcon />}
            {profilePhoto && (
              <div className="bottombar__profilephoto__wrapper">
                <img
                  className="bottombar__profilephoto"
                  src={profilePhoto}
                  alt="profilephoto"
                />
              </div>
            )}
          </LinkButton>
        </div>
      </div>
    </div>
  )
}
