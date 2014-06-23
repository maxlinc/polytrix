require 'logger'

module Polytrix
  module ClassMethods
    def logger
      @logger ||= Polytrix.configuration.logger
    end
  end

  module Logger
    include ClassMethods

    def self.included(base)
      base.extend(ClassMethods)
    end
  end
end
