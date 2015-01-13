require 'yaml'
require 'crosstest/reporters/hash_reporter'

module Crosstest
  module Reporters
    class YAMLReporter < HashReporter
      def convert(data)
        YAML.dump data
      end
    end
  end
end
