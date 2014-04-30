module Polytrix
  class DocumentationGenerator
    include Polytrix::Core::FileFinder

    def initialize(search_path)
      @search_path = search_path
    end

    def process(feature_name)
      template_file = find_file @search_path, feature_name
      erb = ERB.new File.read(template_file)
      erb.result binding
    rescue Polytrix::Core::FileFinder::FileNotFound
      nil
    end
  end
end
