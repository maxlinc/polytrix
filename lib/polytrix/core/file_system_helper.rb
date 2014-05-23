module Polytrix
  module Core
    module FileSystemHelper
      class FileNotFound < StandardError; end

      # Finds a file by loosely matching the file name to a scenario name
      def find_file(search_path, scenario_name, ignored_patterns = read_gitignore(search_path))
        potential_files = Dir.glob("#{search_path}/**/*#{scenario_name.gsub(' ', '_')}.*", File::FNM_CASEFOLD)
        potential_files.concat Dir.glob("#{search_path}/**/*#{scenario_name.gsub(' ', '')}.*", File::FNM_CASEFOLD)

        # Find the first file, not including generated files
        file = potential_files.find { |file|
          !ignored? ignored_patterns, search_path, file
        }

        fail FileNotFound, "No file was found for #{scenario_name} within #{search_path}" if file.nil?
        Pathname.new file
      end

      def slugify(path)
        path.downcase.gsub(' ','_')
      end

      private

      def read_gitignore(dir)
        gitignore_file = "#{dir}/.gitignore"
        File.read(gitignore_file)
      rescue
        ""
      end

      def ignored?(ignored_patterns, base_path, target_file)
        ignored_patterns.split.find do |pattern|
          # if git ignores a folder, we should ignore all files it contains
          pattern = "#{pattern}**" if pattern[-1] == '/'
          relativize(target_file, base_path).fnmatch? pattern
        end
      end

      def relativize(file, base_path)
        Pathname.new(file).relative_path_from Pathname.new(base_path)
      end
    end
  end
end
