Feature: States

  Scenario: Initial state
    Given the ruby SDK
    And the java SDK
    And the python SDK
    And the hello_world polytrix config
    And the standard rspec setup
    When I run `bundle exec polytrix list`
    Then the output should contain:
    """
    Test ID                   Suite  Scenario     Implementor  Status
    katas-hello_world-ruby    Katas  hello world  ruby         <Not Found>
    katas-hello_world-java    Katas  hello world  java         <Not Found>
    katas-hello_world-python  Katas  hello world  python       <Not Found>
    """

  @no-clobber
  Scenario: State after execution
    Given I run `bundle exec polytrix exec python`
    When I run `bundle exec polytrix list`
    Then the output should contain:
    """
    Test ID                   Suite  Scenario     Implementor  Status
    katas-hello_world-ruby    Katas  hello world  ruby         <Not Found>
    katas-hello_world-java    Katas  hello world  java         <Not Found>
    katas-hello_world-python  Katas  hello world  python       Executed
    """

  @no-clobber
  Scenario: State after verification
    Given I run `bundle exec polytrix verify ruby`
    When I run `bundle exec polytrix list`
    Then the output should contain:
    """
    Test ID                   Suite  Scenario     Implementor  Status
    katas-hello_world-ruby    Katas  hello world  ruby         Fully Verified (1 of 1)
    katas-hello_world-java    Katas  hello world  java         <Not Found>
    katas-hello_world-python  Katas  hello world  python       Executed
    """
