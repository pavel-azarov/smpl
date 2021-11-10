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
      | name                  | legal_name                 | registration_id                      | type    | store_id                             |
      | accountCreateTestName | accountCreateTestLegalName | 00000000-0000-1000-8000-222222222222 | account | 00000000-0000-1000-8000-000000000000 |
    Then I see 201 status code in response

  Scenario Outline: Read Account - read an account by authenticated Account Member
    When I create an account membership with the following parameters
      | account_id | store_id   | account_member_id |
      | <last>     | <STORE_ID> | <USER_ID>         |
    Then I see 201 status code in response
    When I read an account passing the following parameters
      | store_id     | id     | EP-Internal-Account-Id |
      | <STORE_ID> | <last> | <last>                |
    Then I see 200 status code in response
    And I see the following properties in the returned Account object
      | name   | legal_name   | registration_id    | type    | id  |
      | <NAME> | <LEGAL_NAME> | <REGISTRATION_ID>   | account | any |

    Examples:
      | NAME                  | LEGAL_NAME                 | REGISTRATION_ID                       | STORE_ID                             | USER_ID                              |
      | accountCreateTestName | accountCreateTestLegalName | 00000000-0000-1000-8000-222222222222  | 00000000-0000-1000-8000-000000000000 | 00000000-0000-1000-8000-111111111112 |

  Scenario Outline: Read Account - read an account by authenticated Account Member when there is no membership between them
    When I create an account membership with the following parameters
      | account_id | store_id   | account_member_id |
      | <last>     | <STORE_ID> | <USER_ID>         |
    Then I see 201 status code in response
    And I create an account with the following parameters
      | name   | legal_name   | registration_id           | type   | store_id   |
      | <NAME> | <LEGAL_NAME> | <REGISTRATION_ID_1> | <TYPE> | <STORE_ID> |
    Then I see 201 status code in response
    When I read an account passing the following parameters
      | store_id     | id     | EP-Internal-Account-Id |
      | <STORE_ID> | <previous> | <last>                |
    Then I see 404 status code in response
    And I see error response with the following parameters
      | status | title     | detail             |
      | 404    | Not Found | account not found  |

    Examples:
      | NAME                  | LEGAL_NAME                 | REGISTRATION_ID_1                    | TYPE    | STORE_ID                             | USER_ID                             |
      | accountCreateTestName | accountCreateTestLegalName | 00000000-0000-1000-8000-222222223333 | account | 00000000-0000-1000-8000-000000000000 |00000000-0000-1000-8000-111111111112 |

  Scenario Outline: Read Account - read all accounts by authenticated Account Member
    And I create an account with the following parameters
      | name   | legal_name   | registration_id           | type   | store_id   |
      | <NAME> | <LEGAL_NAME> | <REGISTRATION_ID_1> | <TYPE> | <STORE_ID_1> |
    Then I see 201 status code in response
    When I create an account membership with the following parameters
      | account_id | store_id   | account_member_id |
      | <last>     | <STORE_ID_1> | <USER_ID>         |
    Then I see 201 status code in response
    And I create an account with the following parameters
      | name   | legal_name   | registration_id           | type   | store_id   |
      | <NAME> | <LEGAL_NAME> | <REGISTRATION_ID_1> | <TYPE> | <STORE_ID_2> |
    Then I see 201 status code in response
    When I read account list with following parameters
      | store_id     | EP-Internal-Account-Id |
      | <STORE_ID_1> |  <previous>                |
    Then I see 200 status code in response
    And I see one account in the returned data with the following parameters
      | name   | legal_name   | registration_id           | type      | id |
      | <NAME> | <LEGAL_NAME> | <REGISTRATION_ID_1> | <TYPE> |    <previous>     |

    Examples:
      | NAME                  | LEGAL_NAME                 | REGISTRATION_ID_1                    | TYPE    | STORE_ID_1                            | STORE_ID_2                            | USER_ID                               |
      | accountCreateTestName | accountCreateTestLegalName | 00000000-0000-1000-8000-222222223333 | account | 00000000-0000-1000-8000-000000000000  | 00000000-0000-2000-8000-000000000000  | 00000000-0000-1000-8000-111111111112  |
