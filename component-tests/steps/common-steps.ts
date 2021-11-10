import {TestContext} from '../shared/common/test-context'
import {binding, given} from 'cucumber-tsflow/dist'
import {postgresClient} from '../shared/hooks/setup'
import {resetMocks} from '../shared/mocks/api'
import {sleep} from '../shared/common/helpers'

@binding([TestContext])
export class CommonSteps {
  constructor(protected testContext: TestContext) {}

  @given('I reset DB and mocks')
  public async resetDb() {
    const tables = await postgresClient.query(
      'SELECT tablename FROM pg_tables WHERE schemaname = current_schema()',
    )
    for (const table of tables.rows) {
      if (table.tablename !== 'schema_migrations' && table.tablename !== 'migrate_advisory_lock') {
        await postgresClient.query('TRUNCATE ' + table.tablename + ' CASCADE;')
      }
    }

    await resetMocks()
  }

  @given('I reset mocks')
  public async resetMocks() {
    await resetMocks()
  }

  @given('I sleep for {int} milliseconds')
  public async sleep(ms: number) {
    await sleep(ms)
  }
}
