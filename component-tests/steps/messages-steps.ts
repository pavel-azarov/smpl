import {binding, given, then, when} from 'cucumber-tsflow/dist'
import * as MessagesConf from '../shared/rabbitmq/messages-config'
import * as MessagesDataStruct from '../shared/rabbitmq/messages-structures'
import {EasUserAuthInfoEvent} from '../shared/rabbitmq/messages-structures'
import {TestContext} from '../shared/common/test-context'
import {TableDefinition} from 'cucumber'
import {expect} from 'chai'
import {rabbitClient} from '../shared/rabbitmq/client'
import {postgresClient, testQueues} from '../shared/hooks/setup'
import {Message} from 'amqp-ts'
import {sleep} from '../shared/common/helpers'

@binding([TestContext])
export class MessagesSteps {
  constructor(protected testContext: TestContext) {}

  @given('I create a queue to listen to the Accounts events')
  public async configureQueueRoutingKey() {
    const exchange = rabbitClient.createExchange(MessagesConf.MESSAGES_EXCHANGE)
    const queue = await rabbitClient.createQueue(
      exchange,
      MessagesConf.MESSAGES_QUEUE_NAME,
      MessagesConf.MESSAGES_ROUTING_KEY,
    )
    testQueues.push(queue)
  }

  @given('I send a message with the following parameters')
  public async sendMessage(table: TableDefinition<EasUserAuthInfoEvent>) {
    const messageParams = table.hashes()[0]
    messageParams.exchange = messageParams.exchange || MessagesConf.MESSAGES_EAS_EXCHANGE
    messageParams.routingKey = messageParams.routingKey || messageParams.routingKey
    const messageBody = {
      time: messageParams.event_time,
      specversion: messageParams.specversion,
      id: messageParams.id,
      source: messageParams.source,
      type: messageParams.type,
      data: {
        id: messageParams.userAuthInfoId,
        name: messageParams.name,
        email: messageParams.email,
        store_id: messageParams.storeId,
        realm_id: messageParams.realmId,
        created_at: messageParams.createdAt,
        updated_at: messageParams.updatedAt,
      },
    }
    const exchange = rabbitClient.createExchange(messageParams.exchange)
    await exchange.initialized
    exchange.send(new Message(messageBody), messageParams.routingKey)
  }

  @given(
    'I wait until the account member with id {string} and store_id {string} appears in the DB, with {string} equal to {string}',
  )
  public async waitForAccountMemberInDB(
    id: string,
    store_id: string,
    time_to_update: string,
    time: string,
  ) {
    const date = new Date(Date.parse(time))
    const query =
      'SELECT * from account_members where id=$1 and store_id=$2 and ' + time_to_update + '=$3'

    let tables
    let retryCount = 0
    for (
      tables = null;
      (tables == null || tables.rows.length == 0) && retryCount < 100;
      tables = await postgresClient.query(query, [id, store_id, date]), retryCount++
    ) {
      await sleep(50)
    }
    expect(tables, `Account member with id ${id} did not appear in DB`).to.not.be.null
    expect(tables.rows.length).to.not.be.equal(
      0,
      `Account member with id ${id} did not appear in DB`,
    )
  }

  @given('There is no account member with id {string} and created_at {string} in the DB')
  public async checkNoAccountMembersWithCreatedTimeInDB(id: string, time: string) {
    const date = new Date(Date.parse(time))
    const query = 'SELECT * from account_members where id=$1 and created_at=$2'
    const tables = await postgresClient.query(query, [id, date])

    expect(tables.rowCount, `Account member with id ${id} DID appear in DB`).to.be.equal(0)
  }

  @given('There is no account member with id {string} in the DB')
  public async checkNoAccountInDB(id: string) {
    const query = 'SELECT * from account_members where id=$1'
    const tables = await postgresClient.query(query, [id])
    expect(tables.rowCount, `Account member with id ${id} DID appear in DB`).to.be.equal(0)
  }
}
