require 'logging'
require 'fileutils'

POLYTRIX_LOG_DIR = '.polytrix/logs/'
FileUtils.mkdir_p POLYTRIX_LOG_DIR

Logging.color_scheme('bright',
                     levels: {
                       info: :green,
                       warn: :yellow,
                       error: :red,
                       fatal: [:white, :on_red]
                     },
                     date: :blue,
                     logger: :cyan
)

Logging.logger['polytrix::exec'].tap do | logger |
  Logging.appenders.stdout(
    'exec_stdout',
    layout: Logging.layouts.pattern(
      pattern: '[%d] %X{implementor} %X{scenario} STDOUT: %m',
      color_scheme: 'bright'
    )
  )
  logger.add_appenders('exec_stdout', Logging.appenders.file("#{POLYTRIX_LOG_DIR}/polytrix.log")
  )
  logger.level = :info
end

module Polytrix
  module ClassMethods
    def logger
      @logger ||= Polytrix.configuration.logger
    end

    def banner(msg, &block)
      logger.info "-----> #{msg}", &block
    end
  end

  class IOToLog < IO
    def initialize(logger)
      @logger = logger
      @buffer = ''
    end

    def write(string)
      (@buffer + string).lines.each do |line|
        if line.end_with? "\n"
          @buffer = ''
          @logger.info(line)
        else
          @buffer = line
        end
      end
    end
  end

  module Logger
    include ClassMethods

    def self.included(base)
      base.extend(ClassMethods)
    end

    def self.default_logger(log_level)
      Logging.logger($stdout).tap do |logger|
        logger.level = log_level
      end
    end
  end
end
