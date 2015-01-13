require 'json'
require 'crosstest/reporters/hash_reporter'

module Crosstest
  module Reporters
    class JSONReporter < HashReporter
      def convert(data)
        JSON.pretty_generate data
      end
    end
  end
end
