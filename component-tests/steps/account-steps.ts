import {TestContext} from '../shared/common/test-context'
import {binding, when} from 'cucumber-tsflow/dist'
import {TableDefinition} from 'cucumber'
import * as AccountData from '../shared/account/http-data-structures'
import {AccountResponseData} from '../shared/account/http-data-structures'
import {ACCOUNT_TYPE, ACCOUNTS_PATH} from '../shared/account/account-config'
import {api} from '../shared/common/api'
import {expect, use} from 'chai'
import {v4 as uuidv4} from 'uuid'
import {ACCOUNT_MEMBERS_PATH} from '../shared/account-members/account-member-config'
import chaiDeepEqualInAnyOrder from 'deep-equal-in-any-order'
import PromisePool from '@supercharge/promise-pool'
import {StepUtils} from '../shared/common/step_utils'
import assert from 'assert'

use(chaiDeepEqualInAnyOrder)

@binding([TestContext])
export class AccountSteps {
  constructor(protected testContext: TestContext) {}

  private _stepUtils = new StepUtils(this.testContext)

  @when('I create one account', '', 60000)
  public async massCreateAccountsAndMemberships(
    table: TableDefinition<AccountData.MassCreateAccountAndAccountMembershipStepData>,
  ) {
    const hash = table.hashes()[0]
    await this._stepUtils.mockEasAuthenticationRealmResponse({realmId: hash.realmId})

    await this.createAcc({
      name: hash.name,
      legal_name: hash.legal_name,
      registration_id: hash.registration_id,
      type: 'account',
      store_id: hash.store_id,
    })
    this._stepUtils.assertResponse(201)
  }

  @when(
    'I create {int} account member(s) and account membership(s) - for the latter I expect response code {int}',
    '',
    60000,
  )
  public async massCreateMemberships(
    count: number,
    accMembRespCode: number,
    table: TableDefinition<AccountData.MassCreateAccountAndAccountMembershipStepData>,
  ) {
    const hash = table.hashes()[0]
    await this._stepUtils.mockEasSuccessfulResponseAnyUserAuthenticationInfo({
      realmId: hash.realmId,
      userId: '.*',
    })

    await PromisePool.for(new Array(count).fill(1).map((_, i) => i + 1))
      .withConcurrency(32)
      .handleError((e, n) =>
        assert.fail(
          'Error with (parallel) creation of account membership # ' + n + ': ' + e.message,
        ),
      )
      .process(async (i) => {
        const userId = hash.userId + ('' + i).padStart(4, '0')
        await this._stepUtils.createAccountMembership({
          account_id: '<last>',
          account_member_id: userId,
          store_id: hash.store_id,
        })
        this._stepUtils.assertResponse(accMembRespCode)
      })
  }

  @when('I have/create an account with the following parameters')
  public async createAccount(table: TableDefinition<AccountData.AccountStepData>) {
    await this.createAcc(table.hashes()[0])
  }

  @when(
    'I use HTTP method {string} when calling create Account endpoint with the following properties',
  )
  public async wrongMethodAccount(
    method: string,
    table: TableDefinition<AccountData.AccountStepData>,
  ) {
    const data = table.hashes()[0]
    const requestData: AccountData.AccountRequestBody = {
      data: {
        type: ACCOUNT_TYPE,
        name: data.name,
        legal_name: data['legal_name'],
        registration_id: data['registration_id'],
      },
    }
    let response
    switch (method) {
      case 'PUT':
        response = await api.put(`${ACCOUNTS_PATH}`, requestData, data.store_id)
        break
      case 'DELETE':
        response = await api.delete(`${ACCOUNTS_PATH}`)
        break
      default:
        break
    }
    this.testContext.addResponse(response)
  }

  @when('I use HTTP method {string} when calling create Account Member endpoint')
  public async wrongMethodAccountMember(method: string) {
    const requestData = {
      data: {
        some: 'data',
      },
    }
    let response
    switch (method) {
      case 'POST':
        response = await api.post(`${ACCOUNT_MEMBERS_PATH}`, requestData)
        break
      case 'PUT':
        response = await api.put(`${ACCOUNT_MEMBERS_PATH}`, requestData)
        break
      case 'DELETE':
        response = await api.delete(`${ACCOUNT_MEMBERS_PATH}`)
        break
      default:
        break
    }
    this.testContext.addResponse(response)
  }

  @when(
    'I use HTTP method POST when calling accounts endpoint providing store id {string} and account id {string}',
  )
  public async postMethodRoot(storeId: string, accountId: string) {
    const response = await api.post(`${ACCOUNTS_PATH}/${accountId}`, {}, storeId)
    this.testContext.addResponse(response)
  }

