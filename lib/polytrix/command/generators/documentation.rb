require 'json'
require 'polytrix/reporters'

module Polytrix
  module Command
    class Generate
      class Documentation < Thor::Group
        include Thor::Actions
        include Polytrix::Util::FileSystem
        include Polytrix::Util::FileSystem
        include Polytrix::Documentation::Helpers::CodeHelper
        class_option :template, default: 'summary', desc: 'The generator template name or directory'
        class_option :destination, default: 'docs/', desc: 'Destination for generated documentation'

        BUILTIN_GENERATORS = Dir["#{Polytrix::Reporters::GENERATORS_DIR}/*"].select { |f| File.directory? f }

        def self.add_generator_to_source_root
          File.expand_path('tests/polytrix/generators', Dir.pwd)
        end

        def self.generators
          BUILTIN_GENERATORS + Dir['tests/polytrix/generators/*'].select { |f| File.directory? f }
        end

        def self.generator_names
          generators.map { |d| File.basename d }
        end

        def add_generators_to_source_root
          generator_dir = self.class.generator_dirs.find { |d| File.basename(d) == options[:template] }
          abort generators_not_found if generators_dir.nil?

          source_paths << generator_dir
        end

        def set_destination_root
          self.destination_root = options[:destination]
        end

        def setup
          Polytrix.setup(options)
        end

        def apply_template
          generator_script = "#{options[:template]}_template.rb"
          apply(generator_script)
        end

        def copy_base_structure
          directory 'files', '.'
        rescue Thor::Error => e
          # It's okay if it the template doesn't have static files, it can be
          # template files only.
          raise e unless e.message.match(/Could not find "files"/)
        end

        protected

        def generators_not_found
          s = "ERROR: No generator named #{options[:template].inspect}, available generators: "
          s << self.class.generator_names.join(', ')
        end
      end
    end
  end
end
