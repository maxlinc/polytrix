@wip
Feature: Cloning

  Polytrix can clone projects from git.

  Scenario: Cloning all SDKs
    Given the hello_world polytrix config
    And the standard rspec setup
    When I run `bundle exec polytrix clone`
    Then the output should contain "-----> Cloning java"
    Then the output should contain "-----> Cloning python"
    Then the output should contain "-----> Cloning ruby"

  Scenario: Cloning selected SDKs
    Given the ruby SDK
    And the java SDK
    And the python SDK
    And the hello_world polytrix config
    And the standard rspec setup
    When I run `bundle exec polytrix clone "(java|ruby)"`
    Then the output should contain "-----> Cloning java"
    Then the output should not contain "-----> Cloning python"
    Then the output should contain "-----> Cloning ruby"

  Scenario: Cloning by scenario
    Given the ruby SDK
    And the java SDK
    And the python SDK
    And the hello_world polytrix config
    And the standard rspec setup
    When I run `bundle exec polytrix clone hello`
    Then the output should contain "-----> Cloning java"
    Then the output should contain "-----> Cloning python"
    Then the output should contain "-----> Cloning ruby"
