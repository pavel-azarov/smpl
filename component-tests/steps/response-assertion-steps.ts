import {binding, when} from 'cucumber-tsflow'
import {expect} from 'chai'
import {TestContext} from '../shared/common/test-context'
import {ErrorResponse, Error, ResponseMetaPage} from '../shared/errors/http-data-structures'
import {TableDefinition} from 'cucumber'
import {StepUtils} from '../shared/common/step_utils'

@binding([TestContext])
export class ResponseAssertionSteps {
  constructor(protected testContext: TestContext) {}

  private _stepUtils = new StepUtils(this.testContext)

  @when('I see {int} status code in response')
  public assertResponseCode(code: number) {
    this._stepUtils.assertResponse(code)
  }

  @when('I see error response with the following parameters')
  public assertErrorWithoutCodes(table: TableDefinition<Error>) {
    const expectedErrorParameters = table.hashes()[0]
    const response = this.testContext.ensureLatestResponse().data as ErrorResponse
    const error = response.errors[0]
    if (error === undefined) {
      expect.fail(`The latest response doesn't contain error data: ${response}`)
    }
    expect(error).to.be.deep.equal(
      expectedErrorParameters,
      'Error response does not contain expected parameters',
    )
  }

  @when('The page metadata section matches')
  public checkMetaPage(table: TableDefinition<ResponseMetaPage>) {
    const actualPage = this.testContext.ensureLatestResponse()?.data.meta.page

    // Unfortunately we cannot use table.rowsHash() directly because it returns
    // an object containing strings and deep equal rightly would not work
    const expectedPage = table.raw().reduce((obj: {[k: string]: number}, entry: string[]) => {
      obj[entry[0]] = parseInt(entry[1])
      return obj
    }, {})

    expect(actualPage).to.be.deep.equal(expectedPage)
  }

  @when('The metadata result total is {int}')
  public checkMetaResultTotal(total: number) {
    const responseTotal = this.testContext.ensureLatestResponse()?.data.meta.results.total
    expect(parseInt(responseTotal)).to.be.equal(total)
  }
}
