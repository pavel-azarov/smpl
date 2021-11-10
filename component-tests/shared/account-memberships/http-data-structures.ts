export interface AccountMembershipStepData {
  'store_id': string
  'account_id': string
  'account_member_id'?: string
  'account_membership_id'?: string
  'type'?: string
  'EP-Internal-Account-Id'?: string
  'ep-internal-search-json'?: string
  'page-limit'?: string
  'page-offset'?: string
}

export interface AccountMembershipRequestBody {
  data: AccountMembershipRequestData
}

export interface AccountMembershipRequestData {
  type: string
  account_member_id: string
}

export interface AccountMembershipAssertionParams {
  account_member_id: string
}

export interface AccountMembershipListAssertionParams {
  account_id: string
  account_member_id: string
}
