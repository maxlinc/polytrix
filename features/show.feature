Feature: Show

  Scenario: Initial state
    Given the ruby SDK
    And the java SDK
    And the python SDK
    And the hello_world polytrix config
    When I run `bundle exec polytrix show katas-hello_world-ruby`
    Then the output should contain:
    """
    katas-hello_world-ruby:                            <Not Found>
      Test suite:                                        Katas
      Test scenario:                                     hello world
      Implementor:                                       ruby
      Source:                                            sdks/ruby/challenges/hello_world.rb
      Data from spies:
    """

  @no-clobber
  Scenario: State after testing
    Given I run `bundle exec polytrix test ruby`
    When I run `bundle exec polytrix show katas-hello_world-ruby`
    Then the output should contain:
    """
    katas-hello_world-ruby:                            Fully Verified (1 of 1)
      Test suite:                                        Katas
      Test scenario:                                     hello world
      Implementor:                                       ruby
      Source:                                            sdks/ruby/challenges/hello_world.rb
      Execution result:
        Exit Status:                                       0
        Stdout:
          Hello, world!
        Stderr:
      Validations:
        default validator:                                 ✓ Passed
      Data from spies:
    """
