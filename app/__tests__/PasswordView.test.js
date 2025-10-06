import { isPasswordValid } from 'Utility'

// test password: aR%3pK7c

test('password is valid', () => {
  const isValid = isPasswordValid('aR%3pK7c')
  expect(isValid).toBe(true)
})

test('password too short', () => {
  const isValid = isPasswordValid('aR%3p')
  expect(isValid).toBe(false)
})

test('password uppercase letter missing', () => {
  const isValid = isPasswordValid('ar%3pk7c')
  expect(isValid).toBe(false)
})

test('password lowercase letter missing', () => {
  const isValid = isPasswordValid('AR%3PK7C')
  expect(isValid).toBe(false)
})

test('password number missing', () => {
  const isValid = isPasswordValid('aR%xpKXc')
  expect(isValid).toBe(false)
})

test('password special character missing', () => {
  const isValid = isPasswordValid('aR03pK7c')
  expect(isValid).toBe(false)
})

test('password special character not allowed: "("', () => {
  const isValid = isPasswordValid('aR(3pK7c')
  expect(isValid).toBe(false)
})

test('password has german letter ß', () => {
  const isValid = isPasswordValid('aR%3ßK7c')
  expect(isValid).toBe(false)
})

test('password has german letter ä', () => {
  const isValid = isPasswordValid('aR%3äK7c')
  expect(isValid).toBe(false)
})

test('password has german letter ö', () => {
  const isValid = isPasswordValid('aR%3öK7c')
  expect(isValid).toBe(false)
})

test('password has german letter ü', () => {
  const isValid = isPasswordValid('aR%3üK7c')
  expect(isValid).toBe(false)
})

test('password has french letter Á', () => {
  const isValid = isPasswordValid('aR%3K7Ác')
  expect(isValid).toBe(false)
})

test('password has arabic letter ـب', () => {
  const isValid = isPasswordValid('aR%3ـبK7c')
  expect(isValid).toBe(false)
})

test('password has japanese letter ア', () => {
  const isValid = isPasswordValid('aR%3K7アc')
  expect(isValid).toBe(false)
})

test('password has emoji 😶‍🌫️', () => {
  const isValid = isPasswordValid('aR%3K7😶‍🌫️c')
  expect(isValid).toBe(false)
})
