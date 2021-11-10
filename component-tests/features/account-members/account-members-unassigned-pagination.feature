Feature: Unassigned Account Members Pagination

  Scenario Outline:  Get all unassigned account members when there are multiple account members scoped by different stores in the system
    Given I reset DB and mocks
    When I mock EAS to return a successful Authentication Realm creation response with the following parameters
      | realmId    |
      | 00000000-1111-1111-8000-222222222222  |
    When I create an account with the following parameters
      | name    | legal_name    | registration_id    | type    | store_id     |
      | <NAME>1 | <LEGAL_NAME>1 | <REGISTRATION_ID>1 | account | <STORE_ID_1> |
    When I create an account with the following parameters
      | name    | legal_name    | registration_id    | type    | store_id    |
      | <NAME>2 | <LEGAL_NAME>2 | <REGISTRATION_ID>2 | account | <STORE_ID_2> |
    And I mock EAS to return a successful user-authentication-info response 5 time with the following parameters
      | realmId    | namePrefix    | emailSuffix    | userIds                                         |
      | <REALM_ID> | <NAME_PREFIX> | <EMAIL_SUFFIX> | <USER_ID_1>,<USER_ID_2>,<USER_ID_3>,<USER_ID_4> |
    And I read Account Member with id "<USER_ID_1>" and store id "<STORE_ID_1>"
    Then I see 200 status code in response
    And I read Account Member with id "<USER_ID_2>" and store id "<STORE_ID_1>"
    Then I see 200 status code in response
    And I create an account membership with the following parameters
      | account_id | store_id     | account_member_id |
      | <last>     | <STORE_ID_1> | <USER_ID_3>       |
    And I read Account Member with id "<USER_ID_4>" and store id "<STORE_ID_2>"
    Then I see 200 status code in response
    When I read unassigned account members list with following parameters
      | store_id     | account_id | page-limit | page-offset |
      | <STORE_ID_1> | <previous> | 3          | 0           |
    Then I see 200 status code in response
    And I see 2 account members in the returned data with following parameters
      | name_prefix   | email_suffix   | user_ids                |
      | <NAME_PREFIX> | <EMAIL_SUFFIX> | <USER_ID_1>,<USER_ID_2>|
    And The following links are populated
      | self | first | last | next | prev |
      | X    | X     | X    |      |      |
    And The page metadata section matches
      | limit   | 3 |
      | offset  | 0 |
      | current | 1 |
      | total   | 1 |
    And The metadata result total is 2
    When I read unassigned account members list with following parameters
      | store_id     | account_id | page-limit | page-offset |
      | <STORE_ID_2> | <last>        | 2          | 0           |
    Then I see 200 status code in response
    And I see 1 account member in the returned data with following parameters
      | name_prefix   | email_suffix   | user_ids    |
      | <NAME_PREFIX> | <EMAIL_SUFFIX> | <USER_ID_4> |
    And The following links are populated
      | self | first | last | next | prev |
      | X    | X     | X    |      |      |
    And The page metadata section matches
      | limit   | 2 |
      | offset  | 0 |
      | current | 1 |
      | total   | 1 |
    And The metadata result total is 1
    Examples:
      | REALM_ID                             | NAME                  | LEGAL_NAME                 | REGISTRATION_ID                      | STORE_ID_1                           | STORE_ID_2                           | USER_ID_1                            | USER_ID_2                            | USER_ID_3                            | USER_ID_4                            | EMAIL_SUFFIX     | NAME_PREFIX  |  |
      | 00000000-1111-1111-8000-222222222222 | accountCreateTestName | accountCreateTestLegalName | 00000000-0000-1000-8000-222222222222 | 00000000-0000-1000-8000-000000000000 | 00000000-0000-2000-8000-000000000000 | 10000000-0000-1000-8000-000000000000 | 20000000-0000-1000-8000-000000000000 | 30000000-0000-1000-8000-000000000000 | 40000000-0000-1000-8000-000000000000 | @elasticpath.com | User with ID |  |
