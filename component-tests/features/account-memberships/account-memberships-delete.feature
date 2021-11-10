Feature: Delete Account Membership

  Background:
    Given I reset DB and mocks
    And I create a queue to listen to the AM events with routing key "account-membership.event.deleted"

  Scenario Outline: Delete Account Membership - happy path
    When I mock EAS to return a successful Authentication Realm creation response with the following parameters
      | realmId    |
      | <REALM_ID> |
    And I mock EAS to return a successful user-authentication-info response with the following parameters
      | realmId    | userId    |
      | <REALM_ID> | <USER_ID> |
    And I mock EAS to return a successful user-authentication-info response with the following parameters
      | realmId    | userId     |
      | <REALM_ID> | <USER_ID2> |
    And I mock EAS to return a successful user-authentication-info response with the following parameters
      | realmId    | userId     |
      | <REALM_ID> | <USER_ID3> |
    And I create an account with the following parameters
      | name   | legal_name   | registration_id           | type   | store_id   |
      | <NAME> | <LEGAL_NAME> | <REGISTRATION_ID_PARENT>1 | <TYPE> | <STORE_ID> |
    Then I see 201 status code in response
    When I create an account membership with the following parameters
      | account_id | store_id   | account_member_id |
      | <last>     | <STORE_ID> | <USER_ID>         |
    Then I see 201 status code in response
    When I create an account membership with the following parameters
      | account_id | store_id   | account_member_id |
      | <last>     | <STORE_ID> | <USER_ID2>        |
    Then I see 201 status code in response
    And I create an account with the following parameters
      | name   | legal_name   | registration_id           | type   | store_id   |
      | <NAME> | <LEGAL_NAME> | <REGISTRATION_ID_PARENT>2 | <TYPE> | <STORE_ID> |
    Then I see 201 status code in response
    When I create an account membership with the following parameters
      | account_id | store_id   | account_member_id |
      | <last>     | <STORE_ID> | <USER_ID>         |
    Then I see 201 status code in response
    And I create an account with the following parameters
      | name   | legal_name   | registration_id           | type   | store_id    |
      | <NAME> | <LEGAL_NAME> | <REGISTRATION_ID_PARENT>3 | <TYPE> | <STORE_ID2> |
    Then I see 201 status code in response
    When I create an account membership with the following parameters
      | account_id | store_id    | account_member_id |
      | <last>     | <STORE_ID2> | <USER_ID3>        |
    Then I see 201 status code in response
    When I delete an account membership with the following parameters
      | account_id | store_id   | account_membership_id |
      | previous-1 | <STORE_ID> | previous-1            |
    And I see exactly 1 emitted CloudEvent with routing key "account-membership.event.deleted", type "account-membership.event.deleted" with the following parameters
      | account_id |
      | previous-1 |
    Then I see 204 status code in response
    When I read an account membership with the following parameters
      | account_id | store_id   | account_membership_id |
      | previous-1 | <STORE_ID> | previous-1            |
    Then I see 404 status code in response
    When I read an account membership with the following parameters
      | account_id | store_id   | account_membership_id |
      | previous-1 | <STORE_ID> | previous-2            |
    Then I see 200 status code in response
    When I read an account membership with the following parameters
      | account_id | store_id   | account_membership_id |
      | previous-2 | <STORE_ID> | previous-3            |
    Then I see 200 status code in response
    When I read an account membership with the following parameters
      | account_id | store_id    | account_membership_id |
      | previous-3 | <STORE_ID2> | previous-4            |
    Then I see 200 status code in response

    Examples:
      | STORE_ID                             | STORE_ID2                            | REALM_ID                             | USER_ID                              | USER_ID2                             | USER_ID3                             | NAME                  | LEGAL_NAME                 | REGISTRATION_ID_PARENT               | TYPE    |
      | 00000000-0000-1000-8000-000000000000 | 00000000-0000-1000-8000-000000000001 | 00000000-0000-1000-8000-111111111111 | 00000000-0000-1000-8000-111111111112 | 00000000-0000-1000-8000-111111111113 | 00000000-0000-1000-8000-111111111114 | accountCreateTestName | accountCreateTestLegalName | 00000000-0000-1000-8000-222222222221 | account |

  Scenario Outline: Delete Account Membership - attempt to delete a membership scoped by another store fails
    When I mock EAS to return a successful Authentication Realm creation response with the following parameters
      | realmId    |
      | <REALM_ID> |
    And I mock EAS to return a successful user-authentication-info response with the following parameters
      | realmId    | userId    |
      | <REALM_ID> | <USER_ID> |
    And I mock EAS to return a successful user-authentication-info response with the following parameters
      | realmId    | userId     |
      | <REALM_ID> | <USER_ID2> |
    And I create an account with the following parameters
      | name   | legal_name   | registration_id           | type   | store_id   |
      | <NAME> | <LEGAL_NAME> | <REGISTRATION_ID_PARENT>1 | <TYPE> | <STORE_ID> |
    Then I see 201 status code in response
    When I create an account membership with the following parameters
      | account_id | store_id   | account_member_id |
      | <last>     | <STORE_ID> | <USER_ID>         |
    Then I see 201 status code in response
    And I create an account with the following parameters
      | name   | legal_name   | registration_id           | type   | store_id    |
      | <NAME> | <LEGAL_NAME> | <REGISTRATION_ID_PARENT>2 | <TYPE> | <STORE_ID2> |
    Then I see 201 status code in response
    When I create an account membership with the following parameters
      | account_id | store_id    | account_member_id |
      | <last>     | <STORE_ID2> | <USER_ID2>        |
    Then I see 201 status code in response
    When I delete an account membership with the following parameters
      | account_id | store_id   | account_membership_id |
      | previous-2 | <STORE_ID> | previous-2            |
    Then I see 404 status code in response
    When I read an account membership with the following parameters
      | account_id | store_id   | account_membership_id |
      | previous-1 | <STORE_ID> | previous-1            |
    Then I see 200 status code in response
    When I read an account membership with the following parameters
      | account_id | store_id    | account_membership_id |
      | previous-2 | <STORE_ID2> | previous-2            |
    Then I see 200 status code in response

    Examples:
      | STORE_ID                             | STORE_ID2                            | REALM_ID                             | USER_ID                              | USER_ID2                             | NAME                  | LEGAL_NAME                 | REGISTRATION_ID_PARENT               | TYPE    |
      | 00000000-0000-1000-8000-000000000000 | 00000000-0000-1000-8000-000000000001 | 00000000-0000-1000-8000-111111111111 | 00000000-0000-1000-8000-111111111112 | 00000000-0000-1000-8000-111111111113 | accountCreateTestName | accountCreateTestLegalName | 00000000-0000-1000-8000-222222222221 | account |
