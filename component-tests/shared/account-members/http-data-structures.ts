export interface AccountMemberAssertionParams {
  id: string
  type: string
  name: string
  email: string
}
export interface AccountMemberStepData {
  'store_id': string
  'id': string
  'EP-Internal-Account-Id'?: string
}

export interface AccountMemberReadParams {
  'store_id'?: string
  'page-limit'?: string
  'page-offset'?: string
  'X-Moltin-Settings-page_length'?: string
  'EP-Internal-Account-Id'?: string
  'ep-internal-search-json'?: string
}

export interface UnassignedAccountMemberReadParams {
  'store_id'?: string
  'account_id'?: string
  'page-limit'?: string
  'page-offset'?: string
  'X-Moltin-Settings-page_length'?: string
}
export interface AccountMemberData {
  name_prefix: string
  email_suffix: string
  user_ids: string
}
