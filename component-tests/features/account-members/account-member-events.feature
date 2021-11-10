Feature: Account Members Events

  Background:
    Given I reset DB and mocks
    When I mock EAS to return a successful Authentication Realm creation response with the following parameters
      | realmId                              |
      | 00000000-0000-1000-8000-111111111111 |
    And I mock EAS to return a successful user-authentication-info response with the following parameters
      | realmId                              | userId                               |
      | 00000000-0000-1000-8000-111111111111 | 00000000-0000-1000-8000-111111111112 |
    And I read Account Member with id "00000000-0000-1000-8000-111111111112" and store id "00000000-0000-1000-8000-000000000000"
    Then I see 200 status code in response

  Scenario Outline: Delete Account Member - event sent
    And I create a queue to listen to the AM events with routing key "account-member.event.deleted"
    When I send a message with the following parameters
      | event_time               | specversion | id                                   | source                | type                                   | exchange                       | userAuthInfoId | routingKey                             | name      | email          | storeId    | realmId    |
      | 2018-07-06T08:23:18.683Z | 1.0         | 00000000-0000-0000-0000-000000000000 | http://localhost:8080 | user-authentication-info.event.deleted | user-authentication-info.topic | <USER_ID>      | user-authentication-info.event.deleted | some_name | some@email.com | <STORE_ID> | <REALM_ID> |
    And I see exactly 1 emitted CloudEvent with routing key "account-member.event.deleted", type "account-member.event.deleted" with the following parameters
      | name                  | email                     |
      | User with ID<USER_ID> | <USER_ID>@elasticpath.com |
    Examples:
      | STORE_ID                             | REALM_ID                             | USER_ID                              |
      | 00000000-0000-1000-8000-000000000000 | 00000000-0000-1000-8000-111111111111 | 00000000-0000-1000-8000-111111111112 |

  Scenario Outline: Update Account Member - event sent
    And I create a queue to listen to the AM events with routing key "account-member.event.updated"
    When I send a message with the following parameters
      | event_time               | specversion | id                                   | source                | type                                   | exchange                       | userAuthInfoId | routingKey                             | name       | email       | storeId    | realmId    | createdAt                | updatedAt                |
      | 2018-07-06T08:23:18.683Z | 1.0         | 00000000-0000-0000-0000-000000000000 | http://localhost:8080 | user-authentication-info.event.updated | user-authentication-info.topic | <USER_ID>      | user-authentication-info.event.updated | <NEW_NAME> | <NEW_EMAIL> | <STORE_ID> | <REALM_ID> | 2018-07-06T08:23:18.683Z | 2018-07-06T08:23:18.683Z |
    And I see exactly 1 emitted CloudEvent with routing key "account-member.event.updated", type "account-member.event.updated" with the following parameters
      | name       | email       |
      | <NEW_NAME> | <NEW_EMAIL> |
    Examples:
      | STORE_ID                             | REALM_ID                             | USER_ID                              | NEW_NAME | NEW_EMAIL     |
      | 00000000-0000-1000-8000-000000000000 | 00000000-0000-1000-8000-111111111111 | 00000000-0000-1000-8000-111111111112 | new_name | new@email.com |
