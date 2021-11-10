Feature: Account Update Operation Tests

  Background:
    Given I reset DB and mocks
    When I create an account with the following parameters
      | name                  | legal_name                 | registration_id                      | type    | store_id                             |
      | accountUpdateTestName | accountUpdateTestLegalName | d203286a-2a18-43f8-ab66-3ab6255f54f8 | account | 00000000-0000-1000-8000-000000000000 |
    Then I see 201 status code in response
    And I create a queue to listen to the AM events with routing key "account.event.updated"

  Scenario Outline: Update Account - happy path
    When I update an account with the following parameters
      | name           | legal_name           | registration_id           | type   | store_id   | id     |
      | <UPDATED_NAME> | <UPDATED_LEGAL_NAME> | <UPDATED_REGISTRATION_ID> | <TYPE> | <STORE_ID> | <last> |
    Then I see 200 status code in response
    And I see the following properties in the returned Account object
      | name           | legal_name           | registration_id           | type    | id     |
      | <UPDATED_NAME> | <UPDATED_LEGAL_NAME> | <UPDATED_REGISTRATION_ID> | account | <last> |
    When I read an account passing the following parameters
      | store_id   | id     |
      | <STORE_ID> | <last> |
    Then I see 200 status code in response
    And I see the following properties in the returned Account object
      | name           | legal_name           | registration_id           | type    | id     |
      | <UPDATED_NAME> | <UPDATED_LEGAL_NAME> | <UPDATED_REGISTRATION_ID> | account | <last> |
    And I see exactly 1 emitted CloudEvent with routing key "account.event.updated", type "account.event.updated" with the following parameters
      | name                         | legal_name                        | registration_id                      |
      | accountUpdateTestNameUpdated | accountUpdateTestLegalNameUpdated | 00000000-0000-1000-8000-444444444444 |

    Examples:
      | UPDATED_NAME                 | UPDATED_LEGAL_NAME                | UPDATED_REGISTRATION_ID              | TYPE    | STORE_ID                             |
      | accountUpdateTestNameUpdated | accountUpdateTestLegalNameUpdated | 00000000-0000-1000-8000-444444444444 | account | 00000000-0000-1000-8000-000000000000 |

  Scenario Outline: Update Account - try to update an account scoped by different store
    When I create an account with the following parameters
      | name   | legal_name   | registration_id | type   | store_id   |
      | <NAME> | <LEGAL_NAME> | <REG_ID>        | <TYPE> | <STORE_ID> |
    Then I see 201 status code in response
    When I update an account with the following parameters
      | name                            | legal_name                           | type   | store_id                             | id     |
      | updateSecondStoreAccNameUPDATED | updateSecondStoreAccLegalNameUPDATED | <TYPE> | 00000000-0000-1000-8000-000000000000 | <last> |
    Then I see 404 status code in response
    And I see error response with the following parameters
      | status | title     | detail            |
      | 404    | Not Found | account not found |
    When I read an account passing the following parameters
      | store_id   | id     |
      | <STORE_ID> | <last> |
    Then I see 200 status code in response
    And I see the following properties in the returned Account object
      | name   | legal_name   | registration_id | type   | id     |
      | <NAME> | <LEGAL_NAME> | <REG_ID>        | <TYPE> | <last> |

    Examples:
      | TYPE    | STORE_ID                             | NAME                     | LEGAL_NAME                    | REG_ID                               |
      | account | 00000000-0000-1000-8000-000000111111 | updateSecondStoreAccName | updateSecondStoreAccLegalName | 00000000-0000-1000-8000-222222333333 |

  Scenario Outline: Update Account - validate that resources are partially updated when we send a subset of fields
    When I partially update Account with the following parameters
      | store_id   | id     | property   | value          |
      | <STORE_ID> | <last> | <PROPERTY> | <UPDATE_VALUE> |
    Then I see 200 status code in response
    And I see property "<PROPERTY>" with value "<UPDATE_VALUE>" in response
    When I read an account passing the following parameters
      | store_id   | id     |
      | <STORE_ID> | <last> |
    Then I see property "<PROPERTY>" with value "<UPDATE_VALUE>" in response
    Examples:
      | STORE_ID                             | PROPERTY        | UPDATE_VALUE                         |
      | 00000000-0000-1000-8000-000000000000 | name            | partialUpdNameUpdated                |
      | 00000000-0000-1000-8000-000000000000 | legal_name      | partialUpdLegalNameUpdated           |
      | 00000000-0000-1000-8000-000000000000 | registration_id | 00000000-0000-1000-8000-222222222229 |

  Scenario Outline: Update Account - update with empty fields doesn't update
    When I update an account with the following parameters
      | name | legal_name | type   | store_id   | id     |
      |      |            | <TYPE> | <STORE_ID> | <last> |
    Then I see 200 status code in response
    And I see the following properties in the returned Account object
      | name                  | legal_name                 | registration_id                      | type    | id  |
      | accountUpdateTestName | accountUpdateTestLegalName | d203286a-2a18-43f8-ab66-3ab6255f54f8 | account | any |
    Examples:
      | STORE_ID                             | TYPE    |
      | 00000000-0000-1000-8000-000000000000 | account |

  Scenario Outline: Update Account - not possible to update ID
    When I update previously created account with the following parameters
      | type   | store_id   | id                                   |
      | <TYPE> | <STORE_ID> | 8034a592-4ac2-4a38-9f18-bdd90e84971d |
    Then I see 200 status code in response
    And I see the following properties in the returned Account object
      | name                  | legal_name                 | registration_id                      | type   | id     |
      | accountUpdateTestName | accountUpdateTestLegalName | d203286a-2a18-43f8-ab66-3ab6255f54f8 | <TYPE> | <last> |
    Examples:
      | STORE_ID                             | TYPE    |
      | 00000000-0000-1000-8000-000000000000 | account |

  Scenario Outline: Update Account - passing wrong type
    When I update an account with the following parameters
      | name                         | legal_name                        | registration_id                      | type       | store_id   | id     |
      | accountUpdateTestNameUpdated | accountUpdateTestLegalNameUpdated | 00000000-0000-1000-8000-444444444444 | wrong_type | <STORE_ID> | <last> |
    Then I see 400 status code in response
    And I see error response with the following parameters
      | status | title       | detail                                                     |
      | 400    | Bad Request | Validation failed: field 'Type' on the 'account-type' tag. |
    When I read an account passing the following parameters
      | store_id   | id     |
      | <STORE_ID> | <last> |
    Then I see 200 status code in response
    And I see the following properties in the returned Account object
      | name                  | legal_name                 | registration_id                      | type    | id  |
      | accountUpdateTestName | accountUpdateTestLegalName | d203286a-2a18-43f8-ab66-3ab6255f54f8 | account | any |

    Examples:
      | STORE_ID                             |
      | 00000000-0000-1000-8000-000000000000 |

