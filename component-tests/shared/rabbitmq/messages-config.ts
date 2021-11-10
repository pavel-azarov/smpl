export const MESSAGES_HOST = process.env['RABBIT_HOSTS'] || 'amqp://localhost:5673/'
export const MESSAGES_HOST_EAS = process.env['RABBIT_HOSTS_EAS'] || 'amqp://localhost:5674/'
export const MESSAGES_EXCHANGE = process.env['TEST_RABBIT_EXCHANGE'] || 'account-management.topic'
export const MESSAGES_EAS_EXCHANGE = 'user-authentication-info.topic'
export const MESSAGES_QUEUE_NAME =
  process.env['TEST_RABBIT_CONSUME_QUEUE'] || 'account-management.event'
export const MESSAGES_ROUTING_KEY = 'account.*'
export const MESSAGES_AM_QUEUE_NAME = 'am_component_tests_queue'
export const MESSAGES_ACCOUNT_ROUTING_KEY = 'account'
