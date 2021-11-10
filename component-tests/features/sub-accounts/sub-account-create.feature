Feature: Sub-account Create Operation Tests

  Background:
    Given I reset DB and mocks

  Scenario Outline: Create Sub-account - happy path
    When I create a linear sub-account structure with depth 5 and the following parameters
      | name-prefix   | legal_name-prefix   | registration_id-prefix   | store_id   |
      | <NAME_PREFIX> | <LEGAL_NAME_PREFIX> | <REGISTRATION_ID_PREFIX> | <STORE_ID> |
    Then I see 201 status code in response
    And I see the following properties in the returned Account object
      | name            | legal_name            | registration_id            | parent_id | ancestors         | type    | id  |
      | <NAME_PREFIX>-5 | <LEGAL_NAME_PREFIX>-5 | <REGISTRATION_ID_PREFIX>-5 | previous  | previous-list-all | account | any |
    When I read an account passing the following parameters
      | store_id   | id     |
      | <STORE_ID> | <last> |
    Then I see 200 status code in response
    And I see the following properties in the returned Account object
      | name            | legal_name            | registration_id            | parent_id | ancestors         | type    | id  |
      | <NAME_PREFIX>-5 | <LEGAL_NAME_PREFIX>-5 | <REGISTRATION_ID_PREFIX>-5 | previous  | previous-list-all | account | any |
    When I create an account with the following parameters
      | name                  | legal_name                  | registration_id                  | store_id   | parent_id  |
      | <PARALLEL_CHILD_NAME> | <PARALLEL_CHILD_LEGAL_NAME> | <PARALLEL_CHILD_REGISTRATION_ID> | <STORE_ID> | previous-3 |
    Then I see 201 status code in response
    And I see the following properties in the returned Account object
      | name                  | legal_name                  | registration_id                  | parent_id  | ancestors       | type    | id  |
      | <PARALLEL_CHILD_NAME> | <PARALLEL_CHILD_LEGAL_NAME> | <PARALLEL_CHILD_REGISTRATION_ID> | previous-3 | previous-list-3 | account | any |
    When I read an account passing the following parameters
      | store_id   | id     |
      | <STORE_ID> | <last> |
    Then I see 200 status code in response
    And I see the following properties in the returned Account object
      | name                  | legal_name                  | registration_id                  | parent_id  | ancestors       | type    | id  |
      | <PARALLEL_CHILD_NAME> | <PARALLEL_CHILD_LEGAL_NAME> | <PARALLEL_CHILD_REGISTRATION_ID> | previous-3 | previous-list-3 | account | any |
    When I read an account passing the following parameters
      | store_id   | id         |
      | <STORE_ID> | previous-3 |
    Then I see 200 status code in response
    And I see the following properties in the returned Account object
      | name            | legal_name            | registration_id            | parent_id  | ancestors       | type    | id  |
      | <NAME_PREFIX>-3 | <LEGAL_NAME_PREFIX>-3 | <REGISTRATION_ID_PREFIX>-3 | previous-2 | previous-list-2 | account | any |

    Examples:
      | NAME_PREFIX              | LEGAL_NAME_PREFIX              | REGISTRATION_ID_PREFIX             | STORE_ID                             | PARALLEL_CHILD_NAME               | PARALLEL_CHILD_LEGAL_NAME               | PARALLEL_CHILD_REGISTRATION_ID       |
      | sub-acc-test-create-name | sub-acc-test-create-legal_name | 00000000-0000-1000-8000-2222222222 | 00000000-0000-1000-8000-000000000000 | parallel-sub-acc-test-create-name | parallel-sub-acc-test-create-legal_name | 00000000-0000-1000-8000-444444444444 |

  Scenario: Create Sub-account - try to specify non-existent-account as a parent
    When I create an account with the following parameters
      | name                           | legal_name                           | registration_id                      | store_id                             | parent_id                            |
      | sub-acc-test-non-existent-name | sub-acc-test-non-existent-legal_name | 00000000-0000-1000-8000-222222222222 | 00000000-0000-1000-8000-000000000000 | 00000000-0000-1000-8000-444444444444 |
    Then I see 404 status code in response
    And I see error response with the following parameters
      | status | title     | detail            |
      | 404    | Not Found | account not found |

  Scenario Outline: Create Sub-account - structure depth exceeding a limit
    When I create a linear sub-account structure with depth 24 and the following parameters
      | name-prefix   | legal_name-prefix   | registration_id-prefix   | store_id   |
      | <NAME_PREFIX> | <LEGAL_NAME_PREFIX> | <REGISTRATION_ID_PREFIX> | <STORE_ID> |
    Then I see 201 status code in response
    When I create an account with the following parameters
      | name             | legal_name             | registration_id             | store_id   | parent_id |
      | <NAME_PREFIX>-25 | <LEGAL_NAME_PREFIX>-25 | <REGISTRATION_ID_PREFIX>-25 | <STORE_ID> | last      |
    Then I see 422 status code in response
    And I see error response with the following parameters
      | status | title                | detail                                 |
      | 422    | Unprocessable Entity | the depth of tree should not exceed 24 |

    Examples:
      | NAME_PREFIX                 | LEGAL_NAME_PREFIX                 | REGISTRATION_ID_PREFIX             | STORE_ID                             |
      | sub-acc-test-off-limit-name | sub-acc-test-off-limit-legal_name | 00000000-0000-1000-8000-2222222222 | 00000000-0000-1000-8000-000000000000 |

  Scenario: Create Sub-account - try to specify not uuid as a parent id
    When I create an account with the following parameters
      | name                              | legal_name                              | registration_id                      | store_id                             | parent_id               |
      | sub-acc-test-parent-not-uuid-name | sub-acc-test-parent-not-uuid-legal_name | 00000000-0000-1000-8000-222222222222 | 00000000-0000-1000-8000-000000000000 | 00000000-0000-1000-8000 |
    Then I see 400 status code in response
    And I see error response with the following parameters
      | status | title       | detail                                                 |
      | 400    | Bad Request | Validation failed: field 'ParentID' on the 'uuid' tag. |

