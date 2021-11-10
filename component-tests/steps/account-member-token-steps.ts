import {binding, when} from 'cucumber-tsflow/dist'
import {TestContext} from '../shared/common/test-context'
import {TableDefinition} from 'cucumber'
import {
  AccountMemberToken,
  TokenResponseData,
  AccountMemberTokenResponseParameters,
  AccountMemberTokenStepData,
  TokenEasRequestBody,
  TokenEasStepData,
} from '../shared/account-member-token/http-data-structures'
import {api} from '../shared/common/api'
import {
  ACCOUNT_MEMBER_TOKEN_PATH,
  ACCOUNT_MEMBER_TOKEN_TYPE,
} from '../shared/account-member-token/acc-member-token-config'
import jwt from 'jsonwebtoken'
import {expect} from 'chai'
import uuidParse from 'uuid-parse'

const TWENTY_FOUR_HOURS_PLUS_MINUTE = 1441
const ONE_HOUR = 60
const TOKEN_LIFETIME = '24'

@binding([TestContext])
export class AccountMemberTokenSteps {
  constructor(protected testContext: TestContext) {}

  @when('I authenticate as account member passing the following parameters')
  public async authenticateAccountMember(table: TableDefinition<AccountMemberTokenStepData>) {
    const stepData = table.hashes()[0]
    const requestBody: TokenEasRequestBody = {
      data: {
        authentication_mechanism: stepData.authenticationMechanism,
        type: stepData.type,
      },
    }
    stepData.accountId =
      stepData.accountId === 'last' ? this.testContext.getLatestAccountId() : stepData.accountId
    stepData.pageListLimitSettings =
      stepData.pageListLimitSettings === undefined ? '19' : stepData.pageListLimitSettings
    const headers = {
      'EP-Internal-Account-Id': stepData.accountId,
      'X-Moltin-Settings-page_length': stepData.pageListLimitSettings,
    }
    if (stepData.accountMemberId !== undefined) {
      headers['EP-Internal-Account-Member-Id'] = stepData.accountMemberId
    }
    this.testContext.addResponse(
      await api.post(ACCOUNT_MEMBER_TOKEN_PATH, requestBody, stepData.storeId, headers),
    )
  }

  @when(
    'I authenticate as account member passing the following parameters but omitting property {string}',
  )
  public async authenticateAccountMemberOmitProperty(
    omittedProperty: string,
    table: TableDefinition<AccountMemberTokenStepData>,
  ) {
    const stepData = table.hashes()[0]
    let requestBody
    stepData.accountId =
      stepData.accountId === 'last' ? this.testContext.getLatestAccountId() : stepData.accountId
    stepData.pageListLimitSettings = '19'
    const headers = {
      'EP-Internal-Account-Member-Id': stepData.accountMemberId,
      'EP-Internal-Account-Id': stepData.accountId,
      'X-Moltin-Settings-page_length': stepData.pageListLimitSettings,
    }
    switch (omittedProperty) {
      case 'authentication_mechanism':
        requestBody = {
          data: {
            type: stepData.type,
          },
        }
        break
      case 'type':
        requestBody = {
          data: {
            authentication_mechanism: stepData.authenticationMechanism,
          },
        }
        break
      default:
        expect.fail('Unsupported property value')
    }
    this.testContext.addResponse(
      await api.post(ACCOUNT_MEMBER_TOKEN_PATH, requestBody, stepData.storeId, headers),
    )
  }

