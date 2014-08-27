module Polytrix
  module Command
    class RunDoc < Thor::Group
      class_option :format,
                   aliases: '-f',
                   enum: %w(markdown rst),
                   default: 'markdown',
                   desc: 'The documentation input format'

      def rundoc
        files = args
        # Logging.mdc['command'] = 'rundoc'
        if files.empty?
          # help('code2doc')
          abort 'No FILES were specified, check usage above'
        end

        files.each do |file|
          target_file_name = File.basename(file, File.extname(file)) + ".#{options[:format]}"
          target_file = File.join(options[:target_dir], target_file_name)
          say_status 'polytrix:code2doc', "Converting #{file} to #{target_file}"
          Polytrix::DocumentationExecutor.new.execute file
        end
      end
    end
  end
end
