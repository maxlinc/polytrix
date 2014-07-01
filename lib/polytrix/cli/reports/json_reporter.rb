require 'json'
require 'polytrix/cli/reports/hash_reporter'

module Polytrix
  module CLI
    module Reports
      class JSONReporter < HashReporter
        def convert(data)
          JSON.pretty_generate data
        end
      end
    end
  end
end
