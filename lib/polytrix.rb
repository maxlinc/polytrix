require 'cause'
require 'thor'
require 'pathname'
require 'psychic/runner'
require 'polytrix/version'
require 'polytrix/logger'
require 'polytrix/logging'
require 'polytrix/error'
require 'polytrix/dash'
require 'polytrix/util'
require 'polytrix/color'
require 'polytrix/validation'
require 'polytrix/result'
require 'polytrix/evidence'
require 'polytrix/spies'
require 'polytrix/project'
require 'polytrix/challenge'
require 'polytrix/challenges'
require 'polytrix/manifest'
require 'polytrix/configuration'
require 'polytrix/result'
require 'polytrix/documentation_generator'
require 'polytrix/validator'
require 'polytrix/validator_registry'

module Polytrix
  include Polytrix::DefaultLogger
  include Polytrix::Logging

  # File extensions that Polytrix can automatically detect/execute
  SUPPORTED_EXTENSIONS = %w(py rb js)

  class << self
    include Polytrix::Util::FileSystem

    DEFAULT_MANIFEST_FILE = 'polytrix.yml'

    # @return [Mutex] a common mutex for global coordination
    attr_accessor :mutex

    # @return [Logger] the common Polytrix logger
    attr_accessor :logger

    attr_accessor :global_runner

    attr_accessor :wants_to_quit

    def logger
      @logger ||= Polytrix.default_file_logger
    end

    def basedir
      @basedir ||= Dir.pwd
    end

    # @private
    def trap_interrupt
      trap('INT') do
        exit!(1) if Polytrix.wants_to_quit
        Polytrix.wants_to_quit = true
        STDERR.puts "\nInterrupt detected... Interrupt again to force quit."
      end
    end

    def setup(options, manifest_file = DEFAULT_MANIFEST_FILE)
      trap_interrupt
      # manifest_file = File.expand_path manifest
      if File.exist? manifest_file
        logger.debug "Loading manifest file: #{manifest_file}"
        @basedir = File.dirname manifest_file
        Polytrix.configuration.manifest = manifest_file
      elsif options[:solo]
        solo_setup(options)
      else
        fail StandardError, "No manifest found at #{manifest_file} and not using --solo mode"
      end

      manifest.build_challenges

      test_dir = options[:test_dir] || File.expand_path('tests/polytrix/', Dir.pwd)
      autoload_polytrix_files(test_dir) unless test_dir.nil? || !File.directory?(test_dir)
      manifest
    end

    def solo_setup(options)
      suites = {}
      solo_basedir = options[:solo]
      solo_glob = options.fetch('solo_glob', "**/*.{#{SUPPORTED_EXTENSIONS.join(',')}}")
      Dir[File.join(solo_basedir, solo_glob)].sort.each do | code_sample |
        code_sample = Pathname.new(code_sample)
        suite_name = relativize(code_sample.dirname, solo_basedir).to_s
        suite_name = solo_basedir if suite_name == '.'
        scenario_name = code_sample.basename(code_sample.extname).to_s
        suite = suites[suite_name] ||= Polytrix::Manifest::Suite.new(samples: [])
        suite.samples << scenario_name
      end
      @manifest = Polytrix.configuration.manifest = Polytrix::Manifest.new(
        projects: {
          File.basename(solo_basedir) => {
            basedir: solo_basedir
          }
        },
        suites: suites
      )
    end

    def select_scenarios(regexp)
      regexp ||= 'all'
      scenarios = manifest.challenges.values
      if regexp == 'all'
        return scenarios
      else
        scenarios = scenarios.find { |c| c.full_name == regexp } ||
                    scenarios.select { |c| c.full_name =~ /#{regexp}/i }
      end

      if scenarios.is_a? Array
        scenarios
      else
        [scenarios]
      end
    end

    def filter_scenarios(regexp, options = {})
      select_scenarios(regexp).tap do |scenarios|
        scenarios.keep_if { |scenario| scenario.failed? == options[:failed] } unless options[:failed].nil?
        scenarios.keep_if { |scenario| scenario.skipped? == options[:skipped] } unless options[:skipped].nil?
        scenarios.keep_if { |scenario| scenario.sample? == options[:samples] } unless options[:samples].nil?
      end
    end

    def filter_projects(regexp, _options = {})
      regexp ||= 'all'
      projects = if regexp == 'all'
               Polytrix.projects
             else
               Polytrix.projects.find { |s| s.name == regexp } ||
               Polytrix.projects.select { |s| s.name =~ /#{regexp}/i }
             end
      if projects.is_a? Array
        projects
      else
        [projects]
      end
    end

    # Returns a default file logger which emits on standard output and to a
    # log file.
    #
    # @return [Logger] a logger
    def default_file_logger
      logfile = File.expand_path(File.join('.polytrix', 'logs', 'polytrix.log'))
      Logger.new(stdout: $stdout, logdev: logfile, level: env_log)
    end

    # Determine the default log level from an environment variable, if it is
    # set.
    #
    # @return [Integer,nil] a log level or nil if not set
    # @api private
    def env_log
      level = ENV['POLYTRIX_LOG'] && ENV['POLYTRIX_LOG'].downcase.to_sym
      level = Util.to_logger_level(level) unless level.nil?
      level
    end

    # Default log level verbosity
    DEFAULT_LOG_LEVEL = :info

    def reset
      @configuration = nil
      Polytrix::ValidatorRegistry.clear
    end

    # The {Polytrix::Manifest} that describes the test scenarios known to Polytrix.
    def manifest
      configuration.manifest
    end

    # The set of {Polytrix::Project}s registered with Polytrix.
    def projects
      manifest.projects.values
    end

    # Registers a {Polytrix::Validator} that will be used during test
    # execution on matching {Polytrix::Challenge}s.
    def validate(desc, scope = { suite: //, scenario: // }, &block)
      fail ArgumentError 'You must pass block' unless block_given?
      validator = Polytrix::Validator.new(desc, scope, &block)

      Polytrix::ValidatorRegistry.register validator
      validator
    end

    # @api private
    def global_runner
      @global_runner ||= Psychic::Runner.new(cwd: Polytrix.basedir, logger: logger)
    end

    # @see Polytrix::Configuration
    def configuration
      fail "configuration doesn't take a block, use configure" if block_given?
      @configuration ||= Configuration.new
    end

    # @see Polytrix::Configuration
    def configure
      yield(configuration)
    end

    # Returns whether or not standard output is associated with a terminal
    # device (tty).
    #
    # @return [true,false] is there a tty?
    def tty?
      $stdout.tty?
    end

    protected

    def autoload_polytrix_files(dir)
      $LOAD_PATH.unshift dir
      Dir["#{dir}/**/*.rb"].each do | file_to_require |
        # TODO: Need a better way to skip generators or only load validators
        next if file_to_require.match %r{generators/.*/files/}
        require relativize(file_to_require, dir).to_s.gsub('.rb', '')
      end
    end
  end
end

Polytrix.mutex = Mutex.new
