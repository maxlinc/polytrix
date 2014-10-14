require 'benchmark'
require 'polytrix/documentation/helpers/code_helper'

module Polytrix
  class Challenge < Polytrix::Dash # rubocop:disable ClassLength
    include Polytrix::Util::FileSystem
    include Polytrix::Logging
    include Polytrix::Util::String
    # View helpers
    include Polytrix::Documentation::Helpers::CodeHelper

    property :name
    property :implementor
    coerce_key :implementor, Polytrix::Implementor
    property :suite, required: true
    property :vars, default: {}
    # coerce_key :vars, Polytrix::Manifest::Environment
    property :source_file
    coerce_key :source_file, Pathname
    property :basedir
    coerce_key :basedir, Pathname
    property :challenge_runner, default: ChallengeRunner.create_runner
    property :result
    coerce_key :results, ChallengeResult
    property :spy_data, default: {}
    property :verification_level, default: 0

    KEYS_TO_PERSIST = [:result, :spy_data]

    def initialize(hash)
      super
      refresh
    end

    def state_file
      @state_file ||= StateFile.new(Dir.pwd, slug)
    end

    def refresh
      @state = state_file.read
      KEYS_TO_PERSIST.each do |key|
        public_send("#{key}=".to_sym, @state[key]) if @state[key]
      end
    end

    def validators
      Polytrix::ValidatorRegistry.validators_for self
    end

    def logger
      implementor.logger
    end

    def slug
      slugify(suite, name, implementor.name)
    end

    def absolute_source_file
      return nil if source_file.nil?

      File.expand_path source_file, basedir
    end

    def detect
      transition_to :detect
    end

    def detect_action
      perform_action(:detect, 'Detecting code sample') do
        fail FeatureNotImplementedError, "Implementor #{name} has not been cloned" unless implementor.cloned?
        fail FeatureNotImplementedError, name if source_file.nil?
        fail FeatureNotImplementedError, name unless File.exist?(absolute_source_file)
      end
    end

    def exec
      transition_to :exec
    end

    def exec_action
      perform_action(:exec, 'Executing') do
        fail FeatureNotImplementedError, "Implementor #{name} has not been cloned" unless implementor.cloned?
        fail FeatureNotImplementedError, name if source_file.nil?
        fail FeatureNotImplementedError, name unless File.exist?(absolute_source_file)
        self.result = challenge_runner.run_challenge self
      end
    end

    def verify
      transition_to :verify
    end

    def destroy
      transition_to :destroy
    end

    def test(_destroy_mode = :passing)
      elapsed = Benchmark.measure do
        banner "Cleaning up any prior instances of #{slug}"
        destroy
        banner "Testing #{slug}"
        verify
        # destroy if destroy_mode == :passing
      end
      info "Finished testing #{slug} #{Util.duration(elapsed.real)}."
      self
      # ensure
      # destroy if destroy_mode == :always
    end

    def destroy_action
      perform_action(:destroy, 'Destroying') do
        @state_file.destroy
        @state_file = nil
        @state = {}
        refresh
      end
    end

    def verify_action
      perform_action(:verify, 'Verifying') do
        validators.each do |validator|
          validation = validator.validate(self)
          status = case validation.result
                   when :passed
                     Polytrix::Color.colorize('✓ Passed', :green)
                   when :failed
                     Polytrix::Color.colorize('x Failed', :red)
                   else
                     Polytrix::Color.colorize(validation.result, :yellow)
                   end
          info format('%-50s %s', validator.description, status)
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
      @state ||= state_file.read
      @state['last_attempted_action'] = what.to_s
      elapsed = Benchmark.measure do
        # synchronize_or_call(what, @state, &block)
        block.call(@state)
      end
      @state['last_completed_action'] = what.to_s
      elapsed
    rescue Polytrix::FeatureNotImplementedError => e
      raise e
    rescue ActionFailed => e
      log_failure(what, e)
      raise(ChallengeFailure, failure_message(what) +
        "  Please see .polytrix/logs/#{name}.log for more details",
            e.backtrace)
    rescue Exception => e # rubocop:disable RescueException
      log_failure(what, e)
      raise ActionFailed,
            "Failed to complete ##{what} action: [#{e.message}]", e.backtrace
    ensure
      KEYS_TO_PERSIST.each do |key|
        @state[key] = public_send(key)
      end
      state_file.write(@state) unless what == :destroy
    end

    def failed?
      last_attempted_action != last_completed_action
    end

    def skipped?
      result.nil?
    end

    def status
      status = last_attempted_action
      failed? ? "#{status}_failed" : status
    end

    def status_description
      case status
      when 'clone' then 'Cloned'
      when 'clone_failed' then 'Clone Failed'
      when 'detect' then 'Sample Found'
      when 'detect_failed', nil then '<Not Found>'
      when 'bootstrap' then 'Bootstrapped'
      when 'bootstrap_failed' then 'Bootstrap Failed'
      when 'detect' then 'Detected'
      when 'exec' then 'Executed'
      when 'exec_failed' then 'Execution Failed'
      when 'verify', 'verify_failed'
        validator_count = validators.count
        validation_count = validations.values.select { |v| v['result'] == :passed }.count
        if validator_count == validation_count
          "Fully Verified (#{validation_count} of #{validator_count})"
        else
          "Partially Verified (#{validation_count} of #{validator_count})"
        end
      # when 'verify_failed' then 'Verification Failed'
      else "<Unknown (#{status})>"
      end
    end

    def status_color
      case status_description
      when '<Not Found>' then :white
      when 'Cloned' then :magenta
      when 'Bootstrapped' then :magenta
      when 'Sample Found' then :cyan
      when 'Executed' then :blue
      when /Verified/
        if status_description =~ /Fully/
          :green
        else
          :yellow
        end
      else :red
      end
    end

    # Returns the last successfully completed action state of the instance.
    #
    # @return [String] a named action which was last successfully completed
    def last_attempted_action
      state_file.read['last_attempted_action']
    end

    def last_completed_action
      state_file.read['last_completed_action']
    end

    def validations
      return nil if result.nil?
      result.validations
    end

    def transition_to(desired)
      transition_result = nil
      begin
        FSM.actions(last_completed_action, desired).each do |transition|
          transition_result = send("#{transition}_action")
        end
      rescue Polytrix::FeatureNotImplementedError
        warn("#{slug} is not implemented")
      rescue ActionFailed => e
        # Need to use with_friendly_errors again somewhere, since errors don't bubble up
        # without fast-fail?
        Polytrix.handle_error(e)
        raise(ChallengeFailure, e.message, e.backtrace)
      end
      transition_result
    end

    def log_failure(what, _e)
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
      "#{what.capitalize} failed for test #{slug}."
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

      TRANSITIONS = [:destroy, :detect, :exec, :verify]

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
