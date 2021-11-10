export interface AccountMemberTokenStepData {
  storeId?: string
  authenticationMechanism?: string
  accountMemberId?: string
  accountId?: string
  type?: string
  pageListLimitSettings?: string
}

export interface AccountMemberTokenResponseParameters {
  accountName: string
  accountId: string
  type: string
  storeId: string
  sub: string
  scopes: string
}

export interface TokenResponseData {
  type: string
  id?: string
  account_id: string
  account_name: string
  token: string
  expires: string
}

export interface AccountMemberToken {
  exp: number
  iat: number
  sub: string
  scope: string
  store_id: string
  ancestors?: string
}

export interface TokenEasStepData {
  authorizationCode?: string
  type: string
  storeId: string
  oauth_code_verifier?: string
  oauth_redirect_uri?: string
  authentication_mechanism: string
  username?: string
  password?: string
  password_profile_id?: string
}

export interface TokenEasRequestBody {
  data: TokenEasRequestData
}

interface TokenEasRequestData {
  type: string
  oauth_authorization_code?: string
  oauth_code_verifier?: string
  oauth_redirect_uri?: string
  authentication_mechanism: string
  username?: string
  password?: string
  password_profile_id?: string
}
