Feature: Account Members Pagination

  Scenario Outline:  Get all account members when there are multiple account members scoped by different stores in the system
    Given I reset DB and mocks
    When I mock EAS to return a successful Authentication Realm creation response with the following parameters
      | realmId    |
      | <REALM_ID> |
    And I mock EAS to return a successful user-authentication-info response 2 times with the following parameters
      | realmId    | namePrefix    | emailSuffix    | userIds                 |
      | <REALM_ID> | <NAME_PREFIX> | <EMAIL_SUFFIX> | <USER_ID_1>,<USER_ID_2> |
    And I read Account Member with id "<USER_ID_1>" and store id "<STORE_ID_1>"
    And I read Account Member with id "<USER_ID_2>" and store id "<STORE_ID_1>"

    And I mock EAS to return a successful user-authentication-info response 1 time with the following parameters
      | realmId    | namePrefix    | emailSuffix    | userIds     |
      | <REALM_ID> | <NAME_PREFIX> | <EMAIL_SUFFIX> | <USER_ID_3> |
    And I read Account Member with id "<USER_ID_3>" and store id "<STORE_ID_2>"
    When I read account members list with following parameters
      | store_id     | page-limit | page-offset |
      | <STORE_ID_1> | 3          | 0           |
    Then I see 200 status code in response
    And I see 2 account members in the returned data with following parameters
      | name_prefix      | email_suffix    | user_ids   |
      | <NAME_PREFIX>    | <EMAIL_SUFFIX>  | <USER_ID_1>,<USER_ID_2>|
    And The following links are populated
      | self | first | last | next | prev |
      | X    | X     | X    |      |      |
    And The page metadata section matches
      | limit   | 3 |
      | offset  | 0 |
      | current | 1 |
      | total   | 1 |
    And The metadata result total is 2
    When I read account members list with following parameters
      | store_id     | page-limit | page-offset |
      | <STORE_ID_2> | 2          | 0           |
    Then I see 200 status code in response
    And I see 1 account member in the returned data with following parameters
      | name_prefix      | email_suffix    | user_ids   |
      | <NAME_PREFIX>    | <EMAIL_SUFFIX>  | <USER_ID_3>|
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
      | STORE_ID_1                           | STORE_ID_2                                     | REALM_ID                            | USER_ID_1                            | USER_ID_2                            | USER_ID_3                            | NAME_PREFIX  | EMAIL_SUFFIX      |
      | 00000000-0000-1000-8000-000000000001 | 00000000-0000-1000-8000-000000000002           |00000000-0000-1000-8000-111111111111 | 10000000-0000-1000-8000-111111111111 | 20000000-0000-1000-8000-111111111111 | 30000000-0000-1000-8000-111111111111 | User With ID | @elasticpath.com  |
