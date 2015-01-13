Feature: Solo execution

  Crosstest has a --solo mode for use if there is only a single project. It will infer some project settings and test scenarios so you can use Crosstest with minimal configuration.

  In --solo mode, Crosstest will:
    - Configure a single project based in the current working directory
    - Auto-detect test scenarios based on file glob pattern

  Scenario: Cloning all projects
    Given the ruby project
    When I run `bundle exec crosstest exec --solo=sdks/ruby`
    Then the output should contain "Executing katas-hello_world-ruby"
