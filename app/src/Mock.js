class Mock {
  constructor() {
    this.results = {}
    this.delay = 0
  }

  result(key, data) {
    this.results[key] = data
    return this
  }

  mock(expectedResult) {
    return new Promise((resolve, reject) => {
      const send = rolledResult => {
        if (!this.results[rolledResult].fail) {
          resolve(this.results[rolledResult])
        } else {
          reject(this.results[rolledResult])
        }
      }

      if (expectedResult) {
        setTimeout(() => {
          send(expectedResult)
        }, this.delay)
        return
      }

      const roll = Math.floor(
        Math.random() * Object.entries(this.results).length || 0
      )
      console.log(this.delay)
      setTimeout(() => {
        send(Object.keys(this.results)[roll])
      }, this.delay)
    })
  }
}

export default Mock
