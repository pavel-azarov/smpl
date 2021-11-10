Feature: Read Account Members

  Background:
    Given I reset DB and mocks
    And I create a queue to listen to the AM events with routing key "account-member.event.created"

  Scenario Outline: Read Account Member - happy path, subsequent reads return data from Account Management
    When I mock EAS to return a successful Authentication Realm creation response with the following parameters
      | realmId    |
      | <REALM_ID> |
    And I mock EAS to return a successful user-authentication-info response with the following parameters
      | realmId    | userId    |
      | <REALM_ID> | <USER_ID> |
    And I read Account Member with id "<USER_ID>" and store id "<STORE_ID>"
    Then I see 200 status code in response
    And I see the following parameters in Account Member response
      | id        | name                  | email                     |
      | <USER_ID> | User with ID<USER_ID> | <USER_ID>@elasticpath.com |
    When I read Account Member with id "<USER_ID>" and store id "<STORE_ID>"
    Then I see 200 status code in response
    And I see the following parameters in Account Member response
      | id        | name                  | email                     |
      | <USER_ID> | User with ID<USER_ID> | <USER_ID>@elasticpath.com |
    And The mocked endpoint for URL path "/v2/authentication-realms/<REALM_ID>/user-authentication-info/<USER_ID>" and method "GET" is called 1 times
    And I see exactly 1 emitted CloudEvent with routing key "account-member.event.created", type "account-member.event.created" with the following parameters
      | name                  | email                     |
      | User with ID<USER_ID> | <USER_ID>@elasticpath.com |
    Examples:
      | STORE_ID                             | REALM_ID                             | USER_ID                              |
      | 00000000-0000-1000-8000-000000000000 | 00000000-0000-1000-8000-111111111111 | 00000000-0000-1000-8000-111111111112 |

  Scenario Outline: Try to read Account Member with empty or absent store id
    And I read Account Member with id "<USER_ID>" and store id ""
    Then I see 400 status code in response
    And I see error response with the following parameters
      | status | title       | detail                                                             |
      | 400    | Bad Request | Validation failed: field 'XMoltinAuthStore' on the 'required' tag. |
    And I read Account Member with id "<USER_ID>" and without store id
    Then I see 400 status code in response
    And I see error response with the following parameters
      | status | title       | detail                                                             |
      | 400    | Bad Request | Validation failed: field 'XMoltinAuthStore' on the 'required' tag. |
    Examples:
      | USER_ID                              |
      | 00000000-0000-1000-8000-111111111112 |

  Scenario Outline: Read Account Member - non-existent Account Member
    When I mock EAS to return a successful Authentication Realm creation response with the following parameters
      | realmId    |
      | <REALM_ID> |
    And I mock EAS to return an unsuccessful user-authentication-info response with the following parameters
      | realmId    | userId    |
      | <REALM_ID> | <USER_ID> |
    And I read Account Member with id "<USER_ID>" and store id "<STORE_ID>"
    Then I see 404 status code in response
    And I see error response with the following parameters
      | status | title     | detail    |
      | 404    | Not Found | not found |
    Examples:
      | STORE_ID                             | REALM_ID                             | USER_ID                              |
      | 00000000-0000-1000-8000-000000000000 | 00000000-0000-1000-8000-111111111111 | 00000000-0000-1000-8000-111111111112 |

  Scenario Outline: wrong method for get Account Member endpoint
    And I use HTTP method "<METHOD>" when calling create Account Member endpoint
# TODO MT-6487 Change 404 to 405 once the get the list of accounts endpoint is done
    Then I see 404 status code in response

    Examples:
      | METHOD |
      | PUT    |
      | POST   |
      | DELETE |


  Scenario Outline: Read Account Member - failing request with 404 with a wrong store_id
    When I mock EAS to return a successful Authentication Realm creation response with the following parameters
      | realmId    |
      | <REALM_ID> |
    And I mock EAS to return a successful user-authentication-info response with the following parameters
      | realmId    | userId    |
      | <REALM_ID> | <USER_ID> |
    And I read Account Member with id "<USER_ID>" and store id "<CORRECT_STORE_ID>"
    Then I see 200 status code in response
    And I mock EAS to return an unsuccessful user-authentication-info response with the following parameters
      | realmId    | userId    |
      | <REALM_ID> | <USER_ID> |
    And I read Account Member with id "<USER_ID>" and store id "<CORRECT_STORE_ID>"
    Then I see 200 status code in response
    When I read Account Member with id "<USER_ID>" and store id "<INCORRECT_STORE_ID>"
    Then I see 404 status code in response

    Examples:
      | CORRECT_STORE_ID                     | INCORRECT_STORE_ID                   | REALM_ID                             | USER_ID                              |
      | 00000000-0000-1000-8000-000000000000 | 00000000-0000-1000-8000-000000000001 | 00000000-0000-1000-8000-111111111111 | 00000000-0000-1000-8000-111111111112 |

