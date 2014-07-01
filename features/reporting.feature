Feature: Reporting

  Polytrix creates YAML reports on teach test run. The reports are designed to be "deep mergable", so that you can split a test suite into separate threads running in parallel, each generating a separate report, and then merge them all to create a combined report.

Scenario: A report for a single SDK
    Given the ruby SDK
    And the hello_world polytrix config
    And the standard rspec setup
    When I successfully run `bundle exec rspec -f Polytrix::RSpec::YAMLReport -o reports/polytrix.yaml`
    Then the file "reports/polytrix.yaml" should contain exactly:
    """
    ---
    global_env:
      LOCALE: en_US.UTF-8
      FAVORITE_NUMBER: '5'
    suites:
      Katas:
        env:
          NAME: Max
        samples:
          hello world:
            ruby:
              validations:
              - validated_by: polytrix
                result: passed
              execution_result:
                exitstatus: 0
                stdout: |
                  Hello, world!
                stderr: ''
              source_file: challenges/hello_world.rb

    """

Scenario: A report for several SDKS
    Given the ruby SDK
    And the java SDK
    And the python SDK
    And the hello_world polytrix config
    And the standard rspec setup
    When I successfully run `bundle exec rspec -f Polytrix::RSpec::YAMLReport -o reports/polytrix.yaml`
    Then the file "reports/polytrix.yaml" should contain exactly:
    """
    ---
    global_env:
      LOCALE: en_US.UTF-8
      FAVORITE_NUMBER: '5'
    suites:
      Katas:
        env:
          NAME: Max
        samples:
          hello world:
            java:
              validations:
              - validated_by: polytrix
                result: passed
              execution_result:
                exitstatus: 0
                stdout: |
                  Hello, world!
                stderr: ''
              source_file: challenges/HelloWorld.java
            python:
              validations:
              - validated_by: polytrix
                result: passed
              execution_result:
                exitstatus: 0
                stdout: |
                  Hello, world!
                stderr: ''
              source_file: challenges/hello_world.py
            ruby:
              validations:
              - validated_by: polytrix
                result: passed
              execution_result:
                exitstatus: 0
                stdout: |
                  Hello, world!
                stderr: ''
              source_file: challenges/hello_world.rb

    """

Scenario: Merging separate reports
    Given the ruby SDK
    And the java SDK
    And the python SDK
    And the hello_world polytrix config
    And the standard rspec setup
    When I successfully run `bundle exec rspec -f Polytrix::RSpec::YAMLReport -t ruby -o reports/polytrix-ruby.yaml`
    When I successfully run `bundle exec rspec -f Polytrix::RSpec::YAMLReport -t java -o reports/polytrix-java.yaml`
    When I successfully run `bundle exec rspec -f Polytrix::RSpec::YAMLReport -t python -o reports/polytrix-python.yaml`
    And I successfully run `bundle exec ruby spec/polytrix_merge.rb reports/polytrix-java.yaml reports/polytrix-python.yaml reports/polytrix-ruby.yaml`
    Then the file "reports/polytrix.yaml" should contain exactly:
    """
    ---
    global_env:
      LOCALE: en_US.UTF-8
      FAVORITE_NUMBER: '5'
    suites:
      Katas:
        env:
          NAME: Max
        samples:
          hello world:
            java:
              validations:
              - validated_by: polytrix
                result: passed
              execution_result:
                exitstatus: 0
                stdout: |
                  Hello, world!
                stderr: ''
              source_file: challenges/HelloWorld.java
            python:
              validations:
              - validated_by: polytrix
                result: passed
              execution_result:
                exitstatus: 0
                stdout: |
                  Hello, world!
                stderr: ''
              source_file: challenges/hello_world.py
            ruby:
              validations:
              - validated_by: polytrix
                result: passed
              execution_result:
                exitstatus: 0
                stdout: |
                  Hello, world!
                stderr: ''
              source_file: challenges/hello_world.rb

    """
