require 'yaml'
require 'polytrix/cli/reports/hash_reporter'

module Polytrix
  module Reports
    class YAMLReporter < HashReporter
      def convert(data)
        YAML.dump data
      end
    end
  end
end
