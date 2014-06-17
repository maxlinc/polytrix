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

    def initialize(template_file, scenario)
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
  end
end
