require 'yaml'
require 'hashie/dash'
require 'hashie/mash'
require 'hashie/extensions/coercion'
require 'hashie/extensions/deep_merge'

module Polytrix
  # Polytrix::Manifest acts as a test manifest. It defines the test scenarios that should be run,
  # and may be shared across multiple implementors when used for a compliance suite.
  #
  # A manifest is generally defined and loaded from YAML. Here's an example manifest:
  #   ---
  #   global_env:
  #     LOCALE: <%= ENV['LANG'] %>
  #     FAVORITE_NUMBER: 5
  #   suites:
  #     Katas:
  #       env:
  #         NAME: 'Max'
  #       samples:
  #         - hello world
  #         - quine
  #     Tutorials:
  #           env:
  #           samples:
  #             - deploying
  #             - documenting
  #
  # The *suites* object defines the tests. Each object, under suites, like *Katas* or *Tutorials* in this
  # example, represents a test suite. A test suite is subdivided into *samples*, that each act as a scenario.
  # The *global_env* object and the *env* under each suite define (and standardize) the input for each test.
  # The *global_env* values will be made available to all tests as environment variables, along with the *env*
  # values for that specific test.
  #
  class Manifest < Polytrix::ManifestSection
    include Polytrix::DefaultLogger
    include Polytrix::Logging
    include Hashie::Extensions::DeepMerge

    def initialize(hash = {})
      super
      implementors.each do | name, implementor |
        implementor.name = name
      end
    end

    class Environment < Hashie::Mash
      include Hashie::Extensions::Coercion
      coerce_value Integer, String
    end

    class CodeSample < Polytrix::ManifestSection
      property :name, required: true

      def self.coerce(data)
        data = { name: data } if data.is_a? String
        new(data)
      end
    end

    class Suite < Polytrix::ManifestSection
      property :env, default: {}
      property :samples, required: true
      coerce_key :samples, Array[CodeSample]
      property :results
    end

    property :implementors, required: true
    coerce_key :implementors, Hash[String => Polytrix::Implementor]
    property :global_env
    coerce_key :global_env, Environment
    property :suites
    coerce_key :suites, Hash[String => Suite]

    attr_accessor :challenges

    def build_challenges
      @challenges ||= Challenges.new

      suites.each do | suite_name, suite |
        suite.samples.each do | sample |
          implementors.each_value do | implementor |
            challenge = implementor.build_challenge suite: suite_name, name: sample.name, vars: suite.env
            @challenges[challenge.slug] = challenge
          end
        end
      end
    end

    # Parses a YAML file to create a {Manifest} object.
    def self.from_yaml(yaml_file)
      ENV['POLYTRIX_SEED'] ||= $PROCESS_ID.to_s
      logger.debug "Loading #{yaml_file}"
      raw_content = File.read(yaml_file)
      processed_content = ERB.new(raw_content).result
      data = YAML.load processed_content
      new data
    end

    def find_suite(suite_name)
      _, suite = suites.find { |name, _| name.to_s.downcase == suite_name.to_s.downcase }
      suite
    end

    def find_challenge(suite_name, scenario_name)
      suite = find_suite suite_name
      return nil if suite.nil?

      if suite.samples.is_a? Array
        # No results yet
        suite.samples.find { |name, _| name.downcase == scenario_name.downcase }
        Challenge.new suite: suite_name, name: scenario_name
      else
        _, challenge_data = find_suite('identity').samples.find { |name, challenge| name.downcase == scenario_name.downcase }
        Challenge.new(suite: suite_name, name: scenario_name, result: challenge_data)
      end
    end
  end
end
