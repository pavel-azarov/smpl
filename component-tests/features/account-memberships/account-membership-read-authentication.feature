Feature: Account Read Authentication Tests

  Background:
    Given I reset DB and mocks
    When I mock EAS to return a successful Authentication Realm creation response with the following parameters
      | realmId                              |
      | 00000000-0000-1000-8000-111111111111 |
    And I mock EAS to return a successful user-authentication-info response with the following parameters
      | realmId                              | userId      |
      | 00000000-0000-1000-8000-111111111111 | 00000000-0000-1000-8000-111111111112 |
    And I mock EAS to return a successful user-authentication-info response with the following parameters
      | realmId                              | userId      |
      | 00000000-0000-1000-8000-111111111111 | 00000000-0000-1000-8000-111111111122 |
    When I create an account with the following parameters
      | name   | legal_name   | registration_id                      | type   | store_id     |
      | accountCreateTestName | accountCreateTestLegalName | 00000000-0000-1000-8000-222222222222 | account | 00000000-0000-1000-8000-000000000000 |
    Then I see 201 status code in response
    When I create an account membership with the following parameters
      | account_id | store_id     | account_member_id |
      | <last>     | 00000000-0000-1000-8000-000000000000 | 00000000-0000-1000-8000-111111111112       |
    Then I see 201 status code in response
    When I create an account membership with the following parameters
      | account_id | store_id     | account_member_id |
      | <last>     | 00000000-0000-1000-8000-000000000000 | 00000000-0000-1000-8000-111111111122       |
    Then I see 201 status code in response
    When I mock EAS to return a successful user-authentication-info response with the following parameters
      | realmId                              | userId      |
      | 00000000-0000-1000-8000-111111111111 | 00000000-0000-1000-8000-111111111133 |
    And I create an account with the following parameters
      | name   | legal_name   | registration_id                      | type   | store_id                             |
      | accountCreateTestName | accountCreateTestLegalName | 00000000-0000-2000-8000-222222222222 | account | 00000000-0000-1000-8000-000000000000 |
    Then I see 201 status code in response
    When I create an account membership with the following parameters
      | account_id | store_id                             | account_member_id                    |
      | <last>     | 00000000-0000-1000-8000-000000000000 | 00000000-0000-1000-8000-111111111133 |
    Then I see 201 status code in response
    When I create an account membership with the following parameters
      | account_id | store_id     | account_member_id |
      | <last>     | 00000000-0000-1000-8000-000000000000 | 00000000-0000-1000-8000-111111111112       |
    Then I see 201 status code in response

  Scenario Outline: Read Account Memberships - read all account memberships by authenticated Account Member
    When I create an account with the following parameters
      | name   | legal_name   | registration_id     | type   | store_id     |
      | <NAME> | <LEGAL_NAME> | <REGISTRATION_ID_2> | <TYPE> | <STORE_ID_2> |
    Then I see 201 status code in response
    When I create an account membership with the following parameters
      | account_id | store_id     | account_member_id |
      | <last>     | <STORE_ID_2> | <USER_ID_3>       |
    Then I see 201 status code in response
    When I read all account memberships with the following parameters
      | account_id   | store_id     | EP-Internal-Account-Id |
      | <previous-1> | <STORE_ID_1> | <previous-1>                     |
    Then I see 200 status code in response
    And I see 2 account memberships in the returned data with the following parameters
      | account_id   | account_member_id    |
      | <previous-1> | <USER_ID_1>,<USER_ID_2> |
    When I read all account memberships with the following parameters
      | account_id   | store_id     | EP-Internal-Account-Id |
      | <previous> | <STORE_ID_1> | <previous-1>             |
    Then I see 404 status code in response
    And I see error response with the following parameters
      | status | title     | detail             |
      | 404    | Not Found | account not found  |
    Examples:
      | NAME                  | LEGAL_NAME                 | REGISTRATION_ID_2                    | TYPE    | STORE_ID_1                           | STORE_ID_2                           |USER_ID_1                            | USER_ID_2                            | USER_ID_3                            |
      | accountCreateTestName | accountCreateTestLegalName | 00000000-0000-2000-8000-222222222222 | account | 00000000-0000-1000-8000-000000000000 | 00000000-0000-2000-8000-000000000000 |00000000-0000-1000-8000-111111111112 | 00000000-0000-1000-8000-111111111122 | 00000000-0000-1000-8000-111111111133  |

  Scenario Outline: Read Account Memberships - read all account memberships by authenticated Account Member
    When I read an account membership with the following parameters
      | account_id | store_id   | account_membership_id | EP-Internal-Account-Id |
      | previous-1 | <STORE_ID_1> | previous-1          | <previous>         |
    Then I see 200 status code in response
    And I see the following parameters in Account Membership response
      | account_member_id |
      | <USER_ID_1>         |
    When I read an account membership with the following parameters
      | account_id | store_id   | account_membership_id     | EP-Internal-Account-Id |
      | previous-1 | <STORE_ID_1> | previous-2                | <previous>           |
    Then I see 200 status code in response
    And I see the following parameters in Account Membership response
      | account_member_id   |
      | <USER_ID_2>         |
    When I read all account memberships with the following parameters
      | account_id   | store_id     | EP-Internal-Account-Id |
      | <last>       | <STORE_ID_1> | <previous>             |
    Then I see 404 status code in response
    And I see error response with the following parameters
      | status | title     | detail             |
      | 404    | Not Found | account not found  |
    Examples:
      | STORE_ID_1                           | USER_ID_1                            | USER_ID_2                            |
      | 00000000-0000-1000-8000-000000000000 | 00000000-0000-1000-8000-111111111112 | 00000000-0000-1000-8000-111111111122 |
