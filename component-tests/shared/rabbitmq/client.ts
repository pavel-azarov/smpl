import {sleep} from '../common/helpers'
import {MESSAGES_HOST, MESSAGES_HOST_EAS} from './messages-config'
import * as Amqp from 'amqp-ts'
import {Exchange, Queue} from 'amqp-ts'

const DEFAULT_TIMEOUT_SEC = 4
const DEFAULT_EXCHANGE_TYPE = 'topic'
const RETRY_MESSAGE_TIMEOUT_MSEC = 100
const RETRY_COUNT = 5

class Client {
  private _connection

  constructor(connection: Amqp.Connection) {
    this._connection = connection
  }

  closeConnection = async (): Promise<void> => {
    if (this._connection.isConnected) {
      await this._connection.close()
    }
  }

  createQueue = async (
    exchange: Exchange,
    queueName: string,
    routingKey: string,
  ): Promise<Amqp.Queue> => {
    try {
      const queue = this._connection.declareQueue(queueName)
      await queue.bind(exchange, routingKey)
      return queue
    } catch (e) {
      await this.closeConnection()
      throw new Error('Failed to create a queue ' + queueName + ' : ' + e)
    }
  }

  getAllMessages = async function (queue: Queue): Promise<object> {
    const messages: object[] = []
    let retryCount = 0

    try {
      while (retryCount < RETRY_COUNT) {
        await sleep(RETRY_MESSAGE_TIMEOUT_MSEC)
        retryCount++
        await queue.recover()
        await queue.activateConsumer(
          async function (message) {
            const msg: any = {}
            msg.deliveryTag = message.fields.deliveryTag
            msg.message = JSON.parse(message.getContent())
            message.ack(true)
            messages.push(msg)

            console.log(
              `message sequence number ${message.fields.deliveryTag} - received from routingKey : ${
                message.fields.routingKey
              }
                  ${message.getContent()} \n`,
            )
          },
          {noAck: false},
        )
        await queue.stopConsumer()
      }
    } catch (e) {
      await Promise.reject('something went wrong.....' + e)
    }

    if (messages.length === 0) {
      await Promise.reject(
        `Unable to find any message after waiting for ${RETRY_MESSAGE_TIMEOUT_MSEC} seconds`,
      )
    }

    return messages
  }

  getMessagesByRoutingKey = async function (
    queueWiremock: Queue,
    queueEAS: Queue,
    routingKey: string,
    retryCountOverride = RETRY_COUNT,
    expectedCount = 1,
  ): Promise<object[]> {
    const messages: object[] = []
    let messageFound = 0
    let retryCount = 0

    try {
      while (messageFound < expectedCount && retryCount < retryCountOverride) {
        await sleep(RETRY_MESSAGE_TIMEOUT_MSEC)
        retryCount++
        console.log(
          `waiting for message with routing key ${routingKey}.....: ${
            retryCount * RETRY_MESSAGE_TIMEOUT_MSEC
          } milliseconds`,
        )

        for (const queue of [queueWiremock, queueEAS]) {
          await queue.recover()
          await queue.activateConsumer(
            async function (message) {
              console.log(`searching for ${routingKey} actual: ${message.fields.routingKey}`)
              if (message.fields.routingKey === routingKey) {
                messageFound++
                message.ack(true)

                messages.push(JSON.parse(message.getContent()))
                console.log(
                  `message received from routingKey : ${message.fields.routingKey}
                  ${message.getContent()} \n`,
                )
              }
            },
            {noAck: false},
          )
          await queue.stopConsumer()
        }
      }
    } catch (e) {
      await Promise.reject(
        `something went wrong while waiting for a message with routing key ${routingKey}: ` + e,
      )
    }
    return messages
  }

  createExchange = (exchangeName: string): Exchange => {
    return this._connection.declareExchange(exchangeName, DEFAULT_EXCHANGE_TYPE)
  }

  publishMessage = async (exchange: Exchange, routingKey: string, msg: string): Promise<void> => {
    try {
      exchange.send(new Amqp.Message(msg), routingKey)
    } catch (e) {
      console.log('Error.... ' + e)
    }
  }

  deleteQueue = async (queue: Amqp.Queue): Promise<void> => {
    try {
      console.log(`deleting queue: ${queue._name}`)
      await queue.delete()
    } catch (e) {
      throw new Error(`something went wrong while trying to delete queue ${queue.name}` + e)
    }
  }

  waitForConnection = async (): Promise<void> => {
    console.log(
      `Waiting up to ${DEFAULT_TIMEOUT_SEC} seconds RabbitMQ connection (${MESSAGES_HOST}) to be established\n`,
    )
    for (let i = 0; i < DEFAULT_TIMEOUT_SEC; i++) {
      if (this._connection.isConnected) {
        console.log('RabbitMQ connection was successfully established \n\n')
        return
      }
      await sleep(1000)
    }
    throw new Error(
      `RabbitMQ connection was not established within ${DEFAULT_TIMEOUT_SEC} seconds\n\n`,
    )
  }
}

export const rabbitClient = new Client(new Amqp.Connection(MESSAGES_HOST))
export const rabbitClientEAS = new Client(new Amqp.Connection(MESSAGES_HOST_EAS))
