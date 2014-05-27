require 'rocco'

module Polytrix
  module Documentation
    module Helpers
      module CodeHelper
        def initialize(*args)
          @segmenter = Rocco::CodeSegmenter.new
          super
        end

        def source
          File.read source_file
        end

        def snippet_after(matcher)
          segments = @segmenter.segment(source)
          segment = segments.find do |s|
            doc_segment_content = s.first.join
            doc_segment_content.match matcher
          end
          segment[1].join if segment # return code segment
        end

        def snippet_between(before_matcher, after_matcher)
        end

      end
    end
  end
end