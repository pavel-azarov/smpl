Feature: Account Create Validation Tests

  Scenario Outline: Create Account - validation
    Given I reset DB and mocks
    When I create an account with the following parameters
      | name         | legal_name  | registration_id                      | type    | store_id                             |
      | <STRING_255> | legal_name1 | 3e0db537-5b2c-4ee9-84cb-48b452df9da3 | account | 00000000-0000-1000-8000-000000000001 |
    Then I see 201 status code in response
    When I create an account with the following parameters
      | name          | legal_name  | registration_id                      | type    | store_id                             |
      | <STRING_255>1 | legal_name1 | bca74699-dd1e-4cdb-a322-52155ce9b7dd | account | 00000000-0000-1000-8000-000000000001 |
    Then I see 400 status code in response
    And I see error response with the following parameters
      | status | title       | detail                                            |
      | 400    | Bad Request | Validation failed: field 'Name' on the 'max' tag. |
    When I create an account with the following parameters
      | name  | legal_name   | registration_id                      | type    | store_id                             |
      | name2 | <STRING_255> | eebd9870-7508-436b-a1ab-563bd1d2b570 | account | 00000000-0000-1000-8000-000000000002 |
    Then I see 201 status code in response
    When I create an account with the following parameters
      | name  | legal_name    | registration_id                      | type    | store_id                             |
      | name2 | <STRING_255>1 | e18c94c0-fe2f-4d50-baf4-f134d05bf598 | account | 00000000-0000-1000-8000-000000000002 |
    Then I see 400 status code in response
    And I see error response with the following parameters
      | status | title       | detail                                                 |
      | 400    | Bad Request | Validation failed: field 'LegalName' on the 'max' tag. |
    When I create an account with the following parameters
      | name  | legal_name  | registration_id | type    | store_id                             |
      | name3 | legal_name3 | <STRING_63>1    | account | 00000000-0000-1000-8000-000000000003 |
    Then I see 400 status code in response
    And I see error response with the following parameters
      | status | title       | detail                                                      |
      | 400    | Bad Request | Validation failed: field 'RegistrationID' on the 'max' tag. |
    When I create an account with the following parameters
      | name  | legal_name  | registration_id | type    | store_id                             |
      | name3 | legal_name3 | <STRING_63>     | account | 00000000-0000-1000-8000-000000000003 |
    Then I see 201 status code in response
    Examples:
      | STRING_63                                                       | STRING_255                                                                                                                                                                                                                                                      |
      | stringstringstringstringstringstrinstringstringstringstringstri | stringstringstringstringstringstringstringstringstringstringstringstringstringstringstringstringstringstringstringstringstringstringstringstringstringstringstringstringstringstringstringstringstringstringstringstringstringstringstringstringstringstringstr |

  Scenario: Validate that it is impossible to create duplicate by creating new or updating an account (store_id, registration_id)
    Given I reset DB and mocks
    When I create an account with the following parameters
      | name  | legal_name  | registration_id                      | type    | store_id                             |
      | name1 | legal_name1 | d203286a-2a18-43f8-ab66-3ab6255f54f8 | account | 00000000-0000-1000-8000-000000000005 |
    Then I see 201 status code in response
    When I create an account with the following parameters
      | name  | legal_name  | registration_id                      | type    | store_id                             |
      | name2 | legal_name2 | d203286a-2a18-43f8-ab66-3ab6255f54f8 | account | 00000000-0000-1000-8000-000000000005 |
    Then I see 409 status code in response
    And I see error response with the following parameters
      | status | title    | detail                                                             |
      | 409    | Conflict | account with the given store id and registration id already exists |

  Scenario: Update Account - can not create duplicate (store_id, registration_id)
    Given I reset DB and mocks
    When I create an account with the following parameters
      | name  | legal_name  | registration_id                      | type    | store_id                             |
      | name1 | legal_name1 | d203286a-2a18-43f8-ab66-3ab6255f54f8 | account | 00000000-0000-1000-8000-000000000005 |
    Then I see 201 status code in response
    When I create an account with the following parameters
      | name  | legal_name  | registration_id                      | type    | store_id                             |
      | name1 | legal_name1 | d203286a-2a18-43f8-ab66-3ab6255f54f9 | account | 00000000-0000-1000-8000-000000000005 |
    Then I see 201 status code in response
    When I update an account with the following parameters
      | registration_id                      | type    | store_id                             | id     |
      | d203286a-2a18-43f8-ab66-3ab6255f54f8 | account | 00000000-0000-1000-8000-000000000005 | <last> |
    Then I see 409 status code in response
    And I see error response with the following parameters
      | status | title    | detail                                                             |
      | 409    | Conflict | account with the given store id and registration id already exists |

  Scenario Outline: Validate that it is possible to create more than one account with null as a registration id
    Given I reset DB and mocks
    When I create an account with the following parameters
      | name  | legal_name  | type    | store_id   |
      | name1 | legal_name1 | account | <STORE_ID> |
    Then I see 201 status code in response
    When I create an account with the following parameters
      | name  | legal_name  | type    | store_id   |
      | name2 | legal_name2 | account | <STORE_ID> |
    Then I see 201 status code in response
    Examples:
      | STORE_ID                             |
      | 00000000-0000-1000-8000-000000000005 |