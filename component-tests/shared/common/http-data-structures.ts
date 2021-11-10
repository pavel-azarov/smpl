export interface SelfLink {
  self: string
}

export interface Error {
  status: string
  detail: string
  title: string
}

export interface PageLinks {
  current: string
  first: string
  last: string
  prev: string
  next: string
}

export interface IdTokenData {
  iss: string
  sub: string
  aud: string | string[]
  iat: number
  exp: number
  name: string
  email: string
}
