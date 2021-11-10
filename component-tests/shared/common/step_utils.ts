import {expect} from 'chai'
import {
  AuthRealmResponseBody,
  CreateAuthRealmMockStepData,
  GetUserAuthenticationInfoMockStepData,
} from '../mocks/http-data-structures'
import {EXTERNAL_AUTHENTICATION_SVC_URL} from '../config'
import * as MockApi from '../mocks/api'
import {
  AccountMembershipRequestBody,
  AccountMembershipStepData,
} from '../account-memberships/http-data-structures'
import {ACCOUNT_MEMBERSHIP_TYPE} from '../account-memberships/account-config'
import {api} from './api'
import {ACCOUNTS_PATH} from '../account/account-config'
import {TestContext} from './test-context'
import {binding} from 'cucumber-tsflow/dist'

@binding([TestContext])
export class StepUtils {
  constructor(protected testContext: TestContext) {}

  public assertResponse(code: number): void {
    expect(this.testContext.ensureLatestResponse().status).to.equal(
      code,
      'Unexpected status code in the latest response; response data: ' +
        JSON.stringify(this.testContext.ensureLatestResponse().data),
    )
  }

  public async mockEasAuthenticationRealmResponse(
    data: CreateAuthRealmMockStepData,
  ): Promise<void> {
    const mockedResponse: AuthRealmResponseBody = {
      data: {
        id: data.realmId,
        name: 'Test Auth Realm',
        meta: {
          created_at: '2020-07-13T20:20:38.738Z',
          updated_at: '2020-07-13T20:20:38.738Z',
        },
        type: 'authentication_realm',
      },
      links: {
        self: `${EXTERNAL_AUTHENTICATION_SVC_URL}/v2/authentication-realms/${data.realmId}`,
      },
    }
    await MockApi.mockApiCall('/v2/authentication-realms', 'POST', 201, mockedResponse)
  }

  public prepareMockCallUserAuthInfo(data: GetUserAuthenticationInfoMockStepData): any {
    const urlPath = `/v2/authentication-realms/${data.realmId}/user-authentication-info/${data.userId}`
    data.name = data.name === undefined ? 'User with ID' + data.userId : data.name
    data.email = data.email === undefined ? data.userId + '@elasticpath.com' : data.email
    const mockedResponse = {
      data: {
        id: data.userId,
        name: data.name,
        email: data.email,
        meta: {
          created_at: '2020-07-13T20:20:38.738Z',
          updated_at: '2020-07-13T20:20:38.738Z',
        },
        type: 'user-authentication-info',
      },
      links: {
        self: `${EXTERNAL_AUTHENTICATION_SVC_URL}/${urlPath}`,
      },
    }
    return {urlPath, mockedResponse}
  }

  public async mockEasSuccessfulResponseAnyUserAuthenticationInfo(
    table: GetUserAuthenticationInfoMockStepData,
  ): Promise<void> {
    const {urlPath, mockedResponse} = this.prepareMockCallUserAuthInfo(table)
    await MockApi.mockApiCallByPattern(urlPath, 'GET', 200, mockedResponse)
  }

  public async createAccountMembership(data: AccountMembershipStepData): Promise<void> {
    const requestData: AccountMembershipRequestBody = {
      data: {
        type: data.type === undefined ? ACCOUNT_MEMBERSHIP_TYPE : data.type,
        account_member_id: data.account_member_id,
      },
    }

    if (data.account_id === '<last>') {
      data.account_id = this.testContext.getLatestAccountId()
    } else if (data.account_id === '<previous>') {
      data.account_id = this.testContext.getPreviousAccountId()
    }

    let response
    if (data['store_id'] === undefined) {
      response = await api.post(
        ACCOUNTS_PATH + '/' + data.account_id + '/account-memberships/',
        requestData,
      )
    } else {
      response = await api.post(
        ACCOUNTS_PATH + '/' + data.account_id + '/account-memberships/',
        requestData,
        data['store_id'],
      )
    }
    this.testContext.addResponse(response)
    if (response.status >= 200 && response.status <= 300) {
      this.testContext.addAccountMembershipId(response.data.data.id)
    }
  }
}
