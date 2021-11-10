import axios, {AxiosResponse} from 'axios'
import {COMPONENT_TESTS_WIREMOCK_URL} from '../config'

const createWiremockStub = (url: string, method: string, status: number) => ({
  request: {
    url,
    method,
  },
  response: {
    status,
  },
})

const createWiremockStubWithBody = (url: string, method: string, status: number, body: object) => ({
  ...createWiremockStub(url, method, status),
  response: {
    status,
    body: JSON.stringify(body),
    headers: {
      'Content-Type': 'application/json',
    },
  },
})

const createWiremockStubByPattern = (url: string, method: string, status: number) => ({
  request: {
    urlPattern: url,
    method,
  },
  response: {
    status,
  },
})

const createWiremockStubWithBodyByPattern = (
  url: string,
  method: string,
  status: number,
  body: object,
) => ({
  ...createWiremockStubByPattern(url, method, status),
  response: {
    status,
    body: JSON.stringify(body),
    headers: {
      'Content-Type': 'application/json',
    },
  },
})

export const mockApiCall = async (
  path: string,
  method: string,
  status: number,
  response?: object,
): Promise<AxiosResponse> => {
  const stub = response
    ? createWiremockStubWithBody(path, method, status, response)
    : createWiremockStub(path, method, status)
  return axios.post(`${COMPONENT_TESTS_WIREMOCK_URL}/__admin/mappings/new`, stub)
}

export const mockApiCallByPattern = async (
  path: string,
  method: string,
  status: number,
  response?: object,
): Promise<AxiosResponse> => {
  const stub = response
    ? createWiremockStubWithBodyByPattern(path, method, status, response)
    : createWiremockStubByPattern(path, method, status)
  return axios.post(`${COMPONENT_TESTS_WIREMOCK_URL}/__admin/mappings/new`, stub)
}

export const resetMocks = async (): Promise<void> => {
  await axios.post(`${COMPONENT_TESTS_WIREMOCK_URL}/__admin/mappings/reset`)
}

export const mockApiCallCount = async (path: string, method: string): Promise<AxiosResponse> => {
  return axios.post(
    `${COMPONENT_TESTS_WIREMOCK_URL}/__admin/requests/count`,
    JSON.stringify({method: method, url: path}),
  )
}
