import {SelfLink} from '../common/http-data-structures'

export interface AccountAuthSettingsResponse {
  data: AccountSettingsData
}

export interface AccountAuthSettingsRequestParams {
  storeIdHeader: string
  storeIdPathParameter: string
  type: string
  url: string
}

export interface AccountAuthSettingsAssertionParams {
  id: string
  type: string
  realmId: string
  realmSelfLink: string
  realmType: string
  clientId: string
}

interface AccountSettingsData {
  id: string
  type: string
  relationships: AuthRealmList
  meta: AccountAuthSettingsMeta
}

interface AccountAuthSettingsMeta {
  client_id: string
}

interface AuthRealmList {
  authentication_realm: AuthRealm
}

interface AuthRealm {
  data: {
    type: string
    id: string
    links: SelfLink
  }
}
