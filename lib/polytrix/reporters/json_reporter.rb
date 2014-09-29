require 'json'
require 'polytrix/reporters/hash_reporter'

module Polytrix
  module Reporters
    class JSONReporter < HashReporter
      def convert(data)
        JSON.pretty_generate data
      end
    end
  end
end
