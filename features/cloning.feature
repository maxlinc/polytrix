@wip
Feature: Cloning

  Crosstest can clone projects from git.

  Scenario: Cloning all projects
    Given the hello_world crosstest config
    When I run `bundle exec crosstest clone`
    Then the output should contain "-----> Cloning java"
    Then the output should contain "-----> Cloning python"
    Then the output should contain "-----> Cloning ruby"

  Scenario: Cloning selected projects
    Given the ruby project
    And the java project
    And the python project
    And the hello_world crosstest config
    When I run `bundle exec crosstest clone "(java|ruby)"`
    Then the output should contain "-----> Cloning java"
    Then the output should not contain "-----> Cloning python"
    Then the output should contain "-----> Cloning ruby"

  Scenario: Cloning by scenario
    Given the ruby project
    And the java project
    And the python project
    And the hello_world crosstest config
    When I run `bundle exec crosstest clone hello`
    Then the output should contain "-----> Cloning java"
    Then the output should contain "-----> Cloning python"
    Then the output should contain "-----> Cloning ruby"
