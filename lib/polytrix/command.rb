require 'thread'

module Polytrix
  module Command
    class Base
      include Polytrix::DefaultLogger
      include Polytrix::Logging
      include Polytrix::Core::FileSystemHelper

      # Need standard executor...
      SUPPORTED_EXTENSIONS = %w(py rb js)

      # Contstructs a new Command object.
      #
      # @param cmd_args [Array] remainder of the arguments from processed ARGV
      # @param cmd_options [Hash] hash of Thor options
      # @param options [Hash] configuration options
      # @option options [String] :action action to take, usually corresponding
      #   to the subcommand name (default: `nil`)
      # @option options [proc] :help a callable that displays help for the
      #   command
      # @option options [Config] :test_dir a Config object (default: `nil`)
      # @option options [Loader] :loader a Loader object (default: `nil`)
      # @option options [String] :shell a Thor shell object
      def initialize(cmd_args, cmd_options, options = {})
        @args = cmd_args
        @options = cmd_options
        @action = options.fetch(:action, nil)
        @help = options.fetch(:help, -> { 'No help provided' })
        @manifest_file = options.fetch('manifest', nil)
        @test_dir = options.fetch('test_dir', nil)
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
      attr_reader :test_dir

      # @return [Thor::Shell] a Thor shell object
      # @api private
      attr_reader :shell

      # @return [String] the action to perform
      # @api private
      attr_reader :action

      def setup
        manifest_file = File.expand_path @manifest_file
        if File.exists? manifest_file
          logger.debug "Loading manifest file: #{manifest_file}"
          Polytrix.configuration.manifest = @manifest_file
        elsif @options.solo
          solo_setup
        else
          fail StandardError, "No manifest found at #{manifest_file} and not using --solo mode"
        end

        Polytrix.configuration.documentation_dir = options[:target_dir]
        Polytrix.configuration.documentation_format = options[:format]

        manifest.build_challenges

        test_dir = @test_dir.nil? ? nil : File.expand_path(@test_dir)
        if test_dir && File.directory?(test_dir)
          $LOAD_PATH.unshift test_dir
          Dir["#{test_dir}/**/*.rb"].each do | file_to_require |
            require relativize(file_to_require, test_dir).to_s.gsub('.rb', '')
          end
        end
      end

      def solo_setup
        suites = {}
        solo_basedir = @options.solo
        solo_glob = @options.fetch(:solo_glob, "**/*.{#{SUPPORTED_EXTENSIONS.join(',')}}")
        Dir[File.join(solo_basedir, solo_glob)].each do | code_sample |
          code_sample = Pathname.new(code_sample)
          suite_name = relativize(code_sample.dirname, solo_basedir).to_s
          suite_name = solo_basedir if suite_name == '.'
          scenario_name = code_sample.basename(code_sample.extname).to_s
          suite = suites[suite_name] ||= Polytrix::Manifest::Suite.new(samples: [])
          suite.samples << scenario_name
        end
        @manifest = Polytrix.configuration.manifest = Polytrix::Manifest.new(
          implementors: {
            File.basename(solo_basedir) => {
              basedir: solo_basedir
            }
          },
          suites: suites
        )
      end

      def manifest
        @manifest ||= Polytrix.configuration.manifest
        @manifest
      end

      # Emit an error message, display contextual help and then exit with a
      # non-zero exit code.
      #
      # **Note** This method calls exit and will not return.
      #
      # @param msg [String] error message
      # @api private
      def die(msg)
        logger.error "\n#{msg}\n\n"
        help.call
        exit 1
      end

      # @return [Array<Scenario>] an array of scenarios
      # @raise [SystemExit] if no scenario are returned
      # @api private
      def all_scenarios
        result = manifest.challenges.values

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
          manifest.challenges.get(regexp) ||
            manifest.challenges.get_all(/#{regexp}/)
        rescue RegexpError => e
          die "Invalid Ruby regular expression, " \
            "you may need to single quote the argument. " \
            "Please try again or consult http://rubular.com/ (#{e.message})"
        end
        result = [result] unless result.is_a? Array

        if result.empty?
          die "No scenarios for regex `#{regexp}', try running `polytrix list'"
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
        arg ||= 'all'
        arg == 'all' ? all_scenarios : filtered_scenarios(arg)
      end
    end

    # Common module to execute a Polytrix action such as create, converge, etc.
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
