require 'hashie/dash'
require 'hashie/extensions/coercion'

module Polytrix
  class Implementor < Hashie::Dash
    include Hashie::Extensions::Coercion
    include Polytrix::Executor
    property :name
    property :basedir
    property :language
    coerce_key :basedir, Pathname

    def initialize(data)
      data[:basedir] ||= "sdks/#{data[:name]}"
      super(data)
    end

    def bootstrap
      execute('./scripts/bootstrap', :cwd => basedir)
    rescue Errno::ENOENT
      puts "Skipping bootstrapping for #{name}, no script/bootstrap exists"
    end
  end
end