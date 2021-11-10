Feature: Account Delete Operation Tests

  Background:
    Given I reset DB and mocks
    And I create an account with the following parameters
      | name                  | legal_name                 | registration_id                      | type    | store_id                             |
      | accountDeleteTestName | accountDeleteTestLegalName | 00000000-0000-1000-8000-222222222222 | account | 00000000-0000-1000-8000-000000000000 |
    And I see 201 status code in response
    And I create an account with the following parameters
      | name                         | legal_name                    | registration_id                      | type    | store_id                             |
      | deleteSecondStoreAccTestName | deleteSecondStoreAccLegalName | 00000000-0000-1000-8000-222222333333 | account | 00000000-0000-1000-8000-000000111111 |
    And I see 201 status code in response
    And I create a queue to listen to the AM events with routing key "account.event.deleted"

  Scenario Outline: Delete Account - happy path
    When I delete an account passing the following parameters
      | store_id     | id     |
      | <STORE_ID_2> | <last> |
    Then I see 204 status code in response
    When I read an account passing the following parameters
      | store_id     | id     |
      | <STORE_ID_2> | <last> |
    Then I see 404 status code in response
    And I see error response with the following parameters
      | detail              | title     | status |
      | account not found   | Not Found | 404    |
    When I read an account passing the following parameters
      | store_id     | id         |
      | <STORE_ID_1> | <previous> |
    Then I see 200 status code in response
    And I see exactly 1 emitted CloudEvent with routing key "account.event.deleted", type "account.event.deleted" with the following parameters
      | name                         | legal_name                    | registration_id                      |
      | deleteSecondStoreAccTestName | deleteSecondStoreAccLegalName | 00000000-0000-1000-8000-222222333333 |

    Examples:
      | STORE_ID_1                           | STORE_ID_2                           |
      | 00000000-0000-1000-8000-000000000000 | 00000000-0000-1000-8000-000000111111 |

  Scenario Outline: Delete Account - try to delete an account scoped by different store
    When I delete an account passing the following parameters
      | store_id     | id     |
      | <STORE_ID_1> | <last> |
    Then I see 404 status code in response
    And I see error response with the following parameters
      | detail              | title     | status |
      | account not found   | Not Found | 404    |
    When I read an account passing the following parameters
      | store_id     | id         |
      | <STORE_ID_1> | <previous> |
    Then I see 200 status code in response
    When I read an account passing the following parameters
      | store_id     | id     |
      | <STORE_ID_2> | <last> |
    Then I see 200 status code in response
    Examples:
      | STORE_ID_1                           | STORE_ID_2                           |
      | 00000000-0000-1000-8000-000000000000 | 00000000-0000-1000-8000-000000111111 |