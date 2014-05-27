require 'rocco'

module Polytrix
  module Documentation
    module Helpers
      module CodeHelper
        # This class will be unnecessary if https://github.com/rtomayko/rocco/issues/104 is resolved
        class CodeSegmenter
          def initialize
            @rocco = Rocco.new( 'test' ) { "" }
          end

          def segment(source)
            @rocco.parse(source)
          end

          def comment(lines)
            lines.map do | line |
              "#{@rocco.options[:comment_chars][:single]} #{line}"
            end.join "\n"
          end
        end

        def initialize(*args)
          @segmenter = CodeSegmenter.new
          super
        end

        def source
          File.read source_file
        end

        # Loses proper indentation on comments
        def snippet_after(matcher)
          segments = @segmenter.segment(source)
          buffer = StringIO.new
          segment = segments.find do |s|
            doc_segment_content = s.first.join
            doc_segment_content.match matcher
          end
          buffer.print segment[1].join "\n" if segment # return code segment
          buffer.string
        end

        def snippet_between(before_matcher, after_matcher)
          segments = @segmenter.segment(source)
          start_segment = find_segment_index segments, before_matcher
          end_segment   = find_segment_index segments, after_matcher
          buffer = StringIO.new
          if start_segment && end_segment
            segments[start_segment...end_segment].each do |segment|
              buffer.puts @segmenter.comment(segment[0]) unless segment == segments[start_segment]
              buffer.puts segment[1].join
            end
          end
          buffer.puts "\n"
          buffer.string
        end

        private
        def find_segment_index(segments, matcher)
          segments.find_index do |s|
            doc_segment_content = s.first.join
            doc_segment_content.match matcher
          end
        end
      end
    end
  end
end