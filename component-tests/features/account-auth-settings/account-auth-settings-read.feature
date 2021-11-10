Feature: Read Account Authentication Settings

  Background:
    Given I reset DB and mocks
    And I mock EAS to return a successful Authentication Realm creation response with the following parameters
      | realmId                              |
      | 00000000-0000-1000-8000-111111111111 |

  Scenario Outline: I read Account Authentication Settings which creates a relationship the first time, and then subsequent reads return the same relationship.
    When I read Account Authentication Settings passing the following parameters
      | storeIdHeader |
      | <STORE_ID>    |
    Then I see 200 status code in response
    And I see the following parameters in Account Authentication settings response
      | type                            | id         | clientId           | realmType            | realmId    | realmSelfLink                        |
      | account_authentication_settings | <STORE_ID> | account-management | authentication_realm | <REALM_ID> | /v2/authentication-realms/<REALM_ID> |
    And I read Account Authentication Settings passing the following parameters
      | storeIdHeader | storeIdPathParameter |
      | <STORE_ID>    | <STORE_ID>           |
    Then I see 200 status code in response
    And I see the following parameters in Account Authentication settings response
      | type                            | id         | clientId           | realmType            | realmId    | realmSelfLink                        |
      | account_authentication_settings | <STORE_ID> | account-management | authentication_realm | <REALM_ID> | /v2/authentication-realms/<REALM_ID> |
    And I read Account Authentication Settings passing the following parameters
      | storeIdHeader | url                                  |
      | <STORE_ID>    | /v2/account-authentication-settings/ |
    Then I see 200 status code in response
    And I see the following parameters in Account Authentication settings response
      | type                            | id         | clientId           | realmType            | realmId    | realmSelfLink                        |
      | account_authentication_settings | <STORE_ID> | account-management | authentication_realm | <REALM_ID> | /v2/authentication-realms/<REALM_ID> |
    And The mocked endpoint for URL path "/v2/authentication-realms" and method "POST" is called 1 times
    Examples:
      | STORE_ID                             | REALM_ID                             |
      | 00000000-0000-1000-8000-000000000000 | 00000000-0000-1000-8000-111111111111 |

  Scenario Outline: I read Account Authentication Settings passing mismatched store id in URL
    And I read Account Authentication Settings passing the following parameters
      | storeIdHeader | storeIdPathParameter |
      | <STORE_ID>    | <WRONG_STORE_ID>     |
    Then I see 422 status code in response
    And I see error response with the following parameters
      | status | title                | detail            |
      | 422    | Unprocessable Entity | store id mismatch |
    Examples:
      | STORE_ID                             | WRONG_STORE_ID                       |
      | 00000000-0000-1000-8000-000000000000 | 00000000-0000-1000-8000-222222222222 |

  Scenario: read Account Authentication Settings passing an empty string as Store id
    When I read Account Authentication Settings passing the following parameters
      | storeIdHeader |
      |               |
    Then I see 400 status code in response
    And I see error response with the following parameters
      | status | title       | detail                                                             |
      | 400    | Bad Request | Validation failed: field 'XMoltinAuthStore' on the 'required' tag. |

  Scenario: read Account Authentication Settings not passing X-MOLTIN-AUTH-STORE header
    When I read Account Authentication Settings passing the following parameters
      | storeIdHeader |
      | omit          |
    Then I see 400 status code in response
    And I see error response with the following parameters
      | status | title       | detail                                                             |
      | 400    | Bad Request | Validation failed: field 'XMoltinAuthStore' on the 'required' tag. |

  Scenario: Read Account Authentication Settings returns error if create Auth Realm request fails in EAS
    And I mock EAS to return a failed Authentication Realm creation response with the following parameters
      | status | title        | detail               |
      | 500    | Server error | something went wrong |
    When I read Account Authentication Settings passing the following parameters
      | storeIdHeader                        |
      | 00000000-0000-1000-8000-000000000000 |
    Then I see 500 status code in response
    And I see error response with the following parameters
      | title                 | detail                                      | status |
      | Internal Server Error | there was a problem processing your request | 500    |
