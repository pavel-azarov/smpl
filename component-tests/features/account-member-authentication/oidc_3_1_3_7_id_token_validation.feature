Feature: Id token validation (https://openid.net/specs/openid-connect-core-1_0.html#IDTokenValidation)

  Background:
    Given I reset DB and mocks
    And I mock EAS to return a successful Authentication Realm creation response with the following parameters
      | realmId                              |
      | 00000000-0000-4000-8000-000000000001 |

  # If the ID Token is encrypted, decrypt it using the keys and algorithms that the Client specified during Registration that the OP was to use to
  # encrypt the ID Token. If encryption was negotiated with the OP at Registration time and the ID Token is not encrypted, the RP SHOULD reject it.
  # 3.1.3.7.1 https://openid.net/specs/openid-connect-core-1_0.html#IDTokenValidation
  #
  # We do not support encrypted ID Tokens so we should throw an exception if this happens.
  Scenario: Validate that the service throws exception in id token is encrypted
  # TODO Fill in a scenario here where we have EAS have an encrypted token when MT-4142 is implemented


  # The Issuer Identifier for the OpenID Provider (which is typically obtained during Discovery) MUST exactly match the value of the iss (issuer) Claim.
  # 3.1.3.7.2 https://openid.net/specs/openid-connect-core-1_0.html#IDTokenValidation
  Scenario Outline: Authenticate in EAS, generated id token contains wrong issuer: unexpected Realm id
    When I mock EAS to return a successful user-authentication-info response with the following parameters
      | realmId    | userId    |
      | <REALM_ID> | <USER_ID> |
    When I mock EAS endpoint "/oidc-idp/token/stores/<STORE_ID>/authentication-realms/00000000-0000-4000-8000-000000000001" for method "POST" to return status 201 and an id token which encodes the following data
      | iss                                                                                         | aud                | sub                                  | exp           | iat   | name                           | email                        |
      | [EAS_ENDPOINT]/stores/<STORE_ID>/authentication-realms/86e1be78-4f7e-4a72-af97-6b6196600dd5 | account-management | 5489d8d0-eea8-4a7a-b51e-5c28b263f0ab | [IN_ONE_HOUR] | [NOW] | idpAccountTokenTestAccountName | idpaccounttokentest@test.com |
    And I create an account with the following parameters
      | name   | legal_name   | registration_id           | type    | store_id   |
      | <NAME> | <LEGAL_NAME> | <REGISTRATION_ID_PARENT>1 | account | <STORE_ID> |
    Then I see 201 status code in response
    When I create an account membership with the following parameters
      | account_id | store_id   | account_member_id |
      | <last>     | <STORE_ID> | <USER_ID>         |
    Then I see 201 status code in response
    And I generate a token providing the following parameters
      | authorizationCode | type                 | storeId    | oauth_redirect_uri    | authentication_mechanism | oauth_code_verifier                         |
      | authorizationCode | account_management_authentication_token | <STORE_ID> | http://localhost:4444 | oidc                     | 0123456789012345678901234567890123456789012 |
    Then I see 403 status code in response
    And I see error response with the following parameters
      | status | title     | detail    |
      | 403    | Forbidden | forbidden |

    Examples:
      | LEGAL_NAME                 | REGISTRATION_ID_PARENT               | USER_ID                              | STORE_ID                             | REALM_ID                             | NAME                           |
      | accountCreateTestLegalName | 00000000-0000-1000-8000-222222222221 | 20354d7a-e4fe-47af-8ff6-187bca92f3f9 | 00000000-0000-4000-8000-000000000000 | 00000000-0000-4000-8000-000000000001 | idpAccountTokenTestAccountName |

  # The Issuer Identifier for the OpenID Provider (which is typically obtained during Discovery) MUST exactly match the value of the iss (issuer) Claim.
  # 3.1.3.7.2 https://openid.net/specs/openid-connect-core-1_0.html#IDTokenValidation
  Scenario Outline: Authenticate in EAS, generated id token contains wrong issuer: unexpected endpoint and Realm id
    When I mock EAS endpoint "/oidc-idp/token/stores/<STORE_ID>/authentication-realms/00000000-0000-4000-8000-000000000001" for method "POST" to return status 201 and an id token which encodes the following data
      | iss                                                         | aud                | sub                                  | exp           | iat   | name                           | email                        |
      | http://wrongissuer.com/86e1be78-4f7e-4a72-af97-6b6196600dd5 | account-management | 5489d8d0-eea8-4a7a-b51e-5c28b263f0ab | [IN_ONE_HOUR] | [NOW] | idpAccountTokenTestAccountName | idpaccounttokentest@test.com |
    And I generate a token providing the following parameters
      | authorizationCode | type                 | storeId    | oauth_redirect_uri    | authentication_mechanism | oauth_code_verifier                         |
      | authorizationCode | account_management_authentication_token | <STORE_ID> | http://localhost:4444 | oidc                     | 0123456789012345678901234567890123456789012 |
    Then I see 403 status code in response
    And I see error response with the following parameters
      | status | title     | detail    |
      | 403    | Forbidden | forbidden |
    Examples:
      | STORE_ID                             |
      | 00000000-0000-4000-8000-000000000000 |

  # The Client MUST validate that the aud (audience) Claim contains its client_id value registered at the Issuer identified by the iss (issuer) Claim
  # as an audience. The aud (audience) Claim MAY contain an array with more than one element. The ID Token MUST be rejected if the ID Token does not
  # list the Client as a valid audience, or if it contains additional audiences not trusted by the Client.
  # 3.1.3.7.3 https://openid.net/specs/openid-connect-core-1_0.html#IDTokenValidation
  Scenario Outline: Authenticate in EAS, generated id token contains wrong (unsupported) audience
    When I mock EAS endpoint "/oidc-idp/token/stores/<STORE_ID>/authentication-realms/<REALM_ID>" for method "POST" to return status 201 and an id token which encodes the following data
      | iss                                                               | aud            | sub                                  | exp           | iat   | name                           | email                        |
      | [EAS_ENDPOINT]/stores/<STORE_ID>/authentication-realms/<REALM_ID> | wrong_audience | 5489d8d0-eea8-4a7a-b51e-5c28b263f0ab | [IN_ONE_HOUR] | [NOW] | idpAccountTokenTestAccountName | idpaccounttokentest@test.com |
    And I generate a token providing the following parameters
      | authorizationCode | type                 | storeId    | oauth_redirect_uri    | authentication_mechanism | oauth_code_verifier                         |
      | authorizationCode | account_management_authentication_token | <STORE_ID> | http://localhost:4444 | oidc                     | 0123456789012345678901234567890123456789012 |
    Then I see 403 status code in response
    And I see error response with the following parameters
      | status | title     | detail    |
      | 403    | Forbidden | forbidden |
    Examples:
      | STORE_ID                             | REALM_ID                             |
      | 00000000-0000-4000-8000-000000000000 | 00000000-0000-4000-8000-000000000001 |

  # The Client MUST validate that the aud (audience) Claim contains its client_id value registered at the Issuer identified by the iss (issuer) Claim
  # as an audience. The aud (audience) Claim MAY contain an array with more than one element. The ID Token MUST be rejected if the ID Token does not
  # list the Client as a valid audience, or if it contains additional audiences not trusted by the Client.
  # 3.1.3.7.3 https://openid.net/specs/openid-connect-core-1_0.html#IDTokenValidation
  #
  # We do not support multiple values (array) for audience assuming it is alway singular.
  Scenario Outline: Authenticate in EAS, generated id token contains an array for audience
    When I mock EAS endpoint "/oidc-idp/token/stores/<STORE_ID>/authentication-realms/<REALM_ID>" for method "POST" to return status 201 and an id token which encodes the following data
      | iss                                                               | aud                                    | sub                                  | exp           | iat   | name                           | email                        |
      | [EAS_ENDPOINT]/stores/<STORE_ID>/authentication-realms/<REALM_ID> | account-management,audience_array_test | 5489d8d0-eea8-4a7a-b51e-5c28b263f0ab | [IN_ONE_HOUR] | [NOW] | idpAccountTokenTestAccountName | idpaccounttokentest@test.com |
    And I generate a token providing the following parameters
      | authorizationCode | type                 | storeId    | oauth_redirect_uri    | authentication_mechanism | oauth_code_verifier                         |
      | authorizationCode | account_management_authentication_token | <STORE_ID> | http://localhost:4444 | oidc                     | 0123456789012345678901234567890123456789012 |
    Then I see 403 status code in response
    And I see error response with the following parameters
      | status | title     | detail    |
      | 403    | Forbidden | forbidden |
    Examples:
      | STORE_ID                             | REALM_ID                             |
      | 00000000-0000-4000-8000-000000000000 | 00000000-0000-4000-8000-000000000001 |

  # If the ID Token contains multiple audiences, the Client SHOULD verify that an azp Claim is present.
  # 3.1.3.7.4 https://openid.net/specs/openid-connect-core-1_0.html#IDTokenValidation
  #
  # We do not support multiple values (array) for audience assuming it is always singular.

  # If an azp (authorized party) Claim is present, the Client SHOULD verify that its client_id is the Claim Value.
  # 3.1.3.7.5 https://openid.net/specs/openid-connect-core-1_0.html#IDTokenValidation
  # We do not support the azp claim

  # If the ID Token is received via direct communication between the Client and the Token Endpoint (which it is in this flow), the TLS server validation MAY be used to validate the issuer in place of checking the token signature. The Client MUST validate the signature of all other ID Tokens according to JWS [JWS] using the algorithm specified in the JWT alg Header Parameter. The Client MUST use the keys provided by the Issuer.
  # 3.1.3.7.6 https://openid.net/specs/openid-connect-core-1_0.html#IDTokenValidation
  # This is TBD as part of https://elasticpath.atlassian.net/browse/MT-2979

  #The alg value SHOULD be the default of RS256 or the algorithm sent by the Client in the id_token_signed_response_alg parameter during Registration
  # 3.1.3.7.7 https://openid.net/specs/openid-connect-core-1_0.html#IDTokenValidation
  #If the JWT alg Header Parameter uses a MAC based algorithm such as HS256, HS384, or HS512, the octets of the UTF-8 representation of the client_secret corresponding to the client_id contained in the aud (audience) Claim are used as the key to validate the signature. For MAC based algorithms, the behavior is unspecified if the aud is multi-valued or if an azp value is present that is different than the aud value.

  # 3.1.3.7.8 https://openid.net/specs/openid-connect-core-1_0.html#IDTokenValidation
  # Not applicable to us.

  # The current time MUST be before the time represented by the exp Claim.
  # 3.1.3.7.9 https://openid.net/specs/openid-connect-core-1_0.html#IDTokenValidation
  Scenario Outline: Authenticate in EAS, generated id token is expired
    When I mock EAS endpoint "/oidc-idp/token/stores/<STORE_ID>/authentication-realms/<REALM_ID>" for method "POST" to return status 201 and an id token which encodes the following data
      | iss                                                               | aud                | sub                                  | exp              | iat   | name   | email   |
      | [EAS_ENDPOINT]/stores/<STORE_ID>/authentication-realms/<REALM_ID> | account-management | 5489d8d0-eea8-4a7a-b51e-5c28b263f0ab | [ONE_SECOND_AGO] | [NOW] | <NAME> | <EMAIL> |
    And I generate a token providing the following parameters
      | authorizationCode | type                 | storeId    | oauth_redirect_uri    | authentication_mechanism | oauth_code_verifier                         |
      | authorizationCode | account_management_authentication_token | <STORE_ID> | http://localhost:4444 | oidc                     | 0123456789012345678901234567890123456789012 |
    Then I see 403 status code in response
    And I see error response with the following parameters
      | status | title     | detail    |
      | 403    | Forbidden | forbidden |

    Examples:
      | STORE_ID                             | REALM_ID                             | NAME         | EMAIL             |
      | 00000000-0000-4000-8000-000000000000 | 00000000-0000-4000-8000-000000000001 | exptokentest | exptoken@test.com |

  # The iat Claim can be used to reject tokens that were issued too far away from the current time, limiting the amount of time that nonces need to be stored to prevent attacks. The acceptable range is Client specific.
  # 3.1.3.7.10 https://openid.net/specs/openid-connect-core-1_0.html#IDTokenValidation

  # If a nonce value was sent in the Authentication Request, a nonce Claim MUST be present and its value checked to verify that it is the same value as the one that was sent in the Authentication Request. The Client SHOULD check the nonce value for replay attacks. The precise method for detecting replay attacks is Client specific
  # 3.1.3.7.11 https://openid.net/specs/openid-connect-core-1_0.html#IDTokenValidation
  # We do not support the nonce claim.

  # If the acr Claim was requested, the Client SHOULD check that the asserted Claim Value is appropriate. The meaning and processing of acr Claim Values is out of scope for this specification.
  # 3.1.3.7.12 https://openid.net/specs/openid-connect-core-1_0.html#IDTokenValidation
  # We do not support the acr claim.

  #If the auth_time Claim was requested, either through a specific request for this Claim or by using the max_age parameter, the Client SHOULD check the auth_time Claim value and request re-authentication if it determines too much time has elapsed since the last End-User authentication.
  # 3.1.3.7.13 https://openid.net/specs/openid-connect-core-1_0.html#IDTokenValidation
  # We do not support the auth_time claim.
