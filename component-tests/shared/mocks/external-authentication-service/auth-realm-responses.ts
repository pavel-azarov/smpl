export interface AuthRealmResponseBody {
  data: AuthRealmData
  links: SelfLinks
}

export interface CreateAuthRealmMockStepData {
  realmId: string
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

interface SelfLinks {
  self: string
}
