module Polytrix
  module Spies
    class FileSystemSpy < Polytrix::Spy
      def initialize(_app, _server_options)
      end

      def spy(_scenario)
      end

      report :summary, SummaryReport
    end
  end
end

Polytrix.configuration.register_spy(Polytrix::Spies::FileSystemSpy)
