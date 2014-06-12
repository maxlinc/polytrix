module Polytrix
  module Documentation
    module ViewHelper
      def polytrix_toc
        buffer = StringIO.new
        buffer.puts '<ul>'
        Polytrix.manifest.suites.each do |suite_name, suite|
          buffer.puts "<li>#{suite_name}</li>"
          buffer.puts '<ul>'
          suite.samples.each do |challenge_name|
            buffer.puts "<li>#{challenge_name}</li>"
          end
          buffer.puts '</ul>'
        end
        buffer.puts '</ul>'

        buffer.string
      end
    end
  end
end
