require 'hashie/dash'
require 'thor'
require 'polytrix/core/manifest_section'

module Polytrix
  module Runners
    autoload :BuffShellOutExecutor, 'polytrix/runners/buff_shellout_executor'
    autoload :MixlibShellOutExecutor, 'polytrix/runners/mixlib_shellout_executor'

    class ExecutionResult < Polytrix::ManifestSection
      property :exitstatus, require: true
      property :stdout, required: true
      property :stderr, required: true
    end

    module Executor
      attr_writer :executor
      attr_accessor :env

      def executor
        @executor ||= if RUBY_PLATFORM == 'java'
                        Polytrix::Runners::BuffShellOutExecutor.new
                      else
                        Polytrix::Runners::MixlibShellOutExecutor.new
                      end
      end

      def execute(command, opts = {})
        opts[:env] = env unless env.nil?
        executor.execute(command, opts)
      end
    end
  end
end
