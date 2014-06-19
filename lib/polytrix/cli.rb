require 'polytrix'

module Polytrix
  module CLI
    autoload :Add, 'polytrix/cli/add'
    autoload :Report, 'polytrix/cli/report'

    class Base < Thor
      def self.common_options
        # I had trouble with class_option and subclasses...
        method_option :manifest, type: 'string', default: 'polytrix.yml', desc: 'The Polytrix test manifest file'
        method_option :config, type: 'string', default: 'polytrix.rb', desc: 'The Polytrix config file'
      end

      protected

      def debug(msg)
        say("polytrix::debug: #{msg}", :cyan) if debugging?
      end

      def debugging?
        ENV['POLYTRIX_DEBUG']
      end

      def setup
        Polytrix.configuration.test_manifest = options[:manifest]
        manifest_file = File.expand_path options[:manifest]
        config_file = File.expand_path options[:config]
        debug "Loading manifest file: #{manifest_file}"
        Polytrix.configuration.test_manifest = manifest_file
        debug "Loading Polytrix config: #{config_file}"
        require_relative config_file
      end
    end

    class Main < Base
      include Polytrix::Documentation::Helpers::CodeHelper

      # register Add, :add, 'add', 'Add implementors or code samples'
      # register Report, :report, 'report', 'Generate test reports'
      desc 'add', 'Add implementors or code samples'
      subcommand 'add', Add

      desc 'report', 'Generate test reports'
      subcommand 'report', Report

      desc 'code2doc FILES', 'Converts annotated code to Markdown or reStructuredText'
      method_option :target_dir, type: :string, default: 'docs'
      method_option :lang, enum: Polytrix::Documentation::CommentStyles::COMMENT_STYLES.keys, desc: 'Source language (auto-detected if not specified)'
      method_option :format, enum: %w(md rst), default: 'md'
      def code2doc(*files)
        if files.empty?
          help('code2doc')
          abort 'No FILES were specified, check usage above'
        end

        files.each do |file|
          target_file_name = File.basename(file, File.extname(file)) + ".#{options[:format]}"
          target_file = File.join(options[:target_dir], target_file_name)
          say "Segmented #{file}, saving as #{target_file}"
          doc = Polytrix::DocumentationGenerator.new.code2doc(File.read(file), options[:lang])
          File.write(target_file, doc)
        end
      end

      desc 'bootstrap [SDKs]', 'Bootstraps the SDK by installing dependencies'
      common_options
      def bootstrap(*sdks)
        setup
        if sdks.empty?
          Polytrix.bootstrap
        else
          each_sdk do |sdk|
            sdk.bootstrap
          end
        end
      end

      desc 'test [SDKs]', 'Runs and tests the code samples'
      common_options
      def test(*sdks)
        test_env = ENV['TEST_ENV_NUMBER'].to_i
        rspec_options = %W[--color -f documentation -f Polytrix::RSpec::YAMLReport -o reports/test_report#{test_env}.yaml spec]
        setup
        unless sdks.empty?
          Polytrix.implementors.map(&:name).each do |sdk|
            # We don't have an "or" for tags, so it's easier to exclude than include multiple tags
            rspec_options.concat %W[-t ~sdk:#{sdk}] unless sdks.include? sdk
          end
        end

        Polytrix.run_tests
        debug "Running rspec with: #{rspec_options}"
        ::RSpec::Core::Runner.run rspec_options
      end

      protected

      def sdks
        return nil if options[:sdks].nil?
        @sdks ||= options[:sdks].split(',').map do |sdk|
          implementor = Polytrix.implementors.find { |i| i.name == sdk }
          abort "SDK #{sdk} not found" if implementor.nil?
          implementor
        end
      end
    end
  end
end
