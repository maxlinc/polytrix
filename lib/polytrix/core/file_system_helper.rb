module Polytrix
  module Core
    module FileSystemHelper
      include Polytrix::Logger
      include Polytrix::StringHelpers
      class FileNotFound < StandardError; end

      # Finds a file by loosely matching the file name to a scenario name
      def find_file(search_path, scenario_name, ignored_patterns = read_gitignore(search_path))
        glob_string = "#{search_path}/**/*#{slugify(scenario_name)}.*"
        potential_files = Dir.glob(glob_string, File::FNM_CASEFOLD)
        potential_files.concat Dir.glob(glob_string.gsub('_', '-'), File::FNM_CASEFOLD)
        potential_files.concat Dir.glob(glob_string.gsub('_', ''), File::FNM_CASEFOLD)

        # Find the first file, not including generated files
        file = potential_files.find do |f|
          !ignored? ignored_patterns, search_path, f
        end

        fail FileNotFound, "No file was found for #{scenario_name} within #{search_path}" if file.nil?
        Pathname.new file
      end

      def recursive_parent_search(path, file_name = nil, &block)
        if block_given?
          obj = yield path
          return obj if obj
        elsif file_name
          file = File.expand_path(file_name, path)
          logger.debug "Checking for #{file}"
          found = File.exists? file
        else
          fail ArgumentError, 'Provide either a file_name to search for, or a block to check directories'
        end

        parent_dir = File.dirname(path)
        return path if found
        return nil if parent_dir == path # we've reached the top
        recursive_parent_search(parent_dir, file_name, &block)
      end

      private

      def read_gitignore(dir)
        gitignore_file = "#{dir}/.gitignore"
        File.read(gitignore_file)
      rescue
        ''
      end

      def ignored?(ignored_patterns, base_path, target_file)
        # Trying to match the git ignore rules but there's some discrepencies.
        ignored_patterns.split.find do |pattern|
          # if git ignores a folder, we should ignore all files it contains
          pattern = "#{pattern}**" if pattern[-1] == '/'
          started_with_slash = pattern.start_with? '/'

          pattern.gsub!(/\A\//, '') # remove leading slashes since we're searching from root
          file = relativize(target_file, base_path)
          ignored = file.fnmatch? pattern
          ignored || (file.fnmatch? "**/#{pattern}" unless started_with_slash)
        end
      end

      def relativize(file, base_path)
        absolute_file = File.absolute_path(file)
        absolute_base_path = File.absolute_path(base_path)
        Pathname.new(absolute_file).relative_path_from Pathname.new(absolute_base_path)
      end
    end
  end
end
