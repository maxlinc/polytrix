require 'thread'

module Polytrix
  module Command
    class Base
      include Polytrix::Logger

      # Contstructs a new Command object.
      #
      # @param cmd_args [Array] remainder of the arguments from processed ARGV
      # @param cmd_options [Hash] hash of Thor options
      # @param options [Hash] configuration options
      # @option options [String] :action action to take, usually corresponding
      #   to the subcommand name (default: `nil`)
      # @option options [proc] :help a callable that displays help for the
      #   command
      # @option options [Config] :config a Config object (default: `nil`)
      # @option options [Loader] :loader a Loader object (default: `nil`)
      # @option options [String] :shell a Thor shell object
      def initialize(cmd_args, cmd_options, options = {})
        @args = cmd_args
        @options = cmd_options
        @action = options.fetch(:action, nil)
        @help = options.fetch(:help, -> { 'No help provided' })
        @manifest = options.fetch('manifest', nil)
        @config = options.fetch('config', nil)
        @loader = options.fetch(:loader, nil)
        @shell = options.fetch(:shell)
      end

      private

      # @return [Array] remainder of the arguments from processed ARGV
      # @api private
      attr_reader :args

      # @return [Hash] hash of Thor options
      # @api private
      attr_reader :options

      # @return [proc] a callable that displays help for the command
      # @api private
      attr_reader :help

      # @return [Config] a Config object
      # @api private
      attr_reader :config

      # @return [Thor::Shell] a Thor shell object
      # @api private
      attr_reader :shell

      # @return [String] the action to perform
      # @api private
      attr_reader :action

      def setup
        manifest_file = File.expand_path @manifest
        config_file = File.expand_path @config
        if File.exists? manifest_file
          logger.debug "Loading manifest file: #{manifest_file}"
          Polytrix.configuration.manifest = manifest_file if File.exists? manifest_file
        end
        if File.exists? config_file
          logger.debug "Loading Polytrix config: #{config_file}"
          require_relative config_file
        end
      end

      # Emit an error message, display contextual help and then exit with a
      # non-zero exit code.
      #
      # **Note** This method calls exit and will not return.
      #
      # @param msg [String] error message
      # @api private
      def die(msg)
        error "\n#{msg}\n\n"
        help.call
        exit 1
      end

      # @return [Array<Scenario>] an array of scenarios
      # @raise [SystemExit] if no scenario are returned
      # @api private
      def all_scenarios
        result = @config.scenarios

        if result.empty?
          die 'No scenarios defined'
        else
          result
        end
      end

      # Return an array on scenarios whos name matches the regular expression.
      #
      # @param regexp [Regexp] a regular expression matching on instance names
      # @return [Array<Instance>] an array of scenarios
      # @raise [SystemExit] if no scenarios are returned or the regular
      #   expression is invalid
      # @api private
      def filtered_scenarios(regexp)
        result = begin
          @config.scenarios.get(regexp) ||
            @config.scenarios.get_all(/#{regexp}/)
        rescue RegexpError => e
          die "Invalid Ruby regular expression, " \
            "you may need to single quote the argument. " \
            "Please try again or consult http://rubular.com/ (#{e.message})"
        end
        result = Array(result)

        if result.empty?
          die "No scenarios for regex `#{regexp}', try running `kitchen list'"
        else
          result
        end
      end

      # Return an array on scenarios whos name matches the regular expression,
      # the full instance name, or  the `"all"` literal.
      #
      # @param arg [String] an instance name, a regular expression, the literal
      #   `"all"`, or `nil`
      # @return [Array<Instance>] an array of scenarios
      # @api private
      def parse_subcommand(arg = nil)
        arg == 'all' ? all_scenarios : filtered_scenarios(arg)
      end
    end

    # Common module to execute a Kitchen action such as create, converge, etc.
    #
    # @author Fletcher Nichol <fnichol@nichol.ca>
    module RunAction
      # Run an instance action (create, converge, setup, verify, destroy) on
      # a collection of scenarios. The instance actions will take place in a
      # seperate thread of execution which may or may not be running
      # concurrently.
      #
      # @param action [String] action to perform
      # @param scenarios [Array<Instance>] an array of scenarios
      def run_action(action, scenarios, *args)
        concurrency = 1
        if options[:concurrency]
          concurrency = options[:concurrency] || scenarios.size
          concurrency = scenarios.size if concurrency > scenarios.size
        end

        queue = Queue.new
        scenarios.each { |i| queue << i }
        concurrency.times { queue << nil }

        threads = []
        concurrency.times do
          threads << Thread.new do
            while (instance = queue.pop)
              instance.public_send(action, *args)
            end
          end
        end
        threads.map { |i| i.join }
      end
    end
  end
end
