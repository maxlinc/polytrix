require 'buff/shell_out'

module Polytrix
  module Executors
    class BuffShellOutExecutor
      def execute(command, opts)
        cwd = opts.delete(:cwd) || Dir.pwd
        execution_result = nil
        Dir.chdir(cwd) do
          shell = Buff::ShellOut.shell_out(command)
          # Buff doesn't have a live_stream like Mixlib
          puts shell.stdout unless Polytrix.configuration.suppress_output
          execution_result = ExecutionResult.new exitstatus: shell.exitstatus, stdout: shell.stdout, stderr: shell.stderr
        end
        execution_result
      end
    end
  end
end
