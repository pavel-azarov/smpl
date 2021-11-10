import axios, {AxiosInstance, AxiosRequestConfig, AxiosResponse, AxiosStatic} from 'axios'

interface RequestResponsePair {
  request: AxiosRequestConfig
  response: AxiosResponse
}

// Request logging class that keeps track of requests and responses
// It also uses the World object to attach the request and response to output
export class RequestLogger {
  private logRequests: RequestResponsePair[]

  private lastRequest: AxiosRequestConfig | null

  private world: any

  constructor() {
    this.addInterceptors(axios)
  }

  public addInterceptors(axios: AxiosStatic | AxiosInstance): any {
    axios.interceptors.request.use((x) => {
      this.lastRequest = x
      return x
    })

    const processResponse = (x: AxiosResponse): any => {
      this.logRequests.push({
        request: this.lastRequest,
        response: x,
      })

      this.lastRequest = null
      this.attachLastRequest()
      return x
    }

    axios.interceptors.response.use(processResponse, (error): any => {
      return processResponse(error.response)
    })
  }

  private getRequestResponsePairAsString(item: RequestResponsePair): string {
    let logStatements = ''
    const request = item.request
    const response = item.response
    const requestLogLines = RequestLogger.getRequestLogLines(request)
    const responseLogLines = RequestLogger.getResponseLogLines(response)

    logStatements +=
      '**** Approximate HTTP Request & Response w/ Some Post Processing ****\n> ' +
      requestLogLines.join('\n> ') +
      '\n\n' +
      '< ' +
      responseLogLines.join('\n< ') +
      '\n'
    return logStatements
  }

  private static getResponseLogLines(response: AxiosResponse<any>): string[] {
    let responseLogLines: string[] = []
    responseLogLines.push('HTTP ?.? ' + response.status + ' ' + response.statusText + '')

    responseLogLines = responseLogLines.concat(RequestLogger.logHeaders(response.headers))

    const responseJsonData = JSON.stringify(response.data, null, 2)

    if (responseJsonData != null && responseJsonData.length > 0) {
      responseLogLines.push('')
      responseLogLines.push(responseJsonData)
    }
    return responseLogLines
  }

  private static getRequestLogLines(request: AxiosRequestConfig): string[] {
    if (!request) {
      return ['']
    }
    let requestLogLines: string[] = []
    if (request.url.startsWith('http')) {
      requestLogLines.push(request.method.toUpperCase() + ' ' + request.url)
    } else {
      requestLogLines.push(request.method.toUpperCase() + ' ' + request.baseURL + request.url)
    }

    requestLogLines = requestLogLines.concat(RequestLogger.logHeaders(request.headers))
    requestLogLines = requestLogLines.concat(
      RequestLogger.logHeaders(request.headers[request.method]),
    )

    requestLogLines.push('')

    if (request.data != null) {
      if (request.headers['Content-Type'] == 'application/json') {
        requestLogLines.push(JSON.stringify(JSON.parse(request.data), null, 2))
      } else {
        requestLogLines.push(request.data)
      }
    }
    return requestLogLines
  }

  private static logHeaders(obj: any): string[] {
    const log: string[] = []
    if (obj != null) {
      for (const property in obj) {
        const val = obj[property]
        if (typeof val == 'string') {
          log.push(property + ': ' + val)
        }
      }
    }
    return log
  }

  public clearRequests(): void {
    this.logRequests = []
  }

  public getRequests(): RequestResponsePair[] {
    return this.logRequests
  }

  public setWorld(world): void {
    this.world = world
    this.logRequests = []
  }

  public attachLastRequest(): void {
    this.world.attach(
      Buffer.from(
        this.getRequestResponsePairAsString(this.logRequests[this.logRequests.length - 1]),
      ).toString('base64'),
    )
  }
}

export const requestLogger = new RequestLogger()
