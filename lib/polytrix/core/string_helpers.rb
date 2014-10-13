autoload :StringScanner, 'strscan'

module Polytrix
  module StringHelpers
    module ClassMethods
      def slugify(*labels)
        labels.map do |label|
          label.downcase.gsub(/[\.\s-]/, '_')
        end.join('-')
      end

      def ansi2html(text)
        HTML.from_ansi(text)
      end

      def escape_html(text)
        HTML.escape_html(text)
      end
      alias_method :h, :escape_html

      def highlight(source, opts = {})
        opts[:language] ||= 'ruby'
        opts[:formatter] ||= 'terminal256'
        Highlight.new(opts).highlight(source)
      end
    end

    def self.included(base)
      base.extend(ClassMethods)
    end

    include ClassMethods
  end

  class Highlight
    def initialize(opts)
      @lexer = Rouge::Lexer.find(opts[:language]) || Rouge::Lexer.guess_by_filename(opts[:filename])
      @formatter = opts[:formatter]
    end

    def highlight(source)
      Rouge.highlight(source, @lexer, @formatter)
    end
  end

  class HTML
    ANSICODES = {
      '1' => 'bold',
      '4' => 'underline',
      '30' => 'black',
      '31' => 'red',
      '32' => 'green',
      '33' => 'yellow',
      '34' => 'blue',
      '35' => 'magenta',
      '36' => 'cyan',
      '37' => 'white',
      '40' => 'bg-black',
      '41' => 'bg-red',
      '42' => 'bg-green',
      '43' => 'bg-yellow',
      '44' => 'bg-blue',
      '45' => 'bg-magenta',
      '46' => 'bg-cyan',
      '47' => 'bg-white'
    }

    def self.from_ansi(text)
      ansi = StringScanner.new(text)
      html = StringIO.new
      until ansi.eos?
        if ansi.scan(/\e\[0?m/)
          html.print(%(</span>))
        elsif ansi.scan(/\e\[0?(\d+)m/)
          # use class instead of style?
          style = ANSICODES[ansi[1]] || 'text-reset'
          html.print(%(<span class="#{style}">))
        else
          html.print(ansi.scan(/./m))
        end
      end
      html.string
    end

    # From Rack

    ESCAPE_HTML = {
      '&' => '&amp;',
      '<' => '&lt;',
      '>' => '&gt;',
      "'" => '&#x27;',
      '"' => '&quot;',
      '/' => '&#x2F;'
    }
    ESCAPE_HTML_PATTERN = Regexp.union(*ESCAPE_HTML.keys)

    # Escape ampersands, brackets and quotes to their HTML/XML entities.
    def self.escape_html(string)
      string.to_s.gsub(ESCAPE_HTML_PATTERN) { |c| ESCAPE_HTML[c] }
    end
  end
end
