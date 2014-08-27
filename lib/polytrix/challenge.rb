require 'benchmark'
require 'hashie/dash'
require 'hashie/extensions/coercion'
require 'hashie/extensions/indifferent_access'
require 'polytrix/documentation/helpers/code_helper'

module Polytrix
  class Challenge < Polytrix::Dash # rubocop:disable ClassLength
    include Polytrix::Logging
    include Polytrix::StringHelpers
    # View helpers
    include Polytrix::Documentation::Helpers::CodeHelper

    property :name
    property :implementor
    coerce_key :implementor, Polytrix::Implementor
    property :suite, required: true
    property :vars, default: {}
    property :source_file
    coerce_key :source_file, Pathname
    property :basedir
    coerce_key :basedir, Pathname
    property :challenge_runner, default: ChallengeRunner.create_runner
    property :result
    # coerce_key :results, Array[ChallengeResult]
    property :env_file
    # coerce_key :vars, Polytrix::Manifest::Environment
    property :plugin_data, default: {}
    property :verification_level, default: 0

    def state_file
      @state_file ||= StateFile.new(Dir.pwd, slug)
    end

    def logger
      implementor.logger
    end

    def slug
      slugify("#{suite}-#{name}-#{implementor.name}")
    end

    def absolute_source_file
      File.expand_path source_file, basedir
    end

    def exec
      transition_to :exec
    end

    def exec_action
      perform_action(:exec, 'Executing') do
        fail FeatureNotImplementedError, "Implementor #{name} has not been cloned" unless implementor.cloned?
        fail FeatureNotImplementedError, name if source_file.nil?
        fail FeatureNotImplementedError, name unless File.exists?(absolute_source_file)
        self.result = challenge_runner.run_challenge self
      end
    end

    def verify
      transition_to :verify
    end

    def destroy
      transition_to :destroy
    end

    def destroy_action
      perform_action(:destroy, 'Destroying') { state_file.destroy }
    end

    def verify_action
      perform_action(:verify, 'Verifying') do
        validators = Polytrix::ValidatorRegistry.validators_for self
        validators.each do |validator|
          validator.validate self
        end
      end
    end

    def perform_action(verb, output_verb)
      banner "#{output_verb} #{slug}..."
      elapsed = action(verb) { yield }
      # elapsed = action(verb) { |state| driver.public_send(verb, state) }
      info("Finished #{output_verb.downcase} #{slug}" \
        " #{Util.duration(elapsed.real)}.")
      # yield if block_given?
      self
    end

    def action(what, &block)
      state = state_file.read
      elapsed = Benchmark.measure do
        # synchronize_or_call(what, state, &block)
        block.call(state)
      end
      state[:last_action] = what.to_s
      elapsed
    rescue Polytrix::FeatureNotImplementedError => e
      raise e
    rescue ActionFailed => e
      log_failure(what, e)
      raise(InstanceFailure, failure_message(what) +
        "  Please see .polytrix/logs/#{name}.log for more details",
            e.backtrace)
    rescue Exception => e # rubocop:disable RescueException
      log_failure(what, e)
      fail ActionFailed,
           "Failed to complete ##{what} action: [#{e.message}]", e.backtrace
    ensure
      state_file.write(state)
    end

    # Returns the last successfully completed action state of the instance.
    #
    # @return [String] a named action which was last successfully completed
    def last_action
      state_file.read['last_action']
    end

    def transition_to(desired)
      transition_result = nil
      begin
        FSM.actions(last_action, desired).each do |transition|
          transition_result = send("#{transition}_action")
        end
      rescue Polytrix::FeatureNotImplementedError
        info("#{slug} is not implemented")
      end
      transition_result
    end

    def log_failure(what, e)
      return if logger.logdev.nil?

      logger.logdev.error(failure_message(what))
      # Error.formatted_trace(e).each { |line| logger.logdev.error(line) }
    end

    # Returns a string explaining what action failed, at a high level. Used
    # for displaying to end user.
    #
    # @param what [String] an action
    # @return [String] a failure message
    # @api private
    def failure_message(what)
      "#{what.capitalize} failed on instance #{slug}."
    end

    # The simplest finite state machine pseudo-implementation needed to manage
    # an Instance.
    #
    # @api private
    class FSM
      # Returns an Array of all transitions to bring an Instance from its last
      # reported transistioned state into the desired transitioned state.
      #
      # @param last [String,Symbol,nil] the last known transitioned state of
      #   the Instance, defaulting to `nil` (for unknown or no history)
      # @param desired [String,Symbol] the desired transitioned state for the
      #   Instance
      # @return [Array<Symbol>] an Array of transition actions to perform
      # @api private
      def self.actions(last = nil, desired)
        last_index = index(last)
        desired_index = index(desired)

        if last_index == desired_index || last_index > desired_index
          Array(TRANSITIONS[desired_index])
        else
          TRANSITIONS.slice(last_index + 1, desired_index - last_index)
        end
      end

      TRANSITIONS = [:destroy, :exec, :verify]

      # Determines the index of a state in the state lifecycle vector. Woah.
      #
      # @param transition [Symbol,#to_sym] a state
      # @param [Integer] the index position
      # @api private
      def self.index(transition)
        if transition.nil?
          0
        else
          TRANSITIONS.find_index { |t| t == transition.to_sym }
        end
      end
    end
  end
end