  @when('I see the following non-expired account token in the response')
  public async assertAccountMemberAuthentication(
    table: TableDefinition<AccountMemberTokenResponseParameters>,
  ) {
    const tokenExp = new Date(0)
    const bodyExp = new Date(0)
    const comparisonDate = new Date()
    const expectedParams = table.hashes()[0]
    if (expectedParams.accountId === 'last') {
      expectedParams.accountId = this.testContext.getLatestAccountId()
    } else if (expectedParams.accountId === 'previous') {
      expectedParams.accountId = this.testContext.getPreviousAccountId()
    }
    if (expectedParams.scopes === 'last') {
      expectedParams.scopes = this.testContext.getLatestAccountId()
    } else if (expectedParams.scopes === 'previous') {
      expectedParams.scopes = this.testContext.getPreviousAccountId()
    }
    const accountTokenObjectList: TokenResponseData[] = this.testContext.ensureLatestResponse().data
      .data
    let accountTokenObject: TokenResponseData
    for (const entry of accountTokenObjectList) {
      if (entry.account_name === expectedParams.accountName) {
        accountTokenObject = entry
        break
      }
    }
    const token = jwt.decode(accountTokenObject.token) as AccountMemberToken
    tokenExp.setUTCSeconds(token.exp)

    //Asserting token
    comparisonDate.setMinutes(comparisonDate.getMinutes() + TWENTY_FOUR_HOURS_PLUS_MINUTE)
    expect(
      tokenExp,
      `Token exp date should be in ${TOKEN_LIFETIME} hours from a token generation moment`,
    ).to.be.lessThan(comparisonDate)
    comparisonDate.setMinutes(comparisonDate.getMinutes() - ONE_HOUR)
    expect(
      tokenExp,
      `Token exp date should be in ${TOKEN_LIFETIME} hours from a token generation moment`,
    ).to.be.greaterThan(comparisonDate)
    expect(token, 'Unexpected iat value in generated token')
      .to.have.property('iat')
      .that.is.a('number')
    const expectedToken: AccountMemberToken = {
      exp: token.exp,
      iat: token.iat,
      sub: expectedParams.sub,
      scope: expectedParams.scopes,
      store_id: expectedParams.storeId,
    }
    expect(token).to.deep.include(expectedToken, 'Unexpected generated token')

    //Asserting Account Member token object
    const expires = Date.parse(accountTokenObject.expires)
    expect(Math.round(expires / 1000)).to.be.equal(
      token.exp,
      'Token exp claim value should have the same date as an Account Member token object expires field',
    )
    const expectedAccountTokenObject: TokenResponseData = {
      account_name: expectedParams.accountName,
      account_id: expectedParams.accountId,
      type: expectedParams.type,
      token: accountTokenObject.token,
      expires: accountTokenObject.expires,
    }
    expect(accountTokenObject).to.deep.include(
      expectedAccountTokenObject,
      'Unexpected Account Member token object',
    )
  }

  @when("I see all three ancestors in the 'ancestors' claim of the token in the right order")
  public async assertAncestors() {
    const accountTokenObjectList: TokenResponseData[] = this.testContext.ensureLatestResponse().data
      .data
    let accountTokenObject: TokenResponseData
    for (const entry of accountTokenObjectList) {
      accountTokenObject = entry
    }
    const token = jwt.decode(accountTokenObject.token) as AccountMemberToken

    const a1 = AccountMemberTokenSteps.arrayToBase64String(
      uuidParse.parse(this.testContext.getAccountIdList()[0]),
    )
    const a2 = AccountMemberTokenSteps.arrayToBase64String(
      uuidParse.parse(this.testContext.getAccountIdList()[1]),
    )
    const a3 = AccountMemberTokenSteps.arrayToBase64String(
      uuidParse.parse(this.testContext.getAccountIdList()[2]),
    )

    expect(token.ancestors).to.be.equal(a1 + ',' + a2 + ',' + a3)
  }
  @when("I see the empty 'ancestors' claim in the token")
  public async assertEmptyAncestors() {
    const accountTokenObjectList: TokenResponseData[] = this.testContext.ensureLatestResponse().data
      .data
    let accountTokenObject: TokenResponseData
    for (const entry of accountTokenObjectList) {
      accountTokenObject = entry
    }
    const token = jwt.decode(accountTokenObject.token) as AccountMemberToken

    expect(token.ancestors).to.be.equal('')
  }

