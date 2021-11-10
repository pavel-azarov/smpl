Feature: Read Account Membership

  Background:
    Given I reset DB and mocks
    And I mock EAS to return a successful Authentication Realm creation response with the following parameters
      | realmId                              |
      | 00000000-0000-1000-8000-111111111111 |
    And I mock EAS to return a successful user-authentication-info response with the following parameters
      | realmId                              | userId                               |
      | 00000000-0000-1000-8000-111111111111 | 00000000-0000-1000-8000-111111111222 |

  Scenario Outline: Read Account Membership - reading a membership scoped by another store fails
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

    When I read an account membership with the following parameters
      | account_id | store_id   | account_membership_id |
      | <last>     | <STORE_ID> | <last>                |
    Then I see 404 status code in response
    And I see error response with the following parameters
      | status | title     | detail                                                               |
      | 404    | Not Found | Repository.GetAccountMembership failed: account membership not found |

    Examples:
      | STORE_ID                             | STORE_ID2                            | REALM_ID                             | USER_ID                              | USER_ID2                             | NAME                  | LEGAL_NAME                 | REGISTRATION_ID_PARENT               | TYPE    |
      | 00000000-0000-1000-8000-000000000000 | 00000000-0000-1000-8000-000000000001 | 00000000-0000-1000-8000-111111111111 | 00000000-0000-1000-8000-111111111222 | 00000000-0000-1000-8000-111111111333 | accountCreateTestName | accountCreateTestLegalName | 00000000-0000-1000-8000-222222222221 | account |

  Scenario Outline: Read Account Membership - reading an account membership with an account scoped by another store fails
    Given I create an account with the following parameters
      | name   | legal_name   | registration_id           | type   | store_id   |
      | <NAME> | <LEGAL_NAME> | <REGISTRATION_ID_PARENT>1 | <TYPE> | <STORE_ID> |
    And I create an account with the following parameters
      | name   | legal_name   | registration_id           | type   | store_id    |
      | <NAME> | <LEGAL_NAME> | <REGISTRATION_ID_PARENT>2 | <TYPE> | <STORE_ID2> |
    And I see 201 status code in response
    And I create an account membership with the following parameters
      | account_id | store_id    | account_member_id |
      | <last>     | <STORE_ID2> | <USER_ID>         |
    And I see 201 status code in response

    When I read an account membership with the following parameters
      | account_id | store_id    | account_membership_id |
      | <previous> | <STORE_ID2> | <USER_ID>             |
    Then I see 404 status code in response
    And I see error response with the following parameters
      | status | title     | detail                                                               |
      | 404    | Not Found | Repository.GetAccountMembership failed: account membership not found |

    Examples:
      | STORE_ID                             | STORE_ID2                            | USER_ID                              | NAME                  | LEGAL_NAME                 | REGISTRATION_ID_PARENT               | TYPE    |
      | 00000000-0000-1000-8000-000000000000 | 00000000-0000-1000-8000-000000000001 | 00000000-0000-1000-8000-111111111222 | accountCreateTestName | accountCreateTestLegalName | 00000000-0000-1000-8000-222222222221 | account |
