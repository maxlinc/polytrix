module Polytrix
  module StringHelpers
    module ClassMethods
      def slugify(*string)
        string.join('-').downcase.gsub(' ', '_')
      end
    end

    def self.included(base)
      base.extend(ClassMethods)
    end

    include ClassMethods
  end
end