  @when('I create {int} accounts/account with following parameters')
  public async createAccounts(count: bigint, table: TableDefinition<AccountData.AccountStepData>) {
    const data = table.hashes()[0]
    for (let i = 1; i <= count; i++) {
      const requestData: AccountData.AccountRequestBody = {
        data: {
          type: ACCOUNT_TYPE,
          name: data['name-prefix'] + i,
          legal_name: data['legal_name-prefix'] + i,
          registration_id: uuidv4(),
        },
      }
      const response = await api.post(ACCOUNTS_PATH, requestData, data['store_id'])
      this.testContext.addResponse(response)
    }
  }

  @when(
    'I see {int} accounts/account in the returned data with prefix {string} in name and {string} in legal_name from {int} to {int}',
  )
  public async assertAccountsCountAndContent(
    count: bigint,
    namePrefix: string,
    legalNamePrefix: string,
    from: bigint,
    to: bigint,
  ) {
    const accounts = this.testContext.ensureLatestResponse().data.data

    expect(accounts.length).to.equal(count, 'Unexpected account amount on a page')

    for (let i = from; i <= to; i++) {
      expect(
        accounts.map(function (val: any) {
          return val.name
        }),
      ).to.contain(namePrefix + i)

      expect(
        accounts.map(function (val: any) {
          return val['legal_name']
        }),
      ).to.contain(legalNamePrefix + i)

      expect(
        accounts.map(function (val: any) {
          return val['links'].self
        }),
      ).to.not.be.null
    }
  }

  @when('I see {int} accounts/account in the returned data')
  public async assertAccountsCount(count: bigint) {
    const accounts = this.testContext.ensureLatestResponse().data.data
    expect(accounts.length).to.equal(count, 'Unexpected account amount on a page')
  }

  @when('I create an account with the following parameters but not passing property {string}')
  public async createAccountMissingProperty(
    property: string,
    table: TableDefinition<AccountData.AccountStepData>,
  ) {
    const data = table.hashes()[0]
    let requestData
    switch (property) {
      case 'name':
        requestData = {
          data: {
            type: data.type,
            attributes: {
              legal_name: data['legal_name'],
              registration_id: data['registration_id'],
            },
          },
        }
        break
      case 'legal_name':
        requestData = {
          data: {
            type: data.type,
            attributes: {
              name: data.name,
              registration_id: data['registration_id'],
            },
          },
        }
        break
      case 'registration_id':
        requestData = {
          data: {
            type: data.type,
            attributes: {
              legal_name: data['legal_name'],
              name: data.name,
            },
          },
        }
        break
      case 'type':
        requestData = {
          data: {
            attributes: {
              name: data.name,
              legal_name: data['legal_name'],
              registration_id: data['registration_id'],
            },
          },
        }
        break
      default:
        expect.fail('Unsupported missing property:' + property)
    }
    this.testContext.addResponse(await api.post(ACCOUNTS_PATH, requestData, data['store_id']))
  }

  @when('I see one account in the returned data with the following parameters')
  public async assertAccountMemberContent(table: TableDefinition<AccountResponseData>) {
    const data = table.hashes()[0]

    const accounts = this.testContext.ensureLatestResponse().data.data

    expect(accounts.length).to.equal(1, 'Unexpected account amount on a page')

    switch (data.id) {
      case '<last>':
        data.id = this.testContext.getLatestAccountId()
        break
      case '<previous>':
        data.id = this.testContext.getPreviousAccountId()
    }

    expect(accounts[0]).to.contain(data)
  }

  @when('The list User Authentication Info response contains the following properties')
  public assertUserAuthInfoListDataResponse(table: TableDefinition<AccountResponseData>) {
    const uaiData = table.hashes()[0]
    const names = uaiData.name.split(',')
    const expected = []
    for (let i = 0; i < names.length; i++) {
      if (names[i] !== '') {
        expected.push({
          name: names[i],
          type: 'account',
        })
      }
    }
    this.assertAccountList(expected)
  }

  private assertAccountList(expected): void {
    if (expected.length > 0) {
      const accList = this.testContext.ensureLatestResponse()?.data.data
      const actual = accList.map((account) => {
        const {id, meta, links, ...userAuthenticationInfoSubset} = account
        delete userAuthenticationInfoSubset.legal_name
        delete userAuthenticationInfoSubset.registration_id
        return userAuthenticationInfoSubset
      })
      expect(actual).to.deep.equalInAnyOrder(expected)
    }
  }

