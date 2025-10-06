function* PasswordGenerator() {
  const charsets = [
    'abcdefghijklmnopqrstuvwxyz',
    'ABCDEFGHIJKLMNOPQRSTUVWXYZ',
    '0123456789',
    '!@.$%^&*-_'
  ]

  while (true) {
    let pw = ''
    for (let set of charsets) {
      pw += set.charAt(flatRandom(set.length))
      pw += set.charAt(flatRandom(set.length))
    }
    const cs = charsets.join('')
    for (let i = 0; i < flatRandom(5) + 4; i++) {
      pw += cs.charAt(flatRandom(cs.length))
    }
    yield Array.from(pw)
      .sort(c => 0.5 - Math.random())
      .join('')
  }
}
const generator = PasswordGenerator()

const flatRandom = max => Math.floor(Math.random() * max)

export default generator
