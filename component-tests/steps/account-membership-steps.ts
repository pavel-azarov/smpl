import {TestContext} from '../shared/common/test-context'
import {binding, when} from 'cucumber-tsflow/dist'
import {TableDefinition} from 'cucumber'
import {ACCOUNTS_PATH} from '../shared/account/account-config'
import {api} from '../shared/common/api'
import {
  AccountMembershipAssertionParams,
  AccountMembershipListAssertionParams,
  AccountMembershipRequestBody,
  AccountMembershipStepData,
} from '../shared/account-memberships/http-data-structures'
import {expect} from 'chai'
import {StepUtils} from '../shared/common/step_utils'
import {ACCOUNT_MEMBERSHIP_TYPE} from '../shared/account-memberships/account-config'

@binding([TestContext])
export class AccountMembershipSteps {
  constructor(protected testContext: TestContext) {}

  private _stepUtils = new StepUtils(this.testContext)

  @when('I have/create an account membership with the following parameters')
  public async createAccountMembershipStep(table: TableDefinition<AccountMembershipStepData>) {
    const data = table.hashes()[0]
    await this.createAccountMembership(data)
  }

  public async createAccountMembership(data: AccountMembershipStepData): Promise<void> {
    await this._stepUtils.createAccountMembership(data)
  }

  @when('I update an account membership with the following parameters')
  public async updateAccountMembershipStep(table: TableDefinition<AccountMembershipStepData>) {
    const data = table.hashes()[0]
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

    if (data.account_membership_id === '<last>') {
      data.account_membership_id = this.testContext.getLatestAccountMembershipId()
    } else if (data.account_membership_id === '<previous>') {
      data.account_membership_id = this.testContext.getPreviousAccountMembershipId()
    }

    let response
    if (data['store_id'] === undefined) {
      response = await api.put(
        ACCOUNTS_PATH +
          '/' +
          data.account_id +
          '/account-memberships/' +
          data.account_membership_id,
        requestData,
      )
    } else {
      response = await api.put(
        ACCOUNTS_PATH +
          '/' +
          data.account_id +
          '/account-memberships/' +
          data.account_membership_id,
        requestData,
        data['store_id'],
      )
    }
    this.testContext.addResponse(response)
    if (response.status >= 200 && response.status <= 300) {
      this.testContext.addAccountMembershipId(response.data.data.id)
    }
  }

  @when('I read an account membership with the following parameters')
  public async getAccountMembership(table: TableDefinition<AccountMembershipStepData>) {
    const data = table.hashes()[0]

    if (data.account_id.startsWith('previous-')) {
      data.account_id = this.testContext.getAccountIdList()[
        parseInt(data.account_id.split('-')[1]) - 1
      ]
    } else {
      if (data.account_id === '<last>') {
        data.account_id = this.testContext.getLatestAccountId()
      } else if (data.account_id === '<previous>') {
        data.account_id = this.testContext.getPreviousAccountId()
      }
    }

    if (data.account_membership_id.startsWith('previous-')) {
      data.account_membership_id = this.testContext.getAccountMembershipIdList()[
        parseInt(data.account_membership_id.split('-')[1]) - 1
      ]
    } else {
      if (data.account_membership_id === '<last>') {
        data.account_membership_id = this.testContext.getLatestAccountMembershipId()
      } else if (data.account_membership_id === '<previous>') {
        data.account_membership_id = this.testContext.getPreviousAccountMembershipId()
      }
    }
    if (data['EP-Internal-Account-Id']) {
      if (data['EP-Internal-Account-Id'].startsWith('<previous-')) {
        data['EP-Internal-Account-Id'] = this.testContext.getAccountIdList()[
          parseInt(data['EP-Internal-Account-Id'].split('-')[1]) - 1
        ]
      } else {
        if (data['EP-Internal-Account-Id'] === '<last>') {
          data['EP-Internal-Account-Id'] = this.testContext.getLatestAccountId()
        } else if (data['EP-Internal-Account-Id'] === '<previous>') {
          data['EP-Internal-Account-Id'] = this.testContext.getPreviousAccountId()
        }
      }
    }

    let response
    if (data['store_id'] === undefined) {
      response = await api.get(
        ACCOUNTS_PATH +
          '/' +
          data.account_id +
          '/account-memberships/' +
          data.account_membership_id,
      )
    } else {
      response = await api.get(
        ACCOUNTS_PATH +
          '/' +
          data.account_id +
          '/account-memberships/' +
          data.account_membership_id,
        data['store_id'],
        data['EP-Internal-Account-Id'] ? data['EP-Internal-Account-Id'] : '',
      )
    }
    this.testContext.addResponse(response)
  }

  @when('I read all account memberships with the following parameters')
  public async getAccountMembershipList(table: TableDefinition<AccountMembershipStepData>) {
    const data = table.hashes()[0]
    let path = `${ACCOUNTS_PATH}`

    if (data['EP-Internal-Account-Id']) {
      if (data['EP-Internal-Account-Id'].startsWith('<previous-')) {
        data['EP-Internal-Account-Id'] = this.testContext.getAccountIdList()[
          parseInt(data['EP-Internal-Account-Id'].split('-')[1]) - 1
        ]
      } else {
        if (data['EP-Internal-Account-Id'] === '<last>') {
          data['EP-Internal-Account-Id'] = this.testContext.getLatestAccountId()
        } else if (data['EP-Internal-Account-Id'] === '<previous>') {
          data['EP-Internal-Account-Id'] = this.testContext.getPreviousAccountId()
        }
      }
    }

    if (data.account_id.startsWith('<previous-')) {
      data.account_id = this.testContext.getAccountIdList()[
        parseInt(data.account_id.split('-')[1]) - 1
      ]
    } else {
      if (data.account_id === '<last>') {
        data.account_id = this.testContext.getLatestAccountId()
      } else if (data.account_id === '<previous>') {
        data.account_id = this.testContext.getPreviousAccountId()
      }
    }

    path = path + '/' + data.account_id + '/account-memberships'
    if (data['page-limit'] != null && data['page-offset'] != null) {
      path = path + `?page[limit]=${data['page-limit']}&page[offset]=${data['page-offset']}`
    }

    const pageSize =
      data['X-Moltin-Settings-page_length'] === undefined
        ? 20
        : data['X-Moltin-Settings-page_length']

    const header = {
      'X-Moltin-Settings-page_length': pageSize,
      'EP-Internal-Account-Id': data['EP-Internal-Account-Id']
        ? data['EP-Internal-Account-Id']
        : '',
    }
    if (data['ep-internal-search-json']) {
      header['ep-internal-search-json'] = data['ep-internal-search-json']
    }
    const response = await api.get(path, data['store_id'], header)
    this.testContext.addResponse(response)
  }

