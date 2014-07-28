module Polytrix
  module Command
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
  end
end
