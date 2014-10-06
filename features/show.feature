Feature: Show

  Scenario: Initial state
    Given the ruby SDK
    And the java SDK
    And the python SDK
    And the hello_world polytrix config
    And the standard rspec setup
    When I run `bundle exec polytrix show katas-hello_world-ruby`
    Then the output should contain:
    """
    <Not Found>  katas-hello_world-ruby
      Test suite:  Katas
      Test scenario:  hello world
      Implementor:  ruby
         Source:  sdks/ruby/challenges/hello_world.rb
      Validations:
      Data from spies:
    """

  @no-clobber
  Scenario: State after testing
    Given I run `bundle exec polytrix test ruby`
    When I run `bundle exec polytrix show katas-hello_world-ruby`
    Then the output should contain:
    """
    Fully Verified (1 of 1)  katas-hello_world-ruby
      Test suite:  Katas
      Test scenario:  hello world
      Implementor:  ruby
         Source:  sdks/ruby/challenges/hello_world.rb
        Execution result:
          Exit Status:  0
          Stdout:
            Hello, world!
          Stderr:
      Validations:
        default validator
      Data from spies:
    """
