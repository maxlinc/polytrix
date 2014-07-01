require 'hashie/dash'
require 'thor'

module Polytrix
  module Runners
    autoload :BuffShellOutExecutor, 'polytrix/runners/buff_shellout_executor'
    autoload :MixlibShellOutExecutor, 'polytrix/runners/mixlib_shellout_executor'

    class ExecutionError < StandardError
      attr_accessor :execution_result
    end

    class ExecutionResult < Hashie::Dash
      property :exitstatus, require: true
      property :stdout, required: true
      property :stderr, required: true
    end

    module Executor
      attr_writer :executor

      def executor
        @executor ||= if RUBY_PLATFORM == 'java'
                        Polytrix::Runners::BuffShellOutExecutor.new
                      else
                        Polytrix::Runners::MixlibShellOutExecutor.new
                      end
      end

      def execute(command, opts = {})
        executor.execute(command, opts)
      end
    end
  end
end
