require 'csv'

module Polytrix
  module CLI
    module Reports
      class YAMLReporter
        def initialize(io = $stdout)
          @buffer = io
        end

        def print_table(table)
          headers = table[0]
          data = {}
          table[1..-1].map do |row|
            row_data = {}
            row.each_with_index do |value, index|
              next if index == 0
              row_data[headers[index]] = value
            end
            data[row[0]] = row_data
          end
          @buffer.puts YAML.dump(data)
        end
      end
    end
  end
end
