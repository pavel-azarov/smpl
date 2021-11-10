Feature: Unassigned Account Members Filtering

  Background:
    Given I reset DB and mocks
    When I mock EAS to return a successful Authentication Realm creation response with the following parameters
      | realmId    |
      | 00000000-1111-1111-8000-222222222222  |
    When I create an account with the following parameters
      | name    | legal_name    | registration_id    | type    | store_id   |
      | accountCreateTestName | accountCreateTestLegalName | 00000000-0000-1000-8000-222222222222 | account | 00000000-0000-1000-8000-000000000001 |
    And I mock EAS to return a successful user-authentication-info response 3 time with the following parameters
      | realmId                              | namePrefix       | emailSuffix           | userIds                                                                                                        |
      | 00000000-1111-1111-8000-222222222222 | wildcard*%_chars | @wildcard*%_chars.com | 10000000-0000-1000-8000-111111111111,20000000-0000-1000-8000-111111111111,30000000-0000-1000-8000-111111111111 |
    And I read Account Member with id "10000000-0000-1000-8000-111111111111" and store id "00000000-0000-1000-8000-000000000001"
    Then I see 200 status code in response
    And I read Account Member with id "20000000-0000-1000-8000-111111111111" and store id "00000000-0000-1000-8000-000000000001"
    Then I see 200 status code in response
    And I read Account Member with id "30000000-0000-1000-8000-111111111111" and store id "00000000-0000-1000-8000-000000000001"
    Then I see 200 status code in response
    And I create an account membership with the following parameters
      | account_id | store_id                             | account_member_id                    |
      | <last>     | 00000000-0000-1000-8000-000000000001 | 30000000-0000-1000-8000-111111111111 |

  Scenario Outline:  Filter unassigned account members - EQ filters
    When I read unassigned account members list with following parameters
      | store_id   | account_id |page-limit | page-offset | ep-internal-search-json                                                   |
      | <STORE_ID> | <last>     |20         | 0           | {"name":"and","args":[{"name":"eq","args":["<EQ_FIELD>","<EQ_FILTER>"]}]} |
    Then I see 200 status code in response
    And I see <RESULT_NUM> account members in the returned data with following parameters
      | name_prefix          | email_suffix          | user_ids          |
      | <RESULT_NAME_PREFIX> | <RESULT_EMAIL_SUFFIX> | <RESULT_USER_IDS> |
    Examples:
      | EQ_FIELD | EQ_FILTER                        | RESULT_NUM | RESULT_NAME_PREFIX | RESULT_EMAIL_SUFFIX   | RESULT_USER_IDS | USER_ID_1                            | STORE_ID                             | USER_ID_2                            |
      | name     |                                  | 0          |                    |                       |                 | 10000000-0000-1000-8000-111111111111 | 00000000-0000-1000-8000-000000000001 | 20000000-0000-1000-8000-111111111111 |
      | name     | non-existent                     | 0          |                    |                       |                 | 10000000-0000-1000-8000-111111111111 | 00000000-0000-1000-8000-000000000001 | 20000000-0000-1000-8000-111111111111 |
      | name     | wildcard*%_chars<USER_ID_1>      | 1          | wildcard*%_chars   | @wildcard*%_chars.com | <USER_ID_1>     | 10000000-0000-1000-8000-111111111111 | 00000000-0000-1000-8000-000000000001 | 20000000-0000-1000-8000-111111111111 |
      | name     | WilDcArd*%_chaRs<USER_ID_1>      | 1          | wildcard*%_chars   | @wildcard*%_chars.com | <USER_ID_1>     | 10000000-0000-1000-8000-111111111111 | 00000000-0000-1000-8000-000000000001 | 20000000-0000-1000-8000-111111111111 |
      | name     | wildcard*%_chars<USER_ID_2>      | 1          | wildcard*%_chars   | @wildcard*%_chars.com | <USER_ID_2>     | 10000000-0000-1000-8000-111111111111 | 00000000-0000-1000-8000-000000000001 | 20000000-0000-1000-8000-111111111111 |
      | name     | *<USER_ID_1>                     | 0          |                    |                       |                 | 10000000-0000-1000-8000-111111111111 | 00000000-0000-1000-8000-000000000001 | 20000000-0000-1000-8000-111111111111 |
      | name     | wildcard*%_chars                 | 0          |                    |                       |                 | 10000000-0000-1000-8000-111111111111 | 00000000-0000-1000-8000-000000000001 | 20000000-0000-1000-8000-111111111111 |
      | name     | *<USER_ID_1>*                    | 0          |                    |                       |                 | 10000000-0000-1000-8000-111111111111 | 00000000-0000-1000-8000-000000000001 | 20000000-0000-1000-8000-111111111111 |
      | email    | <USER_ID_1>@wildcard*%_chars.com | 1          | wildcard*%_chars   | @wildcard*%_chars.com | <USER_ID_1>     | 10000000-0000-1000-8000-111111111111 | 00000000-0000-1000-8000-000000000001 | 20000000-0000-1000-8000-111111111111 |
      | email    | <USER_ID_2>@wildcard*%_chars.com | 1          | wildcard*%_chars   | @wildcard*%_chars.com | <USER_ID_2>     | 10000000-0000-1000-8000-111111111111 | 00000000-0000-1000-8000-000000000001 | 20000000-0000-1000-8000-111111111111 |
      | email    | non-existent                     | 0          |                    |                       |                 | 10000000-0000-1000-8000-111111111111 | 00000000-0000-1000-8000-000000000001 | 20000000-0000-1000-8000-111111111111 |
      | email    | <USER_ID_1>*                     | 0          |                    |                       |                 | 10000000-0000-1000-8000-111111111111 | 00000000-0000-1000-8000-000000000001 | 20000000-0000-1000-8000-111111111111 |

  Scenario Outline:  Filter unassigned account members - LIKE filters
    When I read unassigned account members list with following parameters
      | store_id   | account_id | page-limit | page-offset | ep-internal-search-json                                                         |
      | <STORE_ID> | <last>     |20         | 0           | {"name":"and","args":[{"name":"like","args":["<LIKE_FIELD>","<LIKE_FILTER>"]}]} |
    Then I see 200 status code in response
    And I see <RESULT_NUM> account members in the returned data with following parameters
      | name_prefix          | email_suffix          | user_ids          |
      | <RESULT_NAME_PREFIX> | <RESULT_EMAIL_SUFFIX> | <RESULT_USER_IDS> |
    Examples:
      | LIKE_FIELD | LIKE_FILTER                      | RESULT_NUM | RESULT_NAME_PREFIX | RESULT_EMAIL_SUFFIX   | RESULT_USER_IDS         | STORE_ID                             | USER_ID_1                            | USER_ID_2                            | USER_ID_3                            |
      | name       |                                  | 0          |                    |                       |                         | 00000000-0000-1000-8000-000000000001 | 10000000-0000-1000-8000-111111111111 | 20000000-0000-1000-8000-111111111111 | 30000000-0000-1000-8000-111111111111 |
      | name       | *non-existent*                   | 0          |                    |                       |                         | 00000000-0000-1000-8000-000000000001 | 10000000-0000-1000-8000-111111111111 | 20000000-0000-1000-8000-111111111111 | 30000000-0000-1000-8000-111111111111 |
      | name       | *                                | 2          | wildcard*%_chars   | @wildcard*%_chars.com | <USER_ID_1>,<USER_ID_2> | 00000000-0000-1000-8000-000000000001 | 10000000-0000-1000-8000-111111111111 | 20000000-0000-1000-8000-111111111111 | 30000000-0000-1000-8000-111111111111 |
      | name       | wildcard*%_chars<USER_ID_2>      | 1          | wildcard*%_chars   | @wildcard*%_chars.com | <USER_ID_2>             | 00000000-0000-1000-8000-000000000001 | 10000000-0000-1000-8000-111111111111 | 20000000-0000-1000-8000-111111111111 | 30000000-0000-1000-8000-111111111111 |
      | name       | wildcard*                        | 2          | wildcard*%_chars   | @wildcard*%_chars.com | <USER_ID_1>,<USER_ID_2> | 00000000-0000-1000-8000-000000000001 | 10000000-0000-1000-8000-111111111111 | 20000000-0000-1000-8000-111111111111 | 30000000-0000-1000-8000-111111111111 |
      | name       | wIldcArd*                        | 2          | wildcard*%_chars   | @wildcard*%_chars.com | <USER_ID_1>,<USER_ID_2> | 00000000-0000-1000-8000-000000000001 | 10000000-0000-1000-8000-111111111111 | 20000000-0000-1000-8000-111111111111 | 30000000-0000-1000-8000-111111111111 |
      | name       | *ildc*                           | 2          | wildcard*%_chars   | @wildcard*%_chars.com | <USER_ID_1>,<USER_ID_2> | 00000000-0000-1000-8000-000000000001 | 10000000-0000-1000-8000-111111111111 | 20000000-0000-1000-8000-111111111111 | 30000000-0000-1000-8000-111111111111 |
      | name       | *iLDc*                           | 2          | wildcard*%_chars   | @wildcard*%_chars.com | <USER_ID_1>,<USER_ID_2> | 00000000-0000-1000-8000-000000000001 | 10000000-0000-1000-8000-111111111111 | 20000000-0000-1000-8000-111111111111 | 30000000-0000-1000-8000-111111111111 |
      | email      | <USER_ID_2>@wildcard*%_chars.com | 1          | wildcard*%_chars   | @wildcard*%_chars.com | <USER_ID_2>             | 00000000-0000-1000-8000-000000000001 | 10000000-0000-1000-8000-111111111111 | 20000000-0000-1000-8000-111111111111 | 30000000-0000-1000-8000-111111111111 |
      | name       | *<USER_ID_2>                     | 1          | wildcard*%_chars   | @wildcard*%_chars.com | <USER_ID_2>             | 00000000-0000-1000-8000-000000000001 | 10000000-0000-1000-8000-111111111111 | 20000000-0000-1000-8000-111111111111 | 30000000-0000-1000-8000-111111111111 |
      | email      | <USER_ID_2>*                     | 1          | wildcard*%_chars   | @wildcard*%_chars.com | <USER_ID_2>             | 00000000-0000-1000-8000-000000000001 | 10000000-0000-1000-8000-111111111111 | 20000000-0000-1000-8000-111111111111 | 30000000-0000-1000-8000-111111111111 |
      | email      | *non-existent*                   | 0          |                    |                       |                         | 00000000-0000-1000-8000-000000000001 | 10000000-0000-1000-8000-111111111111 | 20000000-0000-1000-8000-111111111111 | 30000000-0000-1000-8000-111111111111 |

  Scenario Outline:  Filter unassigned account members - mixed filters
    When I read unassigned account members list with following parameters
      | store_id   | account_id | page-limit | page-offset | ep-internal-search-json                                                                                                                                         |
      | <STORE_ID> | <last>     | 20         | 0           | {"name":"and","args":[{"name":"<FILTER_TYPE1>","args":["<LIKE_FIELD1>","<LIKE_FILTER1>"]},{"name":"<FILTER_TYPE2>","args":["<LIKE_FIELD2>","<LIKE_FILTER2>"]}]} |
    Then I see 200 status code in response
    And I see <RESULT_NUM> account members in the returned data with following parameters
      | name_prefix          | email_suffix          | user_ids          |
      | <RESULT_NAME_PREFIX> | <RESULT_EMAIL_SUFFIX> | <RESULT_USER_IDS> |
    Examples:
      | FILTER_TYPE1 | LIKE_FIELD1 | LIKE_FILTER1                | FILTER_TYPE2 | LIKE_FIELD2 | LIKE_FILTER2                     | RESULT_NUM | RESULT_NAME_PREFIX | RESULT_EMAIL_SUFFIX   | RESULT_USER_IDS         | STORE_ID                             | USER_ID_1                            | USER_ID_2                            | USER_ID_3                            |
      | like         | name        | *                           | like         | name        | *                                | 2          | wildcard*%_chars   | @wildcard*%_chars.com | <USER_ID_1>,<USER_ID_2> | 00000000-0000-1000-8000-000000000001 | 10000000-0000-1000-8000-111111111111 | 20000000-0000-1000-8000-111111111111 | 30000000-0000-1000-8000-111111111111 |
      | like         | name        | wildcard*%_chars<USER_ID_1> | like         | email       | <USER_ID_1>@wildcard*%_chars.com | 1          | wildcard*%_chars   | @wildcard*%_chars.com | <USER_ID_1>             | 00000000-0000-1000-8000-000000000001 | 10000000-0000-1000-8000-111111111111 | 20000000-0000-1000-8000-111111111111 | 30000000-0000-1000-8000-111111111111 |
      | like         | name        | wildcard*%_chars*           | like         | email       | *@wildcard*%_chars.com           | 2          | wildcard*%_chars   | @wildcard*%_chars.com | <USER_ID_1>,<USER_ID_2> | 00000000-0000-1000-8000-000000000001 | 10000000-0000-1000-8000-111111111111 | 20000000-0000-1000-8000-111111111111 | 30000000-0000-1000-8000-111111111111 |
      | like         | name        | wildcard*%_chars<USER_ID_1> | like         | email       | non-existent                     | 0          | 0                  |                       |                         | 00000000-0000-1000-8000-000000000001 | 10000000-0000-1000-8000-111111111111 | 20000000-0000-1000-8000-111111111111 | 30000000-0000-1000-8000-111111111111 |
      | like         | name        | non-existent                | like         | email       | <USER_ID_1>@wildcard*%_chars.com | 0          | 0                  |                       |                         | 00000000-0000-1000-8000-000000000001 | 10000000-0000-1000-8000-111111111111 | 20000000-0000-1000-8000-111111111111 | 30000000-0000-1000-8000-111111111111 |
      | eq           | name        | wildcard*%_chars<USER_ID_1> | like         | email       | *@wildcard*%_chars.com           | 1          | wildcard*%_chars   | @wildcard*%_chars.com |<USER_ID_1>                         | 00000000-0000-1000-8000-000000000001 | 10000000-0000-1000-8000-111111111111 | 20000000-0000-1000-8000-111111111111 | 30000000-0000-1000-8000-111111111111 |

  Scenario Outline:  Filter unassigned account members - pagination
    When I read unassigned account members list with following parameters
      | store_id   | account_id | page-limit | page-offset | ep-internal-search-json                                                         |
      | <STORE_ID> | <last>     | 1          | 0           | {"name":"and","args":[{"name":"like","args":["<LIKE_FIELD>","<LIKE_FILTER>"]}]} |
    Then I see 200 status code in response
    And I see 1 account member in the returned data with following parameters
      | name_prefix          | email_suffix          | user_ids    |
      | <RESULT_NAME_PREFIX> | <RESULT_EMAIL_SUFFIX> | <USER_ID_1> |
    And The following links are populated
      | self | first | last | next | prev |
      | X    | X     | X    |      |      |
    And The page metadata section matches
      | limit   | 1 |
      | offset  | 0 |
      | current | 1 |
      | total   | 2 |
    And The metadata result total is 2
    When I read unassigned account members list with following parameters
      | store_id   | account_id | page-limit | page-offset | ep-internal-search-json                                                         |
      | <STORE_ID> | <last>     | 1          | 1           | {"name":"and","args":[{"name":"like","args":["<LIKE_FIELD>","<LIKE_FILTER>"]}]} |
  Then I see 200 status code in response
    And I see 1 account member in the returned data with following parameters
      | name_prefix          | email_suffix          | user_ids    |
      | <RESULT_NAME_PREFIX> | <RESULT_EMAIL_SUFFIX> | <USER_ID_2> |
    And The following links are populated
      | self | first | last | next | prev |
      | X    | X     | X    |      |      |
    And The page metadata section matches
      | limit   | 1 |
      | offset  | 1 |
      | current | 2 |
      | total   | 2 |
    And The metadata result total is 2
    Examples:
      | LIKE_FIELD | LIKE_FILTER | RESULT_NAME_PREFIX | RESULT_EMAIL_SUFFIX   | STORE_ID                             | USER_ID_1                            | USER_ID_2                            | USER_ID_3                            |
      | name       | *wildcard*  | wildcard*%_chars   | @wildcard*%_chars.com | 00000000-0000-1000-8000-000000000001 | 10000000-0000-1000-8000-111111111111 | 20000000-0000-1000-8000-111111111111 | 30000000-0000-1000-8000-111111111111 |

  Scenario Outline:  Filter unassigned account members - store isolation
    And I mock EAS to return a successful user-authentication-info response 1 time with the following parameters
      | realmId                              | namePrefix       | emailSuffix           | userIds     |
      | 00000000-1111-1111-8000-222222222222  | wildcard*%_chars | @wildcard*%_chars.com | <USER_ID_3> |
    And I read Account Member with id "<USER_ID_3>" and store id "<OTHER_STORE_ID>"
    And I create an account with the following parameters
      | name    | legal_name    | registration_id    | type    | store_id   |
      | accountCreateTestName | accountCreateTestLegalName | 00000000-0000-1000-8000-222222222222 | account | <OTHER_STORE_ID> |
    When I read unassigned account members list with following parameters
      | store_id   | account_id | page-limit | page-offset | ep-internal-search-json                                                         |
      | <STORE_ID> | <previous> | 20         | 0           | {"name":"and","args":[{"name":"like","args":["<LIKE_FIELD>","<LIKE_FILTER>"]}]} |
    Then I see 200 status code in response
    And I see 2 account members in the returned data with following parameters
      | name_prefix          | email_suffix          | user_ids                |
      | <RESULT_NAME_PREFIX> | <RESULT_EMAIL_SUFFIX> | <USER_ID_1>,<USER_ID_2> |
    When I read unassigned account members list with following parameters
      | store_id         | account_id | page-limit | page-offset | ep-internal-search-json                                                         |
      | <OTHER_STORE_ID> | <last>        | 20         | 0           | {"name":"and","args":[{"name":"like","args":["<LIKE_FIELD>","<LIKE_FILTER>"]}]} |
    Then I see 200 status code in response
    And I see 1 account members in the returned data with following parameters
      | name_prefix          | email_suffix          | user_ids    |
      | <RESULT_NAME_PREFIX> | <RESULT_EMAIL_SUFFIX> | <USER_ID_3> |
    Examples:
      | LIKE_FIELD | LIKE_FILTER | RESULT_NAME_PREFIX | RESULT_EMAIL_SUFFIX   | STORE_ID                             | OTHER_STORE_ID                       | USER_ID_1                            | USER_ID_2                            | USER_ID_3                            |
      | name       | *wildcard*  | wildcard*%_chars   | @wildcard*%_chars.com | 00000000-0000-1000-8000-000000000001 | 33300000-0000-1000-8000-000000000001 | 10000000-0000-1000-8000-111111111111 | 20000000-0000-1000-8000-111111111111 | 30000000-0000-1000-8000-111111111111 |
