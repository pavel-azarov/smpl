import {SelfLink} from '../common/http-data-structures'

export interface CreateAuthRealmMockStepData {
  realmId: string
  status?: string
  detail?: string
  title?: string
}

export interface GetUserAuthenticationInfoMockStepData {
  realmId: string
  userId: string
  name?: string
  email?: string
}

export interface MultipleUserAuthenticationInfoMockStepData {
  realmId: string
  namePrefix: string
  emailSuffix: string
  userIds: string
}

export interface AuthRealmResponseBody {
  data: AuthRealmData
  links: SelfLink
}

interface AuthRealmData {
  id: string
  name: string
  type: string
  meta?: ItemMeta
}

interface ItemMeta {
  created_at: string
  updated_at: string
}
