Feature: Boostrapping

  Polytrix uses the [script/bootstrap](http://wynnnetherland.com/linked/2013012801/bootstrapping-consistency) pattern to prepare SDKs for testing. You can hook into any package manager, compiler, build tool, or any other toolchain to prepare to build and run samples.

  Scenario: Bootstrapping all SDKs
    Given the ruby SDK
    And the java SDK
    And the python SDK
    And the hello_world polytrix config
    And the standard rspec setup
    When I run `bundle exec polytrix bootstrap`
    Then the output should contain "-----> Bootstrapping java"
    Then the output should contain "-----> Bootstrapping python"
    Then the output should contain "-----> Bootstrapping ruby"

  Scenario: Bootstrapping selected SDKs
    Given the ruby SDK
    And the java SDK
    And the python SDK
    And the hello_world polytrix config
    And the standard rspec setup
    When I run `bundle exec polytrix bootstrap "(java|ruby)"`
    Then the output should contain "-----> Bootstrapping java"
    Then the output should not contain "-----> Bootstrapping python"
    Then the output should contain "-----> Bootstrapping ruby"

  Scenario: Bootstrapping by scenario
    Given the ruby SDK
    And the java SDK
    And the python SDK
    And the hello_world polytrix config
    And the standard rspec setup
    When I run `bundle exec polytrix bootstrap hello`
    Then the output should contain "-----> Bootstrapping java"
    Then the output should contain "-----> Bootstrapping python"
    Then the output should contain "-----> Bootstrapping ruby"
