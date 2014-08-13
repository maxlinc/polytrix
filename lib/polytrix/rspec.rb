require 'polytrix'
begin
  require 'rspec/core'
  require 'rspec/expectations'
  require 'rspec/core/formatters/base_text_formatter'
rescue LoadError
  raise 'polytrix/rspec requires rspec 2 or later'
end

module Polytrix
  module RSpec
    class << self
      def shared_examples(caller) # rubocop:disable MethodLength
        # FIXME: Long method because it's hard to eval in the right context
        caller.instance_eval do
          Polytrix.manifest.suites.each do |suite_name, suite_config|
            describe suite_name do
              samples = suite_config.samples || []
              samples.each do |scenario|
                describe scenario do
                  Polytrix.implementors.each do |sdk|
                    it sdk.name, sdk.name.to_sym => true do
                      begin
                        skip "#{sdk.name} is not setup" unless File.directory? sdk.basedir
                        challenge = sdk.build_challenge suite: suite_name, name: scenario, vars: suite_config.env
                        example.metadata[:polytrix_challenge] = challenge
                        challenge.run
                        validators = Polytrix::ValidatorRegistry.validators_for challenge
                        validators.each do |validator|
                          instance_exec challenge, &validator.callback
                        end
                      rescue Polytrix::FeatureNotImplementedError => e
                        skip e.message
                      rescue ThreadError => e
                        # Extra debug info for ThreadError
                        $stderr.puts "ThreadError detected: #{e.message}"
                        $stderr.puts "ThreadError backtrace: #{e.backtrace}"
                        fail e
                      end
                    end
                  end
                end
              end
            end
          end
        end
      end

      def run_manifest(manifest)
        shared_examples(self)
      end
    end
  end
end
