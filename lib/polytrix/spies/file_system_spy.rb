module Polytrix
  module Spies
    class FileSystemSpy < Polytrix::Spy
      def initialize(app, server_options)
      end

      def spy(challenge)
      end

      report :summary, SummaryReport
    end
  end
end

Polytrix.configuration.register_spy(Polytrix::Spies::FileSystemSpy)