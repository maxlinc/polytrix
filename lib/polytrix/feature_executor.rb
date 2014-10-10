module Polytrix
  class FeatureExecutor
    include Polytrix::Core::FileSystemHelper
    def initialize(spies = Polytrix::Spies)
      @spies   = spies
    end

    def execute(challenge)
      challenge_runner = challenge[:challenge_runner]
      challenge_runner.env = environment_variables(challenge[:vars])
      source_file = challenge[:source_file].to_s
      basedir = challenge[:basedir].to_s
      command = challenge_runner.challenge_command(source_file, basedir)
      execution_result = challenge_runner.run_command(command, cwd: basedir)
      challenge[:result] = Result.new(execution_result: execution_result, source_file: source_file)
      @spies.observe(challenge)
      challenge[:result]
    end

    protected

    def environment_variables(test_vars)
      global_vars = begin
        Polytrix.manifest[:global_env].dup
      rescue
        {}
      end
      global_vars.merge(test_vars.dup)
    end
  end
end
