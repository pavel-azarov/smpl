import {TestContext} from '../shared/common/test-context'
import {binding, given, when} from 'cucumber-tsflow/dist'
import {postgresClient, testQueues} from '../shared/hooks/setup'
import {TableDefinition} from 'cucumber'
import {CloudEventWrapper, OutboxStepData} from '../shared/mocks/outbox-data-structures'
import {v4 as uuidv4} from 'uuid'
import {rabbitClient, rabbitClientEAS} from '../shared/rabbitmq/client'
import * as MessagesConf from '../shared/rabbitmq/messages-config'
import {expect} from 'chai'
import * as MessagesDataStruct from '../shared/rabbitmq/messages-structures'
import {SERVICE_HOST} from '../shared/config'

@binding([TestContext])
export class CommonSteps {
  constructor(protected testContext: TestContext) {}

  @given('I insert into the outbox table the following data')
  public async insertOutbox(table: TableDefinition<OutboxStepData>) {
    const data = table.hashes()[0]
    const query =
      'insert into outbox (id, store_id, type, event, created_at) values ($1, $2, $3, $4, now())'
    await postgresClient.query(query, [uuidv4(), data.store_id, data.type, data.event])
  }

  @given('I insert into the outbox table the following data {int} times')
  public async insertOutboxNTimes(count: number, table: TableDefinition<OutboxStepData>) {
    const data = table.hashes()[0]
    const query =
      'insert into outbox (id, store_id, type, event, created_at) values ($1, $2, $3, $4, now())'
    for (let step = 0; step < count; step++) {
      // Runs 5 times, with values of step 0 through 4.
      await postgresClient.query(query, [uuidv4(), data.store_id, data.type, data.event])
    }
  }

  @given('There is exactly {int} outbox elements in the DB')
  public async checkNoAccountMembersWithCreatedTimeInDB(count: number) {
    const query = 'SELECT * from outbox'
    const tables = await postgresClient.query(query)

    expect(tables.rowCount, `Size of outbox table is not what's expected`).to.be.equal(count)
  }

  @given('I create a queue to listen to the AM events with routing key {string}')
  public async configureQueueRoutingKey(routingKey: string) {
    await CommonSteps.configureQueueRoutingKeyWiremock(routingKey)
    await CommonSteps.configureQueueRoutingKeyEAS(routingKey)
  }

  private static async configureQueueRoutingKeyWiremock(routingKey: string) {
    const exchange = rabbitClient.createExchange(MessagesConf.MESSAGES_EXCHANGE)
    let queue = await rabbitClient.createQueue(
      exchange,
      MessagesConf.MESSAGES_AM_QUEUE_NAME,
      routingKey,
    )
    await queue.delete()
    queue = await rabbitClient.createQueue(
      exchange,
      MessagesConf.MESSAGES_AM_QUEUE_NAME,
      routingKey,
    )
    testQueues.push(queue)
  }

  private static async configureQueueRoutingKeyEAS(routingKey: string) {
    const exchange = rabbitClientEAS.createExchange(MessagesConf.MESSAGES_EXCHANGE)
    let queue = await rabbitClientEAS.createQueue(
      exchange,
      'eas_' + MessagesConf.MESSAGES_AM_QUEUE_NAME,
      routingKey,
    )
    await queue.delete()
    queue = await rabbitClientEAS.createQueue(
      exchange,
      'eas_' + MessagesConf.MESSAGES_AM_QUEUE_NAME,
      routingKey,
    )
    testQueues.push(queue)
  }

  @when(
    'I see exactly {int} emitted CloudEvent with routing key {string}, type {string} with the following parameters',
  )
  public async assertCustomersMessage(
    count: number,
    routingKey: string,
    type: string,
    table: TableDefinition<MessagesDataStruct.AccountsEvent>,
  ) {
    const expectedData = table.hashes()[0]

    if (expectedData['account_id']) {
      if (expectedData['account_id'].startsWith('previous-')) {
        expectedData['account_id'] = this.testContext.getAccountIdList()[
          parseInt(expectedData['account_id'].split('-')[1]) - 1
        ]
      } else {
        if (expectedData['account_id'] === '<last>') {
          expectedData['account_id'] = this.testContext.getLatestAccountId()
        } else if (expectedData['account_id'] === '<previous>') {
          expectedData['account_id'] = this.testContext.getPreviousAccountId()
        }
      }
    }

    const queueWiremock = this.testContext.getTestQueueByName(MessagesConf.MESSAGES_AM_QUEUE_NAME)
    if (queueWiremock === undefined) {
      expect.fail(`Queue ${MessagesConf.MESSAGES_AM_QUEUE_NAME} was not found`)
    }
    const queueEAS = this.testContext.getTestQueueByName(
      'eas_' + MessagesConf.MESSAGES_AM_QUEUE_NAME,
    )
    if (queueEAS === undefined) {
      expect.fail(`Queue eas_${MessagesConf.MESSAGES_AM_QUEUE_NAME} was not found`)
    }

    const messages = (await rabbitClient.getMessagesByRoutingKey(
      queueWiremock,
      queueEAS,
      routingKey,
      150,
      count,
    )) as CloudEventWrapper[]

    expect(messages.length).to.be.equal(
      count,
      `Unexpected amount of emitted messages with routing key ${routingKey}`,
    )
    const message = messages[0]
    this.testContext.addMessage(messages[0])

    expect(message.type).to.be.equal(type)
    expect(message.id).to.be.not.empty
    expect(message.specversion).to.be.equal('1.0')
    expect(message.source).to.include(SERVICE_HOST)
    expect(message.data).to.be.not.empty
    let messageData
    try {
      messageData = JSON.parse(message.data)
    } catch (ex) {
      messageData = message.data
    }

    expect(messageData).to.deep.include(expectedData)
    expect(message.time).to.be.not.empty
  }

  @when('I see no emitted CloudEvent with routing key {string}')
  public async assertNoMessage(routingKey: string) {
    const queue1 = this.testContext.getTestQueueByName(MessagesConf.MESSAGES_AM_QUEUE_NAME)
    if (queue1 === undefined) {
      expect.fail(`Queue ${MessagesConf.MESSAGES_AM_QUEUE_NAME} was not found`)
    }
    const queue2 = this.testContext.getTestQueueByName('eas_' + MessagesConf.MESSAGES_AM_QUEUE_NAME)
    if (queue2 === undefined) {
      expect.fail(`Queue eas_${MessagesConf.MESSAGES_AM_QUEUE_NAME} was not found`)
    }
    const messages = (await rabbitClient.getMessagesByRoutingKey(
      queue1,
      queue2,
      routingKey,
      1,
      0,
    )) as CloudEventWrapper[]
    expect(messages.length).to.be.equal(
      0,
      `Unexpected amount of emitted messages with routing key ${routingKey}`,
    )
  }
}
