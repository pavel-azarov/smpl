export const SERVICE_HOST =
  process.env['COMPONENT_TESTS_ACCOUNT_MANAGEMENT_HOST'] || 'http://localhost:8087'
export const POSTGRES_DSN: string =
  process.env['POSTGRES_DSN_ACCOUNT_MANAGEMENT'] ||
  'postgresql://postgres:password@localhost:5432/postgres?sslmode=disable'
export const COMPONENT_TESTS_WIREMOCK_URL =
  process.env['COMPONENT_TESTS_WIREMOCK_URL'] || 'http://localhost:8381'
export const EXTERNAL_AUTHENTICATION_SVC_URL =
  process.env['EXTERNAL_AUTHENTICATION_SVC_URL'] || 'http://host.docker.internal:8381'
export const COMPONENT_TEST_TIMEOUT = process.env['COMPONENT_TEST_TIMEOUT'] || 15
export const LOG_LEVEL = 'info'
