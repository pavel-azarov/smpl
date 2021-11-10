Feature: Update Account Membership

  Background:
    Given I reset DB and mocks

  Scenario Outline: Update Account Membership - happy path, validate account member id cannot be updated
    When I mock EAS to return a successful Authentication Realm creation response with the following parameters
      | realmId    |
      | <REALM_ID> |
    And I mock EAS to return a successful user-authentication-info response with the following parameters
      | realmId    | userId    |
      | <REALM_ID> | <USER_ID> |
    And I create an account with the following parameters
      | name   | legal_name   | registration_id           | type   | store_id   |
      | <NAME> | <LEGAL_NAME> | <REGISTRATION_ID_PARENT>1 | <TYPE> | <STORE_ID> |
    Then I see 201 status code in response
    When I create an account membership with the following parameters
      | account_id | store_id   | account_member_id |
      | <last>     | <STORE_ID> | <USER_ID>         |
    Then I see 201 status code in response
    And I see the following parameters in Account Membership response
      | account_member_id |
      | <USER_ID>         |
    When I update an account membership with the following parameters
      | account_id | store_id   | account_member_id | account_membership_id |
      | <last>     | <STORE_ID> | <USER_ID>         | <last>                |
    Then I see 200 status code in response
    And I see the following parameters in Account Membership response
      | account_member_id |
      | <USER_ID>         |
    When I update an account membership with the following parameters
      | account_id | store_id   | account_member_id | account_membership_id |
      | <last>     | <STORE_ID> | <USER_ID2>        | <last>                |
    Then I see 400 status code in response
    And I see error response with the following parameters
      | status | title       | detail                           |
      | 400    | Bad Request | the account member did not match |

    Examples:
      | STORE_ID                             | REALM_ID                             | USER_ID                              | USER_ID2                             | NAME                  | LEGAL_NAME                 | REGISTRATION_ID_PARENT               | TYPE    |
      | 00000000-0000-1000-8000-000000000000 | 00000000-0000-1000-8000-111111111111 | 00000000-0000-1000-8000-111111111112 | 00000000-0000-1000-8000-111111111113 | accountCreateTestName | accountCreateTestLegalName | 00000000-0000-1000-8000-222222222221 | account |

  Scenario Outline: Update Account Membership - updating a membership scoped by another store fails
    Given I mock EAS to return a successful Authentication Realm creation response with the following parameters
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
    And I see 201 status code in response
    And I create an account membership with the following parameters
      | account_id | store_id   | account_member_id |
      | <last>     | <STORE_ID> | <USER_ID>         |
    And I see 201 status code in response
    And I create an account with the following parameters
      | name   | legal_name   | registration_id           | type   | store_id    |
      | <NAME> | <LEGAL_NAME> | <REGISTRATION_ID_PARENT>2 | <TYPE> | <STORE_ID2> |
    And I see 201 status code in response
    And I create an account membership with the following parameters
      | account_id | store_id    | account_member_id |
      | <last>     | <STORE_ID2> | <USER_ID2>        |
    And I see 201 status code in response

    When I update an account membership with the following parameters
      | account_id | store_id   | account_membership_id |
      | <last>     | <STORE_ID> | <last>                |
    Then I see 404 status code in response
    And I see error response with the following parameters
      | status | title     | detail                                                               |
      | 404    | Not Found | Repository.GetAccountMembership failed: account membership not found |

    Examples:
      | STORE_ID                             | STORE_ID2                            | REALM_ID                             | USER_ID                              | USER_ID2                             | NAME                  | LEGAL_NAME                 | REGISTRATION_ID_PARENT               | TYPE    |
      | 00000000-0000-1000-8000-000000000000 | 00000000-0000-1000-8000-000000000001 | 00000000-0000-1000-8000-111111111111 | 00000000-0000-1000-8000-111111111222 | 00000000-0000-1000-8000-111111111333 | accountCreateTestName | accountCreateTestLegalName | 00000000-0000-1000-8000-222222222221 | account |
