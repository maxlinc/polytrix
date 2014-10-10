require 'hashie/mash'

# Fabricates test manifests (.polytrix_tests.yml files)

Fabricator(:challenge, from: Polytrix::Challenge) do
  initialize_with { @_klass.new to_hash } # Hash based initialization
  name { SAMPLE_NAMES.sample }
  suite { LANGUAGES.sample }
  source_file { 'spec/fixtures/factorial.py' }
  basedir { 'spec/fixtures' }
  implementor
end
