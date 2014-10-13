require 'hashie'

module Polytrix
  class StateFileLoadError < StandardError; end
  class StateFile
    def initialize(polytrix_root, name)
      @file_name = File.expand_path(
        File.join(polytrix_root, '.polytrix', "#{name}.yml")
      )
    end

    def read
      if File.exist?(file_name)
        Hashie::Mash.load(file_name).dup || {}
      else
        Hashie::Mash.new
      end
    end

    def write(state)
      dir = File.dirname(file_name)
      serialized_string = serialize_hash(Util.stringified_hash(state))

      FileUtils.mkdir_p(dir)
      File.open(file_name, 'wb') { |f| f.write(serialized_string) }
    end

    def destroy
      FileUtils.rm_f(file_name) if File.exist?(file_name)
    end

    private

    attr_reader :file_name

    # @api private
    def serialize_hash(hash)
      ::YAML.dump(hash)
    end
  end
end
