Feature: Sub-account Delete Operation Tests

  Scenario Outline: Delete Sub-account - happy path
    Given I reset DB and mocks
    And I have a linear sub-account structure with depth 3 and the following parameters
      | name-prefix      | legal_name-prefix      | registration_id-prefix             | store_id   |
      | test-delete-name | test-delete-legal_name | a1f3e4cc-cd42-4e38-a2c6-3177146cca | <STORE_ID> |
    And I see 201 status code in response
    And I have a linear sub-account structure with depth 3, the first sub-account parent "previous-3" and the following parameters
      | name-prefix               | legal_name-prefix               | registration_id-prefix              | store_id   |
      | test-delete-branch-1-name | test-delete-branch-1-legal_name | a1f3e4cc-cd42-4e38-a2c6-3177146ccbb | <STORE_ID> |
    And I see 201 status code in response
    And I have a linear sub-account structure with depth 2, the first sub-account parent "previous-3" and the following parameters
      | name-prefix               | legal_name-prefix               | registration_id-prefix              | store_id   |
      | test-delete-branch-2-name | test-delete-branch-2-legal_name | a1f3e4cc-cd42-4e38-a2c6-3177146cccc | <STORE_ID> |
    And I see 201 status code in response
    And I have an account with the following parameters
      | name                        | legal_name                        | registration_id                      | store_id   | parent_id  |
      | test-delete-branch-3-name-1 | test-delete-branch-3-legal_name-1 | a1f3e4cc-cd42-4e38-a2c6-3177146ccd6a | <STORE_ID> | previous-3 |
    And I see 201 status code in response

    When I delete an account passing the following parameters
      | store_id   | id         |
      | <STORE_ID> | previous-4 |
    Then I see 204 status code in response
    When I read an account passing the following parameters
      | store_id   | id         |
      | <STORE_ID> | previous-4 |
    Then I see 404 status code in response
    When I read an account passing the following parameters
      | store_id   | id         |
      | <STORE_ID> | previous-5 |
    Then I see 404 status code in response
    When I read an account passing the following parameters
      | store_id   | id         |
      | <STORE_ID> | previous-6 |
    Then I see 404 status code in response
    And I see error response with the following parameters
      | status | title     | detail            |
      | 404    | Not Found | account not found |
    When I read an account passing the following parameters
      | store_id   | id         |
      | <STORE_ID> | previous-1 |
    Then I see 200 status code in response
    When I read an account passing the following parameters
      | store_id   | id         |
      | <STORE_ID> | previous-2 |
    Then I see 200 status code in response
    When I read an account passing the following parameters
      | store_id   | id         |
      | <STORE_ID> | previous-3 |
    Then I see 200 status code in response
    When I read an account passing the following parameters
      | store_id   | id         |
      | <STORE_ID> | previous-7 |
    Then I see 200 status code in response
    Then I see 200 status code in response
    Then I see 200 status code in response
    When I delete an account passing the following parameters
      | store_id   | id         |
      | <STORE_ID> | previous-3 |
    When I read an account passing the following parameters
      | store_id   | id         |
      | <STORE_ID> | previous-3 |
    Then I see 404 status code in response
    When I read an account passing the following parameters
      | store_id   | id         |
      | <STORE_ID> | previous-7 |
    Then I see 404 status code in response
    And I see error response with the following parameters
      | status | title     | detail            |
      | 404    | Not Found | account not found |
    When I read an account passing the following parameters
      | store_id   | id         |
      | <STORE_ID> | previous-1 |
    Then I see 200 status code in response
    When I read an account passing the following parameters
      | store_id   | id         |
      | <STORE_ID> | previous-2 |
    Then I see 200 status code in response

    Examples:
      | STORE_ID                             |
      | 00000000-0000-1000-8000-000000000000 |
