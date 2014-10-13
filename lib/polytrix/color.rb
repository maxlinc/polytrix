module Polytrix
  module Color
    ANSI = {
      reset: 0, black: 30, red: 31, green: 32, yellow: 33,
      blue: 34, magenta: 35, cyan: 36, white: 37,
      bright_black: 90, bright_red: 91, bright_green: 92,
      bright_yellow: 93, bright_blue: 94, bright_magenta: 95,
      bright_cyan: 96, bright_white: 97
    }.freeze

    COLORS = %w(
      cyan yellow green magenta blue bright_cyan bright_yellow
      bright_green bright_magenta bright_blue
    ).freeze

    # Returns an ansi escaped string representing a color control sequence.
    #
    # @param name [Symbol] a valid color representation, taken from
    #   Polytrix::Color::ANSI
    # @return [String] an ansi escaped string if the color is valid and an
    #   empty string otherwise
    def self.escape(name)
      return '' if name.nil?
      return '' unless ANSI[name]
      "\e[#{ANSI[name]}m"
    end

    # Returns a colorized ansi escaped string with the given color.
    #
    # @param str [String] a string to colorize
    # @param name [Symbol] a valid color representation, taken from
    #   Polytrix::Color::ANSI
    # @return [String] an ansi escaped string if the color is valid and an
    #   unescaped string otherwise
    def self.colorize(str, name)
      color = escape(name)
      color.empty? ? str : "#{color}#{str}#{escape(:reset)}"
    end
  end
end
