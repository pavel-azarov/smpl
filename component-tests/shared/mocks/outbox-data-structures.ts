export interface OutboxStepData {
  store_id: string
  type: string
  event: string
}

export interface CloudEventWrapper {
  specversion: string
  id: string
  source: string
  type: string
  data: CloudEventData | any
  time: string
}

export interface CloudEventData {
  name: string
  email: string
  id: string
  store_id: string
  realm_id: string
  created_at: string
  updated_at: string
}
