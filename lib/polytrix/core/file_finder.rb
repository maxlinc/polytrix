module Polytrix
  module Core
    module FileFinder
      class FileNotFound < StandardError; end

      # Incomplete list
      SOURCE_FILE_EXTENSIONS = %(.java .rb .js .go .php .cs)
      DOC_FILE_EXTENSIONS = %(.md .asciidoc .rdoc .erb)

      # Finds a file by loosely matching the file name to a scenario name
      def find_file(search_path, scenario_name)
        potential_files = Dir.glob("#{search_path}/**/*#{scenario_name}.*", File::FNM_CASEFOLD)
        potential_files.concat Dir.glob("#{search_path}/**/*#{scenario_name.gsub('_', '')}.*", File::FNM_CASEFOLD)

        # Find the first file, not including generated files
        file = potential_files.find { |file|
          is_source?(file) || is_doc?(file)
        }

        fail FileNotFound, "No file was found for #{scenario_name} within #{search_path}" if file.nil?
        Pathname.new file
      end

      private

      def is_source?(file)
        SOURCE_FILE_EXTENSIONS.include? File.extname file
      end

      def is_doc?(file)
        DOC_FILE_EXTENSIONS.include? File.extname(file)
      end
    end
  end
end
