import {binding, when} from 'cucumber-tsflow'
import {expect} from 'chai'
import {TestContext} from '../shared/common/test-context'
import {ErrorResponse, Error} from '../shared/errors/http-data-structures'
import {TableDefinition} from 'cucumber'
import {PageLinks} from '../shared/common/http-data-structures'
import {api} from '../shared/common/api'
import * as AccountData from '../shared/account/http-data-structures'

@binding([TestContext])
export class ResponseAssertionSteps {
  constructor(protected testContext: TestContext) {}

  @when('The following links are populated')
  public checkLinkFieldsNotNull(table: TableDefinition<PageLinks>) {
    const actualLinks = this.testContext.ensureLatestResponse().data.links
    const expectedLinks = Object.entries(table.hashes()[0])

    expectedLinks.map(([k, v]: [string, string]) => {
      if (v == 'X') {
        expect(actualLinks[k], 'key "' + k + '"').to.be.not.null
      } else if (!v || v.length === 0) {
        expect(actualLinks[k], 'key "' + k + '"').to.be.not.null
      } else {
        throw new Error(
          'Unexpected ' +
            v +
            ' for ' +
            k +
            ' detected in table definition, only X or empty is supported.',
        )
      }
    })
  }

  @when('I follow the {string} page link with following parameters')
  public async followNextLink(
    linkName: string,
    table: TableDefinition<AccountData.AccountReadParams>,
  ) {
    const data = table.hashes()[0]
    const links = this.testContext.ensureLatestResponse().data.links
    let linkUrl
    switch (linkName) {
      case 'first':
        linkUrl = links.first
        break
      case 'last':
        linkUrl = links.last
        break
      case 'next':
        linkUrl = links.next
        break
      case 'prev':
        linkUrl = links.prev
        break
      case 'self':
        linkUrl = links.self
        break
      default:
        expect.fail('Specified link name is not supported')
    }
    const response = await api.get(linkUrl, data['store_id'], data['X-Moltin-Settings-page_length'])
    this.testContext.addResponse(response)
  }

  @when('I see empty list in the returned data')
  public assertEmptyData() {
    const entries = this.testContext.ensureLatestResponse().data.data
    expect(entries.length).to.equal(0, 'Unexpected amount of entries on a page')
    expect(entries).to.not.be.equal(undefined, "'data' field is missing in the response")
  }
}
