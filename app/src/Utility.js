export const EXPIRE_TIME = 24 * 60 * 60 * 1000

export const genID = () => {
  let id = ''
  for (let i = 0; i < 1; i++) {
    id += Math.random().toString(36).substr(2, 8)
  }
  return id
}

const blobToBase64 = blob => {
  const reader = new FileReader()
  reader.readAsDataURL(blob)
  return new Promise(resolve => {
    reader.onloadend = () => {
      resolve(reader.result)
    }
  })
}

export const toTimerString = (refDate, compareDate) => {
  const diff = Math.abs(compareDate / 1000 - refDate / 1000)

  const hrs = Math.floor((diff / (60 * 60)) % 24)
  const mins = Math.floor((diff / 60) % 60)

  return `${hrs.toString().padStart(2, '0')}:${mins
    .toString()
    .padStart(2, '0')}`
}

export const isExpired = date => {
  return Date.now() > new Date(date + EXPIRE_TIME)
}

export const secondsToTimerString = seconds => {
  const mins = Math.floor(seconds / 60)
  const secs = seconds % 60
  return `${mins.toString().padStart(2, '0')}:${secs
    .toString()
    .padStart(2, '0')}`
}

export const isPasswordValid = password => {
  let res = true
  ;(!password || password.length < 8) && (res = false)
  !password?.match(/^[a-zA-Z0-9!@.$%^&*-_]+$/) && (res = false)
  !password?.match(/([A-Z])/) && (res = false)
  !password?.match(/([a-z])/) && (res = false)
  !password?.match(/([0-9])/) && (res = false)
  !password?.match(/([!|@|.|$|%|^|&|*|-|_])/) && (res = false)
  return res
}

const Utility = {
  genID,
  blobToBase64,
  secondsToTimerString,
  toTimerString,
  EXPIRE_TIME,
  isPasswordValid
}

export default Utility