  @when('I see the following properties in the returned Account object')
  public assertAccountBodyData(table: TableDefinition<AccountData.AccountStepData>) {
    const data = table.hashes()[0]
    const expectedDataParameters: AccountData.AccountResponseData = {
      name: data.name,
      type: data.type,
      legal_name: data['legal_name'],
      registration_id: data['registration_id'],
    }
    const recentAcc = this.testContext.ensureLatestResponse()
      .data as AccountData.AccountResponseBody
    expect(recentAcc.data).to.deep.include(
      expectedDataParameters,
      'Unexpected account response body data',
    )
    expect(recentAcc.data.id).to.not.be.empty
    if (data.id !== undefined && data.id.length > 0 && data.id !== 'any') {
      if (data.id === '<previous>') {
        data.id = this.testContext.getPreviousAccountId()
      }
      if (data.id === '<last>') {
        data.id = this.testContext.getLatestAccountId()
      }
      expect(recentAcc.data.id).to.be.equal(data.id)
    }
    expect(recentAcc.data.meta.timestamps.created_at).to.not.be.empty
    expect(recentAcc.data.meta.timestamps.updated_at).to.not.be.empty
    expect(recentAcc.links.self).to.not.be.empty

    if (data.parent_id !== undefined) {
      const expectedParent: AccountData.AccountParent = {
        data: {
          id: this.getParentAccountId(data.parent_id),
          type: 'account',
        },
      }
      expect(recentAcc.data.relationships.parent).to.deep.include(
        expectedParent,
        'Unexpected parent element',
      )
    }
    if (data.ancestors !== undefined) {
      const expectedAncestors: AccountData.AccountAncestor[] = this.getAccountAncestorList(
        data.ancestors,
      )
      for (const ancestor of recentAcc.data.relationships.ancestors) {
        expect(expectedAncestors).to.deep.include(ancestor, 'Unexpected ancestors element')
      }
    }
  }

  @when('I see property {string} with value {string} in response')
  public assertResponseProperty(property: string, value: string) {
    expect(this.testContext.ensureLatestResponse().data.data).to.have.deep.property(
      property,
      value,
      'Unexpected property in response',
    )
  }

  @when('I read an account passing the following parameters')
  public async readAccount(table: TableDefinition<AccountData.AccountStepData>) {
    const data = table.hashes()[0]
    if (data.id.startsWith('previous-')) {
      data.id = this.testContext.getAccountIdList()[parseInt(data.id.split('-')[1]) - 1]
    } else {
      switch (data.id) {
        case '<last>':
          data.id = this.testContext.getLatestAccountId()
          break
        case '<previous>':
          data.id = this.testContext.getPreviousAccountId()
          break
      }
    }

    switch (data['EP-Internal-Account-Id']) {
      case '<last>':
        data['EP-Internal-Account-Id'] = this.testContext.getLatestAccountId()
        break
      case '<previous>':
        data['EP-Internal-Account-Id'] = this.testContext.getPreviousAccountId()
    }
    if (data['EP-Internal-Account-Id']) {
      this.testContext.addResponse(
        await api.get(`${ACCOUNTS_PATH}/${data.id}`, data['store_id'], {
          'EP-Internal-Account-Id': data['EP-Internal-Account-Id'],
        }),
      )
    } else {
      this.testContext.addResponse(await api.get(`${ACCOUNTS_PATH}/${data.id}`, data['store_id']))
    }
  }

  @when('I read account list with following parameters')
  public async readAccounts(table: TableDefinition<AccountData.AccountReadParams>) {
    const data = table.hashes()[0]
    let path = `${ACCOUNTS_PATH}`

    if (data['page-limit'] != null && data['page-offset'] != null) {
      path = path + `?page[limit]=${data['page-limit']}&page[offset]=${data['page-offset']}`
    }

    const pageSize =
      data['X-Moltin-Settings-page_length'] === undefined
        ? 20
        : data['X-Moltin-Settings-page_length']

    if (data['EP-Internal-Account-Id']) {
      switch (data['EP-Internal-Account-Id']) {
        case '<last>':
          data['EP-Internal-Account-Id'] = this.testContext.getLatestAccountId()
          break
        case '<previous>':
          data['EP-Internal-Account-Id'] = this.testContext.getPreviousAccountId()
      }
    } else {
      data['EP-Internal-Account-Id'] = ''
    }

    const header = {
      'X-Moltin-Settings-page_length': pageSize,
      'EP-Internal-Account-Id': data['EP-Internal-Account-Id'],
    }
    if (data['ep-internal-search-json']) {
      header['ep-internal-search-json'] = data['ep-internal-search-json']
    }
    this.testContext.addResponse(await api.get(path, data['store_id'], header))
  }

