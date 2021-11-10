Feature: Account Management Outbox

  Background:
    Given I reset DB and mocks
    And I create a queue to listen to the AM events with routing key "account"

  Scenario: Verify that an event is sent when we insert new row in table
    When I insert into the outbox table the following data
      | store_id                             | type    | event                                                                                                                                                                                                                                                                                                                                                                                                                                                                                               |
      | 00000000-0000-1000-8000-000000000000 | account | {"specversion":"1.0","id":"43e5b312-1538-11ec-bf4d-0242ac120006","source":"http://localhost:8087","type":"account","subject":"subj","datacontenttype":"sdf","dataschema":"sdf","time":"2021-09-14T08:46:34.3121976Z","data":"{\"id\":\"8e37ac0a-f9bc-49c4-ae47-f533da0f3c05\",\"name\":\"My Name\",\"legal_name\":\"My Legal Name\",\"registration_id\":\"294478f6-969f-4c06-a9f8-cf6ac9ee686b\",\"created_at\":\"2021-09-14T08:46:34.3022183Z\",\"updated_at\":\"2021-09-14T08:46:34.3022183Z\"}"} |
    And I see exactly 1 emitted CloudEvent with routing key "account", type "account" with the following parameters
      | name    | legal_name    | registration_id                      |
      | My Name | My Legal Name | 294478f6-969f-4c06-a9f8-cf6ac9ee686b |

  Scenario: Verify that 50 events are sent when we insert new row in table 50 times
    When I insert into the outbox table the following data 50 times
      | store_id                             | type    | event                                                                                                                                                                                                                                                                                                                                                                                                                                                                                               |
      | 00000000-0000-1000-8000-000000000000 | account | {"specversion":"1.0","id":"43e5b312-1538-11ec-bf4d-0242ac120006","source":"http://localhost:8087","type":"account","subject":"subj","datacontenttype":"sdf","dataschema":"sdf","time":"2021-09-14T08:46:34.3121976Z","data":"{\"id\":\"8e37ac0a-f9bc-49c4-ae47-f533da0f3c05\",\"name\":\"My Name\",\"legal_name\":\"My Legal Name\",\"registration_id\":\"294478f6-969f-4c06-a9f8-cf6ac9ee686b\",\"created_at\":\"2021-09-14T08:46:34.3022183Z\",\"updated_at\":\"2021-09-14T08:46:34.3022183Z\"}"} |
    And I see exactly 50 emitted CloudEvent with routing key "account", type "account" with the following parameters
      | name    | legal_name    | registration_id                      |
      | My Name | My Legal Name | 294478f6-969f-4c06-a9f8-cf6ac9ee686b |

  Scenario: Verify that an the outbox element is not deleted after message relay finds that it's malformed during processing
    When I insert into the outbox table the following data
      | store_id                             | type    | event                    |
      | 00000000-0000-1000-8000-000000000000 | account | {"no":"required_fields"} |
    And I sleep for 5500 milliseconds
    And I see no emitted CloudEvent with routing key "account"
    And There is exactly 1 outbox elements in the DB
