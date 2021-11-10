Feature: Account Read Operation Tests

  Scenario: Read Account - non-existent account
    Given I reset DB and mocks
    When I read an account passing the following parameters
      | store_id                             | id                                   |
      | 00000000-0000-1000-8000-000000000000 | 00000000-0000-1000-8000-111111111111 |
    Then I see 404 status code in response
    And I see error response with the following parameters
      | detail              | title     | status |
      | account not found   | Not Found | 404    |

  Scenario Outline: Read Account - read an account scoped by another store
    Given I reset DB and mocks
    And I create an account with the following parameters
      | name                         | legal_name                        | registration_id                      | type   | store_id     |
      | accReadAnotherStoreTestName1 | accReadAnotherStoreTestLegalName1 | 00000000-0000-1000-8000-222222222221 | <TYPE> | <STORE_ID_1> |
    And I see 201 status code in response
    And I create an account with the following parameters
      | name                         | legal_name                        | registration_id                      | type   | store_id     |
      | accReadAnotherStoreTestName2 | accReadAnotherStoreTestLegalName2 | 00000000-0000-1000-8000-333333333333 | <TYPE> | <STORE_ID_2> |
    And I see 201 status code in response
    When I read an account passing the following parameters
      | store_id     | id     |
      | <STORE_ID_1> | <last> |
    Then I see 404 status code in response
    And I see error response with the following parameters
      | status | title     | detail            |
      | 404    | Not Found | account not found |

    Examples:
      | TYPE    | STORE_ID_1                           | STORE_ID_2                           |
      | account | 00000000-0000-1000-8000-000000000000 | 00000000-0000-1000-8000-111111111111 |

  Scenario: wrong method get account endpoint
    And I use HTTP method POST when calling accounts endpoint providing store id "88888888-4444-4333-8333-111111111111" and account id "88888888-4444-4333-8333-111111111111"
    Then I see 405 status code in response