  @when('I delete an account membership with the following parameters')
  public async deleteAccountMembership(table: TableDefinition<AccountMembershipStepData>) {
    const data = table.hashes()[0]

    if (data.account_id.startsWith('previous-')) {
      data.account_id = this.testContext.getAccountIdList()[
        parseInt(data.account_id.split('-')[1]) - 1
      ]
    } else {
      if (data.account_id === '<last>') {
        data.account_id = this.testContext.getLatestAccountId()
      } else if (data.account_id === '<previous>') {
        data.account_id = this.testContext.getPreviousAccountId()
      }
    }

    if (data.account_membership_id.startsWith('previous-')) {
      data.account_membership_id = this.testContext.getAccountMembershipIdList()[
        parseInt(data.account_membership_id.split('-')[1]) - 1
      ]
    } else {
      if (data.account_membership_id === '<last>') {
        data.account_membership_id = this.testContext.getLatestAccountMembershipId()
      } else if (data.account_membership_id === '<previous>') {
        data.account_membership_id = this.testContext.getPreviousAccountMembershipId()
      }
    }

    let response
    if (data['store_id'] === undefined) {
      response = await api.delete(
        ACCOUNTS_PATH +
          '/' +
          data.account_id +
          '/account-memberships/' +
          data.account_membership_id,
      )
    } else {
      response = await api.delete(
        ACCOUNTS_PATH +
          '/' +
          data.account_id +
          '/account-memberships/' +
          data.account_membership_id,
        data['store_id'],
      )
    }
    this.testContext.addResponse(response)
  }

  @when('I use HTTP method {string} when calling create Account Memberships endpoint')
  public async wrongMethodAccountMemberships(method: string) {
    const requestData = {
      data: {
        some: 'data',
      },
    }
    let response
    switch (method) {
      case 'PUT':
        response = await api.put(
          `${ACCOUNTS_PATH}/00000000-0000-0000-0000-0000000000/account-memberships`,
          requestData,
        )
        break
      case 'DELETE':
        response = await api.delete(
          `${ACCOUNTS_PATH}/00000000-0000-0000-0000-0000000000/account-memberships`,
        )
        break
      default:
        break
    }
    this.testContext.addResponse(response)
  }

  @when('I use HTTP method {string} when calling create Account Membership endpoint')
  public async wrongMethodAccountMembership(method: string) {
    const requestData = {
      data: {
        some: 'data',
      },
    }
    let response
    switch (method) {
      case 'PUT':
        response = await api.put(
          `${ACCOUNTS_PATH}/00000000-0000-0000-0000-0000000000/account-memberships/00000000-0000-0000-0000-0000000000`,
          requestData,
        )
        break
      default:
        break
    }
    this.testContext.addResponse(response)
  }

  @when('I see the following parameters in Account Membership response')
  public assertAccountMembershipBody(table: TableDefinition<AccountMembershipAssertionParams>) {
    const data = table.hashes()[0]
    const expectedObject = {
      data: {
        type: 'account_membership',
        relationships: {
          account_member: {
            data: {
              id: data.account_member_id,
              type: 'account_member',
            },
          },
        },
      },
    }
    const response = this.testContext.ensureLatestResponse().data
    expect(response.data.id).to.not.be.empty
    expect(response.data.meta.timestamps.created_at).to.not.be.empty
    expect(response.data.meta.timestamps.updated_at).to.not.be.empty
    expect(response.links.self).to.not.be.empty
    delete response.data.id
    delete response.data.meta

    expect(response).to.deep.include(
      expectedObject,
      'Unexpected Account Membership response object',
    )
  }

  @when('I see {int} account membership(s) in the returned data with the following parameters')
  public async assertAccountMembershipsCountAndContent(
    count: bigint,
    table: TableDefinition<AccountMembershipListAssertionParams>,
  ) {
    const accountMemberships = this.testContext.ensureLatestResponse().data.data
    const data = table.hashes()[0]
    const accountMemberIds = data.account_member_id.split(',')

    if (data.account_id.startsWith('<previous-')) {
      data.account_id = this.testContext.getAccountIdList()[
        parseInt(data.account_id.split('-')[1]) - 1
      ]
    } else {
      if (data.account_id === '<last>') {
        data.account_id = this.testContext.getLatestAccountId()
      } else if (data.account_id === '<previous>') {
        data.account_id = this.testContext.getPreviousAccountId()
      }
    }

    expect(accountMemberships.length).to.equal(
      count,
      'Unexpected account membership amount on a page',
    )
    for (let i = 0; i < count; i++) {
      expect(accountMemberships[i].relationships['account_member'].data.id).to.contain(
        accountMemberIds[i],
      )
      expect(accountMemberships[i].links.self).to.not.be.null
    }
  }
}
