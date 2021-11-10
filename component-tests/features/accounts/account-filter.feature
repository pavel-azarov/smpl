Feature: Account Filter Operation Tests

  Background:
    Given I reset DB and mocks
    When I create an account with the following parameters
      | name     | legal_name     | registration_id                      | type    | store_id                             |
      | name_one | legal_name_one | 00000000-0000-0000-8000-000000000000 | account | 00000000-0000-1000-8000-000000000000 |
    When I create an account with the following parameters
      | name     | legal_name     | registration_id                      | type    | store_id                             |
      | name_one | legal_name_one | 00000000-0000-0000-8000-000000000001 | account | 00000000-0000-1000-8000-000000000000 |
    Then I see 201 status code in response
    When I create an account with the following parameters
      | name     | legal_name     | registration_id                      | type    | store_id                             |
      | name_two | legal_name_two | 00000000-0000-0000-8000-000000000002 | account | 00000000-0000-1000-8000-000000000000 |
    Then I see 201 status code in response
    When I create an account with the following parameters
      | name             | legal_name          | registration_id                      | type    | store_id                             |
      | wildcard*%_chars | legal_wildcard_name | 00000000-0000-0000-8000-000000000003 | account | 00000000-0000-1000-8000-000000000000 |
    Then I see 201 status code in response

  Scenario Outline: Filter Account list - eq filter
    When I read account list with following parameters
      | store_id   | page-limit | page-offset | ep-internal-search-json |
      | <STORE_ID> | 10         | 0           | <SEARCH_PARAMS>      |
    And I see <RESULT_TOTAL> account in the returned data
    And The list User Authentication Info response contains the following properties
      | name    |
      | <NAMES> |
    And The metadata result total is <RESULT_TOTAL>
    And The following links are populated
      | current | first | last | next | prev |
      | X       | X     | X    |      |      |
    And The page metadata section matches
      | limit   | 10            |
      | offset  | 0             |
      | current | 1             |
      | total   | <PAGES_TOTAL> |

    Examples:
      | STORE_ID                             | SEARCH_PARAMS                                                                                           | RESULT_TOTAL | NAMES             | PAGES_TOTAL |
      | 00000000-0000-1000-8000-000000000000 | {"name":"and","args":[{"name":"eq","args":["name",""]}]}                                                | 0            |                   | 0           |
      | 00000000-0000-1000-8000-000000000000 | {"name":"and","args":[{"name":"eq","args":["name","*"]}]}                                               | 0            |                   | 0           |
      | 00000000-0000-1000-8000-000000000000 | {"name":"and","args":[{"name":"eq","args":["name","name_one"]}]}                                        | 2            | name_one,name_one | 1           |
      | 00000000-0000-1000-8000-000000000000 | {"name":"and","args":[{"name":"eq","args":["name","NamE_oNe"]}]}                                        | 2            | name_one,name_one | 1           |
      | 00000000-0000-1000-8000-000000000000 | {"name":"and","args":[{"name":"eq","args":["name","Nam"]}]}                                             | 0            |                   | 0           |
      | 00000000-0000-1000-8000-000000000000 | {"name":"and","args":[{"name":"eq","args":["name","nam"]}]}                                             | 0            |                   | 0           |
      | 00000000-0000-1000-8000-000000000000 | {"name":"and","args":[{"name":"eq","args":["legal_name","legal_name_one"]}]}                            | 2            | name_one,name_one | 1           |
      | 00000000-0000-1000-8000-000000000000 | {"name":"and","args":[{"name":"eq","args":["legal_name","non-existent"]}]}                              | 0            |                   | 0           |
      | 00000000-0000-1000-8000-000000000000 | {"name":"and","args":[{"name":"eq","args":["registration_id","00000000-0000-0000-8000-000000000000"]}]} | 1            | name_one          | 1           |
      | 00000000-0000-1000-8000-000000000000 | {"name":"and","args":[{"name":"eq","args":["registration_id","non-existent"]}]}                         | 0            |                   | 0           |

  Scenario Outline: Filter Account list - like filter
    When I read account list with following parameters
      | store_id   | page-limit | page-offset | ep-internal-search-json |
      | <STORE_ID> | 10         | 0           | <SEARCH_PARAMS>      |
    And I see <RESULT_TOTAL> account in the returned data
    And The list User Authentication Info response contains the following properties
      | name    |
      | <NAMES> |
    And The metadata result total is <RESULT_TOTAL>
    And The following links are populated
      | current | first | last | next | prev |
      | X       | X     | X    |      |      |
    And The page metadata section matches
      | limit   | 10            |
      | offset  | 0             |
      | current | 1             |
      | total   | <PAGES_TOTAL> |
    Examples:
      | STORE_ID                             | SEARCH_PARAMS                                                                                             | RESULT_TOTAL | NAMES                                       | PAGES_TOTAL |
      | 00000000-0000-1000-8000-000000000000 | {"name":"and","args":[{"name":"like","args":["name","*"]}]}                                               | 4            | name_one,name_one,name_two,wildcard*%_chars | 1           |
      | 00000000-0000-1000-8000-000000000000 | {"name":"and","args":[{"name":"like","args":["name",""]}]}                                                | 0            |                                             | 0           |
      | 00000000-0000-1000-8000-000000000000 | {"name":"and","args":[{"name":"like","args":["name","name_one"]}]}                                        | 2            | name_one,name_one                           | 1           |
      | 00000000-0000-1000-8000-000000000000 | {"name":"and","args":[{"name":"like","args":["registration_id","00000000-0000-0000-8000-000000000001"]}]} | 1            | name_one                                    | 1           |
      | 00000000-0000-1000-8000-000000000000 | {"name":"and","args":[{"name":"like","args":["registration_id","*000000000001"]}]}                        | 1            | name_one                                    | 1           |
      | 00000000-0000-1000-8000-000000000000 | {"name":"and","args":[{"name":"like","args":["name","Name_one"]}]}                                        | 2            | name_one,name_one                           | 1           |
      | 00000000-0000-1000-8000-000000000000 | {"name":"and","args":[{"name":"like","args":["name","name_*"]}]}                                          | 3            | name_one,name_one,name_two                  | 1           |
      | 00000000-0000-1000-8000-000000000000 | {"name":"and","args":[{"name":"like","args":["name","Name_*"]}]}                                          | 3            | name_one,name_one,name_two                  | 1           |
      | 00000000-0000-1000-8000-000000000000 | {"name":"and","args":[{"name":"like","args":["name","*e"]}]}                                              | 2            | name_one,name_one                           | 1           |
      | 00000000-0000-1000-8000-000000000000 | {"name":"and","args":[{"name":"like","args":["name","*ame*"]}]}                                           | 3            | name_one,name_one,name_two                  | 1           |
      | 00000000-0000-1000-8000-000000000000 | {"name":"and","args":[{"name":"like","args":["name","*NameOne*"]}]}                                       | 0            |                                             | 0           |
      | 00000000-0000-1000-8000-000000000000 | {"name":"and","args":[{"name":"like","args":["name","*nameone*"]}]}                                       | 0            |                                             | 0           |
      | 00000000-0000-1000-8000-000000000000 | {"name":"and","args":[{"name":"like","args":["name","*d*%_*"]}]}                                          | 1            | wildcard*%_chars                            | 1           |
      | 00000000-0000-1000-8000-000000000000 | {"name":"and","args":[{"name":"like","args":["legal_name","legal_name_one"]}]}                            | 2            | name_one,name_one                           | 1           |
      | 00000000-0000-1000-8000-000000000000 | {"name":"and","args":[{"name":"like","args":["legal_name","legal_NAME_one"]}]}                            | 2            | name_one,name_one                           | 1           |
      | 00000000-0000-1000-8000-000000000000 | {"name":"and","args":[{"name":"like","args":["legal_name","*_name_one"]}]}                                | 2            | name_one,name_one                           | 1           |
      | 00000000-0000-1000-8000-000000000000 | {"name":"and","args":[{"name":"like","args":["legal_name","*naMe_*"]}]}                                   | 3            | name_one,name_one,name_two                  | 1           |

  Scenario Outline: Filter Account list - mixed filter
    When I read account list with following parameters
      | store_id   | page-limit | page-offset | ep-internal-search-json |
      | <STORE_ID> | 10         | 0           | <SEARCH_PARAMS>      |
    And I see <RESULT_TOTAL> account in the returned data
    And The list User Authentication Info response contains the following properties
      | name    |
      | <NAMES> |
    And The metadata result total is <RESULT_TOTAL>
    And The following links are populated
      | current | first | last | next | prev |
      | X       | X     | X    |      |      |
    And The page metadata section matches
      | limit   | 10            |
      | offset  | 0             |
      | current | 1             |
      | total   | <PAGES_TOTAL> |

    Examples:
      | STORE_ID                             | SEARCH_PARAMS                                                                                                                          | RESULT_TOTAL | NAMES                      | PAGES_TOTAL |
      | 00000000-0000-1000-8000-000000000000 | {"name":"and","args":[{"name":"eq","args":["name","name_one"]},{"name":"like","args":["legal_name","*name*"]}]}                        | 2            | name_one,name_one          | 1           |
      | 00000000-0000-1000-8000-000000000000 | {"name":"and","args":[{"name":"like","args":["name","name*"]},{"name":"like","args":["legal_name","*name*"]}]}                         | 3            | name_one,name_one,name_two | 1           |
      | 00000000-0000-1000-8000-000000000000 | {"name":"and","args":[{"name":"eq","args":["name","name_one"]},{"name":"like","args":["registration_id","00000000-0000-0000-8000*"]}]} | 2            | name_one,name_one          | 1           |
      | 00000000-0000-1000-8000-000000000000 | {"name":"and","args":[{"name":"eq","args":["name","name_one"]},{"name":"like","args":["legal_name","*non_existent*"]}]}                | 0            |                            | 0           |

  Scenario Outline: Filter Account list - pagination
    When I read account list with following parameters
      | store_id   | page-limit | page-offset | ep-internal-search-json |
      | <STORE_ID> | 2          | 0           | <SEARCH_PARAMS>      |
    And I see 2 account in the returned data
    And The list User Authentication Info response contains the following properties
      | name              |
      | name_one,name_one |
    And The metadata result total is 3
    And The following links are populated
      | current | first | last | next | prev |
      | X       | X     | X    | X    |      |
    And The page metadata section matches
      | limit   | 2 |
      | offset  | 0 |
      | current | 1 |
      | total   | 2 |
    When I read account list with following parameters
      | store_id   | page-limit | page-offset | ep-internal-search-json |
      | <STORE_ID> | 2          | 2           | <SEARCH_PARAMS>      |
    And I see 1 account in the returned data
    And The list User Authentication Info response contains the following properties
      | name     |
      | name_two |
    And The metadata result total is 3
    And The following links are populated
      | current | first | last | next | prev |
      | X       | X     | X    |      | X    |
    And The page metadata section matches
      | limit   | 2 |
      | offset  | 2 |
      | current | 2 |
      | total   | 2 |

    Examples:
      | STORE_ID                             | SEARCH_PARAMS                                                    |
      | 00000000-0000-1000-8000-000000000000 | {"name":"and","args":[{"name":"like","args":["name","name_*"]}]} |

  Scenario Outline: Filter Account list - store isolation
    When I create an account with the following parameters
      | name             | legal_name     | registration_id                      | type    | store_id     |
      | name_two_store_2 | legal_name_two | 00000000-0000-0000-8000-000000000010 | account | <STORE_ID_2> |
    When I read account list with following parameters
      | store_id   | page-limit | page-offset | ep-internal-search-json |
      | <STORE_ID> | 2          | 0           | <SEARCH_PARAMS>      |
    And I see 1 account in the returned data
    And The list User Authentication Info response contains the following properties
      | name     |
      | name_two |

    When I read account list with following parameters
      | store_id     | page-limit | page-offset | ep-internal-search-json |
      | <STORE_ID_2> | 2          | 0           | <SEARCH_PARAMS>      |
    And I see 1 account in the returned data
    And The list User Authentication Info response contains the following properties
      | name             |
      | name_two_store_2 |

    Examples:
      | STORE_ID_2                           | STORE_ID                             | SEARCH_PARAMS                                                                |
      | 00000000-0000-1000-8000-000000000001 | 00000000-0000-1000-8000-000000000000 | {"name":"and","args":[{"name":"eq","args":["legal_name","legal_name_two"]}]} |
