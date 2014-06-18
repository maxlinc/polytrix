require 'polytrix'

module Polytrix
  module CLI
    autoload :Add, 'polytrix/cli/add'

    class Main < Thor
      include Polytrix::Documentation::Helpers::CodeHelper

      register Add, :add, 'add', 'add implementors or tests'

      class_option :manifest, type: 'string', default: 'polytrix.yml', desc: 'The Polytrix test manifest file'
      class_option :config, type: 'string', default: 'polytrix.rb', desc: 'The Polytrix config file'

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
          puts "Segmented #{file}, saving as #{target_file}"
          doc = Polytrix::DocumentationGenerator.new.code2doc(File.read(file), options[:lang])
          File.write(target_file, doc)
        end
      end

      desc 'bootstrap [SDKs]', 'Bootstraps the SDK by installing dependencies'
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

      desc 'test', 'Runs and tests the code samples'
      def test
        setup
        if options[:sdk]
        else
          rspec_options = %w[--color]
          Polytrix.run_tests
          ::RSpec::Core::Runner.run rspec_options
        end
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

      def setup
        Polytrix.configuration.test_manifest = options[:manifest]
        manifest_file = File.expand_path options[:manifest]
        config_file = File.expand_path options[:config]
        puts "Loading manifest file: #{manifest_file}"
        Polytrix.configuration.test_manifest = manifest_file
        puts "Loading Polytrix config: #{config_file}"
        require_relative config_file
      end
    end
  end
end
