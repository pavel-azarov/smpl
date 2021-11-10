Feature: Pagination

  Background:
    Given I reset DB and mocks

  Scenario: Paginated account list with default page limit and page offset queries
    When I create 20 accounts with following parameters
      | store_id                             | name-prefix | legal_name-prefix |
      | 00000000-0000-1000-8000-111111111111 | account     | legal_name        |
    And I read account list with following parameters
      | store_id                             | X-Moltin-Settings-page_length |
      | 00000000-0000-1000-8000-111111111111 | 19                            |
    Then I see 200 status code in response
    And I see 19 accounts in the returned data with prefix "account" in name and "legal_name" in legal_name from 1 to 19
    And The following links are populated
      | current | first | last | next | prev |
      | X       | X     | X    | X    |      |
    And The page metadata section matches
      | limit   | 19 |
      | offset  | 0  |
      | current | 1  |
      | total   | 2  |
    And The metadata result total is 20

  Scenario Outline:  Make sure that all the links and data are correct on the first, the last and an arbitrary pages
    When I create 9 accounts with following parameters
      | store_id   | name-prefix | legal_name-prefix |
      | <STORE_ID> | account     | legal_name        |
    And I read account list with following parameters
      | store_id   | page-limit | page-offset | X-Moltin-Settings-page_length |
      | <STORE_ID> | 2          | 4           | 20                            |

    Then I see 200 status code in response
    And I see 2 accounts in the returned data with prefix "<NAME_PREFIX>" in name and "<LEGAL_NAME_PREFIX>" in legal_name from 5 to 6
    And The following links are populated
      | current | first | last | next | prev |
      | X       | X     | X    | X    | X    |
    And The page metadata section matches
      | limit   | 2 |
      | offset  | 4 |
      | current | 3 |
      | total   | 5 |
    And The metadata result total is 9

    When I follow the "next" page link with following parameters
      | store_id   | X-Moltin-Settings-page_length |
      | <STORE_ID> | 20                            |
    Then I see 200 status code in response
    And I see 2 accounts in the returned data with prefix "<NAME_PREFIX>" in name and "<LEGAL_NAME_PREFIX>" in legal_name from 7 to 8
    And The following links are populated
      | current | first | last | next | prev |
      | X       | X     | X    | X    | X    |
    And The page metadata section matches
      | limit   | 2 |
      | offset  | 6 |
      | current | 4 |
      | total   | 5 |
    And The metadata result total is 9

    When I follow the "prev" page link with following parameters
      | store_id   | X-Moltin-Settings-page_length |
      | <STORE_ID> | 20                            |
    Then I see 200 status code in response
    And I see 2 account in the returned data with prefix "<NAME_PREFIX>" in name and "<LEGAL_NAME_PREFIX>" in legal_name from 5 to 6
    And The following links are populated
      | current | first | last | next | prev |
      | X       | X     | X    | X    | X    |
    And The page metadata section matches
      | limit   | 2 |
      | offset  | 4 |
      | current | 3 |
      | total   | 5 |
    And The metadata result total is 9

    When I follow the "first" page link with following parameters
      | store_id   | X-Moltin-Settings-page_length |
      | <STORE_ID> | 20                            |

    Then I see 200 status code in response
    And I see 2 account in the returned data with prefix "<NAME_PREFIX>" in name and "<LEGAL_NAME_PREFIX>" in legal_name from 1 to 2
    And The following links are populated
      | current | first | last | next | prev |
      | X       | X     | X    | X    | X    |
    And The page metadata section matches
      | limit   | 2 |
      | offset  | 0 |
      | current | 1 |
      | total   | 5 |
    And The metadata result total is 9

    When I follow the "last" page link with following parameters
      | store_id   | X-Moltin-Settings-page_length |
      | <STORE_ID> | 20                            |
    Then I see 200 status code in response
    And I see 1 account in the returned data with prefix "<NAME_PREFIX>" in name and "<LEGAL_NAME_PREFIX>" in legal_name from 9 to 9
    And The following links are populated
      | current | first | last | next | prev |
      | X       | X     | X    |      | X    |
    And The page metadata section matches
      | limit   | 2 |
      | offset  | 8 |
      | current | 5 |
      | total   | 5 |
    And The metadata result total is 9
    Examples:
      | STORE_ID                             | NAME_PREFIX | LEGAL_NAME_PREFIX |
      | 00000000-0000-1000-8000-111111111111 | account     | legal_name        |

  Scenario Outline:  Passing negative values as offset and limit
    When I create 9 accounts with following parameters
      | store_id   | name-prefix | legal_name-prefix |
      | <STORE_ID> | account     | legal_name        |
    And I read account list with following parameters
      | store_id   | page-limit | page-offset | X-Moltin-Settings-page_length |
      | <STORE_ID> | -2         | 6           | 20                            |
    Then I see 400 status code in response
    And I see error response with the following parameters
      | status | title       | detail                                                                   |
      | 400    | Bad Request | Validation failed: field 'Limit' on the 'positive-pagination-limit' tag. |
    When I read account list with following parameters
      | store_id   | page-limit | page-offset | X-Moltin-Settings-page_length |
      | <STORE_ID> | 2          | -1          | 20                            |

    Then I see 400 status code in response
    And I see error response with the following parameters
      | status | title       | detail                                                                         |
      | 400    | Bad Request | Validation failed: field 'Offset' on the 'non-negative-pagination-offset' tag. |
    Examples:
      | STORE_ID                             |
      | 00000000-0000-1000-8000-111111111111 |

  Scenario Outline: Verify pagination upper limits for offset and limit parameters
    When I read account list with following parameters
      | store_id   | page-limit | page-offset | X-Moltin-Settings-page_length |
      | <STORE_ID> | 100        | 10000       | 20                            |
    Then I see 200 status code in response
    Examples:
      | STORE_ID                             |
      | 00000000-0000-1000-8000-111111111111 |

  Scenario Outline: Verify pagination enforced limits for offset and limit parameters
    When I read account list with following parameters
      | store_id   | page-limit | page-offset | X-Moltin-Settings-page_length |
      | <STORE_ID> | 100        | 10001       | 20                            |
    Then I see 400 status code in response
    And I see error response with the following parameters
      | status | title       | detail                                            |
      | 400    | Bad Request | page offset has been exceeded enforced limitation |
    When I read account list with following parameters
      | store_id   | page-limit | page-offset | X-Moltin-Settings-page_length |
      | <STORE_ID> | 101        | 10000       | 20                            |
    Then I see 400 status code in response
    And I see error response with the following parameters
      | status | title       | detail                                           |
      | 400    | Bad Request | page limit has been exceeded enforced limitation |
    Examples:
      | STORE_ID                             |
      | 00000000-0000-1000-8000-111111111111 |

  Scenario:  Pagination when there is no data scoped by provided store
    When I read account list with following parameters
      | store_id                             | page-limit | page-offset |
      | 00000000-0000-3000-8000-333333333333 | 2          | 0           |
    Then I see 200 status code in response
    And I see empty list in the returned data
    And The following links are populated
      | current | first | last | next | prev |
      | X       | X     | X    |      |      |
    And The page metadata section matches
      | limit   | 2 |
      | offset  | 0 |
      | current | 1 |
      | total   | 0 |
    And The metadata result total is 0

  Scenario Outline:  Paginate account members when there are account members and page-limit is not provided or is empty or equals 0 or is not numeric
    When I mock EAS to return a successful Authentication Realm creation response with the following parameters
      | realmId    |
      | <REALM_ID> |
    And I mock EAS to return a successful user-authentication-info response 2 times with the following parameters
      | realmId    | namePrefix    | emailSuffix    | userIds                 |
      | <REALM_ID> | <NAME_PREFIX> | <EMAIL_SUFFIX> | <USER_ID_1>,<USER_ID_2> |
    And I read Account Member with id "<USER_ID_1>" and store id "<STORE_ID_1>"
    And I read Account Member with id "<USER_ID_2>" and store id "<STORE_ID_1>"
    And I mock EAS to return a successful user-authentication-info response 1 time with the following parameters
      | realmId    | namePrefix    | emailSuffix    | userIds     |
      | <REALM_ID> | <NAME_PREFIX> | <EMAIL_SUFFIX> | <USER_ID_3> |
    And I read Account Member with id "<USER_ID_3>" and store id "<STORE_ID_2>"
    When I read account members list with following parameters
      | store_id     | page-offset |
      | <STORE_ID_2> | 0           |
    Then I see 200 status code in response
    And I see 1 account member in the returned data with following parameters
      | name_prefix   | email_suffix   | user_ids    |
      | <NAME_PREFIX> | <EMAIL_SUFFIX> | <USER_ID_3> |
    And The following links are populated
      | self | first | last | next | prev |
      | X    | X     | X    |      |      |
    And The page metadata section matches
      | limit   | 20 |
      | offset  | 0  |
      | current | 1  |
      | total   | 1  |
    And The metadata result total is 1
    When I read account members list with following parameters
      | store_id     | page-offset | page-limit |
      | <STORE_ID_2> | 0           |            |
    Then I see 200 status code in response
    And I see 1 account member in the returned data with following parameters
      | name_prefix   | email_suffix   | user_ids    |
      | <NAME_PREFIX> | <EMAIL_SUFFIX> | <USER_ID_3> |
    And The following links are populated
      | self | first | last | next | prev |
      | X    | X     | X    |      |      |
    And The page metadata section matches
      | limit   | 20 |
      | offset  | 0  |
      | current | 1  |
      | total   | 1  |
    And The metadata result total is 1
    When I read account members list with following parameters
      | store_id     | page-limit | page-offset |
      | <STORE_ID_2> | 0          | 0           |
    Then I see 400 status code in response
    And I see error response with the following parameters
      | status | title       | detail                                                                   |
      | 400    | Bad Request | Validation failed: field 'Limit' on the 'positive-pagination-limit' tag. |
    When I read account members list with following parameters
      | store_id     | page-limit | page-offset |
      | <STORE_ID_2> | abcd       | 0           |
    Then I see 400 status code in response
    And I see error response with the following parameters
      | status | title       | detail                                                                   |
      | 400    | Bad Request | Validation failed: field 'Limit' on the 'positive-pagination-limit' tag. |
    Examples:
      | STORE_ID_1                           | STORE_ID_2                           | REALM_ID                             | USER_ID_1                            | USER_ID_2                            | USER_ID_3                            | NAME_PREFIX  | EMAIL_SUFFIX     |
      | 00000000-0000-1000-8000-000000000001 | 00000000-0000-1000-8000-000000000002 | 00000000-0000-1000-8000-111111111111 | 10000000-0000-1000-8000-111111111111 | 20000000-0000-1000-8000-111111111111 | 30000000-0000-1000-8000-111111111111 | User With ID | @elasticpath.com |


  Scenario: Paginate accounts when page-limit is not provided or is empty or equals 0 or is not numeric
    When I read account list with following parameters
      | store_id                             | page-offset |
      | 00000000-0000-3000-8000-333333333333 | 0           |
    Then I see 200 status code in response
    And I see empty list in the returned data
    And The following links are populated
      | current | first | last | next | prev |
      | X       | X     | X    |      |      |
    And The page metadata section matches
      | limit   | 20 |
      | offset  | 0  |
      | current | 1  |
      | total   | 0  |
    And The metadata result total is 0
    When I read account list with following parameters
      | store_id                             | page-limit | page-offset |
      | 00000000-0000-3000-8000-333333333333 | 0          | 0           |
    Then I see 400 status code in response
    And I see error response with the following parameters
      | status | title       | detail                                                                   |
      | 400    | Bad Request | Validation failed: field 'Limit' on the 'positive-pagination-limit' tag. |
    When I read account list with following parameters
      | store_id                             | page-offset | page-limit |
      | 00000000-0000-3000-8000-333333333333 | 0           |            |
    Then I see 200 status code in response
    And I see empty list in the returned data
    And The following links are populated
      | current | first | last | next | prev |
      | X       | X     | X    |      |      |
    And The page metadata section matches
      | limit   | 20 |
      | offset  | 0  |
      | current | 1  |
      | total   | 0  |
    And The metadata result total is 0
    When I read account list with following parameters
      | store_id                             | page-limit | page-offset |
      | 00000000-0000-3000-8000-333333333333 | abcd       | 0           |
    Then I see 400 status code in response
    And I see error response with the following parameters
      | status | title       | detail                                                                   |
      | 400    | Bad Request | Validation failed: field 'Limit' on the 'positive-pagination-limit' tag. |


  Scenario:  Paginate account memberships when page-limit is not provided or is empty or equals 0 or is not numeric
    And I mock EAS to return a successful Authentication Realm creation response with the following parameters
      | realmId                              |
      | 00000000-0000-1000-8000-111111111111 |
    And I mock EAS to return a successful user-authentication-info response with the following parameters
      | realmId                              | userId                               |
      | 00000000-0000-1000-8000-111111111111 | 00000000-0000-1000-8000-111111111114 |
    And I create an account with the following parameters
      | name                  | legal_name                 | registration_id                       | type    | store_id                             |
      | accountCreateTestName | accountCreateTestLegalName | 00000000-0000-1000-8000-2222222222213 | account | 00000000-0000-1000-8000-000000000001 |
    And I see 201 status code in response
    And I create an account membership with the following parameters
      | account_id | store_id                             | account_member_id                    |
      | <last>     | 00000000-0000-1000-8000-000000000001 | 00000000-0000-1000-8000-111111111114 |
    And I see 201 status code in response
    When I read all account memberships with the following parameters
      | account_id | store_id                             | page-limit | page-offset |
      | <last>     | 00000000-0000-1000-8000-000000000001 |            | 0           |
    Then I see 200 status code in response
    And The page metadata section matches
      | limit   | 20 |
      | offset  | 0  |
      | current | 1  |
      | total   | 1  |
    And The metadata result total is 1
    When I read all account memberships with the following parameters
      | account_id | store_id                             | page-offset |
      | <last>     | 00000000-0000-1000-8000-000000000001 | 0           |
    Then I see 200 status code in response
    And The page metadata section matches
      | limit   | 20 |
      | offset  | 0  |
      | current | 1  |
      | total   | 1  |
    And The metadata result total is 1
    When I read all account memberships with the following parameters
      | account_id | store_id                             | page-offset | page-limit |
      | <last>     | 00000000-0000-1000-8000-000000000001 | 0           | 0          |
    Then I see 400 status code in response
    And I see error response with the following parameters
      | status | title       | detail                                                                   |
      | 400    | Bad Request | Validation failed: field 'Limit' on the 'positive-pagination-limit' tag. |
    When I read all account memberships with the following parameters
      | account_id | store_id                             | page-offset | page-limit |
      | <last>     | 00000000-0000-1000-8000-000000000001 | 0           | abcd       |
    Then I see 400 status code in response
    And I see error response with the following parameters
      | status | title       | detail                                                                   |
      | 400    | Bad Request | Validation failed: field 'Limit' on the 'positive-pagination-limit' tag. |