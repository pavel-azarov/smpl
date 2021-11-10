Feature: Accounts Pagination

  Scenario Outline:  Get all accounts when there are multiple accounts scoped by different stores in the system
    Given I reset DB and mocks
    And I create an account with the following parameters
      | name                 | legal_name                | registration_id                      | store_id     |
      | accPagDeletedAccName | accPagDeletedAccLegalName | 00000000-0000-1000-8000-333333333333 | <STORE_ID_1> |
    And I see 201 status code in response
    And I delete an account passing the following parameters
      | store_id     | id     |
      | <STORE_ID_1> | <last> |
    And I see 204 status code in response
    When I create 2 accounts with following parameters
      | store_id     | name-prefix            | legal_name-prefix            |
      | <STORE_ID_1> | <NAME_PREFIX_MULTIPLE> | <LEGAL_NAME_PREFIX_MULTIPLE> |
    And I create 1 account with following parameters
      | store_id     | name-prefix          | legal_name-prefix          |
      | <STORE_ID_2> | <NAME_PREFIX_SINGLE> | <LEGAL_NAME_PREFIX_SINGLE> |
    When I read account list with following parameters
      | store_id     | page-limit | page-offset |
      | <STORE_ID_1> | 3          | 0           |
    Then I see 200 status code in response
    And I see 2 account in the returned data with prefix "<NAME_PREFIX_MULTIPLE>" in name and "<LEGAL_NAME_PREFIX_MULTIPLE>" in legal_name from 1 to 2
    And The following links are populated
      | current | first | last | next | prev |
      | X       | X     | X    |      |      |
    And The page metadata section matches
      | limit   | 3 |
      | offset  | 0 |
      | current | 1 |
      | total   | 1 |
    And The metadata result total is 2
    When I read account list with following parameters
      | store_id     | page-limit | page-offset |
      | <STORE_ID_2> | 2          | 0           |
    Then I see 200 status code in response
    And I see 1 account in the returned data with prefix "<NAME_PREFIX_SINGLE>" in name and "<LEGAL_NAME_PREFIX_SINGLE>" in legal_name from 1 to 1
    And The following links are populated
      | current | first | last | next | prev |
      | X       | X     | X    |      |      |
    And The page metadata section matches
      | limit   | 2 |
      | offset  | 0 |
      | current | 1 |
      | total   | 1 |
    And The metadata result total is 1
    Examples:
      | STORE_ID_1                           | STORE_ID_2                           | NAME_PREFIX_SINGLE | NAME_PREFIX_MULTIPLE | LEGAL_NAME_PREFIX_SINGLE | LEGAL_NAME_PREFIX_MULTIPLE |
      | 00000000-0000-1000-8000-111111111111 | 00000000-0000-2000-8000-222222222222 | account-single     | account-multiple     | legal_name-single        | legal_name-multiple        |
