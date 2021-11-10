export interface AccountsEvent {
  id: string
}

export interface EasUserAuthInfoEvent {
  specversion: string
  id: string
  source: string
  type: string
  exchange: string
  routingKey: string
  name: string
  email: string
  userAuthInfoId: string
  storeId: string
  realmId: string
  createdAt: string
  updatedAt: string
  event_time: string
}
