require 'yaml'
require 'hashie/dash'
require 'hashie/mash'
require 'hashie/extensions/coercion'
require 'hashie/extensions/deep_merge'

module Polytrix
  class Manifest < Hashie::Dash
    include Hashie::Extensions::DeepMerge

    class Environment < Hashie::Mash
      # Hashie Coercion - automatically treat all values as string
      def self.coerce(obj)
        data = obj.inject({}) do |h, (key, value)|
          h[key] = value.to_s
          h
        end
        new data
      end
    end

    class Suite < Hashie::Dash
      property :env, :default => {}
      property :samples, :default => []
      property :results
    end

    class Suites < Hashie::Mash
      # Hashie Coercion - automatically treat all values as string
      def self.coerce(obj)
        data = obj.inject({}) do |h, (key, value)|
          h[key] = Polytrix::Manifest::Suite.new(value)
          h
        end
        new data
      end
    end

    include Hashie::Extensions::Coercion
    property :global_env
    coerce_key :global_env, Polytrix::Manifest::Environment
    property :suites
    coerce_key :suites, Polytrix::Manifest::Suites

    def self.from_yaml(yaml_file)
      raw_content = File.read(yaml_file)
      processed_content = ERB.new(raw_content).result
      data = YAML::load processed_content
      new data
    end
  end
end