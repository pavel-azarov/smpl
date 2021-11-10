Feature: Account Create Operation Tests

  Background:
    Given I reset DB and mocks
    And I create a queue to listen to the AM events with routing key "account.event.created"

  Scenario Outline: Create Account - happy path
    Given I reset DB and mocks
    When I create an account with the following parameters
      | name   | legal_name   | registration_id          | type   | store_id   |
      | <NAME> | <LEGAL_NAME> | <REGISTRATION_ID_PARENT> | <TYPE> | <STORE_ID> |
    And I see exactly 1 emitted CloudEvent with routing key "account.event.created", type "account.event.created" with the following parameters
      | name   | legal_name   | registration_id   |
      | <NAME> | <LEGAL_NAME> | <REGISTRATION_ID_PARENT> |
    When I create an account with the following parameters
      | name   | legal_name   | registration_id   | type   | store_id   | parent_id |
      | <NAME> | <LEGAL_NAME> | <REGISTRATION_ID> | <TYPE> | <STORE_ID> | last      |
    Then I see 201 status code in response
    And I see the following properties in the returned Account object
      | name   | legal_name   | registration_id   | parent_id | type    | id  |
      | <NAME> | <LEGAL_NAME> | <REGISTRATION_ID> | previous  | account | any |
    When I read an account passing the following parameters
      | store_id   | id     |
      | <STORE_ID> | <last> |
    Then I see 200 status code in response
    And I see the following properties in the returned Account object
      | name   | legal_name   | registration_id   | parent_id | type    | id  |
      | <NAME> | <LEGAL_NAME> | <REGISTRATION_ID> | previous  | account | any |

    Examples:
      | NAME                  | LEGAL_NAME                 | REGISTRATION_ID                      | REGISTRATION_ID_PARENT               | TYPE    | STORE_ID                             |
      | accountCreateTestName | accountCreateTestLegalName | 00000000-0000-1000-8000-222222222222 | 00000000-0000-1000-8000-222222222221 | account | 00000000-0000-1000-8000-000000000000 |

  Scenario Outline: Create Account - operations should fail with wrong type value
    Given I reset DB and mocks
    When I create an account with the following parameters
      | name   | legal_name   | registration_id   | type  | store_id   |
      | <NAME> | <LEGAL_NAME> | <REGISTRATION_ID> | wrong | <STORE_ID> |
    Then I see 422 status code in response
    And I see error response with the following parameters
      | status | title                | detail                                                     |
      | 422    | Unprocessable Entity | Validation failed: field 'Type' on the 'account-type' tag. |

    Examples:
      | NAME                  | LEGAL_NAME                 | REGISTRATION_ID                      | STORE_ID                             |
      | accountCreateTestName | accountCreateTestLegalName | 00000000-0000-1000-8000-222222222222 | 00000000-0000-1000-8000-000000000000 |

  Scenario Outline: Create Account - operations should fail with empty store_id
    Given I reset DB and mocks
    When I create an account with the following parameters
      | name   | legal_name   | registration_id   | type    | store_id |
      | <NAME> | <LEGAL_NAME> | <REGISTRATION_ID> | account |          |
    Then I see 400 status code in response
    And I see error response with the following parameters
      | status | title       | detail                                                             |
      | 400    | Bad Request | Validation failed: field 'XMoltinAuthStore' on the 'required' tag. |
    When I create an account with the following parameters
      | name   | legal_name   | registration_id   | type    |
      | <NAME> | <LEGAL_NAME> | <REGISTRATION_ID> | account |
    Then I see 400 status code in response
    And I see error response with the following parameters
      | status | title       | detail                                                             |
      | 400    | Bad Request | Validation failed: field 'XMoltinAuthStore' on the 'required' tag. |
    Examples:
      | NAME                  | LEGAL_NAME                 | REGISTRATION_ID                      |
      | accountCreateTestName | accountCreateTestLegalName | 00000000-0000-1000-8000-222222222222 |

  Scenario Outline: wrong method for create Account endpoint
    And I use HTTP method "<METHOD>" when calling create Account endpoint with the following properties
      | name                | legal_name               | registration_id                      | store_id                             |
      | wrongMethodTestName | wrongMethodTestLegalName | 88888888-4444-4333-8333-111111111113 | 88888888-4444-4333-8333-111111111111 |
    Then I see 405 status code in response

    Examples:
      | METHOD |
      | PUT    |
      | DELETE |
