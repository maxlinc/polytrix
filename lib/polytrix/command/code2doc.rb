module Polytrix
  module Command
    class Code2Doc < Thor::Group
      class_option :format,
                   aliases: '-f',
                   enum: %w(markdown rst),
                   default: 'markdown',
                   desc: 'Target documentation format'

      class_option :target_dir,
                   aliases: '-d',
                   default: 'docs/',
                   desc: 'The target directory where documentation for generated documentation.'

      def code2doc
        files = args
        Logging.mdc['command'] = 'code2doc'
        if files.empty?
          # help('code2doc')
          abort 'No FILES were specified, check usage above'
        end

        files.each do |file|
          target_file_name = File.basename(file, File.extname(file)) + ".#{options[:format]}"
          target_file = File.join(options[:target_dir], target_file_name)
          say_status 'polytrix:code2doc', "Converting #{file} to #{target_file}"
          doc = Polytrix::DocumentationGenerator.new.code2doc(file, options[:lang])
          FileUtils.mkdir_p File.dirname(target_file)
          File.write(target_file, doc)
        end
      rescue Polytrix::Documentation::CommentStyles::UnknownStyleError => e
        abort "Unknown file extension: #{e.extension}, please use --lang to set the language manually"
      end
    end
  end
end
