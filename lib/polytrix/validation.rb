require 'hashie/dash'

module Polytrix
  class Validation < Polytrix::ManifestSection
    # TODO: Should we have (expectation) 'failed' vs (unexpected) 'error'?
    ALLOWABLE_STATES = %w(passed pending failed skipped)

    property :result, required: true
    property :error
    property :error_source

    def result=(state)
      state = state.to_s
      fail invalidate_state_error unless ALLOWABLE_STATES.include? state
      super
    end

    def error=(e)
      self[:error_source] = source_from_error(e)
      self[:error] = e.message
    end

    ALLOWABLE_STATES.each do |state|
      define_method "#{state}?" do
        result == state?
      end
    end

    protected

    def invalidate_state_error(state)
      ArgumentError.new "Invalid result state: #{state}, should be one of #{ALLOWABLE_STATES.inspect}"
    end

    def source_from_error(e)
      error_location = e.backtrace_locations.delete_if { |l| l.absolute_path =~ /gems\/rspec-/ }.first
      error_source = File.read(error_location.absolute_path)
      error_lineno = error_location.lineno - 1 # lineno counts from 1
      get_dedented_block(error_source, error_lineno)
    end

    def get_dedented_block(source_text, target_lineno)
      block = []
      lines = source_text.lines
      target_indent = lines[target_lineno][/\A */].size
      lines[0...target_lineno].reverse.each do |line|
        indent = line[/\A */].size
        block.prepend line
        break if indent < target_indent
      end
      lines[target_lineno..lines.size].each do |line|
        indent = line[/\A */].size
        block.push line
        break if indent < target_indent
      end
      block.join
    end
  end
end
