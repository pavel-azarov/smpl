Feature: Generate a token via External Authentication Service(EAS) with the password grant type

  Background:
    Given I reset DB and mocks
    And I mock EAS to return a successful Authentication Realm creation response with the following parameters
      | realmId                              |
      | 00000000-0000-4000-8000-000000000001 |

  Scenario Outline: Authenticate account member in EAS and generate a token - happy path
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
    And I generate a token providing the following parameters
      | type                                    | storeId    | authentication_mechanism | username  | password   | password_profile_id                  |
      | account_management_authentication_token | <STORE_ID> | password                 | <USER_ID> | <PASSWORD> | 00000000-0000-0000-0000-000000000000 |
    Then I see 201 status code in response
    And I see the following non-expired account token in the response
      | accountName | accountId | type                                    | storeId    | sub       | scopes |
      | <NAME>      | last      | account_management_authentication_token | <STORE_ID> | <USER_ID> | last   |

    Examples:
      | PASSWORD |  | LEGAL_NAME                 | REGISTRATION_ID_PARENT               | USER_ID                              | STORE_ID                             | REALM_ID                             | NAME                           | EMAIL                        |
      | pa$$word |  | accountCreateTestLegalName | 00000000-0000-1000-8000-222222222221 | 20354d7a-e4fe-47af-8ff6-187bca92f3f9 | 00000000-0000-4000-8000-000000000000 | 00000000-0000-4000-8000-000000000001 | idpAccountTokenTestAccountName | idpaccounttokentest@test.com |

  Scenario Outline: Authenticate account member in EAS and generate a token - there is no account membership
    Given I mock EAS endpoint "/oidc-idp/token/stores/<STORE_ID>/authentication-realms/<REALM_ID>" for method "POST" to return status 201 and an id token which encodes the following data
      | iss                                                               | aud                | sub       | exp           | iat   | name   | email   |
      | [EAS_ENDPOINT]/stores/<STORE_ID>/authentication-realms/<REALM_ID> | account-management | <USER_ID> | [IN_ONE_HOUR] | [NOW] | <NAME> | <EMAIL> |
    And I mock EAS to return a successful user-authentication-info response with the following parameters
      | realmId    | userId    |
      | <REALM_ID> | <USER_ID> |
    When I generate a token providing the following parameters
      | type                                    | storeId    | authentication_mechanism | username  | password   | password_profile_id                  |
      | account_management_authentication_token | <STORE_ID> | password                 | <USER_ID> | <PASSWORD> | 00000000-0000-0000-0000-000000000000 |
    Then I see 201 status code in response
    And I see empty list in the returned data

    Examples:
      | PASSWORD | USER_ID                              | STORE_ID                             | REALM_ID                             | NAME                           | EMAIL                        |
      | pa$$word | 20354d7a-e4fe-47af-8ff6-187bca92f3f9 | 00000000-0000-4000-8000-000000000000 | 00000000-0000-4000-8000-000000000001 | idpAccountTokenTestAccountName | idpaccounttokentest@test.com |

  Scenario Outline: Authenticate account member in EAS and generate a token - account member is created and updated with the data from id token
    Given I mock EAS endpoint "/oidc-idp/token/stores/<STORE_ID>/authentication-realms/<REALM_ID>" for method "POST" to return status 201 and an id token which encodes the following data
      | iss                                                               | aud                | sub       | exp           | iat   | name   | email   |
      | [EAS_ENDPOINT]/stores/<STORE_ID>/authentication-realms/<REALM_ID> | account-management | <USER_ID> | [IN_ONE_HOUR] | [NOW] | <NAME> | <EMAIL> |
    And I mock EAS to return a successful user-authentication-info response with the following parameters
      | realmId    | userId    | name   | email   |
      | <REALM_ID> | <USER_ID> | <NAME> | <EMAIL> |
    When I generate a token providing the following parameters
      | type                                    | storeId    | authentication_mechanism | username  | password   | password_profile_id                  |
      | account_management_authentication_token | <STORE_ID> | password                 | <USER_ID> | <PASSWORD> | 00000000-0000-0000-0000-000000000000 |
    Then I see 201 status code in response
    When I read account members list with following parameters
      | store_id   | page-limit | page-offset |
      | <STORE_ID> | 3          | 0           |
    Then I see 200 status code in response
    And I see an account member in the returned list with following parameters
      | name   | email   | id |
      | <NAME> | <EMAIL> | <USER_ID>|
    When I mock EAS endpoint "/oidc-idp/token/stores/<STORE_ID>/authentication-realms/<REALM_ID>" for method "POST" to return status 201 and an id token which encodes the following data
      | iss                                                               | aud                | sub       | exp           | iat   | name           | email           |
      | [EAS_ENDPOINT]/stores/<STORE_ID>/authentication-realms/<REALM_ID> | account-management | <USER_ID> | [IN_ONE_HOUR] | [NOW] | <UPDATED_NAME> | <UPDATED_EMAIL> |
    And I generate a token providing the following parameters
      | type                                    | storeId    | authentication_mechanism | username   | password   | password_profile_id                  |
      | account_management_authentication_token | <STORE_ID> | <AUTH_MECHANISM>         | <USERNAME> | <PASSWORD> | 00000000-0000-0000-0000-000000000000 |
    Then I see 201 status code in response
    When I read account members list with following parameters
      | store_id   | page-limit | page-offset |
      | <STORE_ID> | 3          | 0           |
    Then I see 200 status code in response
    And I see an account member in the returned list with following parameters
      | name           | email           | id |
      | <UPDATED_NAME> | <UPDATED_EMAIL> | <USER_ID>|
    And I do not see an account member in the returned list with following parameters
      | name   | email   |
      | <NAME> | <EMAIL> |

    Examples:
      | USERNAME                             | PASSWORD | AUTH_MECHANISM | USER_ID                              | STORE_ID                             | REALM_ID                             | NAME                           | EMAIL                        | UPDATED_NAME                          | UPDATED_EMAIL                       |
      | 20354d7a-e4fe-47af-8ff6-187bca92f3f9 | pa$$word | password       | 20354d7a-e4fe-47af-8ff6-187bca92f3f9 | 00000000-0000-4000-8000-000000000000 | 00000000-0000-4000-8000-000000000001 | idpAccountTokenTestAccountName | idpaccounttokentest@test.com | idpAccountTokenTestAccountUpdatedName | updatedidpaccounttokentest@test.com |

  Scenario Outline: EAS returns error when trying to generate account token
    When I mock EAS endpoint "/oidc-idp/token/stores/<STORE_ID>/authentication-realms/<REALM_ID>" for method "POST" to return an error with status 403
    And I generate a token providing the following parameters
      | type                                    | storeId    | authentication_mechanism | username   | password   | password_profile_id                  |
      | account_management_authentication_token | <STORE_ID> | <AUTH_MECHANISM>         | <USERNAME> | <PASSWORD> | 00000000-0000-0000-0000-000000000000 |
    Then I see 500 status code in response
    And I see error response with the following parameters
      | status | detail                                      | title                 |
      | 500    | there was a problem processing your request | Internal Server Error |
    Examples:
      | USERNAME                             | PASSWORD | AUTH_MECHANISM | STORE_ID                             | REALM_ID                             |
      | 20354d7a-e4fe-47af-8ff6-187bca92f3f9 | pa$$word | password       | 00000000-0000-4000-8000-000000000000 | 00000000-0000-4000-8000-000000000001 |

  Scenario Outline: Required params are not supplied or have wrong format
    And I generate a token providing the following parameters
      | type                                    | storeId    | authentication_mechanism | username   | password   | password_profile_id |
      | account_management_authentication_token | <STORE_ID> | <AUTH_MECHANISM>         | <USERNAME> | <PASSWORD> | <PASSW_PROFILE_ID>  |
    Then I see <ERR_CODE> status code in response
    And I see error response with the following parameters
      | status     | detail    | title   |
      | <ERR_CODE> | <MESSAGE> | <TITLE> |
    Examples:
      | PASSW_PROFILE_ID                     | USERNAME    | PASSWORD    | STORE_ID                             | AUTH_MECHANISM | ERR_CODE | MESSAGE                                                                                                          | TITLE                |
      | 00000000-0000-0000-0000-000000000000 | (not set)   | (not set)   | 00000000-0000-4000-8000-000000000000 | password       | 422      | Validation failed: field 'Username' on the 'cannot_be_empty' tag; field 'Password' on the 'cannot_be_empty' tag. | Unprocessable Entity |
      | 00000000-0000-0000-0000-000000000000 | hello_world | (not set)   | 00000000-0000-4000-8000-000000000000 | password       | 422      | Validation failed: field 'Password' on the 'cannot_be_empty' tag.                                                | Unprocessable Entity |
      | 00000000-0000-0000-0000-000000000000 | (not set)   | hello_world | 00000000-0000-4000-8000-000000000000 | password       | 422      | Validation failed: field 'Username' on the 'cannot_be_empty' tag.                                                | Unprocessable Entity |
      | (not set)                            | hello_world | hello_world | 00000000-0000-4000-8000-000000000000 | password       | 422      | Validation failed: field 'PasswordProfileID' on the 'cannot_be_empty' tag.                                       | Unprocessable Entity |
      | hello_world                          | hello_world | hello_world | 00000000-0000-4000-8000-000000000000 | password       | 422      | Validation failed: field 'PasswordProfileID' on the 'must_be_uuid' tag.                                          | Unprocessable Entity |

  Scenario Outline: EAS rejects the token request
    When I mock EAS endpoint "/oidc-idp/token/stores/<STORE_ID>/authentication-realms/<REALM_ID>" for method "POST" to return an invalid grant error with status 400
    And I generate a token providing the following parameters
      | type                                    | storeId    | authentication_mechanism | username   | password   | password_profile_id                  |
      | account_management_authentication_token | <STORE_ID> | <AUTH_MECHANISM>         | <USERNAME> | <PASSWORD> | 00000000-0000-0000-0000-000000000000 |
    Then I see 400 status code in response
    And I see error response with the following parameters
      | status | detail                | title       |
      | 400    | authentication failed | Bad Request |
    Examples:
      | USERNAME                             | PASSWORD | AUTH_MECHANISM | STORE_ID                             | REALM_ID                             |
      | 20354d7a-e4fe-47af-8ff6-187bca92f3f9 | pa$$word | password       | 00000000-0000-4000-8000-000000000000 | 00000000-0000-4000-8000-000000000001 |

  Scenario Outline: The service has improper client_id configured and user receives 500 error
    When I mock EAS endpoint "/oidc-idp/token/stores/<STORE_ID>/authentication-realms/<REALM_ID>" for method "POST" to return an invalid client error with status 400
    And I generate a token providing the following parameters
      | authorizationCode    | type                                    | storeId    | authentication_mechanism | username   | password   | password_profile_id                  |
      | <AUTHORIZATION_CODE> | account_management_authentication_token | <STORE_ID> | <AUTH_MECHANISM>         | <USERNAME> | <PASSWORD> | 00000000-0000-0000-0000-000000000000 |
    Then I see 500 status code in response
    And I see error response with the following parameters
      | status | detail                                      | title                 |
      | 500    | there was a problem processing your request | Internal Server Error |
    Examples:
      | USERNAME                             | PASSWORD | AUTH_MECHANISM | STORE_ID                             | REALM_ID                             |
      | 20354d7a-e4fe-47af-8ff6-187bca92f3f9 | pa$$word | password       | 00000000-0000-4000-8000-000000000000 | 00000000-0000-4000-8000-000000000001 |

  Scenario Outline: Authenticate account member in EAS and generate a token - validate ancestors in Account Member Token
    When I mock EAS to return a successful user-authentication-info response with the following parameters
      | realmId    | userId    |
      | <REALM_ID> | <USER_ID> |
    When I mock EAS endpoint "/oidc-idp/token/stores/<STORE_ID>/authentication-realms/<REALM_ID>" for method "POST" to return status 201 and an id token which encodes the following data
      | iss                                                               | aud                | sub       | exp           | iat   | name   | email   |
      | [EAS_ENDPOINT]/stores/<STORE_ID>/authentication-realms/<REALM_ID> | account-management | <USER_ID> | [IN_ONE_HOUR] | [NOW] | <NAME> | <EMAIL> |
    And I create an account with the following parameters
      | name             | legal_name             | registration_id                    | type    | store_id   |
      | <NAME>-ancestor3 | <LEGAL_NAME>-ancestor3 | <REGISTRATION_ID_PARENT>-ancestor3 | account | <STORE_ID> |
    And I create an account with the following parameters
      | name             | legal_name             | registration_id                    | type    | store_id   | parent_id |
      | <NAME>-ancestor2 | <LEGAL_NAME>-ancestor2 | <REGISTRATION_ID_PARENT>-ancestor2 | account | <STORE_ID> | last      |
    And I create an account with the following parameters
      | name             | legal_name             | registration_id                    | type    | store_id   | parent_id |
      | <NAME>-ancestor1 | <LEGAL_NAME>-ancestor1 | <REGISTRATION_ID_PARENT>-ancestor1 | account | <STORE_ID> | last      |
    And I create an account with the following parameters
      | name   | legal_name   | registration_id          | type    | store_id   | parent_id |
      | <NAME> | <LEGAL_NAME> | <REGISTRATION_ID_PARENT> | account | <STORE_ID> | last      |
    Then I see 201 status code in response
    When I create an account membership with the following parameters
      | account_id | store_id   | account_member_id |
      | <last>     | <STORE_ID> | <USER_ID>         |
    Then I see 201 status code in response
    And I generate a token providing the following parameters
      | type                                    | storeId    | authentication_mechanism | username  | password   | password_profile_id                  |
      | account_management_authentication_token | <STORE_ID> | password                 | <USER_ID> | <PASSWORD> | 00000000-0000-0000-0000-000000000000 |
    Then I see 201 status code in response
    And I see all three ancestors in the 'ancestors' claim of the token in the right order

    Examples:
      | PASSWORD |  | LEGAL_NAME                 | REGISTRATION_ID_PARENT               | USER_ID                              | STORE_ID                             | REALM_ID                             | NAME                           | EMAIL                        |
      | pa$$word |  | accountCreateTestLegalName | 00000000-0000-1000-8000-222222222221 | 20354d7a-e4fe-47af-8ff6-187bca92f3f9 | 00000000-0000-4000-8000-000000000000 | 00000000-0000-4000-8000-000000000001 | idpAccountTokenTestAccountName | idpaccounttokentest@test.com |

  Scenario Outline: Authenticate account member in EAS and generate a token - validate empty ancestors in Account Member Token
    When I mock EAS to return a successful user-authentication-info response with the following parameters
      | realmId    | userId    |
      | <REALM_ID> | <USER_ID> |
    When I mock EAS endpoint "/oidc-idp/token/stores/<STORE_ID>/authentication-realms/<REALM_ID>" for method "POST" to return status 201 and an id token which encodes the following data
      | iss                                                               | aud                | sub       | exp           | iat   | name   | email   |
      | [EAS_ENDPOINT]/stores/<STORE_ID>/authentication-realms/<REALM_ID> | account-management | <USER_ID> | [IN_ONE_HOUR] | [NOW] | <NAME> | <EMAIL> |
    And I create an account with the following parameters
      | name             | legal_name             | registration_id                    | type    | store_id   |
      | <NAME>-ancestor3 | <LEGAL_NAME>-ancestor3 | <REGISTRATION_ID_PARENT>-ancestor3 | account | <STORE_ID> |
    Then I see 201 status code in response
    When I create an account membership with the following parameters
      | account_id | store_id   | account_member_id |
      | <last>     | <STORE_ID> | <USER_ID>         |
    Then I see 201 status code in response
    And I generate a token providing the following parameters
      | type                                    | storeId    | authentication_mechanism | username  | password   | password_profile_id                  |
      | account_management_authentication_token | <STORE_ID> | password                 | <USER_ID> | <PASSWORD> | 00000000-0000-0000-0000-000000000000 |
    Then I see 201 status code in response
    And I see the empty 'ancestors' claim in the token

    Examples:
      | PASSWORD |  | LEGAL_NAME                 | REGISTRATION_ID_PARENT               | USER_ID                              | STORE_ID                             | REALM_ID                             | NAME                           | EMAIL                        |
      | pa$$word |  | accountCreateTestLegalName | 00000000-0000-1000-8000-222222222221 | 20354d7a-e4fe-47af-8ff6-187bca92f3f9 | 00000000-0000-4000-8000-000000000000 | 00000000-0000-4000-8000-000000000001 | idpAccountTokenTestAccountName | idpaccounttokentest@test.com |
