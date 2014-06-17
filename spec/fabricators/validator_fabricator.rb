require 'hashie/mash'

Fabricator(:validator, from: Polytrix::Validator) do
  initialize_with do
    callback = @_transient_attributes.delete :callback
    scope = @_transient_attributes
    @_klass.new(scope, &callback)
  end # Hash based initialization
  transient suite: LANGUAGES.sample
  transient sample: SAMPLE_NAMES.sample
  transient callback: Proc.new { Proc.new { |challenge| } } # rubocop:disable Proc
end
