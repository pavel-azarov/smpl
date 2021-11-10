/* eslint-disable @typescript-eslint/camelcase */
import {binding, when} from 'cucumber-tsflow/dist'
import {TestContext} from '../shared/common/test-context'
import {expect} from 'chai'
import * as AccSettingHttpStructures from '../shared/account-auth-settings/http-data-structures'
import {TableDefinition} from 'cucumber'
import {Method} from 'axios'
import {
  COMPONENT_TESTS_WIREMOCK_URL,
  EXTERNAL_AUTHENTICATION_SVC_URL,
  SERVICE_HOST,
} from '../shared/config'
import {api} from '../shared/common/api'
import {ACCOUNT_SETTINGS_PATH} from '../shared/account-auth-settings/acc-auth-settings-config'
import {
  AccountMemberAssertionParams,
  AccountMemberData,
  AccountMemberReadParams,
  AccountMemberStepData,
  UnassignedAccountMemberReadParams,
} from '../shared/account-members/http-data-structures'
import {ACCOUNT_MEMBERS_PATH} from '../shared/account-members/account-member-config'
import {ACCOUNTS_PATH} from '../shared/account/account-config'

@binding([TestContext])
export class AccountAuthSettingsSteps {
  constructor(protected testContext: TestContext) {}

  @when('I read Account Authentication Settings passing the following parameters')
  public async readAccountAuthSettings(
    table: TableDefinition<AccSettingHttpStructures.AccountAuthSettingsRequestParams>,
  ) {
    const data = table.hashes()[0]
    if (data.url === undefined) {
      data.url =
        data.storeIdPathParameter === undefined
          ? ACCOUNT_SETTINGS_PATH
          : `${ACCOUNT_SETTINGS_PATH}${data.storeIdPathParameter}`
    } else {
      data.url = `${SERVICE_HOST}${data.url}`
    }
    if (data.storeIdHeader === 'omit') {
      this.testContext.addResponse(await api.get(data.url))
    } else {
      this.testContext.addResponse(await api.get(data.url, data.storeIdHeader))
    }
  }

  @when('I read an account member passing the following parameters')
  public async readAccount(table: TableDefinition<AccountMemberStepData>) {
    const data = table.hashes()[0]

    if (data['EP-Internal-Account-Member-Id']) {
      this.testContext.addResponse(
        await api.get(`${ACCOUNT_MEMBERS_PATH}${data.id}`, data['store_id'], {
          'EP-Internal-Account-Member-Id': data['EP-Internal-Account-Member-Id'],
        }),
      )
    } else {
      this.testContext.addResponse(
        await api.get(`${ACCOUNT_MEMBERS_PATH}${data.id}`, data['store_id']),
      )
    }
  }

  @when('I read Account Member with id {string} and store id {string}')
  public async readAccountMember(id: string, storeId: string) {
    const url = `${SERVICE_HOST}/v2/account-members/${id}`
    this.testContext.addResponse(await api.get(url, storeId))
  }

  @when('I read account members list with following parameters')
  public async readAccountMembersList(table: TableDefinition<AccountMemberReadParams>) {
    const data = table.hashes()[0]
    let path = `${ACCOUNT_MEMBERS_PATH}`

    let alreadyHasQueryParams = false
    if (data['page-limit'] != null) {
      path = path + `?page[limit]=${data['page-limit']}`
      alreadyHasQueryParams = true
    }
    if (data['page-offset'] != null) {
      path = path + (alreadyHasQueryParams ? '&' : '?') + `page[offset]=${data['page-offset']}`
    }

    const pageSize =
      data['X-Moltin-Settings-page_length'] === undefined
        ? 20
        : data['X-Moltin-Settings-page_length']

    if (data['EP-Internal-Account-Member-Id']) {
      this.testContext.addResponse(
        await api.get(path, data['store_id'], {
          'X-Moltin-Settings-page_length': pageSize,
          'EP-Internal-Account-Member-Id': data['EP-Internal-Account-Member-Id'],
        }),
      )
    } else {
      const header = {
        'X-Moltin-Settings-page_length': pageSize,
      }
      if (data['ep-internal-search-json']) {
        header['ep-internal-search-json'] = data['ep-internal-search-json']
      }
      this.testContext.addResponse(await api.get(path, data['store_id'], header))
    }
  }

  @when('I read unassigned account members list with following parameters')
  public async readUnAssignedAccountMembersList(
    table: TableDefinition<UnassignedAccountMemberReadParams>,
  ) {
    const data = table.hashes()[0]
    switch (data.account_id) {
      case '<last>':
        data.account_id = this.testContext.getLatestAccountId()
        break
      case '<previous>':
        data.account_id = this.testContext.getPreviousAccountId()
    }
    let path = `${ACCOUNTS_PATH}/${data.account_id}/account-memberships/unassigned-account-members/`

    let alreadyHasQueryParams = false
    if (data['page-limit'] != null) {
      path = path + `?page[limit]=${data['page-limit']}`
      alreadyHasQueryParams = true
    }
    if (data['page-offset'] != null) {
      path = path + (alreadyHasQueryParams ? '&' : '?') + `page[offset]=${data['page-offset']}`
    }

    const pageSize =
      data['X-Moltin-Settings-page_length'] === undefined
        ? 20
        : data['X-Moltin-Settings-page_length']

    const header = {
      'X-Moltin-Settings-page_length': pageSize,
    }
    if (data['ep-internal-search-json']) {
      header['ep-internal-search-json'] = data['ep-internal-search-json']
    }

    this.testContext.addResponse(await api.get(path, data['store_id'], header))
  }

