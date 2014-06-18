module Polytrix
  module CLI
    class Add < Thor
      include Polytrix::Documentation::Helpers::CodeHelper

      desc 'implementor', 'Add an implementor to the project'
      def implementor
      end
    end
  end
end
