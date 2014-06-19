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

      def self.doc_options
        method_option :target_dir, type: :string, default: 'docs'
        method_option :lang, enum: Polytrix::Documentation::CommentStyles::COMMENT_STYLES.keys, desc: 'Source language (auto-detected if not specified)'
        method_option :format, enum: %w(md rst), default: 'md'
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
      doc_options
      def code2doc(*files)
        if files.empty?
          help('code2doc')
          abort 'No FILES were specified, check usage above'
        end

        files.each do |file|
          target_file_name = File.basename(file, File.extname(file)) + ".#{options[:format]}"
          target_file = File.join(options[:target_dir], target_file_name)
          say_status 'polytrix:code2doc', "Converting #{file} to #{target_file}"
          doc = Polytrix::DocumentationGenerator.new.code2doc(file, options[:lang])
          File.write(target_file, doc)
        end
      rescue Polytrix::Documentation::CommentStyles::UnknownStyleError => e
        abort "Unknown file extension: #{e.extension}, please use --lang to set the language manually"
      end

      desc 'exec', 'Executes code sample(s), using the SDK settings if provided'
      method_option :code2doc, type: :boolean, desc: 'Convert successfully executed code samples to documentation using the code2doc command'
      doc_options
      def exec(*files)
        if files.empty?
          help('exec')
          abort 'No FILES were specified, check usage above'
        end

        implementor =  if options[:sdk]
          Polytrix.implementors.find { |i| i.name == options[:sdk] }
        elsif Polytrix.implementors.empty?
          Polytrix.configuration.implementor name: File.basename(Dir.pwd), basedir: Dir.pwd
        else
          Polytrix.implementors.first
        end

        files.each do | file |
          short_name = File.basename(file)
          challenge_data = {
            source_file: File.expand_path(file, Dir.pwd)
          }
          challenge = implementor.build_challenge challenge_data
          say_status "polytrix:exec[#{short_name}]", "Executing #{file}..."
          results = challenge.run
          exit_code = results.result.execution_result.exitstatus
          color = exit_code == 0 ? :green : :red
          say_status "polytrix:exec[#{short_name}]", "Finished with exec code: #{results.result.execution_result.exitstatus}", color
          code2doc(file) if options[:code2doc]
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
      method_option :rspec_options, format: 'string', desc: 'Extra options to pass to rspec'
      common_options
      def test(*sdks)
        setup
        test_env = ENV['TEST_ENV_NUMBER'].to_i
        rspec_options = %W[--color -f documentation -f Polytrix::RSpec::YAMLReport -o reports/test_report#{test_env}.yaml]
        rspec_options.concat options[:rspec_options].split if options[:rspec_options]
        unless sdks.empty?
          Polytrix.implementors.map(&:name).each do |sdk|
            # We don't have an "or" for tags, so it's easier to exclude than include multiple tags
            rspec_options.concat %W[-t ~#{sdk.to_sym}] unless sdks.include? sdk
          end
        end

        Polytrix.run_tests
        say_status 'polytrix:test', "Testing with rspec options: #{rspec_options.join ' '}"
        ::RSpec::Core::Runner.run rspec_options
        say_status 'polytrix:test', "Test execution completed"
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