  static arrayToBase64String(a) {
    return unescape(Buffer.from(a).toString('base64')).split('=').join('')
  }

  @when('I generate a token providing the following parameters')
  public async generateTokenEas(table: TableDefinition<TokenEasStepData>) {
    const data = table.hashes()[0]
    const requestData: TokenEasRequestBody = {
      data: {
        oauth_authorization_code:
          data.authorizationCode == '(not set)' ? null : data.authorizationCode,
        oauth_code_verifier:
          data.oauth_code_verifier == '(not set)' ? null : data.oauth_code_verifier,
        type: data.type == '(not set)' ? null : data.type,
        oauth_redirect_uri: data.oauth_redirect_uri == '(not set)' ? null : data.oauth_redirect_uri,
        authentication_mechanism:
          data.authentication_mechanism == '(not set)' ? null : data.authentication_mechanism,
        username: data.username == '(not set)' ? null : data.username,
        password: data.password == '(not set)' ? null : data.password,
        password_profile_id:
          data.password_profile_id == '(not set)' ? null : data.password_profile_id,
      },
    }

    const response = await api.post(
      ACCOUNT_MEMBER_TOKEN_PATH,
      requestData,
      data.storeId == '(not set)' ? null : data.storeId,
    )
    if (response.status >= 200 && response.status <= 300) {
      this.testContext.addAccountIdFromLastCreationOrOidcLogin(response.data.data.account_id)
    }
    this.testContext.addResponse(response)
  }

  @when(
    'I see a token with an entity type "account_management_authentication_token" in the response',
  )
  public assertTokenResponseType() {
    const responseData = this.testContext.ensureLatestResponse().data.data[0] as TokenResponseData
    expect(responseData.type).to.be.equal(
      ACCOUNT_MEMBER_TOKEN_TYPE,
      'Unexpected type in a token response',
    )
  }

  @when('I see token is not empty in the token response')
  public assertTokenResponseIdToken() {
    const responseData = this.testContext.ensureLatestResponse().data.data[0] as TokenResponseData
    expect(responseData.token, 'Token should not be empty in a token response').to.be.not.empty
  }

  @when('I see account id in the token response belongs to an account from request')
  public assertTokenResponseAccountId() {
    const responseData = this.testContext.ensureLatestResponse().data.data[0] as TokenResponseData
    expect(responseData.account_id).to.be.equal(
      this.testContext.getLatestAccountId(),
      "Account id in the token response doesn't match an account id from request",
    )
  }

  @when(
    'I see account id in the token response belongs to account number {int} created or logged in via oidc',
  )
  public assertTokenResponseAccountIdForNthAccountCreatedOrOidcAuthenticated(index: number) {
    const responseData = this.testContext.ensureLatestResponse().data.data[0] as TokenResponseData
    const accountId = this.testContext.getAccountIdForPreviousCreatedOrOidcLogin(index - 1)
    expect(responseData.account_id).to.be.equal(
      accountId,
      "Account id in the token response doesn't match an account id from request",
    )
  }

  @when('I see account id is not empty in the token response')
  public assertTokenResponseAccountIdNotEmpty() {
    const responseData = this.testContext.ensureLatestResponse().data.data[0] as TokenResponseData
    expect(responseData.account_id, 'Account id in the token response is empty').to.be.not.empty
  }

  @when('I see expiration date in 24 hours in the token response')
  public async assertTokenResponseExpirationDate() {
    const responseData = this.testContext.ensureLatestResponse().data.data[0] as TokenResponseData
    const oneDayLaterDate = new Date()
    oneDayLaterDate.setHours(oneDayLaterDate.getHours() + 25)
    expect(
      new Date(responseData.expires),
      'Expiration date should be in 24 hours from a token generation moment',
    ).to.be.lessThan(oneDayLaterDate)
  }
}
