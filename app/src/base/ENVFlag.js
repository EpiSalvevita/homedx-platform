import React, { useEffect, useCallback } from 'react'
import { useDispatch, useSelector } from 'react-redux'
import { useQuery } from '@apollo/client'
import { GET_USER_DATA } from 'services/graphql'
import { getBackendStatus } from '../services/system.service'

export default function ENVFlag() {
  const { testaccount } = useSelector(({ base }) => base?.userdata)
  const dispatch = useDispatch()

  const { data: userData, refetch: refetchUser } = useQuery(GET_USER_DATA, {
    skip: true // Skip initial auto-fetch
  })

  const fetchBackendStatus = useCallback(async () => {
    try {
      const status = await getBackendStatus()
      dispatch({ type: 'setBackendStatus', backendStatus: status })
    } catch (error) {
      console.error('Error fetching backend status:', error)
    }
  }, [dispatch])

  // Auto-fetch backend status when component mounts
  useEffect(() => {
    fetchBackendStatus()
  }, [fetchBackendStatus])

  const fetchUserData = useCallback(async () => {
    try {
      const { data } = await refetchUser()
      if (data?.me) {
        dispatch({ type: 'setUserdata', userdata: data.me })
      }
    } catch (error) {
      console.error('Error fetching user data:', error)
    }
  }, [dispatch, refetchUser])

  return (
    process.env.ENV !== 'prod' && (
      <div
        onClick={() => {
          fetchBackendStatus()
          fetchUserData()
        }}
        style={{
          zIndex: 9999,
          position: 'fixed',
          top: 4,
          left: '50%',
          transform: 'translateX(-50%)',
          padding: 12,
          backgroundColor: '#800343',
          textTransform: 'uppercase',
          borderRadius: 8,
          textAlign: 'center'
        }}>
        <div>
          <small>{process.env.ENV}</small>
        </div>

        <div>
          <small> {testaccount ? 'test account' : 'real account'}</small>
        </div>
      </div>
    )
  )
}
