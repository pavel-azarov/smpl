export interface ErrorResponse {
  errors: Error[]
}

export interface Error {
  title: string
  detail: string
  status: string
}

export interface ResponseMetaPage {
  limit: number
  offset: number
  current: number
  total: number
}
