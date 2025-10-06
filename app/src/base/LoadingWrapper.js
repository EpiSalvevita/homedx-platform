import React, { useState, useEffect } from 'react'
import { useSelector } from 'react-redux'
import ResultLoader from './ResultLoader'

import Background2 from 'assets/images/background.b64.svg'
import Background from 'assets/images/background-2.b64.svg'

export default function LoadingWrapper({ children }) {
  const { isLoading, pathname } = useSelector(({ base }) => base)
  const [bg, setBG] = useState({})

  useEffect(() => {
    if (!pathname) return
    if (
      isLoading ||
      pathname === '/my-result' ||
      pathname === '/profile' ||
      pathname === '/my-account' ||
      pathname === '/change-account-data'
    )
      setBG({ backgroundImage: `url(${Background})` })
    else if (pathname === '/login' || pathname === '/signup')
      setBG({ backgroundImage: `url(${Background2})` })
    else setBG({})

    return () => {}
  }, [pathname, isLoading])

  return (
    <>
      <div
        className={`loader ${(isLoading && 'show') || ''}`}
        style={{ backgroundImage: `url(${Background})` }}>
        <ResultLoader />
      </div>
      <div className={`content ${(!isLoading && 'show') || ''}`} style={bg}>
        {children}
      </div>
    </>
  )
}
