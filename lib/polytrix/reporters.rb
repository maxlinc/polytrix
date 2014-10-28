module Polytrix
  module Reporters
    autoload :MarkdownReporter, 'polytrix/reporters/markdown_reporter'
    # autoload :HTMLReporter, 'polytrix/reporters/html_reporter'
    autoload :JSONReporter, 'polytrix/reporters/json_reporter'
    autoload :YAMLReporter, 'polytrix/reporters/yaml_reporter'

    RESOURCES_DIR = File.expand_path '../../../resources/', __FILE__
    GENERATORS_DIR = File.expand_path 'templates/', RESOURCES_DIR
    ASSETS_DIR = File.expand_path 'assets/', RESOURCES_DIR

    def self.reporter(format, shell)
      case format
      when 'text'
        shell
      when 'markdown'
        MarkdownReporter.new
      when 'json'
        JSONReporter.new
      when 'yaml'
        YAMLReporter.new
      else
        fail "Unknown report format #{options[:format]}"
      end
    end
  end
end