  @when('I see {int} account member/members in the returned data')
  public async assertAccountMembersCount(count: bigint) {
    const accountMembers = this.testContext.ensureLatestResponse().data.data
    expect(accountMembers.length).to.equal(count, 'Unexpected account amount on a page')
  }

  @when('I see {int} account member/members in the returned data with following parameters')
  public async assertAccountMembersCountAndContent(
    count: bigint,
    table: TableDefinition<AccountMemberData>,
  ) {
    const accountMembers = this.testContext.ensureLatestResponse().data.data
    const data = table.hashes()[0]
    const userIds = data.user_ids.split(',')

    expect(accountMembers.length).to.equal(count, 'Unexpected account amount on a page')
    for (let i = 0; i < count; i++) {
      const expectedObject = {
        id: userIds[i],
        name: data.name_prefix + userIds[i],
        email: userIds[i] + data.email_suffix,
        type: 'account_member',
        links: {self: `${SERVICE_HOST}/v2/account-members/${userIds[i]}`},
      }
      expect(accountMembers).to.deep.include(
        expectedObject,
        'Unexpected Account Member response object',
      )

      expect(
        accountMembers.map(function (val: any) {
          return val['links'].self
        }),
      ).to.not.be.null
    }
  }

  @when('I see an account member in the returned list with following parameters')
  public async assertAccountMembersInList(table: TableDefinition<AccountMemberAssertionParams>) {
    const accountMembers = this.testContext.ensureLatestResponse().data.data
    const data = table.hashes()[0]
    const expectedObject = {
      name: data.name,
      email: data.email,
      id: data.id,
    }
    for (const accMember of accountMembers) {
      if (accMember.name === data.name) {
        expect(accMember).to.deep.include(
          expectedObject,
          'Unexpected Account Member response object',
        )
        break
      }
      expect.fail('There is no account member with provided parameters in a list')
    }
  }

  @when('I do not see an account member in the returned list with following parameters')
  public async assertAccountMembersNotInList(table: TableDefinition<AccountMemberAssertionParams>) {
    const accountMembers = this.testContext.ensureLatestResponse().data.data
    const data = table.hashes()[0]
    for (const accMember of accountMembers) {
      if (accMember.name === data.name && accMember.email === data.email) {
        expect.fail('Account member is in a list')
      }
    }
  }

  @when('I read Account Member with id {string} and without store id')
  public async readAccountMemberNoStoreID(id: string) {
    const url = `${SERVICE_HOST}/v2/account-members/${id}`
    this.testContext.addResponse(await api.get(url))
  }

  @when('I see the following parameters in Account Authentication settings response')
  public assertAccAuthSettingsBody(
    table: TableDefinition<AccSettingHttpStructures.AccountAuthSettingsAssertionParams>,
  ) {
    const data = table.hashes()[0]
    const easURL = EXTERNAL_AUTHENTICATION_SVC_URL || COMPONENT_TESTS_WIREMOCK_URL
    const expectedObject: AccSettingHttpStructures.AccountAuthSettingsResponse = {
      data: {
        id: data.id,
        type: data.type,
        meta: {
          client_id: data.clientId,
        },
        relationships: {
          authentication_realm: {
            data: {
              id: data.realmId,
              type: data.realmType,
              links: {
                self: `${easURL}${data.realmSelfLink}`,
              },
            },
          },
        },
      },
    }
    const response = this.testContext.ensureLatestResponse()
      .data as AccSettingHttpStructures.AccountAuthSettingsResponse
    expect(response).to.deep.include(
      expectedObject,
      'Unexpected Account Authentication Settings response object',
    )
  }

  @when('I see the following parameters in Account Member response')
  public assertAccountMemberBody(table: TableDefinition<AccountMemberAssertionParams>) {
    const data = table.hashes()[0]
    const expectedObject = {
      data: {
        id: data.id,
        type: 'account_member',
        name: data.name,
        email: data.email,
      },
      links: {self: `${SERVICE_HOST}/v2/account-members/${data.id}`},
    }
    const response = this.testContext.ensureLatestResponse().data
    expect(response).to.deep.include(expectedObject, 'Unexpected Account Member response object')
  }

  @when(
    'I use HTTP method {string} when calling Account Authentication Settings endpoint with the following properties',
  )
  public async wrongMethodAuthSettings(
    method: Method,
    table: TableDefinition<AccSettingHttpStructures.AccountAuthSettingsRequestParams>,
  ) {
    const bodyParameters = table.hashes()[0]
    const data = {
      data: {
        type: bodyParameters.type,
      },
    }
    switch (method) {
      case 'POST':
        this.testContext.addResponse(
          await api.post(ACCOUNT_SETTINGS_PATH, data, bodyParameters.storeIdHeader),
        )
        break
      case 'PUT':
        this.testContext.addResponse(
          await api.put(ACCOUNT_SETTINGS_PATH, data, bodyParameters.storeIdHeader),
        )
        break
      case 'DELETE':
        this.testContext.addResponse(
          await api.delete(ACCOUNT_SETTINGS_PATH, bodyParameters.storeIdHeader),
        )
        break
      default:
        expect.fail('Unsupported operation')
    }
  }
}
