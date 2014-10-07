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
        ANSI2HTML.ansi2html(text)
      end
    end

    def self.included(base)
      base.extend(ClassMethods)
    end

    include ClassMethods
  end

  class ANSI2HTML
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

    def self.ansi2html(text)
      ansi = StringScanner.new(text)
      html = StringIO.new
      until ansi.eos?
        if ansi.scan(/\e\[0?m/)
          html.print(%{</span>})
        elsif ansi.scan(/\e\[0?(\d+)m/)
          # use class instead of style?
          style = ANSICODES[ansi[1]] || 'text-reset'
          html.print(%{<span class="#{style}">})
        else
          html.print(ansi.scan(/./m))
        end
      end
      html.string
    end
  end
end
