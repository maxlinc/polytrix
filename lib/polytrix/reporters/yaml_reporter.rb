require 'yaml'
require 'polytrix/reporters/hash_reporter'

module Polytrix
  module Reporters
    class YAMLReporter < HashReporter
      def convert(data)
        YAML.dump data
      end
    end
  end
end
