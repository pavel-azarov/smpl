Feature: Account Memberships Pagination Store Isolation

  Background:
    Given I reset DB and mocks
    And I mock EAS to return a successful Authentication Realm creation response with the following parameters
      | realmId                              |
      | 00000000-0000-1000-8000-111111111111 |
    And I mock EAS to return a successful user-authentication-info response with the following parameters
      | realmId                              | userId                               |
      | 00000000-0000-1000-8000-111111111111 | 00000000-0000-1000-8000-111111111112 |
    And I mock EAS to return a successful user-authentication-info response with the following parameters
      | realmId                              | userId                               |
      | 00000000-0000-1000-8000-111111111111 | 00000000-0000-1000-8000-111111111113 |
    And I mock EAS to return a successful user-authentication-info response with the following parameters
      | realmId                              | userId                               |
      | 00000000-0000-1000-8000-111111111111 | 00000000-0000-1000-8000-111111111114 |

    And I create an account with the following parameters
      | name                  | legal_name                 | registration_id                       | type    | store_id                             |
      | accountCreateTestName | accountCreateTestLegalName | 00000000-0000-1000-8000-2222222222211 | account | 00000000-0000-1000-8000-000000000000 |
    And I see 201 status code in response
    And I create an account membership with the following parameters
      | account_id | store_id   | account_member_id |
      | <last>     | 00000000-0000-1000-8000-000000000000 | 00000000-0000-1000-8000-111111111112         |
    And I see 201 status code in response

    And I create an account with the following parameters
      | name                  | legal_name                 | registration_id                       | type    | store_id                             |
      | accountCreateTestName | accountCreateTestLegalName | 00000000-0000-1000-8000-2222222222212 | account | 00000000-0000-1000-8000-000000000000 |
    And I see 201 status code in response
    And I create an account membership with the following parameters
      | account_id | store_id                             | account_member_id                    |
      | <last>     | 00000000-0000-1000-8000-000000000000 | 00000000-0000-1000-8000-111111111112 |
    And I see 201 status code in response
    And I create an account membership with the following parameters
      | account_id | store_id                             | account_member_id                    |
      | <last>     | 00000000-0000-1000-8000-000000000000 | 00000000-0000-1000-8000-111111111113 |
    And I see 201 status code in response

    And I create an account with the following parameters
      | name                  | legal_name                 | registration_id                       | type    | store_id                             |
      | accountCreateTestName | accountCreateTestLegalName | 00000000-0000-1000-8000-2222222222213 | account | 00000000-0000-1000-8000-000000000001 |
    And I see 201 status code in response
    And I create an account membership with the following parameters
      | account_id | store_id                             | account_member_id                    |
      | <last>     | 00000000-0000-1000-8000-000000000001 | 00000000-0000-1000-8000-111111111114 |
    And I see 201 status code in response

  Scenario Outline:  When I read the first account, which has 1 membership, I see only 1 membership
    When I read all account memberships with the following parameters
      | account_id   | store_id   | page-limit | page-offset |
      | <previous-1> | <STORE_ID> | 3          | 0           |
    Then I see 200 status code in response
    And I see 1 account membership in the returned data with the following parameters
      | account_id   | account_member_id |
      | <previous-1> | <USER_ID>         |
    And The following links are populated
      | current | first | last | next | prev |
      | X       | X     | X    |      |      |
    And The page metadata section matches
      | limit   | 3 |
      | offset  | 0 |
      | current | 1 |
      | total   | 1 |
    And The metadata result total is 1

    Examples:
      | STORE_ID                             | USER_ID                              |
      | 00000000-0000-1000-8000-000000000000 | 00000000-0000-1000-8000-111111111112 |

  Scenario Outline:  When I read the second account, which has 2 memberships, I see 2 memberships
    When I read all account memberships with the following parameters
      | account_id   | store_id   | page-limit | page-offset |
      | <previous-2> | <STORE_ID> | 3          | 0           |
    Then I see 200 status code in response
    And I see 2 account memberships in the returned data with the following parameters
      | account_id   | account_member_id    |
      | <previous-2> | <USER_ID>,<USER_ID2> |
    And The following links are populated
      | current | first | last | next | prev |
      | X       | X     | X    |      |      |
    And The page metadata section matches
      | limit   | 3 |
      | offset  | 0 |
      | current | 1 |
      | total   | 1 |
    And The metadata result total is 2

    Examples:
      | STORE_ID                             | USER_ID                              | USER_ID2                             |
      | 00000000-0000-1000-8000-000000000000 | 00000000-0000-1000-8000-111111111112 | 00000000-0000-1000-8000-111111111113 |

  Scenario Outline:  When I read the third account, from a different store which has 1 membership, I see only 1 membership
    When I read all account memberships with the following parameters
      | account_id   | store_id    | page-limit | page-offset |
      | <previous-3> | <STORE_ID2> | 3          | 0           |
    Then I see 200 status code in response
    And I see 1 account membership in the returned data with the following parameters
      | account_id   | account_member_id |
      | <previous-3> | <USER_ID3>        |
    And The following links are populated
      | current | first | last | next | prev |
      | X       | X     | X    |      |      |
    And The page metadata section matches
      | limit   | 3 |
      | offset  | 0 |
      | current | 1 |
      | total   | 1 |
    And The metadata result total is 1

    Examples:
      | STORE_ID2                             | USER_ID3                             |
      | 00000000-0000-1000-8000-000000000001  | 00000000-0000-1000-8000-111111111114 |

  Scenario Outline:  When I read the first account, with a different store id, then I get account not found failure
    When I read all account memberships with the following parameters
      | account_id   | store_id    | page-limit | page-offset |
      | <previous-1> | <STORE_ID2> | 3          | 0           |
    Then I see 404 status code in response
    And I see error response with the following parameters
      | status | title       | detail                                                                                                                     |
      | 404    | Not Found | account not found |

    Examples:
      | STORE_ID2                             |
      | 00000000-0000-1000-8000-000000000001  |

