Feature: Read Account Membership

  Background:
    Given I reset DB and mocks
    And I create a queue to listen to the AM events with routing key "account-membership.event.created"

  Scenario Outline: Create Account Membership - happy path, subsequent reads return data from Account Management
    When I mock EAS to return a successful Authentication Realm creation response with the following parameters
      | realmId    |
      | <REALM_ID> |
    And I mock EAS to return a successful user-authentication-info response with the following parameters
      | realmId    | userId    |
      | <REALM_ID> | <USER_ID> |
    And I create an account with the following parameters
      | name   | legal_name   | registration_id           | type   | store_id   |
      | <NAME> | <LEGAL_NAME> | <REGISTRATION_ID_PARENT>1 | <TYPE> | <STORE_ID> |
    And I create an account with the following parameters
      | name   | legal_name   | registration_id           | type   | store_id   |
      | <NAME> | <LEGAL_NAME> | <REGISTRATION_ID_PARENT>2 | <TYPE> | <STORE_ID> |
    Then I see 201 status code in response
    When I create an account membership with the following parameters
      | account_id | store_id   | account_member_id |
      | <last>     | <STORE_ID> | <USER_ID>         |
    Then I see 201 status code in response
    And I see the following parameters in Account Membership response
      | account_member_id |
      | <USER_ID>         |
    When I read an account membership with the following parameters
      | account_id | store_id   | account_membership_id |
      | <last>     | <STORE_ID> | <last>                |
    Then I see 200 status code in response
    And I see the following parameters in Account Membership response
      | account_member_id |
      | <USER_ID>         |
    And I see exactly 1 emitted CloudEvent with routing key "account-membership.event.created", type "account-membership.event.created" with the following parameters
      | account_id |
      | <last>     |
    When I create an account membership with the following parameters
      | account_id | store_id   | account_member_id |
      | <previous> | <STORE_ID> | <USER_ID>         |
    Then I see 201 status code in response
    And I see the following parameters in Account Membership response
      | account_member_id |
      | <USER_ID>         |
    And I see 201 status code in response
    When I read an account membership with the following parameters
      | account_id | store_id   | account_membership_id |
      | <previous> | <STORE_ID> | <last>                |
    Then I see 200 status code in response
    And I see the following parameters in Account Membership response
      | account_member_id |
      | <USER_ID>         |
    And The mocked endpoint for URL path "/v2/authentication-realms/<REALM_ID>/user-authentication-info/<USER_ID>" and method "GET" is called 1 times
    When I mock EAS to return a successful user-authentication-info response with the following parameters
      | realmId    | userId     |
      | <REALM_ID> | <USER_ID2> |
    And I create an account membership with the following parameters
      | account_id | store_id   | account_member_id |
      | <previous> | <STORE_ID> | <USER_ID2>        |
    Then I see 201 status code in response
    And I see the following parameters in Account Membership response
      | account_member_id |
      | <USER_ID2>        |
    When I read an account membership with the following parameters
      | account_id | store_id   | account_membership_id |
      | <previous> | <STORE_ID> | <last>                |
    Then I see 200 status code in response
    And I see the following parameters in Account Membership response
      | account_member_id |
      | <USER_ID2>        |
    Examples:
      | STORE_ID                             | REALM_ID                             | USER_ID                              | USER_ID2                             | NAME                  | LEGAL_NAME                 | REGISTRATION_ID_PARENT               | TYPE    |
      | 00000000-0000-1000-8000-000000000000 | 00000000-0000-1000-8000-111111111111 | 00000000-0000-1000-8000-111111111112 | 00000000-0000-1000-8000-111111111113 | accountCreateTestName | accountCreateTestLegalName | 00000000-0000-1000-8000-222222222221 | account |


  Scenario Outline: Create Account Membership - creating an account membership with a non-existent Account Member fails
    When I mock EAS to return a successful Authentication Realm creation response with the following parameters
      | realmId    |
      | <REALM_ID> |
    And I mock EAS to return an unsuccessful user-authentication-info response with the following parameters
      | realmId    | userId    |
      | <REALM_ID> | <USER_ID> |
    And I create an account with the following parameters
      | name   | legal_name   | registration_id           | type   | store_id   |
      | <NAME> | <LEGAL_NAME> | <REGISTRATION_ID_PARENT>1 | <TYPE> | <STORE_ID> |
    And I see 201 status code in response
    When I create an account membership with the following parameters
      | account_id | store_id   | account_member_id |
      | <last>     | <STORE_ID> | <USER_ID>         |
    Then I see 404 status code in response
    And I see error response with the following parameters
      | status | title     | detail    |
      | 404    | Not Found | not found |

    Examples:
      | STORE_ID                             | REALM_ID                             | USER_ID                              | NAME                  | LEGAL_NAME                 | REGISTRATION_ID_PARENT               | TYPE    |
      | 00000000-0000-1000-8000-000000000000 | 00000000-0000-1000-8000-111111111111 | 00000000-0000-1000-8000-111111111112 | accountCreateTestName | accountCreateTestLegalName | 00000000-0000-1000-8000-222222222221 | account |


  Scenario Outline: Create Account Membership - creating an account membership with an account scoped by another store fails
    When I mock EAS to return a successful Authentication Realm creation response with the following parameters
      | realmId    |
      | <REALM_ID> |
    And I mock EAS to return a successful user-authentication-info response with the following parameters
      | realmId    | userId    |
      | <REALM_ID> | <USER_ID> |
    And I create an account with the following parameters
      | name   | legal_name   | registration_id           | type   | store_id   |
      | <NAME> | <LEGAL_NAME> | <REGISTRATION_ID_PARENT>1 | <TYPE> | <STORE_ID> |
    And I create an account with the following parameters
      | name   | legal_name   | registration_id           | type   | store_id    |
      | <NAME> | <LEGAL_NAME> | <REGISTRATION_ID_PARENT>2 | <TYPE> | <STORE_ID2> |
    Then I see 201 status code in response
    When I create an account membership with the following parameters
      | account_id | store_id    | account_member_id |
      | <previous> | <STORE_ID2> | <USER_ID>         |
    Then I see 404 status code in response
    And I see error response with the following parameters
      | status | title     | detail            |
      | 404    | Not Found | account not found |

    Examples:
      | STORE_ID                             | STORE_ID2                            | REALM_ID                             | USER_ID                              | NAME                  | LEGAL_NAME                 | REGISTRATION_ID_PARENT               | TYPE    |
      | 00000000-0000-1000-8000-000000000000 | 00000000-0000-1000-8000-000000000001 | 00000000-0000-1000-8000-111111111111 | 00000000-0000-1000-8000-111111111112 | accountCreateTestName | accountCreateTestLegalName | 00000000-0000-1000-8000-222222222221 | account |

  Scenario Outline: Create Account Membership - creating a duplicate account membership fails
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
    When I create an account membership with the following parameters
      | account_id | store_id   | account_member_id |
      | <last>     | <STORE_ID> | <USER_ID>         |
    Then I see 409 status code in response
    And I see error response with the following parameters
      | status | title    | detail                                                                            |
      | 409    | Conflict | account membership with the given account id and account member id already exists |

    Examples:
      | STORE_ID                             | REALM_ID                             | USER_ID                              | NAME                  | LEGAL_NAME                 | REGISTRATION_ID_PARENT               | TYPE    |
      | 00000000-0000-1000-8000-000000000000 | 00000000-0000-1000-8000-111111111111 | 00000000-0000-1000-8000-111111111112 | accountCreateTestName | accountCreateTestLegalName | 00000000-0000-1000-8000-222222222221 | account |

  Scenario Outline: Create Account Membership - wrong entity type fails
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
      | account_id | store_id   | account_member_id | type       |
      | <last>     | <STORE_ID> | <USER_ID>         | wrong-type |
    Then I see 422 status code in response
    And I see error response with the following parameters
      | status | title                | detail                                                                |
      | 422    | Unprocessable Entity | Validation failed: field 'Type' on the 'account-membership-type' tag. |
    Examples:
      | STORE_ID                             | REALM_ID                             | USER_ID                              | NAME                  | LEGAL_NAME                 | REGISTRATION_ID_PARENT               | TYPE    |
      | 00000000-0000-1000-8000-000000000000 | 00000000-0000-1000-8000-111111111111 | 00000000-0000-1000-8000-111111111112 | accountCreateTestName | accountCreateTestLegalName | 00000000-0000-1000-8000-222222222221 | account |

  Scenario Outline: Create Account Membership - creating a membership with an account member scoped by different store fails
    When I mock EAS to return a successful Authentication Realm creation response with the following parameters
      | realmId    |
      | <REALM_ID> |
    And I mock EAS to return a successful user-authentication-info response with the following parameters
      | realmId    | userId    |
      | <REALM_ID> | <USER_ID> |
    And I read Account Member with id "<USER_ID>" and store id "<STORE_ID2>"
    And I create an account with the following parameters
      | name   | legal_name   | registration_id           | type   | store_id   |
      | <NAME> | <LEGAL_NAME> | <REGISTRATION_ID_PARENT>1 | <TYPE> | <STORE_ID> |
    Then I see 201 status code in response
    And I mock EAS to return an unsuccessful user-authentication-info response with the following parameters
      | realmId    | userId    |
      | <REALM_ID> | <USER_ID> |
    When I create an account membership with the following parameters
      | account_id | store_id   | account_member_id |
      | <last>     | <STORE_ID> | <USER_ID>         |
    Then I see 404 status code in response
    And I see error response with the following parameters
      | status | title     | detail    |
      | 404    | Not Found | not found |

    Examples:
      | STORE_ID                             | STORE_ID2                            | REALM_ID                             | USER_ID                              | NAME                  | LEGAL_NAME                 | REGISTRATION_ID_PARENT               | TYPE    |
      | 00000000-0000-1000-8000-000000000000 | 00000000-0000-1000-8000-000000000001 | 00000000-0000-1000-8000-111111111111 | 00000000-0000-1000-8000-111111111111 | accountCreateTestName | accountCreateTestLegalName | 00000000-0000-1000-8000-222222222221 | account |

  Scenario Outline: wrong method for get Account Memberships endpoint
    And I use HTTP method "<METHOD>" when calling create Account Memberships endpoint
    Then I see 405 status code in response

    Examples:
      | METHOD |
      | PUT    |
      | DELETE |

  Scenario Outline: Create Account Membership - attempt to create account memberships over limit fails
    When I create one account
      | name                   | legal_name                  | registration_id                      | store_id   | realmId    |
      | accCreateLimitTestName | accCreateLimitTestLegalName | 00000000-0000-1000-8000-222222222221 | <STORE_ID> | <REALM_ID> |
    When I create 1000 account members and account memberships - for the latter I expect response code 201
      | store_id   | realmId    | userId            |
      | <STORE_ID> | <REALM_ID> | <USER_ID_PREFIX>1 |
    When I create 1 account member and account membership - for the latter I expect response code 400
      | store_id   | realmId    | userId            |
      | <STORE_ID> | <REALM_ID> | <USER_ID_PREFIX>2 |
    And I see error response with the following parameters
      | status | title       | detail                                                                        |
      | 400    | Bad Request | the number of account memberships with a particular account exceeds the limit |
    Examples:
      | STORE_ID                             | REALM_ID                             | USER_ID_PREFIX                  |
      | 00000000-0000-1000-8000-000000000000 | 00000000-0000-1000-8000-111111111111 | 00000000-0000-1000-8000-1111111 |

