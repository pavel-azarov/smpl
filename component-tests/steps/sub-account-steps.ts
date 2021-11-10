import {TestContext} from '../shared/common/test-context'
import {binding, when} from 'cucumber-tsflow/dist'
import {TableDefinition} from 'cucumber'
import * as AccountData from '../shared/account/http-data-structures'
import {ACCOUNT_TYPE, ACCOUNTS_PATH} from '../shared/account/account-config'
import {api} from '../shared/common/api'

@binding([TestContext])
export class AccountSteps {
  constructor(protected testContext: TestContext) {}

  @when(
    'I have/create a linear sub-account structure with depth {int} and the following parameters',
  )
  public async createAccountStruct(
    depth: number,
    table: TableDefinition<AccountData.AccountStepData>,
  ) {
    const data = table.hashes()[0]
    const requestData: AccountData.AccountRequestBody = {
      data: {
        type: ACCOUNT_TYPE,
        name: `${data['name-prefix']}-1`,
        legal_name: `${data['legal_name-prefix']}-1`,
        registration_id: `${data['registration_id-prefix']}-1`,
      },
    }
    await this.createAccount(requestData, data['store_id'])
    await this.createSubAccountStruct(depth, data)
  }

  @when(
    'I have/create a linear sub-account structure with depth {int}, the first sub-account parent {string} and the following parameters',
  )
  public async createAccountStructWithParent(
    depth: number,
    parent: string,
    table: TableDefinition<AccountData.AccountStepData>,
  ) {
    const data = table.hashes()[0]
    if (parent.startsWith('previous-')) {
      parent = this.testContext.getAccountIdList()[parseInt(parent.split('-')[1]) - 1]
    }
    const requestData: AccountData.AccountRequestBody = {
      data: {
        type: ACCOUNT_TYPE,
        name: `${data['name-prefix']}-1`,
        legal_name: `${data['name-prefix']}-1`,
        registration_id: `${data['registration_id-prefix']}-1`,
        parent_id: parent,
      },
    }
    await this.createAccount(requestData, data['store_id'])
    await this.createSubAccountStruct(depth, data)
  }

  private async createSubAccountStruct(depth: number, parameters): Promise<void> {
    for (let i = 2; i <= depth; i++) {
      const requestData = {
        data: {
          type: ACCOUNT_TYPE,
          name: `${parameters['name-prefix']}-` + i,
          legal_name: `${parameters['legal_name-prefix']}-` + i,
          registration_id: `${parameters['registration_id-prefix']}-` + i,
          parent_id: this.testContext.getLatestAccountId(),
        },
      }
      await this.createAccount(requestData, parameters['store_id'])
    }
  }

  private async createAccount(
    requestData: AccountData.AccountRequestBody,
    storeId: string,
  ): Promise<void> {
    const response = await api.post(ACCOUNTS_PATH, requestData, storeId)
    this.testContext.addResponse(response)
    if (response.status >= 200 && response.status <= 300) {
      this.testContext.addAccountId(response.data.data.id)
      this.testContext.addAccountName(response.data.data.name)
    }
  }
}
