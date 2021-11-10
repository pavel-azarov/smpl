Feature: Account Management Authentication Token Renewal or Switching

  Background:
    Given I reset DB and mocks
    And I mock EAS to return a successful Authentication Realm creation response with the following parameters
      | realmId                              |
      | 00000000-0000-1000-8000-111111111111 |

  Scenario Outline: Account Member authentication by AM Authentication Token - happy path
    Given I mock EAS to return a successful user-authentication-info response with the following parameters
      | realmId    | userId          |
      | <REALM_ID> | <ACC_MEMBER_ID> |
    And I create an account with the following parameters
      | name     | legal_name   | registration_id     | type   | store_id     |
      | <NAME>_4 | <LEGAL_NAME> | <REGISTRATION_ID>_4 | <TYPE> | <STORE_ID_2> |
    And I see 201 status code in response
    And I create an account with the following parameters
      | name     | legal_name   | registration_id     | type   | store_id     |
      | <NAME>_1 | <LEGAL_NAME> | <REGISTRATION_ID>_1 | <TYPE> | <STORE_ID_1> |
    And I see 201 status code in response
    And I create an account with the following parameters
      | name     | legal_name   | registration_id     | type   | store_id     |
      | <NAME>_2 | <LEGAL_NAME> | <REGISTRATION_ID>_2 | <TYPE> | <STORE_ID_1> |
    And I see 201 status code in response
    And I create an account with the following parameters
      | name     | legal_name   | registration_id     | type   | store_id     |
      | <NAME>_3 | <LEGAL_NAME> | <REGISTRATION_ID>_3 | <TYPE> | <STORE_ID_1> |
    And I see 201 status code in response
    And I read Account Member with id "<ACC_MEMBER_ID>" and store id "<STORE_ID_1>"
    And I create an account membership with the following parameters
      | account_id | store_id     | account_member_id |
      | <last>     | <STORE_ID_1> | <ACC_MEMBER_ID>   |
    And I see 201 status code in response
    And I create an account membership with the following parameters
      | account_id | store_id     | account_member_id |
      | <previous> | <STORE_ID_1> | <ACC_MEMBER_ID>   |
    And I see 201 status code in response

    When I authenticate as account member passing the following parameters
      | storeId      | authenticationMechanism                 | accountMemberId | type                                    | accountId | pageListLimitSettings |
      | <STORE_ID_1> | account_management_authentication_token | <ACC_MEMBER_ID> | account_management_authentication_token | last      | 19                    |
    Then I see 201 status code in response
    And I see the following non-expired account token in the response
      | accountName | accountId | type                                    | storeId      | sub             | scopes |
      | <NAME>_3    | last      | account_management_authentication_token | <STORE_ID_1> | <ACC_MEMBER_ID> | last   |
    And I see the following non-expired account token in the response
      | accountName | accountId | type                                    | storeId      | sub             | scopes   |
      | <NAME>_2    | previous  | account_management_authentication_token | <STORE_ID_1> | <ACC_MEMBER_ID> | previous |
    And The following links are populated
      | self | first | last | next | prev |
      | X    | X     | X    |      |      |
    And The page metadata section matches
      | limit   | 19 |
      | offset  | 0  |
      | current | 1  |
      | total   | 1  |
    And The metadata result total is 2
    And The mocked endpoint for URL path "/v2/authentication-realms/<REALM_ID>/user-authentication-info/<ACC_MEMBER_ID>" and method "GET" is called 1 times

    Examples:
      | STORE_ID_1                           | STORE_ID_2                           | REALM_ID                             | ACC_MEMBER_ID                        | NAME                  | LEGAL_NAME             | REGISTRATION_ID                      | TYPE    |
      | 00000000-0000-1000-8000-000000000000 | 00000000-0000-1000-8000-000000000002 | 00000000-0000-1000-8000-111111111111 | 00000000-0000-1000-8000-111111111112 | accMemberAuthTestName | accMemberAuthLegalName | 00000000-0000-1000-8000-222222222221 | account |

  Scenario Outline: Account Member authentication by AM Authentication Token should have an empty list of tokens when there are no memberships - there is no membership between Account and Account Member
    Given I mock EAS to return a successful user-authentication-info response with the following parameters
      | realmId                              | userId          |
      | 00000000-0000-1000-8000-111111111111 | <ACC_MEMBER_ID> |
    And I create an account with the following parameters
      | name   | legal_name                     | registration_id                      | type    | store_id   |
      | <NAME> | accMemberAuthNoAmTestLegalName | 00000000-0000-1000-8000-222222222221 | account | <STORE_ID> |
    Then I see 201 status code in response
    And I read Account Member with id "<ACC_MEMBER_ID>" and store id "<STORE_ID>"

    When I authenticate as account member passing the following parameters
      | storeId    | authenticationMechanism                 | accountMemberId | type                                    | accountId |
      | <STORE_ID> | account_management_authentication_token | <ACC_MEMBER_ID> | account_management_authentication_token | last      |
    Then I see 201 status code in response
    And I see empty list in the returned data

    Examples:
      | STORE_ID                             | ACC_MEMBER_ID                        | NAME                      |
      | 00000000-0000-1000-8000-000000000000 | 00000000-0000-1000-8000-111111111112 | accMemberAuthNoAmTestName |

  Scenario Outline: Account Member authentication by AM Authentication Token - Account Member doesn't exist in EAS and doesn't exist in AM
    Given I mock EAS to return an unsuccessful user-authentication-info response with the following parameters
      | realmId                              | userId          |
      | 00000000-0000-1000-8000-111111111111 | <ACC_MEMBER_ID> |
    And I create an account with the following parameters
      | name   | legal_name                     | registration_id                      | type    | store_id   |
      | <NAME> | accMemberAuthNoAmTestLegalName | 00000000-0000-1000-8000-222222222221 | account | <STORE_ID> |
    Then I see 201 status code in response

    When I authenticate as account member passing the following parameters
      | storeId    | authenticationMechanism                 | accountMemberId | type                                    | accountId |
      | <STORE_ID> | account_management_authentication_token | <ACC_MEMBER_ID> | account_management_authentication_token | last      |
    Then I see 403 status code in response
    And I see error response with the following parameters
      | status | title     | detail    |
      | 403    | Forbidden | forbidden |

    Examples:
      | STORE_ID                             | ACC_MEMBER_ID                        | NAME                      |
      | 00000000-0000-1000-8000-000000000000 | 00000000-0000-1000-8000-111111111112 | accMemberAuthNoAmTestName |

  Scenario Outline: Account Member authentication by AM Authentication Token - Account member is scoped by another store
    # Any time you want to make calls with a different store_id you should reset the mocks on EAS.
    Given I mock EAS to return a successful user-authentication-info response with the following parameters
      | realmId    | userId            |
      | <REALM_ID> | <ACC_MEMBER_ID_1> |
    And I create an account with the following parameters
      | name     | legal_name   | registration_id     | type   | store_id     |
      | <NAME>_1 | <LEGAL_NAME> | <REGISTRATION_ID>_1 | <TYPE> | <STORE_ID_1> |
    And I see 201 status code in response
    And I create an account with the following parameters
      | name     | legal_name   | registration_id     | type   | store_id     |
      | <NAME>_2 | <LEGAL_NAME> | <REGISTRATION_ID>_2 | <TYPE> | <STORE_ID_2> |
    And I see 201 status code in response
    And I create an account membership with the following parameters
      | account_id | store_id     | account_member_id |
      | <previous> | <STORE_ID_1> | <ACC_MEMBER_ID_1> |
    And I see 201 status code in response
    # All subsequent requests to EAS will use the new STORE_ID_2 store
    # If you switch stores, you need to restore and switch all the mocks again.
    And I mock EAS to return a successful user-authentication-info response with the following parameters
      | realmId    | userId            |
      | <REALM_ID> | <ACC_MEMBER_ID_2> |
    And I mock EAS to return an unsuccessful user-authentication-info response with the following parameters
      | realmId    | userId            |
      | <REALM_ID> | <ACC_MEMBER_ID_1> |
    And I create an account membership with the following parameters
      | account_id | store_id     | account_member_id |
      | <last>     | <STORE_ID_2> | <ACC_MEMBER_ID_2> |
    And I see 201 status code in response

    When I authenticate as account member passing the following parameters
      | storeId      | authenticationMechanism                 | accountMemberId   | type                                    | accountId | pageListLimitSettings |
      | <STORE_ID_2> | account_management_authentication_token | <ACC_MEMBER_ID_1> | account_management_authentication_token | last      | 19                    |
    Then I see 403 status code in response
    And I see error response with the following parameters
      | status | title     | detail    |
      | 403    | Forbidden | forbidden |

    Examples:
      | STORE_ID_1                           | STORE_ID_2                           | REALM_ID                             | ACC_MEMBER_ID_1                      | ACC_MEMBER_ID_2                      | NAME                  | LEGAL_NAME             | REGISTRATION_ID                      | TYPE    |
      | 00000000-0000-1000-8000-000000000000 | 00000000-0000-1000-8000-000000000002 | 00000000-0000-1000-8000-111111111111 | 00000000-0000-1000-8000-111111111112 | 00000000-0000-1000-8000-000000000333 | accMemberAuthTestName | accMemberAuthLegalName | 00000000-0000-1000-8000-222222222221 | account |

  Scenario Outline: Account Member authentication by AM Authentication Token - EP-Internal-Account-Member-Id header is not passed or empty
    Given I create an account with the following parameters
      | name     | legal_name   | registration_id     | type   | store_id   |
      | <NAME>_1 | <LEGAL_NAME> | <REGISTRATION_ID>_1 | <TYPE> | <STORE_ID> |
    And I see 201 status code in response

    When I authenticate as account member passing the following parameters
      | storeId    | authenticationMechanism                 | type                                    | accountId | pageListLimitSettings |
      | <STORE_ID> | account_management_authentication_token | account_management_authentication_token | last      | 19                    |
    Then I see 400 status code in response
    And I see error response with the following parameters
      | status | title       | detail                                                                      |
      | 400    | Bad Request | Validation failed: field 'EPInternalAccountMemberID' on the 'required' tag. |
    When I authenticate as account member passing the following parameters
      | storeId    | authenticationMechanism                 | accountMemberId | type                                    | accountId | pageListLimitSettings |
      | <STORE_ID> | account_management_authentication_token |                 | account_management_authentication_token | last      | 19                    |
    Then I see 400 status code in response
    And I see error response with the following parameters
      | status | title       | detail                                                                      |
      | 400    | Bad Request | Validation failed: field 'EPInternalAccountMemberID' on the 'required' tag. |

    Examples:
      | STORE_ID                             | NAME                          | LEGAL_NAME                     | REGISTRATION_ID                      | TYPE    |
      | 00000000-0000-1000-8000-000000000000 | accMemberAuthNoHeaderTestName | accMemberAuthNoHeaderLegalName | 00000000-0000-1000-8000-222222222221 | account |

  Scenario Outline: Account Member authentication by AM Authentication Token - required field is not passed\empty
    Given I mock EAS to return a successful user-authentication-info response with the following parameters
      | realmId    | userId          |
      | <REALM_ID> | <ACC_MEMBER_ID> |
    And I create an account with the following parameters
      | name                           | legal_name                      | registration_id                      | type    | store_id   |
      | accMemberAuthReqFieldsTestName | accMemberAuthReqFieldsLegalName | 00000000-0000-1000-8000-222222222221 | account | <STORE_ID> |
    And I see 201 status code in response
    And I create an account membership with the following parameters
      | account_id | store_id   | account_member_id |
      | <last>     | <STORE_ID> | <ACC_MEMBER_ID>   |
    And I see 201 status code in response

    When I authenticate as account member passing the following parameters but omitting property "<PROPERTY>"
      | storeId    | authenticationMechanism                 | accountMemberId | type                                    | accountId | pageListLimitSettings |
      | <STORE_ID> | account_management_authentication_token | <ACC_MEMBER_ID> | account_management_authentication_token | last      | 19                    |
    Then I see 422 status code in response
    And I see error response with the following parameters
      | status | title                | detail   |
      | 422    | Unprocessable Entity | <DETAIL> |
    When I authenticate as account member passing the following parameters
      | storeId    | authenticationMechanism | accountMemberId | type | accountId |
      | <STORE_ID> |                         | <ACC_MEMBER_ID> |      | last      |
    Then I see 422 status code in response
    And I see error response with the following parameters
      | status | title                | detail                                                                                                                    |
      | 422    | Unprocessable Entity | Validation failed: field 'Type' on the 'account_token_type' tag; field 'AuthenticationMechanism' on the 'is_invalid' tag. |

    Examples:
      | PROPERTY                 | STORE_ID                             | REALM_ID                             | ACC_MEMBER_ID                        | DETAIL                                                                      |
      | authentication_mechanism | 00000000-0000-1000-8000-000000000000 | 00000000-0000-1000-8000-111111111111 | 00000000-0000-1000-8000-111111111112 | Validation failed: field 'AuthenticationMechanism' on the 'is_invalid' tag. |
      | type                     | 00000000-0000-1000-8000-000000000000 | 00000000-0000-1000-8000-111111111111 | 00000000-0000-1000-8000-111111111112 | Validation failed: field 'Type' on the 'account_token_type' tag.            |

  Scenario Outline: Account Member authentication by AM Authentication Token - wrong type
    Given I mock EAS to return a successful user-authentication-info response with the following parameters
      | realmId    | userId          |
      | <REALM_ID> | <ACC_MEMBER_ID> |
    And I create an account with the following parameters
      | name                           | legal_name                      | registration_id                      | type    | store_id   |
      | accMemberAuthWrongTypeTestName | accMemberAuthWrongTypeLegalName | 00000000-0000-1000-8000-222222222221 | account | <STORE_ID> |
    And I see 201 status code in response
    And I create an account membership with the following parameters
      | account_id | store_id   | account_member_id |
      | <last>     | <STORE_ID> | <ACC_MEMBER_ID>   |
    And I see 201 status code in response

    When I authenticate as account member passing the following parameters
      | storeId    | authenticationMechanism                 | accountMemberId | type       | accountId |
      | <STORE_ID> | account_management_authentication_token | <ACC_MEMBER_ID> | wrong_type | last      |
    Then I see 422 status code in response
    And I see error response with the following parameters
      | status | title                | detail                                                           |
      | 422    | Unprocessable Entity | Validation failed: field 'Type' on the 'account_token_type' tag. |

    Examples:
      | STORE_ID                             | REALM_ID                             | ACC_MEMBER_ID                        |
      | 00000000-0000-1000-8000-000000000000 | 00000000-0000-1000-8000-111111111111 | 00000000-0000-1000-8000-111111111112 |

  Scenario Outline: Account Member authentication by AM Authentication Token - omitting\passing empty X-Moltin-Auth-Store header
    Given I mock EAS to return a successful user-authentication-info response with the following parameters
      | realmId    | userId          |
      | <REALM_ID> | <ACC_MEMBER_ID> |
    And I create an account with the following parameters
      | name                         | legal_name                    | registration_id                      | type    | store_id   |
      | accMemberAuthStoreIdTestName | accMemberAuthStoreIdLegalName | 00000000-0000-1000-8000-222222222221 | account | <STORE_ID> |
    And I see 201 status code in response
    And I create an account membership with the following parameters
      | account_id | store_id   | account_member_id |
      | <last>     | <STORE_ID> | <ACC_MEMBER_ID>   |
    And I see 201 status code in response

    When I authenticate as account member passing the following parameters
      | authenticationMechanism                 | accountMemberId | type       | accountId |
      | account_management_authentication_token | <ACC_MEMBER_ID> | wrong_type | last      |
    Then I see 400 status code in response
    And I see error response with the following parameters
      | status | title       | detail                                                             |
      | 400    | Bad Request | Validation failed: field 'XMoltinAuthStore' on the 'required' tag. |
    When I authenticate as account member passing the following parameters
      | storeId | authenticationMechanism                 | accountMemberId | type       | accountId |
      |         | account_management_authentication_token | <ACC_MEMBER_ID> | wrong_type | last      |
    Then I see 400 status code in response
    And I see error response with the following parameters
      | status | title       | detail                                                             |
      | 400    | Bad Request | Validation failed: field 'XMoltinAuthStore' on the 'required' tag. |

    Examples:
      | STORE_ID                             | REALM_ID                             | ACC_MEMBER_ID                        |
      | 00000000-0000-1000-8000-000000000000 | 00000000-0000-1000-8000-111111111111 | 00000000-0000-1000-8000-111111111112 |
