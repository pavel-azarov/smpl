Feature: Filter Account Memberships tests

  Background:
    Given I reset DB and mocks
    And I mock EAS to return a successful Authentication Realm creation response with the following parameters
      | realmId                              |
      | 00000000-0000-1000-8000-111111111111 |
    And I mock EAS to return a successful user-authentication-info response with the following parameters
      | realmId                              | userId                               |
      | 00000000-0000-1000-8000-111111111111 | 00000000-0000-1000-8000-111111111111 |
    And I create an account with the following parameters
      | name                  | legal_name                 | registration_id                      | type    | store_id                             |
      | accountFilterTestName | accountFilterTestLegalName | 00000000-0000-1000-8000-222222222221 | account | 00000000-0000-1000-8000-000000000000 |
    Then I see 201 status code in response
    And I create an account membership with the following parameters
      | account_id | store_id                             | account_member_id                    |
      | <last>     | 00000000-0000-1000-8000-000000000000 | 00000000-0000-1000-8000-111111111111 |
    And I see 201 status code in response
    And I mock EAS to return a successful user-authentication-info response with the following parameters
      | realmId                              | userId                               |
      | 00000000-0000-1000-8000-111111111111 | 00000000-0000-1000-8000-111111111112 |
    And I create an account membership with the following parameters
      | account_id | store_id                             | account_member_id                    |
      | <last>     | 00000000-0000-1000-8000-000000000000 | 00000000-0000-1000-8000-111111111112 |
    And I see 201 status code in response

  Scenario Outline: Get all account memberships with EQ filters
    When I read all account memberships with the following parameters
      | account_id   | store_id                             | EP-Internal-Account-Id | ep-internal-search-json |
      | <previous-1> | 00000000-0000-1000-8000-000000000000 | <previous-1>           | <FILTER>             |
    Then I see 200 status code in response
    And I see <EXPECTED_COUNT> account memberships in the returned data with the following parameters
      | account_id   | account_member_id     |
      | <previous-1> | <EXPECTED_ACC_MEMBER> |

    Examples:
      | FILTER                                                                                                    | EXPECTED_COUNT | EXPECTED_ACC_MEMBER                  |
      | {"name":"and","args":[{"name":"eq","args":["account_member_id","00000000-0000-1000-8000-111111111111"]}]} | 1              | 00000000-0000-1000-8000-111111111111 |
      | {"name":"and","args":[{"name":"eq","args":["account_member_id",""]}]}                                     | 0              |                                      |
      | {"name":"and","args":[{"name":"eq","args":["account_member_id","*"]}]}                                    | 0              |                                      |
      | {"name":"and","args":[{"name":"eq","args":["account_member_id","00000000-0000-1000-8000-1111111111"]}]}   | 0              |                                      |
      | {"name":"and","args":[{"name":"eq","args":["account_member_id","00000000-0000-1000-8000-111111111113"]}]} | 0              |                                      |
      | {"name":"and","args":[{"name":"eq","args":["account_member_id","non-numeric-value"]}]}                    | 0              |                                      |

  Scenario Outline: Get all account memberships with LIKE filters
    When I read all account memberships with the following parameters
      | account_id   | store_id                             | EP-Internal-Account-Id | ep-internal-search-json |
      | <previous-1> | 00000000-0000-1000-8000-000000000000 | <previous-1>           | <FILTER>             |
    Then I see 200 status code in response
    And I see <EXPECTED_COUNT> account memberships in the returned data with the following parameters
      | account_id   | account_member_id     |
      | <previous-1> | <EXPECTED_ACC_MEMBER> |

    Examples:
      | FILTER                                                                                                      | EXPECTED_COUNT | EXPECTED_ACC_MEMBER                                                       |
      | {"name":"and","args":[{"name":"like","args":["account_member_id","*12"]}]}                                  | 1              | 00000000-0000-1000-8000-111111111112                                      |
      | {"name":"and","args":[{"name":"like","args":["account_member_id","*"]}]}                                    | 2              | 00000000-0000-1000-8000-111111111111,00000000-0000-1000-8000-111111111112 |
      | {"name":"and","args":[{"name":"like","args":["account_member_id","*8000*"]}]}                               | 2              | 00000000-0000-1000-8000-111111111111,00000000-0000-1000-8000-111111111112 |
      | {"name":"and","args":[{"name":"like","args":["account_member_id",""]}]}                                     | 0              |                                                                           |
      | {"name":"and","args":[{"name":"like","args":["account_member_id","00000000-0000-1000-8000-1111111111"]}]}   | 0              |                                                                           |
      | {"name":"and","args":[{"name":"like","args":["account_member_id","00000000-0000-1000-8000-111111111113"]}]} | 0              |                                                                           |
      | {"name":"and","args":[{"name":"like","args":["account_member_id","non-numeric-value"]}]}                    | 0              |                                                                           |

  Scenario Outline: Get all account memberships - filter and store isolation
    And I mock EAS to return a successful user-authentication-info response with the following parameters
      | realmId    | userId     |
      | <REALM_ID> | <USER_ID2> |
    And I create an account with the following parameters
      | name                        | legal_name                       | registration_id                      | type    | store_id    |
      | accountFilterStore2TestName | accountFilterStore2TestLegalName | 00000000-0000-1000-8000-112222222221 | account | <STORE_ID2> |
    Then I see 201 status code in response
    When I create an account membership with the following parameters
      | account_id | store_id    | account_member_id |
      | <last>     | <STORE_ID2> | <USER_ID2>        |
    Then I see 201 status code in response
    When I read all account memberships with the following parameters
      | account_id | store_id      | EP-Internal-Account-Id | ep-internal-search-json |
      | <ACC_ID>   | <QUERY_STORE> | <ACC_ID>               | <FILTER>             |
    Then I see 200 status code in response
    And I see <EXPECTED_COUNT> account memberships in the returned data with the following parameters
      | account_id | account_member_id     |
      | <ACC_ID>   | <EXPECTED_ACC_MEMBER> |

    Examples:
      | FILTER                                                                                                    | ACC_ID       | QUERY_STORE                          | EXPECTED_COUNT | EXPECTED_ACC_MEMBER                  | STORE_ID2                            | REALM_ID                             | USER_ID2                             |
      | {"name":"and","args":[{"name":"eq","args":["account_member_id","00000000-0000-1000-8000-111111111111"]}]} | <previous-1> | 00000000-0000-1000-8000-000000000000 | 1              | 00000000-0000-1000-8000-111111111111 | 00000000-0000-1000-8000-000000000001 | 00000000-0000-1000-8000-111111111111 | 00000000-0000-1000-8000-111111111112 |
      | {"name":"and","args":[{"name":"eq","args":["account_member_id","00000000-0000-1000-8000-111111111112"]}]} | <previous-2> | 00000000-0000-1000-8000-000000000001 | 1              | 00000000-0000-1000-8000-111111111112 | 00000000-0000-1000-8000-000000000001 | 00000000-0000-1000-8000-111111111111 | 00000000-0000-1000-8000-111111111112 |


  Scenario Outline: Get all account memberships with a filter - pagination
    When I read all account memberships with the following parameters
      | account_id   | store_id   | EP-Internal-Account-Id | ep-internal-search-json | page-limit | page-offset |
      | <previous-1> | <STORE_ID> | <previous-1>           | <FILTER>             | 1          | 0           |
    Then I see 200 status code in response
    And I see 1 account memberships in the returned data with the following parameters
      | account_id   | account_member_id |
      | <previous-1> | <USER_ID>         |
    And The following links are populated
      | current | first | last | next | prev |
      | X       | X     | X    | X    |      |
    And The page metadata section matches
      | limit   | 1 |
      | offset  | 0 |
      | current | 1 |
      | total   | 2 |
    When I read all account memberships with the following parameters
      | account_id   | store_id   | EP-Internal-Account-Id | ep-internal-search-json | page-limit | page-offset |
      | <previous-1> | <STORE_ID> | <previous-1>           | <FILTER>             | 1          | 1           |
    Then I see 200 status code in response
    And I see 1 account memberships in the returned data with the following parameters
      | account_id   | account_member_id |
      | <previous-1> | <USER_ID2>        |
    And The following links are populated
      | current | first | last | next | prev |
      | X       | X     | X    |      | X    |
    And The page metadata section matches
      | limit   | 1 |
      | offset  | 1 |
      | current | 2 |
      | total   | 2 |

    Examples:
      | FILTER                                                                   | STORE_ID                             | USER_ID                              | USER_ID2                             |
      | {"name":"and","args":[{"name":"like","args":["account_member_id","*"]}]} | 00000000-0000-1000-8000-000000000000 | 00000000-0000-1000-8000-111111111111 | 00000000-0000-1000-8000-111111111112 |
