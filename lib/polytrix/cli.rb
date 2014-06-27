require 'polytrix'
require 'thor'

module Polytrix
  module CLI
    autoload :Add, 'polytrix/cli/add'
    autoload :Report, 'polytrix/cli/report'

    class Base < Thor
      include Polytrix::Core::FileSystemHelper

      def self.config_options
        # I had trouble with class_option and subclasses...
        method_option :manifest, type: 'string', default: 'polytrix_tests.yml', desc: 'The Polytrix test manifest file'
        method_option :config, type: 'string', default: 'polytrix.rb', desc: 'The Polytrix config file'
      end

      def self.log_options
        method_option :quiet, type: :boolean, default: false, desc: 'Do not print log messages'
      end

      def self.doc_options
        method_option :target_dir, type: :string, default: 'docs'
        method_option :lang, enum: Polytrix::Documentation::CommentStyles::COMMENT_STYLES.keys, desc: 'Source language (auto-detected if not specified)'
        method_option :format, enum: %w(md rst), default: 'md'
      end

      def self.sdk_options
        method_option :sdk, type: 'string', desc: 'An implementor name or directory', default: '.'
      end

      protected

      def find_sdks(sdks)
        sdks.map do |sdk|
          implementor = Polytrix.implementors.find { |i| i.name == sdk }
          abort "SDK #{sdk} not found" if implementor.nil?
          implementor
        end
      end

      def pick_implementor(sdk)
        Polytrix.implementors.find { |i| i.name == sdk } || Polytrix.configuration.implementor(sdk)
      end

      def debug(msg)
        say("polytrix::debug: #{msg}", :cyan) if debugging?
      end

      def debugging?
        !ENV['POLYTRIX_DEBUG'].nil?
      end

      def setup
        manifest_file = File.expand_path options[:manifest]
        config_file = File.expand_path options[:config]
        if File.exists? manifest_file
          debug "Loading manifest file: #{manifest_file}"
          Polytrix.configuration.test_manifest = manifest_file if File.exists? manifest_file
        end
        if File.exists? config_file
          debug "Loading Polytrix config: #{config_file}"
          require_relative config_file
        end
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
          say_status 'polytrix:code2doc', "Converting #{file} to #{target_file}", !quiet?
          doc = Polytrix::DocumentationGenerator.new.code2doc(file, options[:lang])
          FileUtils.mkdir_p File.dirname(target_file)
          File.write(target_file, doc)
        end
      rescue Polytrix::Documentation::CommentStyles::UnknownStyleError => e
        abort "Unknown file extension: #{e.extension}, please use --lang to set the language manually"
      end

      desc 'exec', 'Executes code sample(s), using the SDK settings if provided'
      method_option :code2doc, type: :boolean, desc: 'Convert successfully executed code samples to documentation using the code2doc command'
      doc_options
      sdk_options
      config_options
      def exec(*files)
        setup
        if files.empty?
          help('exec')
          abort 'No FILES were specified, check usage above'
        end

        exec_options = {
          # default_implementor: pick_implementor(options[:sdk])
        }

        files.each do | file |
          say_status "polytrix:exec", "Running #{file}..."
          results = Polytrix.exec(file, exec_options)
          display_results results
          code2doc(file) if options[:code2doc]
        end
      end

      desc 'bootstrap [SDKs]', 'Bootstraps the SDK by installing dependencies'
      config_options
      def bootstrap(*sdks)
        setup
        implementors = find_sdks(sdks)
        if implementors.empty?
          Polytrix.bootstrap
        else
          implementors.each do |implementor|
            implementor.bootstrap
          end
        end
      end

      desc 'test [SDKs]', 'Runs and tests the code samples'
      method_option :rspec_options, format: 'string', desc: 'Extra options to pass to rspec'
      config_options
      def test(*sdks)
        setup
        implementors = find_sdks(sdks)
        Polytrix.configuration.rspec_options = options[:rspec_options]
        Polytrix.run_tests(implementors)
      end

      protected

      def quiet?
        options[:quiet] || false
      end

      def display_results(challenge)
        short_name = challenge.name
        exit_code = challenge.result.execution_result.exitstatus
        color = exit_code == 0 ? :green : :red
        stderr = challenge.result.execution_result.stderr
        say_status "polytrix:exec[#{short_name}][stderr]", stderr, !quiet? unless stderr.empty?
        say_status "polytrix:exec[#{short_name}]", "Finished with exec code: #{challenge.result.execution_result.exitstatus}", color unless quiet?
      end
    end
  end
end
