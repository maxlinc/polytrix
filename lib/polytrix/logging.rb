module Polytrix
  module DefaultLogger
    module ClassMethods
      def logger
        @logger ||= Polytrix.configuration.default_logger
      end
    end

    def self.included(base)
      base.extend(ClassMethods)
    end

    include ClassMethods
  end

  module Logging
    class << self
      private

      def logger_method(meth)
        define_method(meth) do |*args|
          logger.public_send(meth, *args)
        end
      end
    end

    logger_method :banner
    logger_method :debug
    logger_method :info
    logger_method :warn
    logger_method :error
    logger_method :fatal
  end
end
