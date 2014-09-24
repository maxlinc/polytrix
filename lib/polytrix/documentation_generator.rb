require 'tilt' # seems to be a bug where padrino-helpers should require tilt
require 'padrino-helpers'

module Polytrix
  class DocumentationGenerator
    [
      Padrino::Helpers::OutputHelpers,
      Padrino::Helpers::AssetTagHelpers,
      Padrino::Helpers::TagHelpers,
      Polytrix::Documentation::Helpers::CodeHelper
    ].each do | helper|
      include helper
    end

    attr_reader :scenario

    def initialize(template_file = nil, scenario = nil)
      @scenario = scenario
      @template_file = template_file
    end

    def process(challenges)
      @challenges = challenges
      if File.readable? @template_file
        # @template_file ||= find_file @search_path, scenario, ""
        erb = ERB.new File.read(@template_file)
        @result = erb.result(binding) || ''
      end
    end

    def save(target_file)
      fail 'No results to write, please call process before save' if @result.nil?
      if @result.empty?
        # Warn: skip creating empty file
      else
        FileUtils.mkdir_p File.dirname(target_file)
        File.open(target_file, 'wb') do |f|
          f.write @result
        end
      end
    end

    def code2doc(source_file, language = nil)
      source_code = File.read(source_file)
      if language.nil?
        language, comment_style = Documentation::CommentStyles.infer File.extname(source_file)
        segmenter_language = comment_style[:language] || language
      else
        segmenter_language = language
      end

      buffer = StringIO.new
      segmenter_options = {
        language: segmenter_language
      }
      segmenter = Polytrix::Documentation::CodeSegmenter.new(segmenter_options)
      segments = segmenter.segment source_code
      segments.each do |comment, code|
        comment = comment.join("\n")
        code = code.join("\n")
        buffer.puts comment unless comment.empty?
        buffer.puts code_block code, language unless code.empty?
      end
      buffer.string
    end
  end
end
