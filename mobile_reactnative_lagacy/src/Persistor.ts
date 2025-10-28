import {
  Set_Encrypted_AsyncStorage,
  Get_Encrypted_AsyncStorage
} from 'react-native-encrypted-asyncstorage'
import Config from 'react-native-config'
import AsyncStorage from '@react-native-async-storage/async-storage'

const saveToken: (token: string) => void = async token => {
  try {
    await Set_Encrypted_AsyncStorage(
      'text',
      '@token',
      token,
      Config.ENCRYPT_KEY
    )
    return true
  } catch (e) {
    console.error(e)
    return false
  }
}

const getToken: () => Promise<string> = async () => {
  try {
    const token: string = await Get_Encrypted_AsyncStorage(
      'text',
      '@token',
      Config.ENCRYPT_KEY
    )
    return token
  } catch (e) {
    console.log(e)
    return ''
  }
}

const clearToken: () => Promise<boolean> = async () => {
  try {
    await AsyncStorage.removeItem('@token')
    return true
  } catch (e) {
    console.log(e)
    return false
  }
}

type PersistorProps = {
  getToken: () => Promise<string>
  clearToken: () => Promise<boolean>
  saveToken: (token: string) => void
}

const Persistor: PersistorProps = { getToken, clearToken, saveToken }
export default Persistor
