module Polytrix
  module CLI
    class Add < Polytrix::CLI::Base
      include Polytrix::Documentation::Helpers::CodeHelper

      desc 'implementor', 'Add an implementor to the project'
      def implementor
        raise NotImplementedError
      end
    end
  end
end
