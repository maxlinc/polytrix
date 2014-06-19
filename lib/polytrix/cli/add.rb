module Polytrix
  module CLI
    class Add < Polytrix::CLI::Base
      include Polytrix::Documentation::Helpers::CodeHelper

      desc 'implementor', 'Add an implementor to the project'
      def implementor
        fail NotImplementedError
      end
    end
  end
end
