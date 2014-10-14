module Polytrix
  module Executors
    autoload :BuffShellOutExecutor, 'polytrix/executors/buff_shellout_executor'
    autoload :MixlibShellOutExecutor, 'polytrix/executors/mixlib_shellout_executor'

    class ExecutionResult < Polytrix::Dash
      property :exitstatus, require: true
      property :stdout, required: true
      property :stderr, required: true
      coerce_value String, ->(v) { v.force_encoding('utf-8') }
    end
  end

  module Executor
    attr_writer :executor
    attr_accessor :env

    def executor
      @executor ||= if RUBY_PLATFORM == 'java'
                      # TODO: Display warning that JRuby support is experimental
                      # (because executor may not be equivalent)
                      Polytrix::Executors::BuffShellOutExecutor.new
                    else
                      Polytrix::Executors::MixlibShellOutExecutor.new
                    end
    end

    def execute(command, opts = {})
      opts[:env] = env unless env.nil?
      executor.execute(command, opts)
    end
  end
end
