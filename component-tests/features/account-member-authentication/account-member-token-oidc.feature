Feature: Authenticate an account member via External Authentication Service(EAS) and generate a token

  Background:
    Given I reset DB and mocks
    And I mock EAS to return a successful Authentication Realm creation response with the following parameters
      | realmId                              |
      | 00000000-0000-4000-8000-000000000001 |


  Scenario Outline: Authenticate account member in EAS and generate a token - there are multiple memberships for an account member
    When I mock EAS to return a successful user-authentication-info response with the following parameters
      | realmId    | userId    |
      | <REALM_ID> | <USER_ID> |
    When I mock EAS endpoint "/oidc-idp/token/stores/<STORE_ID>/authentication-realms/<REALM_ID>" for method "POST" to return status 201 and an id token which encodes the following data
      | iss                                                               | aud                | sub       | exp           | iat   | name   | email   |
      | [EAS_ENDPOINT]/stores/<STORE_ID>/authentication-realms/<REALM_ID> | account-management | <USER_ID> | [IN_ONE_HOUR] | [NOW] | <NAME> | <EMAIL> |
    And I create an account with the following parameters
      | name   | legal_name   | registration_id           | type    | store_id   |
      | <NAME> | <LEGAL_NAME> | <REGISTRATION_ID_PARENT>1 | account | <STORE_ID> |
    Then I see 201 status code in response
    When I create an account membership with the following parameters
      | account_id | store_id   | account_member_id |
      | <last>     | <STORE_ID> | <USER_ID>         |
    Then I see 201 status code in response
    And I create an account with the following parameters
      | name    | legal_name   | registration_id           | type    | store_id   |
      | <NAME2> | <LEGAL_NAME> | <REGISTRATION_ID_PARENT>3 | account | <STORE_ID> |
    Then I see 201 status code in response
    When I create an account membership with the following parameters
      | account_id | store_id   | account_member_id |
      | <last>     | <STORE_ID> | <USER_ID>         |
    Then I see 201 status code in response
    And I generate a token providing the following parameters
      | authorizationCode | type                                    | storeId    | oauth_redirect_uri    | authentication_mechanism | oauth_code_verifier                         |
      | authorizationCode | account_management_authentication_token | <STORE_ID> | http://localhost:4444 | oidc                     | 0123456789012345678901234567890123456789012 |
    Then I see 201 status code in response
    And I see the following non-expired account token in the response
      | accountName | accountId | type                                    | storeId    | sub       | scopes |
      | <NAME2>     | last      | account_management_authentication_token | <STORE_ID> | <USER_ID> | last   |
    And I see the following non-expired account token in the response
      | accountName | accountId | type                                    | storeId    | sub       | scopes   |
      | <NAME>      | previous  | account_management_authentication_token | <STORE_ID> | <USER_ID> | previous |

    Examples:
      | LEGAL_NAME                 | REGISTRATION_ID_PARENT               | USER_ID                              | STORE_ID                             | REALM_ID                             | NAME                           | NAME2                           | EMAIL                        |
      | accountCreateTestLegalName | 00000000-0000-1000-8000-222222222221 | 20354d7a-e4fe-47af-8ff6-187bca92f3f9 | 00000000-0000-4000-8000-000000000000 | 00000000-0000-4000-8000-000000000001 | idpAccountTokenTestAccountName | idpAccountTokenTestAccountName2 | idpaccounttokentest@test.com |

  Scenario Outline: Authenticate account member in EAS and generate a token - there is no account membership
    And I create a queue to listen to the AM events with routing key "account-member.event.created"
    Given I mock EAS endpoint "/oidc-idp/token/stores/<STORE_ID>/authentication-realms/<REALM_ID>" for method "POST" to return status 201 and an id token which encodes the following data
      | iss                                                               | aud                | sub       | exp           | iat   | name   | email   |
      | [EAS_ENDPOINT]/stores/<STORE_ID>/authentication-realms/<REALM_ID> | account-management | <USER_ID> | [IN_ONE_HOUR] | [NOW] | <NAME> | <EMAIL> |
    And I mock EAS to return a successful user-authentication-info response with the following parameters
      | realmId    | userId    | name   | email   |
      | <REALM_ID> | <USER_ID> | <NAME> | <EMAIL> |
    When I generate a token providing the following parameters
      | authorizationCode | type                                    | storeId    | oauth_redirect_uri    | authentication_mechanism | oauth_code_verifier                         |
      | authorizationCode | account_management_authentication_token | <STORE_ID> | http://localhost:4444 | oidc                     | 0123456789012345678901234567890123456789012 |
    And I see exactly 1 emitted CloudEvent with routing key "account-member.event.created", type "account-member.event.created" with the following parameters
      | name   | email   |
      | <NAME> | <EMAIL> |
    Then I see 201 status code in response
    And I see empty list in the returned data

    Examples:
      | USER_ID                              | STORE_ID                             | REALM_ID                             | NAME                           | EMAIL                        |
      | 20354d7a-e4fe-47af-8ff6-187bca92f3f9 | 00000000-0000-4000-8000-000000000000 | 00000000-0000-4000-8000-000000000001 | idpAccountTokenTestAccountName | idpaccounttokentest@test.com |

  Scenario Outline: Authenticate account member in EAS and generate a token - account member is created and updated with the data from id token
    Given I mock EAS endpoint "/oidc-idp/token/stores/<STORE_ID>/authentication-realms/<REALM_ID>" for method "POST" to return status 201 and an id token which encodes the following data
      | iss                                                               | aud                | sub       | exp           | iat   | name   | email   |
      | [EAS_ENDPOINT]/stores/<STORE_ID>/authentication-realms/<REALM_ID> | account-management | <USER_ID> | [IN_ONE_HOUR] | [NOW] | <NAME> | <EMAIL> |
    And I mock EAS to return a successful user-authentication-info response with the following parameters
      | realmId    | userId    | name   | email   |
      | <REALM_ID> | <USER_ID> | <NAME> | <EMAIL> |
    When I generate a token providing the following parameters
      | authorizationCode | type                                    | storeId    | oauth_redirect_uri    | authentication_mechanism | oauth_code_verifier                         |
      | authorizationCode | account_management_authentication_token | <STORE_ID> | http://localhost:4444 | oidc                     | 0123456789012345678901234567890123456789012 |
    Then I see 201 status code in response
    When I read account members list with following parameters
      | store_id   | page-limit | page-offset |
      | <STORE_ID> | 3          | 0           |
    Then I see 200 status code in response
    And I see an account member in the returned list with following parameters
      | name   | email   | id        |
      | <NAME> | <EMAIL> | <USER_ID> |
    When I mock EAS endpoint "/oidc-idp/token/stores/<STORE_ID>/authentication-realms/<REALM_ID>" for method "POST" to return status 201 and an id token which encodes the following data
      | iss                                                               | aud                | sub       | exp           | iat   | name           | email           |
      | [EAS_ENDPOINT]/stores/<STORE_ID>/authentication-realms/<REALM_ID> | account-management | <USER_ID> | [IN_ONE_HOUR] | [NOW] | <UPDATED_NAME> | <UPDATED_EMAIL> |
    And I generate a token providing the following parameters
      | authorizationCode | type                                    | storeId    | oauth_redirect_uri    | authentication_mechanism | oauth_code_verifier                         |
      | authorizationCode | account_management_authentication_token | <STORE_ID> | http://localhost:4444 | oidc                     | 0123456789012345678901234567890123456789012 |
    Then I see 201 status code in response
    When I read account members list with following parameters
      | store_id   | page-limit | page-offset |
      | <STORE_ID> | 3          | 0           |
    Then I see 200 status code in response
    And I see an account member in the returned list with following parameters
      | name           | email           | id        |
      | <UPDATED_NAME> | <UPDATED_EMAIL> | <USER_ID> |
    And I do not see an account member in the returned list with following parameters
      | name   | email   |
      | <NAME> | <EMAIL> |

    Examples:
      | USER_ID                              | STORE_ID                             | REALM_ID                             | NAME                           | EMAIL                        | UPDATED_NAME                          | UPDATED_EMAIL                       |
      | 20354d7a-e4fe-47af-8ff6-187bca92f3f9 | 00000000-0000-4000-8000-000000000000 | 00000000-0000-4000-8000-000000000001 | idpAccountTokenTestAccountName | idpaccounttokentest@test.com | idpAccountTokenTestAccountUpdatedName | updatedidpaccounttokentest@test.com |

  Scenario Outline: EAS returns error when trying to generate account token
    When I mock EAS endpoint "/oidc-idp/token/stores/<STORE_ID>/authentication-realms/<REALM_ID>" for method "POST" to return an error with status 403
    And I generate a token providing the following parameters
      | authorizationCode | type                                    | storeId    | oauth_redirect_uri    | authentication_mechanism | oauth_code_verifier                         |
      | authorizationCode | account_management_authentication_token | <STORE_ID> | http://localhost:4444 | oidc                     | 0123456789012345678901234567890123456789012 |
    Then I see 500 status code in response
    And I see error response with the following parameters
      | status | detail                                      | title                 |
      | 500    | there was a problem processing your request | Internal Server Error |
    Examples:
      | STORE_ID                             | REALM_ID                             |
      | 00000000-0000-4000-8000-000000000000 | 00000000-0000-4000-8000-000000000001 |

  Scenario Outline: Required params are not supplied
    And I generate a token providing the following parameters
      | authorizationCode | type   | storeId    | oauth_redirect_uri | authentication_mechanism | oauth_code_verifier |
      | <AUTH_CODE>       | <TYPE> | <STORE_ID> | <REDIRECT>         | <AUTH_MECHANISM>         | <VERIFIER>          |
    Then I see <ERR_CODE> status code in response
    And I see error response with the following parameters
      | status     | detail    | title   |
      | <ERR_CODE> | <MESSAGE> | <TITLE> |
    Examples:
      | AUTH_CODE         | REDIRECT              | VERIFIER                                    | STORE_ID                             | AUTH_MECHANISM | TYPE                                    | ERR_CODE | MESSAGE                                                                         | TITLE                |
      | authorizationCode |                       | 0123456789012345678901234567890123456789012 | 00000000-0000-4000-8000-000000000000 | oidc           | account_management_authentication_token | 422      | Validation failed: field 'OAuthRedirectURI' on the 'cannot_be_empty' tag.       | Unprocessable Entity |
      | authorizationCode | http://localhost:4444 |                                             | 00000000-0000-4000-8000-000000000000 | oidc           | account_management_authentication_token | 422      | Validation failed: field 'OAuthCodeVerifier' on the 'cannot_be_empty' tag.      | Unprocessable Entity |
      | (not set)         | http://localhost:4444 | 0123456789012345678901234567890123456789012 | 00000000-0000-4000-8000-000000000000 | oidc           | account_management_authentication_token | 422      | Validation failed: field 'OAuthAuthorizationCode' on the 'cannot_be_empty' tag. | Unprocessable Entity |
      | authorizationCode | (not set)             | 0123456789012345678901234567890123456789012 | 00000000-0000-4000-8000-000000000000 | oidc           | account_management_authentication_token | 422      | Validation failed: field 'OAuthRedirectURI' on the 'cannot_be_empty' tag.       | Unprocessable Entity |
      | authorizationCode | http://localhost:4444 | (not set)                                   | 00000000-0000-4000-8000-000000000000 | oidc           | account_management_authentication_token | 422      | Validation failed: field 'OAuthCodeVerifier' on the 'cannot_be_empty' tag.      | Unprocessable Entity |
      | authorizationCode | http://localhost:4444 | 0123456789012345678901234567890123456789012 |                                      | oidc           | account_management_authentication_token | 400      | Validation failed: field 'XMoltinAuthStore' on the 'required' tag.              | Bad Request          |
      | authorizationCode | http://localhost:4444 | 0123456789012345678901234567890123456789012 | (not set)                            | oidc           | account_management_authentication_token | 400      | Validation failed: field 'XMoltinAuthStore' on the 'uuid' tag.                  | Bad Request          |
      | authorizationCode | http://localhost:4444 | 0123456789012345678901234567890123456789012 | 00000000-0000-4000-8000-000000000000 |                | account_management_authentication_token | 422      | Validation failed: field 'AuthenticationMechanism' on the 'is_invalid' tag.     | Unprocessable Entity |
      | authorizationCode | http://localhost:4444 | 0123456789012345678901234567890123456789012 | 00000000-0000-4000-8000-000000000000 | (not set)      | account_management_authentication_token | 422      | Validation failed: field 'AuthenticationMechanism' on the 'is_invalid' tag.     | Unprocessable Entity |
      | authorizationCode | http://localhost:4444 | 0123456789012345678901234567890123456789012 | 00000000-0000-4000-8000-000000000000 | oidc           |                                         | 422      | Validation failed: field 'Type' on the 'account_token_type' tag.                | Unprocessable Entity |
      | authorizationCode | http://localhost:4444 | 0123456789012345678901234567890123456789012 | 00000000-0000-4000-8000-000000000000 | oidc           | (not set)                               | 422      | Validation failed: field 'Type' on the 'account_token_type' tag.                | Unprocessable Entity |

  Scenario Outline: EAS rejects the token request
    When I mock EAS endpoint "/oidc-idp/token/stores/<STORE_ID>/authentication-realms/<REALM_ID>" for method "POST" to return an invalid grant error with status 400
    And I generate a token providing the following parameters
      | authorizationCode | type                                    | storeId    | oauth_redirect_uri    | authentication_mechanism | oauth_code_verifier                         |
      | authorizationCode | account_management_authentication_token | <STORE_ID> | http://localhost:4444 | oidc                     | 0123456789012345678901234567890123456789012 |
    Then I see 400 status code in response
    And I see error response with the following parameters
      | status | detail                | title       |
      | 400    | authentication failed | Bad Request |
    Examples:
      | STORE_ID                             | REALM_ID                             |
      | 00000000-0000-4000-8000-000000000000 | 00000000-0000-4000-8000-000000000001 |

  Scenario Outline: The service has improper client_id configured for authentication_mechanism and user receives 500 error
    When I mock EAS endpoint "/oidc-idp/token/stores/<STORE_ID>/authentication-realms/<REALM_ID>" for method "POST" to return an invalid client error with status 400
    And I generate a token providing the following parameters
      | authorizationCode | type                                    | storeId    | oauth_redirect_uri    | authentication_mechanism | oauth_code_verifier                         |
      | authorizationCode | account_management_authentication_token | <STORE_ID> | http://localhost:4444 | oidc                     | 0123456789012345678901234567890123456789012 |
    Then I see 500 status code in response
    And I see error response with the following parameters
      | status | detail                                      | title                 |
      | 500    | there was a problem processing your request | Internal Server Error |
    Examples:
      | STORE_ID                             | REALM_ID                             |
      | 00000000-0000-4000-8000-000000000000 | 00000000-0000-4000-8000-000000000001 |
