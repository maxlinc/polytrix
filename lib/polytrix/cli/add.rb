module Polytrix
  module CLI
    class Add < Polytrix::CLI::Base
      include Thor::Actions
      desc 'sample IMPLEMENTOR SCENARIO', 'Add a code sample for an implementor'
      # sdk_options
      method_option :language, type: 'string', desc: 'Programming language to use (if not already configured by the implementor)', default: 'rb'
      def sample(implementor, scenario)
        # implementor = pick_implementor(options[:sdk])
        implementor = pick_implementor implementor
        language = implementor.language || options[:language]
        generate_source implementor, scenario, language
      end

      protected

      source_root Polytrix.configuration.template_dir
      # source_root implementor.basedir

      def generate_source(implementor, scenario, language)
        source_paths.prepend File.expand_path(implementor.basedir)
        @implementor = implementor
        @scenario = implementor.build_challenge({
          name: scenario
        })
        @language = language

        output_file = File.join(implementor.basedir, "#{scenario.gsub(' ', '_')}.#{language}")
        template('code_sample.tt', output_file)
      end

      def commented(comment)
        return if comment.nil?

        buffer = StringIO.new
        _lang, comment_style = Polytrix::Documentation::CommentStyles.infer @language
        if use_multiline? comment, comment_style
          buffer.puts comment_style[:multi][:start]
          comment.lines.each do |line|
            buffer.puts comment_line(line, comment_style[:multi][:middle])
          end
          buffer.puts comment_style[:multi][:end]
        else
          comment.lines.each do |line|
            buffer.puts comment_line(line, comment_style[:single])
          end
        end
        buffer.string
      end

      def comment_line(line, comment_string)
        comment_string ||= ""
        if line.strip.empty?
          whitespace, line = line.gsub("\n", ''), ""
        else
          whitespace, line = line.rstrip.match(/([\s]*)(.*)/).captures
        end

        "#{whitespace}#{comment_string} #{line}"
      end

      def use_multiline?(comment, comment_style)
        return comment.lines.size > 1 && !comment_style[:multi].nil? && (comment_style[:multi][:idiomatic] != false)
      end
    end
  end
end
