import {SelfLink} from '../common/http-data-structures'

export interface AccountStepData {
  'name': string
  'legal_name': string
  'registration_id': string
  'parent_id'?: string
  'name-prefix'?: string
  'legal_name-prefix'?: string
  'registration_id-prefix'?: string
  'type'?: string
  'store_id'?: string
  'id'?: string
  'ancestors'?: string
  'EP-Internal-Account-Id'?: string
}

export interface MassCreateAccountAndAccountMembershipStepData {
  'name': string
  'legal_name': string
  'registration_id': string
  'parent_id'?: string
  'name-prefix'?: string
  'legal_name-prefix'?: string
  'registration_id-prefix'?: string
  'type'?: string
  'store_id'?: string
  'id'?: string
  'account_member_id': string
  'ancestors'?: string
  'EP-Internal-Account-Id'?: string
  'realmId'?: string
  'userId'?: string
}

export interface AccountPartialUpdStepData {
  store_id: string
  property: string
  value: string
  id: string
}

export interface AccountRequestBody {
  data: AccountRequestData
}

export interface AccountRequestData {
  type: string
  name: string
  legal_name: string
  registration_id: string
  parent_id?: string
}

export interface AccountResponseBody {
  data: AccountResponseData
  meta: AccountMeta
  links: SelfLink
}

export interface AccountResponseData {
  id?: string
  type: string
  name: string
  legal_name: string
  registration_id?: string
  meta?: AccountMeta
  relationships?: AccountRel
}

export interface AccountMeta {
  timestamps: {
    created_at: string
    updated_at: string
  }
}

export interface AccountReadParams {
  'store_id'?: string
  'page-limit'?: string
  'page-offset'?: string
  'X-Moltin-Settings-page_length'?: string
  'EP-Internal-Account-Id'?: string
  'ep-internal-search-json'?: string
}

export interface AccountRel {
  ancestors: AccountAncestor[]
  parent: AccountParent
}

export interface AccountAncestor {
  data: {
    id: string
    type: string
  }
}

export interface AccountParent {
  data: {
    id: string
    type: string
  }
}