  @when('I update an account with the following parameters')
  public async updateAccount(table: TableDefinition<AccountData.AccountStepData>) {
    const data = table.hashes()[0]
    const type = data.type !== undefined ? data.type : ACCOUNT_TYPE
    if (data.id === '<last>') {
      data.id = this.testContext.ensureLatestResponse().data.data.id
    }
    const requestData: AccountData.AccountRequestBody = {
      data: {
        type: type,
        name: data.name,
        legal_name: data['legal_name'],
        registration_id: data['registration_id'],
      },
    }
    let response
    if (data['store_id'] === undefined) {
      response = await api.put(`${ACCOUNTS_PATH}/${data.id}`, requestData)
    } else {
      response = await api.put(`${ACCOUNTS_PATH}/${data.id}`, requestData, data['store_id'])
    }
    this.testContext.addResponse(response)
  }

  @when('I update previously created account with the following parameters')
  public async updateAccountId(table: TableDefinition<AccountData.AccountStepData>) {
    const urlId = this.testContext.ensureLatestResponse().data.data.id
    const data = table.hashes()[0]
    const requestData = {
      data: {
        type: ACCOUNT_TYPE,
        id: data.id,
      },
    }
    const response = await api.put(`${ACCOUNTS_PATH}/${urlId}`, requestData, data['store_id'])
    this.testContext.addResponse(response)
  }

  @when('I partially update Account with the following parameters')
  public async partialUpdateCustomerBasedOnIndex(
    table: TableDefinition<AccountData.AccountPartialUpdStepData>,
  ) {
    const data = table.hashes()[0]
    if (data.id === '<last>') {
      data.id = this.testContext.ensureLatestResponse().data.data.id
    }
    let requestData
    switch (data.property) {
      case 'name':
        requestData = {
          data: {
            type: ACCOUNT_TYPE,
            name: data.value,
          },
        }
        break
      case 'legal_name':
        requestData = {
          data: {
            type: ACCOUNT_TYPE,
            legal_name: data.value,
          },
        }
        break
      case 'registration_id':
        requestData = {
          data: {
            type: ACCOUNT_TYPE,
            registration_id: data.value,
          },
        }
        break
      default:
        expect.fail('Unsupported property name')
    }
    this.testContext.addResponse(
      await api.put(`${ACCOUNTS_PATH}/${data.id}`, requestData, data['store_id']),
    )
  }

  @when('I delete an account passing the following parameters')
  public async deleteAccount(table: TableDefinition<AccountData.AccountStepData>) {
    const data = table.hashes()[0]
    if (data.id === '<last>') {
      data.id = this.testContext.getLatestAccountId()
    } else if (data.id.startsWith('previous-')) {
      data.id = this.testContext.getAccountIdList()[parseInt(data.id.split('-')[1]) - 1]
    }
    this.testContext.addResponse(await api.delete(`${ACCOUNTS_PATH}/${data.id}`, data['store_id']))
  }

  private getParentAccountId(stepParam: string): string {
    let accountId: string = stepParam
    if (stepParam.startsWith('previous-')) {
      accountId = this.testContext.getAccountIdList()[parseInt(stepParam.split('-')[1]) - 1]
    } else {
      switch (stepParam) {
        case 'previous':
          accountId = this.testContext.getPreviousAccountId()
          break
        case 'last':
          accountId = this.testContext.getLatestAccountId()
          break
      }
    }
    return accountId
  }

  private getAccountAncestorList(stepParam: string): AccountData.AccountAncestor[] {
    let ancestorIdList: string[] = []
    let ancestors: AccountData.AccountAncestor[] = []
    if (stepParam === '') {
      ancestors = []
    } else if (stepParam.startsWith('previous-list-')) {
      if (stepParam === 'previous-list-all') {
        ancestorIdList = this.testContext.getPreviousAccountIdListButLast()
      } else {
        ancestorIdList = this.testContext
          .getAccountIdList()
          .slice(0, parseInt(stepParam.split('-')[2]))
      }
    } else {
      ancestorIdList = stepParam.split(',')
    }
    for (const ancestorId of ancestorIdList) {
      ancestors.push({
        data: {
          id: ancestorId,
          type: 'account',
        },
      })
    }
    return ancestors
  }

  private async createAcc(data: AccountData.AccountStepData): Promise<void> {
    const type = data.type !== undefined ? data.type : ACCOUNT_TYPE
    const requestData: AccountData.AccountRequestBody = {
      data: {
        type: type,
        name: data.name,
        legal_name: data['legal_name'],
        registration_id: data['registration_id'],
      },
    }
    if (data['parent_id'] !== undefined) {
      requestData.data['parent_id'] = this.getParentAccountId(data['parent_id'])
    }
    let response
    if (data['store_id'] === undefined) {
      response = await api.post(ACCOUNTS_PATH, requestData)
    } else {
      response = await api.post(ACCOUNTS_PATH, requestData, data['store_id'])
    }
    this.testContext.addResponse(response)
    if (response.status >= 200 && response.status <= 300) {
      this.testContext.addAccountId(response.data.data.id)
      this.testContext.addAccountName(response.data.data.name)
    }
  }
}
