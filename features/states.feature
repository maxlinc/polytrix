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
    Suite  Scenario     Implementor  Status
    Katas  hello world  ruby         <Not Found>
    Katas  hello world  java         <Not Found>
    Katas  hello world  python       <Not Found>
    """

  @no-clobber
  Scenario: State after execution
    Given I run `bundle exec polytrix exec python`
    When I run `bundle exec polytrix list`
    Then the output should contain:
    """
    Suite  Scenario     Implementor  Status
    Katas  hello world  ruby         <Not Found>
    Katas  hello world  java         <Not Found>
    Katas  hello world  python       Executed
    """

  @no-clobber
  Scenario: State after verification
    Given I run `bundle exec polytrix verify ruby`
    When I run `bundle exec polytrix list`
    Then the output should contain:
    """
    Suite  Scenario     Implementor  Status
    Katas  hello world  ruby         Verified (x1)
    Katas  hello world  java         <Not Found>
    Katas  hello world  python       Executed
    """
