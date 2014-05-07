require 'singleton'
require 'hashie/mash'

module Polytrix
  class ResultTracker
    include Singleton

    attr_reader :results

    def example_started(example)
      data_for(example)[example.description] = Hashie::Mash.new
    end

    def execution_result(example, result)
      data_for(example)[example.description][:execution_result] = result
    end

    private
    def data_for(example)
      @results ||= Hashie::Mash.new
      group_names = example.example_group.parent_groups.map{|g| g.description}
      group_names.inject(@results, :initializing_reader)
    end
  end
end