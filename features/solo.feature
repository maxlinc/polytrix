Feature: Solo execution

  Polytrix has a --solo mode for use if there is only a single project. It will infer some project settings and test scenarios so you can use Polytrix with minimal configuration.

  In --solo mode, Polytrix will:
    - Configure a single project based in the current working directory
    - Auto-detect test scenarios based on file glob pattern

  Scenario: Cloning all projects
    Given the ruby project
    When I run `bundle exec polytrix exec --solo=sdks/ruby`
    Then the output should contain "Executing katas-hello_world-ruby"
