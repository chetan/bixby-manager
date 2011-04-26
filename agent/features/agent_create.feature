Feature: Create Agent
  An Agent should be loaded from disk if possible
  Otherwise a new Agent should be created

  Scenario: Create new agent (no existing)
    Given a manager at "http://localhost:3000"
    And a root dir of "/tmp/devops/test"
    And there is "no" existing agent
    When I create an agent
    Then I should have "a new" Agent

  Scenario: Create new agent (with existing config)
    Given a manager at "http://localhost:3000"
    And a root dir of "/tmp/devops/test"
    And there is "a" existing agent
    When I create an agent
    Then I should have "an old" Agent

  Scenario: Create new agent writes config
    Given a manager at "http://localhost:3000"
    And a root dir of "/tmp/devops/test"
    And there is "no" existing agent
    When I create an agent
    Then a config file should be written

  Scenario: Create new agent without manager uri
    Given a root dir of "/tmp/devops/test"
    And there is "no" existing agent
    Then it should raise Exception when I create an agent

  @stdout
  Scenario: Corrupted configuration throws error
    Given a manager at "http://localhost:3000"
    And a root dir of "/tmp/devops/test"
    And there is "a" existing agent
    And a corrupted configuration
    When I create an agent
    Then stdout should contain "exiting"
