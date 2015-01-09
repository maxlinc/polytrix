@wip
Feature: Cloning

  Polytrix can clone projects from git.

  Scenario: Cloning all projects
    Given the hello_world polytrix config
    When I run `bundle exec polytrix clone`
    Then the output should contain "-----> Cloning java"
    Then the output should contain "-----> Cloning python"
    Then the output should contain "-----> Cloning ruby"

  Scenario: Cloning selected projects
    Given the ruby project
    And the java project
    And the python project
    And the hello_world polytrix config
    When I run `bundle exec polytrix clone "(java|ruby)"`
    Then the output should contain "-----> Cloning java"
    Then the output should not contain "-----> Cloning python"
    Then the output should contain "-----> Cloning ruby"

  Scenario: Cloning by scenario
    Given the ruby project
    And the java project
    And the python project
    And the hello_world polytrix config
    When I run `bundle exec polytrix clone hello`
    Then the output should contain "-----> Cloning java"
    Then the output should contain "-----> Cloning python"
    Then the output should contain "-----> Cloning ruby"
