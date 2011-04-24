Feature: Create Agent
  An Agent should be loaded from disk if possible
  Otherwise a new Agent should be created

  Scenario: Create new agent
    Given a manager at "http://localhost:3000"
    And a root dir of "/tmp/devops/test"
    And there is "no" existing agent
    When I create an agent
    Then I should have a new Agent
