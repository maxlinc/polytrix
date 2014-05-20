module Polytrix
  class DocumentationGenerator
    include Polytrix::Core::FileFinder
    attr_reader :template_file
    attr_reader :scenario

    def initialize(search_path, scenario, default_template = nil)
      @search_path = search_path
      @scenario = scenario
      @template_file = template_file
      begin
        @template_file ||= find_file @search_path, scenario, ""
      rescue Polytrix::Core::FileFinder::FileNotFound
        @template_file = default_template
      end
    end

    def process(challenges)
      if @template_file
        @template_file ||= find_file @search_path, scenario, ""
        erb = ERB.new File.read(template_file)
        erb.result binding
      end
    end
  end
end
