import Config from 'react-native-config'

type HdxHeaders = {
  Accept?: string
  Authorization: string
  'Content-Type'?: string
  'X-AUTH-TOKEN'?: string
}

const post = async (
  path: string,
  params?: Object | null,
  token?: string | null | undefined
) => {
  const headers: HdxHeaders = {
    Accept: 'application/json',
    'Content-Type': 'application/json;charset=utf-8',
    Authorization: `Bearer ${token || ''}`
  }

  // Using Bearer token in Authorization header

  let body = {
    lang: 'de'
  }
  console.log({ params, body })
  if (params) {
    body = { ...body, ...params }
  }

  let res: Response = new Response()
  try {
    res = await fetch(
      `${Config.HOMEDX_API_URL}/gg-homedx-json/gg-api/v1${path}`,
      {
        method: 'POST',
        body: JSON.stringify(body),
        headers
      }
    )
    return res
  } catch (e: any) {
    console.error(e)
  } finally {
    return res
  }
}

const postFormData = async (
  path: string,
  formData?: FormData,
  token?: string | null | undefined
) => {
  const headers: HdxHeaders = {
    Accept: 'application/json',
    Authorization: `Bearer ${token || ''}`
  }

  // Using Bearer token in Authorization header

  let res: Response = new Response()

  try {
    res = await fetch(
      `${Config.HOMEDX_API_URL}/gg-homedx-json/gg-api/v1${path}`,
      {
        method: 'POST',
        body: formData,
        headers
      }
    )
    return res
  } catch (e: any) {
    console.error(e)
  } finally {
    return res
  }
}

const Network = { post, postFormData }
export default Network
