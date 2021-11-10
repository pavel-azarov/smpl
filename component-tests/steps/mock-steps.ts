/* eslint-disable @typescript-eslint/camelcase */
import {binding, then, when} from 'cucumber-tsflow'
import {EXTERNAL_AUTHENTICATION_SVC_URL} from '../shared/config'
import {expect} from 'chai'
import {
  CreateAuthRealmMockStepData,
  GetUserAuthenticationInfoMockStepData,
  MultipleUserAuthenticationInfoMockStepData,
} from '../shared/mocks/http-data-structures'
import {TableDefinition} from 'cucumber'
import * as MockApi from '../shared/mocks/api'
import {mockApiCall} from '../shared/mocks/api'
import {TestContext} from '../shared/common/test-context'
import {IdTokenData} from '../shared/common/http-data-structures'
import {generateIdToken} from '../shared/common/helpers'
import {StepUtils} from '../shared/common/step_utils'

@binding([TestContext])
export class MockSteps {
  constructor(protected testContext: TestContext) {}

  private _stepUtils = new StepUtils(this.testContext)

  @when(
    'I mock EAS to return a successful Authentication Realm creation response with the following parameters',
  )
  public async mockEasAuthenticationRealmResponse(
    table: TableDefinition<CreateAuthRealmMockStepData>,
  ) {
    await this._stepUtils.mockEasAuthenticationRealmResponse(table.hashes()[0])
  }

  @when(
    'I mock EAS to return a failed Authentication Realm creation response with the following parameters',
  )
  public async mockEasAuthenticationRealmFailureResponse(
    table: TableDefinition<CreateAuthRealmMockStepData>,
  ) {
    const data = table.hashes()[0]
    const mockedResponse = {
      errors: {
        status: data.status,
        title: data.title,
        detail: data.detail,
      },
      links: {
        self: `${EXTERNAL_AUTHENTICATION_SVC_URL}/v2/authentication-realms/${data.realmId}`,
      },
    }
    await MockApi.mockApiCall('/v2/authentication-realms', 'POST', 500, mockedResponse)
  }

  @when(
    'I mock EAS to return a successful user-authentication-info response with the following parameters',
  )
  public async mockEasSuccessfulResponseUserAuthenticationInfo(
    table: TableDefinition<GetUserAuthenticationInfoMockStepData>,
  ) {
    const {urlPath, mockedResponse} = this._stepUtils.prepareMockCallUserAuthInfo(table.hashes()[0])
    await MockApi.mockApiCall(urlPath, 'GET', 200, mockedResponse)
  }

  public async mockEasSuccessfulResponseAnyUserAuthenticationInfo(
    table: GetUserAuthenticationInfoMockStepData,
  ): Promise<void> {
    await this._stepUtils.mockEasSuccessfulResponseAnyUserAuthenticationInfo(table)
  }

  @when(
    'I mock EAS to return a successful user-authentication-info response {int} times/time with the following parameters',
  )
  public async mockEasSuccessfulResponseUserAuthenticationInfos(
    count: bigint,
    table: TableDefinition<MultipleUserAuthenticationInfoMockStepData>,
  ) {
    const data = table.hashes()[0]
    const userIds = data.userIds.split(',')
    const urlPath = `/v2/authentication-realms/${data.realmId}/user-authentication-info/`

    for (let i = 1; i <= count; i++) {
      const userId = userIds[i - 1]
      const mockedResponse = {
        data: {
          id: userId,
          name: data.namePrefix + userId,
          email: userId + data.emailSuffix,
          meta: {
            created_at: '2020-07-13T20:20:38.738Z',
            updated_at: '2020-07-13T20:20:38.738Z',
          },
          type: 'user-authentication-info',
        },
        links: {
          self: `${EXTERNAL_AUTHENTICATION_SVC_URL}/${urlPath}${userId}`,
        },
      }
      await MockApi.mockApiCall(urlPath + userId, 'GET', 200, mockedResponse)
    }
  }

  @when(
    'I mock EAS to return an unsuccessful user-authentication-info response with the following parameters',
  )
  public async mockEasUnsuccessfulResponseUserAuthenticationInfo(
    table: TableDefinition<GetUserAuthenticationInfoMockStepData>,
  ) {
    const data = table.hashes()[0]
    const urlPath = `/v2/authentication-realms/${data.realmId}/user-authentication-info/${data.userId}`
    const mockedResponse = {
      errors: [
        {
          detail: 'The user authentication info id was not found: ' + data.userId,
          status: '404',
          title: 'User authentication info not found',
        },
      ],
      links: {
        self: `${EXTERNAL_AUTHENTICATION_SVC_URL}/${urlPath}`,
      },
    }
    await MockApi.mockApiCall(urlPath, 'GET', 200, mockedResponse)
  }

  @then('The mocked endpoint for URL path {string} and method {string} is called {int} times')
  public async mockCallCount(urlPath: string, method: string, called: number) {
    await MockApi.mockApiCallCount(urlPath, method).then((response) => {
      expect(response.data.count).to.be.equal(called)
    })
  }

  @when(
    'I mock EAS endpoint {string} for method {string} to return status {int} and an id token which encodes the following data',
  )
  public async mockEasTokenCorrectResponse(
    urlPath: string,
    method: string,
    status: number,
    table: TableDefinition<IdTokenData>,
  ) {
    const stepData = table.hashes()[0]
    let iat = 0
    let exp = 0
    switch (stepData.iat) {
      case '[NOW]':
        iat = new Date().getTime() / 1000
        break
      default:
        expect.fail(`iat value ${stepData.iat} is unsupported`)
    }
    switch (stepData.exp) {
      case '[IN_ONE_HOUR]':
        exp = (new Date().getTime() + 3600000) / 1000
        break
      case '[ONE_SECOND_AGO]':
        exp = (new Date().getTime() - 1000) / 1000
        break
      default:
        expect.fail(`exp value ${stepData.exp} is unsupported`)
    }
    const issuerEndpoint =
      process.env['OIDC_ISSUER_WITHOUT_REALM'] || 'http://localhost:8080/oidc-idp'
    const tokenData: IdTokenData = {
      iss: stepData.iss.replace('[EAS_ENDPOINT]', issuerEndpoint),
      sub: stepData.sub,
      aud: stepData.aud,
      exp: exp,
      iat: iat,
      name: stepData.name,
      email: stepData.email,
    }
    if (stepData.aud.includes(',')) {
      tokenData.aud = stepData.aud.split(',')
    }
    const signedToken = generateIdToken(tokenData)
    await mockApiCall(urlPath, method, status, {id_token: signedToken})
  }

  @when('I mock EAS endpoint {string} for method {string} to return an error with status {int}')
  public async mockEasTokenErrorResponse(urlPath: string, method: string, status: number) {
    await mockApiCall(urlPath, method, status)
  }

  @when(
    'I mock EAS endpoint {string} for method {string} to return an invalid grant error with status {int}',
  )
  public async mockEasInvalidGrantErrorResponse(urlPath: string, method: string, status: number) {
    const error_response = JSON.parse(
      '{"error":"invalid_grant","errorDescription":"code not valid"}',
    )
    await mockApiCall(urlPath, method, status, error_response)
  }

  @when(
    'I mock EAS endpoint {string} for method {string} to return an invalid client error with status {int}',
  )
  public async mockEasInvalidClientErrorResponse(urlPath: string, method: string, status: number) {
    const error_response = JSON.parse(
      '{"error":"invalid_client","errorDescription":"code not valid"}',
    )
    return mockApiCall(urlPath, method, status, error_response)
  }
}
