import axios, {AxiosResponse} from 'axios'
import {assert} from 'chai'
import {logger} from './helpers'
import {SERVICE_HOST} from '../config'
import {requestLogger} from './logging'

export class Api {
  public response: AxiosResponse
  private _host = SERVICE_HOST
  public error: any
  public errorData: any

  private axiosInstance = axios.create({
    baseURL: this._host,
  })

  constructor() {
    requestLogger.addInterceptors(this.axiosInstance)
  }

  get = async (
    path: string,
    storeId?: string,
    header?: any,
    failOnError = true,
  ): Promise<AxiosResponse> => {
    const headers =
      storeId !== undefined ? Api.getHeaders(storeId, header) : Api.getHeadersNoStore(header)
    try {
      this.response = await this.axiosInstance.get(path, headers)
      this.logResponse()
    } catch (error) {
      this.logError(error, failOnError)
      this.response = error.response
    }
    return this.response
  }

  post = async (
    path: string,
    requestObject: object,
    storeId?: string,
    header?: object,
    failOnError = true,
  ): Promise<AxiosResponse> => {
    this.logRequest(path, requestObject)
    const headers =
      storeId !== undefined ? Api.getHeaders(storeId, header) : Api.getHeadersNoStore(header)
    try {
      this.response = await this.axiosInstance.post(path, requestObject, headers)
      this.logResponse()
    } catch (error) {
      this.logError(error, failOnError)
      this.response = error.response
    }
    return this.response
  }

  put = async (path: string, requestObject: object, storeId?: string): Promise<AxiosResponse> => {
    this.logRequest(path, requestObject)
    const headers = storeId !== undefined ? Api.getHeaders(storeId) : Api.getHeadersNoStore()
    try {
      this.response = await this.axiosInstance.put(path, requestObject, headers)
      this.logResponse()
    } catch (error) {
      this.logError(error)
      this.response = error.response
    }
    return this.response
  }

  delete = async (path: string, storeId?: string, failOnError = true): Promise<AxiosResponse> => {
    const headers = storeId !== undefined ? Api.getHeaders(storeId) : Api.getHeadersNoStore()
    try {
      this.response = await this.axiosInstance.delete(path, headers)
      this.logResponse()
    } catch (error) {
      this.logError(error, failOnError)
      this.response = error.response
    }
    return this.response
  }

  private static getHeaders(storeId: string, header?: object): object {
    const baseHeaders = {
      'Content-Type': 'application/json',
      'X-Moltin-Auth-Store': storeId,
    }
    return this.mergeHeaders(baseHeaders, header)
  }

  private static getHeadersNoStore(header?: object): object {
    const baseHeaders = {
      'Content-Type': 'application/json',
    }
    return this.mergeHeaders(baseHeaders, header)
  }

  private static mergeHeaders(baseHeaders: object, header?: object): object {
    let resultHeaders
    if (header !== undefined) {
      resultHeaders = {
        headers: {
          ...baseHeaders,
          ...header,
        },
      }
    } else {
      resultHeaders = {
        headers: {
          ...baseHeaders,
        },
      }
    }
    return resultHeaders
  }

  logResponse = (): void => {
    logger.info(this.response.config)
    logger.info('status code: ' + this.response.status)
    logger.info('status text: ' + this.response.statusText)
    logger.info(this.response.data)
  }

  logRequest = (request, config): void => {
    logger.info(request)
    logger.info(config)
  }

  logError = (error: any, failOnError = true): void => {
    this.error = error
    const errorObjStr = JSON.stringify(error)

    if ('error' in error) {
      this.errorData = error['response'].data
    } else {
      throw error
    }

    if (failOnError) {
      logger.error(errorObjStr)
      logger.error(this.errorData)
      assert.fail(JSON.stringify(this.errorData))
    } else {
      logger.info(errorObjStr)
      logger.info(this.errorData)
    }
  }
}

export const api = new Api()
