Feature: Account Read Authentication Tests

  Background:
    Given I reset DB and mocks
    When I mock EAS to return a successful Authentication Realm creation response with the following parameters
      | realmId    |
      | 00000000-0000-1000-8000-111111111111 |
    And I mock EAS to return a successful user-authentication-info response with the following parameters
      | realmId                              | userId                               |
      | 00000000-0000-1000-8000-111111111111 | 00000000-0000-1000-8000-111111111112 |
    And I create an account with the following parameters
      | name                  | legal_name                  | registration_id                     | type    | store_id                             |
      | accountCreateTestName | accountCreateTestLegalName | 00000000-0000-1000-8000-222222222222 | account | 00000000-0000-1000-8000-000000000000 |
    Then I see 201 status code in response
    When I create an account membership with the following parameters
      | account_id | store_id                             | account_member_id                    |
      | <last>     | 00000000-0000-1000-8000-000000000000 | 00000000-0000-1000-8000-111111111112 |
    Then I see 201 status code in response

  Scenario Outline: Read Account Member - read an account member by authenticated Account Member
    When I read an account member passing the following parameters
      | store_id     | id     | EP-Internal-Account-Member-Id |
      | <STORE_ID> | <USER_ID> | <USER_ID>                |
    Then I see 200 status code in response
    And I see the following parameters in Account Member response
      | id        | name                   | email                     |
      | <USER_ID> | User with ID<USER_ID> | <USER_ID>@elasticpath.com |

    Examples:
      | STORE_ID                             |  USER_ID                              |
      | 00000000-0000-1000-8000-000000000000 |  00000000-0000-1000-8000-111111111112 |

  Scenario Outline: Read Account Member - read an account member which has a membership with the same account as authenticated Account Member
    When I mock EAS to return a successful user-authentication-info response with the following parameters
      | realmId    | userId      |
      | <REALM_ID> | <USER_ID_2> |
    When I create an account membership with the following parameters
      | account_id | store_id   | account_member_id |
      | <last>     | <STORE_ID> | <USER_ID_2>       |
    Then I see 201 status code in response
    When I read an account member passing the following parameters
      | store_id   | id          | EP-Internal-Account-Member-Id |
      | <STORE_ID> | <USER_ID_1> | <USER_ID_2>                   |
    Then I see 404 status code in response
    And I see error response with the following parameters
      | status | title     | detail             |
      | 404    | Not Found | account member not found  |

    Examples:
      |REALM_ID| STORE_ID                             | USER_ID_1                            | USER_ID_2                            |
      |00000000-0000-1000-8000-111111111111| 00000000-0000-1000-8000-000000000000 | 00000000-0000-1000-8000-111111111112 | 00000000-0000-1000-8000-111111111122 |

  Scenario Outline: Read Account Member- read all account members by authenticated Account Member
    When I mock EAS to return a successful user-authentication-info response with the following parameters
      | realmId    | userId    |
      | <REALM_ID> | <USER_ID_2> |
    When I create an account membership with the following parameters
      | account_id | store_id   | account_member_id |
      | <last>     | <STORE_ID_1> | <USER_ID_2>       |
    Then I see 201 status code in response

    And I mock EAS to return a successful user-authentication-info response with the following parameters
      | realmId    | userId      |
      | <REALM_ID> | <USER_ID_3> |
    When I create an account with the following parameters
      | name   | legal_name   | registration_id   | type   | store_id   |
      | <NAME> | <LEGAL_NAME> | <REGISTRATION_ID> | <TYPE> | <STORE_ID_2> |
    Then I see 201 status code in response
    When I create an account membership with the following parameters
      | account_id | store_id   | account_member_id |
      | <last>     | <STORE_ID_2> | <USER_ID_3>       |
    Then I see 201 status code in response
    When I read account members list with following parameters
      | store_id     | EP-Internal-Account-Member-Id     |
      | <STORE_ID_1> | <USER_ID_2>                        |
    Then I see 200 status code in response
    And I see 1 account member in the returned data with following parameters
      | name_prefix      | email_suffix     | user_ids   |
      | User with ID    | @elasticpath.com | <USER_ID_2>|

    Examples:
      | REALM_ID                             | NAME                  | LEGAL_NAME                 | REGISTRATION_ID                     | TYPE    | STORE_ID_1  |  STORE_ID_2                        | USER_ID_2 |USER_ID_3|
      | 00000000-0000-1000-8000-111111111111 | accountCreateTestName | accountCreateTestLegalName | 00000000-0000-1000-8000-222222222222| account | 00000000-0000-1000-8000-000000000000| 00000000-0000-2000-8000-000000000000 |00000000-0000-1000-8000-111111111122|00000000-0000-1000-8000-111111111133|
