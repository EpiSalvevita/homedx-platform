import { useEffect, useState } from 'react'
import {
  BleError,
  BleManager,
  Device,
  Subscription
} from 'react-native-ble-plx'

import Config from 'react-native-config'

const SCAN_TIME: number = 5000

export default function useBluetooth() {
  const [subscription, setSubscription] = useState<Subscription>()
  const [manager, setManager] = useState<BleManager>(() => new BleManager())
  const [devices, setDevices] = useState<Device[]>([])
  const [isScanning, setIsScanning] = useState<boolean>(false)

  useEffect(() => {
    Config.DEBUG === 'true' && console.log('bluetooth: init')

    const sub = manager?.onStateChange(state => {
      if (state === 'PoweredOn') {
        Config.DEBUG === 'true' && console.log('bluetooth: powered on')
        startScan()
      }
    })
    setSubscription(sub)
    return () => {
      sub?.remove
    }
  }, [])

  const startScan = () => {
    const arr: Device[] = []
    setIsScanning(true)
    manager?.startDeviceScan(
      null,
      { allowDuplicates: false },
      (error: BleError | null, device: Device | null) => {
        if (error) {
          console.error(error.message)
        } else if (device) {
          const exists = arr.find(
            (d: Device) =>
              d.id === device.id ||
              d.name === device.name ||
              d.localName === device.localName
          )
          if (!exists) {
            arr.push(device)
          }
        }
      }
    )
    setTimeout(() => {
      manager?.stopDeviceScan()
      setDevices(arr)
      setIsScanning(false)
    }, SCAN_TIME)
  }

  return { manager, devices, isScanning }
}
