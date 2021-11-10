import {rabbitClient, rabbitClientEAS} from './client'
import {AfterAll, Before, BeforeAll} from 'cucumber'
import {testQueues} from '../hooks/setup'

Before(async function () {
  if (testQueues !== undefined) {
    for (const queue of testQueues) {
      await rabbitClient.deleteQueue(queue)
      await rabbitClientEAS.deleteQueue(queue)
    }
    testQueues.length = 0
  }
})

BeforeAll(async () => {
  await rabbitClient.waitForConnection()
  await rabbitClientEAS.waitForConnection()
})

AfterAll(async () => {
  await rabbitClient.closeConnection()
  await rabbitClientEAS.closeConnection()
})
