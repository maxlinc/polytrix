module Crosstest
  module Spies
    class FileSystemSpy < Crosstest::Spy
      def initialize(_app, _server_options)
      end

      def spy(_scenario)
      end

      report :summary, SummaryReport
    end
  end
end

Crosstest.configuration.register_spy(Crosstest::Spies::FileSystemSpy)
