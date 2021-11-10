Feature: Account Management Events

  Background:
    Given I reset DB and mocks

  Scenario Outline: Verify that the second "User Auth Info Created" message with the same User Auth Info id is consumed
    When I mock EAS to return a successful Authentication Realm creation response with the following parameters
      | realmId    |
      | <REALM_ID> |
    And I read Account Authentication Settings passing the following parameters
      | storeIdHeader |
      | <STORE_ID>    |
    And I send a message with the following parameters
      | event_time        | specversion | id   | source                | type                                   | exchange                       | routingKey                             | userAuthInfoId      | name   | email   | storeId    | realmId    | createdAt    | updatedAt    |
      | <EVENT_TIME_2019> | 1.0         | <ID> | http://localhost:8080 | user-authentication-info.event.created | user-authentication-info.topic | user-authentication-info.event.created | <USER_AUTH_INFO_ID> | <NAME> | <EMAIL> | <STORE_ID> | <REALM_ID> | <CREATED_AT> | <UPDATED_AT> |
    And I wait until the account member with id "<USER_AUTH_INFO_ID>" and store_id "<STORE_ID>" appears in the DB, with "created_at" equal to "<EVENT_TIME_2019>"
    And I read Account Member with id "<USER_AUTH_INFO_ID>" and store id "<STORE_ID>"
    Then I see 200 status code in response
    And I see the following parameters in Account Member response
      | id               | name   | email   |
      | <USER_AUTH_INFO_ID> | <NAME> | <EMAIL> |
    When I send a message with the following parameters
      | event_time        | specversion | id   | source                | type                                   | exchange                       | routingKey                             | userAuthInfoId      | name           | email           | storeId    | realmId    | createdAt    | updatedAt    |
      | <EVENT_TIME_2020> | 1.0         | <ID> | http://localhost:8080 | user-authentication-info.event.created | user-authentication-info.topic | user-authentication-info.event.created | <USER_AUTH_INFO_ID> | <NAME_UPDATED> | <EMAIL_UPDATED> | <STORE_ID> | <REALM_ID> | <CREATED_AT> | <UPDATED_AT> |
    And I wait until the account member with id "<USER_AUTH_INFO_ID>" and store_id "<STORE_ID>" appears in the DB, with "created_at" equal to "<EVENT_TIME_2020>"
    And I read Account Member with id "<USER_AUTH_INFO_ID>" and store id "<STORE_ID>"
    Then I see 200 status code in response
    And I see the following parameters in Account Member response
      | id               | name           | email           |
      | <USER_AUTH_INFO_ID> | <NAME_UPDATED> | <EMAIL_UPDATED> |

    Examples:
      | EVENT_TIME_2019          | EVENT_TIME_2020          | USER_AUTH_INFO_ID                       | NAME         | EMAIL                 | EMAIL_UPDATED                 | NAME_UPDATED         | ID                                   | STORE_ID                             | REALM_ID                             | CREATED_AT               | UPDATED_AT               |
      | 2019-11-11T08:08:18.888Z | 2020-04-05T01:01:01.555Z | 00000000-0000-1000-8000-111111111122 | createdEvent | createdEvent@test.com | createdEvent_updated@test.com | createdEvent_updated | 00000000-0000-1000-8000-111111111111 | 00000000-0000-1000-8000-000000000000 | 00000000-0000-1000-8000-222222222222 | 2018-07-06T08:23:18.683Z | 2018-07-06T08:23:18.683Z |


  Scenario Outline: Verify that when a user authenticates with AM before AM receives the event, the user can both login, and we update the user data with the event data when we receive the message
    Given I mock EAS endpoint "/oidc-idp/token/stores/<STORE_ID>/authentication-realms/<REALM_ID>" for method "POST" to return status 201 and an id token which encodes the following data
      | iss                                                               | aud                | sub       | exp           | iat   | name   | email   |
      | [EAS_ENDPOINT]/stores/<STORE_ID>/authentication-realms/<REALM_ID> | account-management | <USER_ID> | [IN_ONE_HOUR] | [NOW] | <NAME> | <EMAIL> |
    And I mock EAS to return a successful user-authentication-info response with the following parameters
      | realmId    | userId    | name   | email   |
      | <REALM_ID> | <USER_ID> | <NAME> | <EMAIL> |
    And I mock EAS to return a successful Authentication Realm creation response with the following parameters
      | realmId    |
      | <REALM_ID> |
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
    When I send a message with the following parameters
      | event_time   | specversion | id   | source                | type                                   | exchange                       | routingKey                             | userAuthInfoId | name           | email           | storeId    | realmId    | createdAt    | updatedAt    |
      | <EVENT_TIME> | 1.0         | <ID> | http://localhost:8080 | user-authentication-info.event.created | user-authentication-info.topic | user-authentication-info.event.created | <USER_ID>      | <UPDATED_NAME> | <UPDATED_EMAIL> | <STORE_ID> | <REALM_ID> | <CREATED_AT> | <UPDATED_AT> |
    And I wait until the account member with id "<USER_ID>" and store_id "<STORE_ID>" appears in the DB, with "created_at" equal to "<EVENT_TIME>"
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
      | EVENT_TIME               | USER_ID                              | STORE_ID                             | REALM_ID                             | NAME                           | EMAIL                        | UPDATED_NAME                          | UPDATED_EMAIL                       | CREATED_AT               | UPDATED_AT               | ID                                   |
      | 2021-04-05T08:23:18.683Z | 20354d7a-e4fe-47af-8ff6-187bca92f3f9 | 00000000-0000-4000-8000-000000000000 | 00000000-0000-4000-8000-000000000001 | idpAccountTokenTestAccountName | idpaccounttokentest@test.com | idpAccountTokenTestAccountUpdatedName | updatedidpaccounttokentest@test.com | 2018-07-06T08:23:18.683Z | 2018-07-06T08:23:18.683Z | 00000000-0000-1000-8000-111111111111 |

  Scenario Outline: Verify that no account member is created via message when the realm ID of account member in the message does not match the realm ID in the account authentication settings for the store.
    And I mock EAS to return a successful Authentication Realm creation response with the following parameters
      | realmId    |
      | <REALM_ID> |
    When I send a message with the following parameters
      | event_time   | specversion | id   | source                | type                                   | exchange                       | routingKey                             | userAuthInfoId | name           | email           | storeId    | realmId              | createdAt    | updatedAt    |
      | <EVENT_TIME> | 1.0         | <ID> | http://localhost:8080 | user-authentication-info.event.created | user-authentication-info.topic | user-authentication-info.event.created | <USER_ID>      | <UPDATED_NAME> | <UPDATED_EMAIL> | <STORE_ID> | <DIFFERENT_REALM_ID> | <CREATED_AT> | <UPDATED_AT> |
    And I sleep for 200 milliseconds
    When I read account members list with following parameters
      | store_id   | page-limit | page-offset |
      | <STORE_ID> | 10         | 0           |
    Then I see 200 status code in response
    And I see 0 account members in the returned data
    And There is no account member with id "<USER_ID>" in the DB

    Examples:
      | EVENT_TIME               | USER_ID                              | STORE_ID                             | REALM_ID                             | DIFFERENT_REALM_ID                   | UPDATED_NAME                          | UPDATED_EMAIL                       | CREATED_AT               | UPDATED_AT               | ID                                   |
      | 2021-04-05T08:23:18.683Z | 20354d7a-e4fe-47af-8ff6-187bca92f3f9 | 00000000-0000-4000-8000-000000000000 | 00000000-0000-4000-8000-000000000001 | 00000000-0000-4000-8000-000000000002 | idpAccountTokenTestAccountUpdatedName | updatedidpaccounttokentest@test.com | 2018-07-06T08:23:18.683Z | 2018-07-06T08:23:18.683Z | 00000000-0000-1000-8000-111111111111 |

  Scenario Outline: User Auth Info Updated event - happy path, two consecutive messages with the same User Auth Info ID are successfully consumed
    When I mock EAS to return a successful Authentication Realm creation response with the following parameters
      | realmId    |
      | <REALM_ID> |
    And I mock EAS to return a successful user-authentication-info response with the following parameters
      | realmId    | userId              |
      | <REALM_ID> | <USER_AUTH_INFO_ID> |
    And I read Account Member with id "<USER_AUTH_INFO_ID>" and store id "<STORE_ID>"
    Then I see 200 status code in response
    And I send a message with the following parameters
      | event_time        | specversion | id   | source                | type                                   | name   | exchange                       | userAuthInfoId   | routingKey                             | email   | storeId    | realmId    | createdAt    | updatedAt    |
      | <EVENT_TIME_2019> | 1.0         | <ID> | http://localhost:8080 | user-authentication-info.event.updated | <NAME> | user-authentication-info.topic | <USER_AUTH_INFO_ID> | user-authentication-info.event.updated | <EMAIL> | <STORE_ID> | <REALM_ID> | <CREATED_AT> | <UPDATED_AT> |
    And I wait until the account member with id "<USER_AUTH_INFO_ID>" and store_id "<STORE_ID>" appears in the DB, with "updated_at" equal to "<EVENT_TIME_2019>"
    And There is no account member with id "<USER_AUTH_INFO_ID>" and created_at "<CREATED_AT>" in the DB
    And There is no account member with id "<USER_AUTH_INFO_ID>" and created_at "<EVENT_TIME_2019>" in the DB
    And I read Account Member with id "<USER_AUTH_INFO_ID>" and store id "<STORE_ID>"
    Then I see 200 status code in response
    And I see the following parameters in Account Member response
      | id               | name   | email   |
      | <USER_AUTH_INFO_ID> | <NAME> | <EMAIL> |
    When I send a message with the following parameters
      | event_time        | specversion | id   | source                | type                                   | exchange                       | userAuthInfoId   | routingKey                             | name           | email           | storeId    | realmId    | createdAt    | updatedAt    |
      | <EVENT_TIME_2020> | 1.0         | <ID> | http://localhost:8080 | user-authentication-info.event.updated | user-authentication-info.topic | <USER_AUTH_INFO_ID> | user-authentication-info.event.updated | <NAME_UPDATED> | <EMAIL_UPDATED> | <STORE_ID> | <REALM_ID> | <CREATED_AT> | <UPDATED_AT> |
    And I wait until the account member with id "<USER_AUTH_INFO_ID>" and store_id "<STORE_ID>" appears in the DB, with "updated_at" equal to "<EVENT_TIME_2020>"
    And There is no account member with id "<USER_AUTH_INFO_ID>" and created_at "<CREATED_AT>" in the DB
    And There is no account member with id "<USER_AUTH_INFO_ID>" and created_at "<EVENT_TIME_2020>" in the DB
    And I read Account Member with id "<USER_AUTH_INFO_ID>" and store id "<STORE_ID>"
    Then I see 200 status code in response
    And I see the following parameters in Account Member response
      | id               | name           | email           |
      | <USER_AUTH_INFO_ID> | <NAME_UPDATED> | <EMAIL_UPDATED> |

    Examples:
      | EVENT_TIME_2020          | EVENT_TIME_2019          | USER_AUTH_INFO_ID                    | NAME         | EMAIL                 | EMAIL_UPDATED                 | NAME_UPDATED         | ID                                   | STORE_ID                             | REALM_ID                             | CREATED_AT               | UPDATED_AT               |
      | 2020-04-05T01:01:01.555Z | 2019-11-11T08:08:18.888Z | 00000000-0000-1000-8000-111111111122 | updatedEvent | updatedEvent@test.com | createdEvent_updated@test.com | createdEvent_updated | 00000000-0000-1000-8000-111111111111 | 00000000-0000-1000-8000-000000000000 | 00000000-0000-1000-8000-222222222222 | 2018-07-06T08:23:18.683Z | 2018-07-06T08:23:18.683Z |

  Scenario Outline: Verify User Auth Info Updated event will create a new account member if it does not exist
    When I mock EAS to return a successful Authentication Realm creation response with the following parameters
      | realmId    |
      | <REALM_ID> |
    And I send a message with the following parameters
      | event_time        | specversion | id   | source                | type                                   | name   | exchange                       | userAuthInfoId      | routingKey                             | email   | storeId    | realmId    | createdAt    | updatedAt    |
      | <EVENT_TIME_2019> | 1.0         | <ID> | http://localhost:8080 | user-authentication-info.event.updated | <NAME> | user-authentication-info.topic | <USER_AUTH_INFO_ID> | user-authentication-info.event.updated | <EMAIL> | <STORE_ID> | <REALM_ID> | <CREATED_AT> | <UPDATED_AT> |
    And I wait until the account member with id "<USER_AUTH_INFO_ID>" and store_id "<STORE_ID>" appears in the DB, with "created_at" equal to "<EVENT_TIME_2019>"
    When I read account members list with following parameters
      | store_id   | page-limit | page-offset |
      | <STORE_ID> | 10         | 0           |
    Then I see 200 status code in response
    And I see 1 account members in the returned data
    Examples:
      | EVENT_TIME_2019          | USER_AUTH_INFO_ID                    | NAME         | ID                                   | EMAIL                 | STORE_ID                             | REALM_ID                             | CREATED_AT               | UPDATED_AT               |
      | 2019-11-11T08:08:18.888Z | 00000000-0000-1000-8000-111111111122 | updatedEvent | 00000000-0000-1000-8000-111111111111 | updatedEvent@test.com | 00000000-0000-1000-8000-000000000000 | 00000000-0000-1000-8000-222222222222 | 2018-07-06T08:23:18.683Z | 2018-07-06T08:23:18.683Z |

  Scenario Outline: Verify that no account member is updated via message when the realm ID of account member in the message does not match the realm ID in the account authentication settings for the store.
    And I mock EAS to return a successful Authentication Realm creation response with the following parameters
      | realmId    |
      | <REALM_ID> |
    When I send a message with the following parameters
      | event_time   | specversion | id   | source                | type                                   | exchange                       | routingKey                            | userAuthInfoId | name           | email           | storeId    | realmId              | createdAt    | updatedAt    |
      | <EVENT_TIME> | 1.0         | <ID> | http://localhost:8080 | user-authentication-info.event.updated | user-authentication-info.topic | user-authentication-info.event.update | <USER_ID>      | <UPDATED_NAME> | <UPDATED_EMAIL> | <STORE_ID> | <DIFFERENT_REALM_ID> | <CREATED_AT> | <UPDATED_AT> |
    And I sleep for 200 milliseconds
    When I read account members list with following parameters
      | store_id   | page-limit | page-offset |
      | <STORE_ID> | 10         | 0           |
    Then I see 200 status code in response
    And I see 0 account members in the returned data
    And There is no account member with id "<USER_ID>" in the DB
    Examples:
      | EVENT_TIME               | USER_ID                              | STORE_ID                             | REALM_ID                             | DIFFERENT_REALM_ID                   | UPDATED_NAME                          | UPDATED_EMAIL                       | CREATED_AT               | UPDATED_AT               | ID                                   |
      | 2021-04-05T08:23:18.683Z | 20354d7a-e4fe-47af-8ff6-187bca92f3f9 | 00000000-0000-4000-8000-000000000000 | 00000000-0000-4000-8000-000000000001 | 00000000-0000-4000-8000-000000000002 | idpAccountTokenTestAccountUpdatedName | updatedidpaccounttokentest@test.com | 2018-07-06T08:23:18.683Z | 2018-07-06T08:23:18.683Z | 00000000-0000-1000-8000-111111111111 |

  Scenario Outline: Verify that no account member is deleted via message when the realm ID of account member in the message does not match the realm ID in the account authentication settings for the store.
    And I mock EAS to return a successful Authentication Realm creation response with the following parameters
      | realmId    |
      | <REALM_ID> |
    And I mock EAS to return a successful user-authentication-info response with the following parameters
      | realmId    | userId              |
      | <REALM_ID> | <USER_AUTH_INFO_ID> |
    And I read Account Member with id "<USER_AUTH_INFO_ID>" and store id "<STORE_ID>"
    Then I see 200 status code in response
    When I send a message with the following parameters
      | event_time   | specversion | id   | source                | type                                   | exchange                       | routingKey                             | userAuthInfoId | name           | email           | storeId    | realmId              | createdAt    | updatedAt    |
      | <EVENT_TIME> | 1.0         | <ID> | http://localhost:8080 | user-authentication-info.event.deleted | user-authentication-info.topic | user-authentication-info.event.deleted | <USER_ID>      | <UPDATED_NAME> | <UPDATED_EMAIL> | <STORE_ID> | <DIFFERENT_REALM_ID> | <CREATED_AT> | <UPDATED_AT> |
    And I sleep for 200 milliseconds
    When I read account members list with following parameters
      | store_id   | page-limit | page-offset |
      | <STORE_ID> | 10         | 0           |
    Then I see 200 status code in response
    And I see 1 account members in the returned data
    Examples:
      | EVENT_TIME               | USER_ID                              | STORE_ID                             | REALM_ID                             | UPDATED_NAME                          | DIFFERENT_REALM_ID                   | CREATED_AT               | UPDATED_EMAIL                       | UPDATED_AT               | ID                                   | USER_AUTH_INFO_ID                    |  |
      | 2021-04-05T08:23:18.683Z | 20354d7a-e4fe-47af-8ff6-187bca92f3f9 | 00000000-0000-4000-8000-000000000000 | 00000000-0000-4000-8000-000000000001 | idpAccountTokenTestAccountUpdatedName | 00000000-0000-4000-8000-000000000002 | 2018-07-06T08:23:18.683Z | updatedidpaccounttokentest@test.com | 2018-07-06T08:23:18.683Z | 00000000-0000-1000-8000-111111111111 | 13000000-0000-1000-8000-111111111111 |  |

  Scenario Outline: Verify that multiple deletes work properly
    And I mock EAS to return a successful Authentication Realm creation response with the following parameters
      | realmId    |
      | <REALM_ID> |
    And I mock EAS to return a successful user-authentication-info response with the following parameters
      | realmId    | userId              |
      | <REALM_ID> | <USER_AUTH_INFO_ID> |
    And I read Account Member with id "<USER_AUTH_INFO_ID>" and store id "<STORE_ID>"
    Then I see 200 status code in response
    When I send a message with the following parameters
      | event_time   | specversion | id   | source                | type                                   | exchange                       | userAuthInfoId      | routingKey                             | name           | email           | storeId    | realmId    | createdAt    | updatedAt    |
      | <EVENT_TIME> | 1.0         | <ID> | http://localhost:8080 | user-authentication-info.event.deleted | user-authentication-info.topic | <USER_AUTH_INFO_ID> | user-authentication-info.event.deleted | <UPDATED_NAME> | <UPDATED_EMAIL> | <STORE_ID> | <REALM_ID> | <CREATED_AT> | <UPDATED_AT> |
    And I sleep for 200 milliseconds
    When I read account members list with following parameters
      | store_id   | page-limit | page-offset |
      | <STORE_ID> | 10         | 0           |
    Then I see 200 status code in response
    And I see 0 account members in the returned data
    When I send a message with the following parameters
      | event_time   | specversion | id   | source                | type                                   | exchange                       | userAuthInfoId      | routingKey                             | name           | email           | storeId    | realmId    | createdAt    | updatedAt    |
      | <EVENT_TIME> | 1.0         | <ID> | http://localhost:8080 | user-authentication-info.event.deleted | user-authentication-info.topic | <USER_AUTH_INFO_ID> | user-authentication-info.event.deleted | <UPDATED_NAME> | <UPDATED_EMAIL> | <STORE_ID> | <REALM_ID> | <CREATED_AT> | <UPDATED_AT> |
    And I sleep for 200 milliseconds
    When I read account members list with following parameters
      | store_id   | page-limit | page-offset |
      | <STORE_ID> | 10         | 0           |
    Then I see 200 status code in response
    And I see 0 account members in the returned data
    And I read Account Member with id "<USER_AUTH_INFO_ID>" and store id "<STORE_ID>"
    Then I see 200 status code in response
    When I read account members list with following parameters
      | store_id   | page-limit | page-offset |
      | <STORE_ID> | 10         | 0           |
    Then I see 200 status code in response
    And I see 1 account members in the returned data
    Examples:
      | EVENT_TIME               | STORE_ID                             | REALM_ID                             | UPDATED_NAME                          | CREATED_AT               | UPDATED_EMAIL                       | UPDATED_AT               | ID                                   | USER_AUTH_INFO_ID                    |  |
      | 2021-04-05T08:23:18.683Z | 00000000-0000-4000-8000-000000000000 | 00000000-0000-4000-8000-000000000001 | idpAccountTokenTestAccountUpdatedName | 2018-07-06T08:23:18.683Z | updatedidpaccounttokentest@test.com | 2018-07-06T08:23:18.683Z | 00000000-0000-1000-8000-111111111111 | 13000000-0000-1000-8000-111111111111 |  |

  Scenario Outline: Authenticate account member in EAS and generate a token - account member is updated by User Auth Info Updated event
      Given I mock EAS to return a successful Authentication Realm creation response with the following parameters
        | realmId    |
        | <REALM_ID> |
      And I mock EAS endpoint "/oidc-idp/token/stores/<STORE_ID>/authentication-realms/<REALM_ID>" for method "POST" to return status 201 and an id token which encodes the following data
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
        | name   | email   | id |
        | <NAME> | <EMAIL> |<USER_ID>|
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
        | name           | email           | id |
        | <UPDATED_NAME> | <UPDATED_EMAIL> | <USER_ID>|
      And I do not see an account member in the returned list with following parameters
        | name   | email   |
        | <NAME> | <EMAIL> |
      And I send a message with the following parameters
        | event_time   | specversion | id   | source                | type                                   | name                    | exchange                       | routingKey                             | userAuthInfoId | email                    | storeId    | realmId    | createdAt    | updatedAt    |
        | <EVENT_TIME> | 1.0         | <ID> | http://localhost:8080 | user-authentication-info.event.updated | <UPDATED_NAME_BY_EVENT> | user-authentication-info.topic | user-authentication-info.event.updated | <USER_ID>      | <UPDATED_EMAIL_BY_EVENT> | <STORE_ID> | <REALM_ID> | <CREATED_AT> | <UPDATED_AT> |
      And I wait until the account member with id "<USER_ID>" and store_id "<STORE_ID>" appears in the DB, with "updated_at" equal to "<EVENT_TIME>"
      When I read account members list with following parameters
        | store_id   | page-limit | page-offset |
        | <STORE_ID> | 3          | 0           |
      Then I see 200 status code in response
      And I see an account member in the returned list with following parameters
        | name                 | email                    | id        |
        | <UPDATED_NAME_BY_EVENT> | <UPDATED_EMAIL_BY_EVENT> | <USER_ID> |
      And I do not see an account member in the returned list with following parameters
        | name           | email           |
        | <UPDATED_NAME> | <UPDATED_EMAIL> |
      Examples:
        | EVENT_TIME               | STORE_ID                             | USER_ID                              | REALM_ID                             | NAME                           | EMAIL                        | UPDATED_EMAIL                       | UPDATED_NAME                          | UPDATED_EMAIL_BY_EVENT          | UPDATED_NAME_BY_EVENT | CREATED_AT               | UPDATED_AT               |
        | 2021-04-05T08:23:18.683Z | 00000000-0000-4000-8000-000000000000 | 00000000-0000-3000-8000-000000000000 | 00000000-0000-4000-8000-000000000001 | idpAccountTokenTestAccountName | idpaccounttokentest@test.com | updatedidpaccounttokentest@test.com | idpAccountTokenTestAccountUpdatedName | updatetestemailbyevent@test.com | updatetestnamebyevent | 2018-07-06T08:23:18.683Z | 2018-07-06T08:23:18.683Z |
