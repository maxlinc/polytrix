require "thor"

require "polytrix"
require "polytrix/command"
# require "polytrix/command/base"
require "polytrix/command/code2doc"

module Polytrix
  class CLI < Thor

    # Common module to load and invoke a CLI-implementation agnostic command.
    module PerformCommand

      # Perform a scenario subcommand.
      #
      # @param task [String] action to take, usually corresponding to the
      #   subcommand name
      # @param command [String] command class to create and invoke]
      # @param args [Array] remainder arguments from processed ARGV
      #   (default: `nil`)
      # @param additional_options [Hash] additional configuration needed to
      #   set up the command class (default: `{}`)
      def perform(task, command, args = nil, additional_options = {})
        require "polytrix/command/#{command}"

        command_options = {
          :action => task,
          :help => -> { help(task) },
          :config => @config,
          :shell => shell
        }.merge(additional_options)

        str_const = Thor::Util.camel_case(command)
        klass = ::Polytrix::Command.const_get(str_const)
        klass.new(args, options, command_options).call
      rescue ArgumentError => e
        abort e.message
      end
    end

    include Logging
    include PerformCommand

    # The maximum number of concurrent instances that can run--which is a bit
    # high
    MAX_CONCURRENCY = 9999

    # Constructs a new instance.
    def initialize(*args)
      super
      $stdout.sync = true
      #Polytrix.logger = Polytrix.default_file_logger
    end

    desc "list [INSTANCE|REGEXP|all]", "Lists one or more scenarios"
    method_option :bare,
      :aliases => "-b",
      :type => :boolean,
      :desc => "List the name of each scenario only, one per line"
    method_option :log_level,
      :aliases => "-l",
      :desc => "Set the log level (debug, info, warn, error, fatal)"
    def list(*args)
      update_config!
      perform("list", "list", args)
    end

    {
      :clone     => "Change scenario state to cloned. " \
                    "Clone the code sample from git",
      :bootstrap => "Change scenario state to bootstraped. " \
                    "Running bootstrap scripts for the implementor",
      :exec      => "Change instance state to executed. " \
                    "Execute the code sample and capture the results.",
      :verify    => "Change instance state to verified. " \
                    "Assert that the captured results match the expectations for the scenario."
    }.each do |action, short_desc|
      desc(
        "#{action} [INSTANCE|REGEXP|all]",
        short_desc
      )
      long_desc <<-DESC
        The scenario states are in order: cloned, bootstrapped, executed, verified.
        Change one or more scenarios from the current state to the #{action} state. Actions for all
        intermediate states will be executed.
      DESC
      method_option :concurrency,
        :aliases => "-c",
        :type => :numeric,
        :lazy_default => MAX_CONCURRENCY,
        :desc => <<-DESC.gsub(/^\s+/, "").gsub(/\n/, " ")
          Run a #{action} against all matching instances concurrently. Only N
          instances will run at the same time if a number is given.
        DESC
      method_option :log_level,
        :aliases => "-l",
        :desc => "Set the log level (debug, info, warn, error, fatal)"
      method_option :manifest,
        :aliases => "-m",
        :desc => "The Polytrix test manifest file location",
        :default => 'polytrix.yml'
      method_option :config,
        :aliases => "-C",
        :desc => "The Polytrix config file file location",
        :default => 'polytrix.rb'
      define_method(action) do |*args|
        update_config!
        perform(action, "action", args, options)
      end
    end

    desc "test [INSTANCE|REGEXP|all]",
      "Test (clone, bootstrap, exec, and verify) one or more scenarios"
    long_desc <<-DESC
      The scenario states are in order: cloned, bootstrapped, executed, verified.
      Test changes the state of one or more scenarios executes
      the actions for each state up to verify.
    DESC
    method_option :concurrency,
      :aliases => "-c",
      :type => :numeric,
      :lazy_default => MAX_CONCURRENCY,
      :desc => <<-DESC.gsub(/^\s+/, "").gsub(/\n/, " ")
        Run a test against all matching instances concurrently. Only N
        instances will run at the same time if a number is given.
      DESC
    method_option :log_level,
      :aliases => "-l",
      :desc => "Set the log level (debug, info, warn, error, fatal)"
    method_option :manifest,
        :aliases => "-m",
        :desc => "The Polytrix test manifest file location",
        :default => 'polytrix.yml'
      method_option :config,
        :aliases => "-C",
        :desc => "The Polytrix config file file location",
        :default => 'polytrix.rb'
    def test(*args)
      abort "Test isn't implemented yet... need to implement an FSM"
      # update_config!
      # ensure_initialized
      # perform("test", "test", args, options)
    end

    desc "version", "Print Polytrix's version information"
    def version
      puts "Polytrix version #{Polytrix::VERSION}"
    end
    map %w[-v --version] => :version

    # register Polytrix::Generator::Init, "init",
    #   "init", "Adds some configuration to your cookbook so Polytrix can rock"
    # long_desc <<-D, :for => "init"
    #   Init will add Test Polytrix support to an existing project for
    #   convergence integration testing. A default .polytrix.yml file (which is
    #   intended to be customized) is created in the project's root directory
    #   and one or more gems will be added to the project's Gemfile.
    # D
    # tasks["init"].options = Polytrix::Generator::Init.class_options

    register Polytrix::Command::Code2Doc, "code2doc",
      "code2doc [FILEs]", "Convert sample code into documentation"
    long_desc <<-D, :for => "code2doc"
      Convert annotated sample code into Markdown or reStructureText documentation.
      For example:

      > polytrix code2doc samples/hello_world.rb

      will create docs/hello_world.md.
    D
    tasks["code2doc"].options = Polytrix::Command::Code2Doc.class_options

    private

    # Ensure the any failing commands exit non-zero.
    #
    # @return [true] you die always on failure
    # @api private
    def self.exit_on_failure?
      true
    end

    # @return [Logger] the common logger
    # @api private
    def logger
      Polytrix.logger
    end

    # Update and finalize options for logging, concurrency, and other concerns.
    #
    # @api private
    def update_config!

    end

    # If auto_init option is active, invoke the init generator.
    #
    # @api private
    def ensure_initialized

    end

    def duration(total)
      total = 0 if total.nil?
      minutes = (total / 60).to_i
      seconds = (total - (minutes * 60))
      format("(%dm%.2fs)", minutes, seconds)
    end
  end
end
