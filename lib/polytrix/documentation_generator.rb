module Polytrix
  class DocumentationGenerator
    include Polytrix::Core::FileFinder
    attr_reader :template_file

    def initialize(search_path)
      @search_path = search_path
    end

    def process(scenario)
      @template_file = find_file @search_path, scenario, ""
      erb = ERB.new File.read(template_file)
      erb.result binding
    rescue Polytrix::Core::FileFinder::FileNotFound
      nil
    end
  end
end
