Feature: Read Unassigned Account Members

  Background:
    Given I reset DB and mocks
    When I mock EAS to return a successful Authentication Realm creation response with the following parameters
      | realmId    |
      | 00000000-1111-1111-8000-222222222222  |

  Scenario Outline: Read Unassigned Account Member - happy path
    When I create an account with the following parameters
      | name     | legal_name   | registration_id    | type    | store_id  |
      | <NAME>1 | <LEGAL_NAME>1 | <REGISTRATION_ID>1 | account | <STORE_ID> |
    When I create an account with the following parameters
      | name     | legal_name   | registration_id    | type    | store_id  |
      | <NAME>2 | <LEGAL_NAME>2 | <REGISTRATION_ID>2 | account | <STORE_ID> |
    And I mock EAS to return a successful user-authentication-info response 4 time with the following parameters
      | realmId    | namePrefix    | emailSuffix    | userIds                                         |
      | <REALM_ID> | <NAME_PREFIX> | <EMAIL_SUFFIX> | <USER_ID_1>,<USER_ID_2>,<USER_ID_3>,<USER_ID_4> |
    And I read Account Member with id "<USER_ID_4>" and store id "<STORE_ID>"
    Then I see 200 status code in response
    And I create an account membership with the following parameters
      | account_id | store_id   | account_member_id |
      | <previous> | <STORE_ID> | <USER_ID_1>       |
    And I create an account membership with the following parameters
      | account_id | store_id   | account_member_id |
      | <previous> | <STORE_ID> | <USER_ID_2>       |
    And I create an account membership with the following parameters
      | account_id | store_id   | account_member_id |
      | <last>     | <STORE_ID> | <USER_ID_2>       |
    And I create an account membership with the following parameters
      | account_id | store_id   | account_member_id |
      | <last>     | <STORE_ID> | <USER_ID_3>       |
    When I read unassigned account members list with following parameters
      | store_id   | account_id |
      | <STORE_ID> | <previous> |
    Then I see 200 status code in response
    And I see 2 account members in the returned data with following parameters
      | name_prefix   | email_suffix   | user_ids                |
      | <NAME_PREFIX> | <EMAIL_SUFFIX> | <USER_ID_3>,<USER_ID_4> |
    Examples:
      | REALM_ID                             | NAME                  | LEGAL_NAME                 | REGISTRATION_ID                      | STORE_ID                             | USER_ID_1                            | USER_ID_2                            | USER_ID_3                            | USER_ID_4                            | EMAIL_SUFFIX     | NAME_PREFIX  |  |
      | 00000000-1111-1111-8000-222222222222 | accountCreateTestName | accountCreateTestLegalName | 00000000-0000-1000-8000-222222222222 | 00000000-0000-1000-8000-000000000000 | 10000000-0000-1000-8000-000000000000 | 20000000-0000-1000-8000-000000000000 | 30000000-0000-1000-8000-000000000000 | 40000000-0000-1000-8000-000000000000 | @elasticpath.com | User with ID |  |

  Scenario Outline: Read Unassigned Account Member - some account members are scoped by another store
    When I create an account with the following parameters
      | name    | legal_name    | registration_id    | type    | store_id     |
      | <NAME>1 | <LEGAL_NAME>1 | <REGISTRATION_ID>1 | account | <STORE_ID_1> |
    When I create an account with the following parameters
      | name    | legal_name    | registration_id    | type    | store_id    |
      | <NAME>2 | <LEGAL_NAME>2 | <REGISTRATION_ID>2 | account | <STORE_ID_2> |
    And I mock EAS to return a successful user-authentication-info response 4 time with the following parameters
      | realmId    | namePrefix    | emailSuffix    | userIds                                         |
      | <REALM_ID> | <NAME_PREFIX> | <EMAIL_SUFFIX> | <USER_ID_1>,<USER_ID_2>,<USER_ID_3>,<USER_ID_4> |
    And I read Account Member with id "<USER_ID_2>" and store id "<STORE_ID_1>"
    Then I see 200 status code in response
    And I read Account Member with id "<USER_ID_4>" and store id "<STORE_ID_2>"
    Then I see 200 status code in response
    And I create an account membership with the following parameters
      | account_id | store_id    | account_member_id |
      | <previous> | <STORE_ID_1> | <USER_ID_1>       |
    And I create an account membership with the following parameters
      | account_id | store_id     | account_member_id |
      | <last>     | <STORE_ID_2> | <USER_ID_3>       |
    When I read unassigned account members list with following parameters
      | store_id    | account_id |
      | <STORE_ID_1> | <previous> |
    Then I see 200 status code in response
    And I see 1 account members in the returned data with following parameters
      | name_prefix   | email_suffix   | user_ids    |
      | <NAME_PREFIX> | <EMAIL_SUFFIX> | <USER_ID_2> |
    Examples:
      | REALM_ID                             | NAME                  | LEGAL_NAME                 | REGISTRATION_ID                      | STORE_ID_1                           | STORE_ID_2                           | USER_ID_1                            | USER_ID_2                            | USER_ID_3                            | USER_ID_4                            | EMAIL_SUFFIX     | NAME_PREFIX  |  |
      | 00000000-1111-1111-8000-222222222222 | accountCreateTestName | accountCreateTestLegalName | 00000000-0000-1000-8000-222222222222 | 00000000-0000-1000-8000-000000000000 | 00000000-0000-2000-8000-000000000000 | 10000000-0000-1000-8000-000000000000 | 20000000-0000-1000-8000-000000000000 | 30000000-0000-1000-8000-000000000000 | 40000000-0000-1000-8000-000000000000 | @elasticpath.com | User with ID |  |

  Scenario Outline: Try to read Unassigned Account Members with non-existent account id
    When I read unassigned account members list with following parameters
      | store_id   | account_id                           |
      | <STORE_ID> | 00000000-0000-1111-8000-000000000000 |
    Then I see 404 status code in response
    And I see error response with the following parameters
      | status | title     | detail            |
      | 404    | Not Found | account not found |
    Examples:
      | STORE_ID                             |
      | 00000000-0000-1000-8000-000000000000 |

  Scenario Outline: Read Unassigned Account Member - by correct account but another store or non-existent store
    When I create an account with the following parameters
      | name    | legal_name    | registration_id    | type    | store_id     |
      | <NAME>1 | <LEGAL_NAME>1 | <REGISTRATION_ID>1 | account | <STORE_ID_1> |
    When I create an account with the following parameters
      | name    | legal_name    | registration_id    | type    | store_id    |
      | <NAME>2 | <LEGAL_NAME>2 | <REGISTRATION_ID>2 | account | <STORE_ID_2> |
    And I mock EAS to return a successful user-authentication-info response 4 time with the following parameters
      | realmId    | namePrefix    | emailSuffix    | userIds                                         |
      | <REALM_ID> | <NAME_PREFIX> | <EMAIL_SUFFIX> | <USER_ID_1>,<USER_ID_2>,<USER_ID_3>,<USER_ID_4> |
    And I read Account Member with id "<USER_ID_2>" and store id "<STORE_ID_1>"
    Then I see 200 status code in response
    And I read Account Member with id "<USER_ID_4>" and store id "<STORE_ID_2>"
    Then I see 200 status code in response
    And I create an account membership with the following parameters
      | account_id | store_id    | account_member_id |
      | <previous> | <STORE_ID_1> | <USER_ID_1>       |
    And I create an account membership with the following parameters
      | account_id | store_id     | account_member_id |
      | <last>     | <STORE_ID_2> | <USER_ID_3>       |
    When I read unassigned account members list with following parameters
      | store_id     | account_id |
      | <STORE_ID_2> | <previous> |
    Then I see 404 status code in response
    And I see error response with the following parameters
      | status | title     | detail            |
      | 404    | Not Found | account not found |
    When I read unassigned account members list with following parameters
      | store_id                | account_id |
      | <NOT_EXISTENT_STORE_ID> | <previous> |
      Then I see 404 status code in response
      And I see error response with the following parameters
        | status | title     | detail            |
        | 404    | Not Found | account not found |
    Examples:
      | REALM_ID                             | NAME                  | LEGAL_NAME                 | REGISTRATION_ID                      | STORE_ID_1                           | STORE_ID_2                           | USER_ID_1                            | USER_ID_2                            | USER_ID_3                            | USER_ID_4                            | EMAIL_SUFFIX     | NAME_PREFIX  | NOT_EXISTENT_STORE_ID                |
      | 00000000-1111-1111-8000-222222222222 | accountCreateTestName | accountCreateTestLegalName | 00000000-0000-1000-8000-222222222222 | 00000000-0000-1000-8000-000000000000 | 00000000-0000-2000-8000-000000000000 | 10000000-0000-1000-8000-000000000000 | 20000000-0000-1000-8000-000000000000 | 30000000-0000-1000-8000-000000000000 | 40000000-0000-1000-8000-000000000000 | @elasticpath.com | User with ID | 70000000-0000-1000-8000-000000000000 |

  Scenario Outline: Read Unassigned Account Member - all account members are assigned to the account, the list should be empty.
    When I create an account with the following parameters
      | name    | legal_name    | registration_id    | type    | store_id   |
      | <NAME>1 | <LEGAL_NAME>1 | <REGISTRATION_ID>1 | account | <STORE_ID> |
    And I mock EAS to return a successful user-authentication-info response 4 time with the following parameters
      | realmId    | namePrefix    | emailSuffix    | userIds                 |
      | <REALM_ID> | <NAME_PREFIX> | <EMAIL_SUFFIX> | <USER_ID_1>,<USER_ID_2> |
    And I create an account membership with the following parameters
      | account_id | store_id   | account_member_id |
      | <last> | <STORE_ID> | <USER_ID_1>       |
    And I create an account membership with the following parameters
      | account_id | store_id   | account_member_id |
      | <last>     | <STORE_ID> | <USER_ID_2>       |
    When I read unassigned account members list with following parameters
      | store_id   | account_id |
      | <STORE_ID> | <last>        |
    Then I see 200 status code in response
    And I see 0 account members in the returned data
    Examples:
      | REALM_ID                             | NAME                  | LEGAL_NAME                 | REGISTRATION_ID                      | STORE_ID                             | USER_ID_1                            | USER_ID_2                            | NAME_PREFIX  | EMAIL_SUFFIX     |
      | 00000000-1111-1111-8000-222222222222 | accountCreateTestName | accountCreateTestLegalName | 00000000-0000-1000-8000-222222222222 | 00000000-0000-1000-8000-000000000000 | 10000000-0000-1000-8000-000000000000 | 20000000-0000-1000-8000-000000000000 | User with ID | @elasticpath.com |

  Scenario Outline: Read Unassigned Account Member - no account members are assigned to the account, the list should return all account members.
    When I create an account with the following parameters
      | name    | legal_name    | registration_id    | type    | store_id   |
      | <NAME>1 | <LEGAL_NAME>1 | <REGISTRATION_ID>1 | account | <STORE_ID> |
    And I mock EAS to return a successful user-authentication-info response 4 time with the following parameters
      | realmId    | namePrefix    | emailSuffix    | userIds                 |
      | <REALM_ID> | <NAME_PREFIX> | <EMAIL_SUFFIX> | <USER_ID_1>,<USER_ID_2> |
    And I read Account Member with id "<USER_ID_1>" and store id "<STORE_ID>"
    Then I see 200 status code in response
    And I read Account Member with id "<USER_ID_2>" and store id "<STORE_ID>"
    Then I see 200 status code in response
    When I read unassigned account members list with following parameters
      | store_id   | account_id |
      | <STORE_ID> | <last>        |
    Then I see 200 status code in response
    And I see 2 account members in the returned data with following parameters
      | name_prefix   | email_suffix   | user_ids                |
      | <NAME_PREFIX> | <EMAIL_SUFFIX> | <USER_ID_1>,<USER_ID_2> |
    Examples:
      | REALM_ID                             | NAME                  | LEGAL_NAME                 | REGISTRATION_ID                      | STORE_ID                             | USER_ID_1                            | USER_ID_2                            | NAME_PREFIX  | EMAIL_SUFFIX     |
      | 00000000-1111-1111-8000-222222222222 | accountCreateTestName | accountCreateTestLegalName | 00000000-0000-1000-8000-222222222222 | 00000000-0000-1000-8000-000000000000 | 10000000-0000-1000-8000-000000000000 | 20000000-0000-1000-8000-000000000000 | User with ID | @elasticpath.com |
