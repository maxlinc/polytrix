Feature: Running SDKs

  Polytrix uses the [script/bootstrap](http://wynnnetherland.com/linked/2013012801/bootstrapping-consistency) pattern to prepare SDKs for testing. You can hook into any package manager, compiler, build tool, or any other toolchain to prepare to build and run samples.

  Polytrix also sets up tags for the SDKs so you can use the normal rspec `-t` option to select which SDK to run.

  Scenario: Bootstrap an SDK
    Given the java SDK
    And the empty polytrix config
    And the standard rspec setup
    When I run `bundle exec rspec`
    Then the output should contain ":compileJava"
    And the output should contain "BUILD SUCCESSFUL"

Scenario: Running all SDKs
    Given the ruby SDK
    And the java SDK
    And the python SDK
    And the hello_world polytrix config
    And the standard rspec setup
    When I run `bundle exec rspec`
    And the output should contain "3 examples, 0 failures"

  Scenario: Running a single SDK
    Given the ruby SDK
    And the java SDK
    And the python SDK
    And the hello_world polytrix config
    And the standard rspec setup
    When I run `bundle exec rspec -t ruby`
    Then the output should contain "Hello, world!"
    And the output should contain "1 example, 0 failures"

  Scenario: Custom assertions
    Given the ruby SDK
    And the java SDK
    And the python SDK
    And the hello_world polytrix config
    And the standard rspec setup
    And a file named "spec/custom_spec.rb" with:
    """
    require 'polytrix/rspec'
    Polytrix.implementors = Dir['sdks/*'].map{ |sdk|
      name = File.basename(sdk)
      Polytrix::Implementor.new :name => name
    }

    Polytrix.configure do |polytrix|
      polytrix.test_manifest = 'polytrix.yml'
    end

    # This is more of an integration test, but makes sure the rspec API is working.
    # Expect results to all be pending, because there's no implementors in this proj.

    describe 'Katas' do
      code_sample 'Hello World' do |challenge|
        # You can make assertions about the process using the Mixlib::ShellOut API
        expect(challenge[:result].execution_result.stdout).to include 'Hello, world!'
        expect(challenge[:result].execution_result.stderr).to be_empty
        expect(challenge[:result].execution_result.exitstatus).to eq(1) # normally this would be 0
      end

      code_sample 'Quine' do |challenge|
        expect(challenge[:result].execution_result.stdout).to eq File.read(challenge[:result].source)
      end
    end
    """
    When I run `bundle exec rspec spec/custom_spec.rb`
    And the output should match /expected: 1\s+got: 0/
